# tmtable
A time machine table. This package provides a mechanism for a table (data.frame) that could change over time. Hence the name tmtable.

Some applications need to have a table of data that can potentially change (rows or columns) over time. We can version the individual tables and stored them as files, list of tables, or other schemes. The goal of this package is to create an object (tmtable) that is not far-removed from a data frame. Then, one can add snapshots at particular time points (or version point) and retrieve these snapshots at need. There is overhead for storing this additional information but the benefits of simpler user experience are thought to outweigh the costs in this package.

## Background

In databases, Microsoft introduced a TemporalTable approach to SQL Server but the approach is used generically in many different circumstances. Two additional fields are added to a row: 
- ValidFrom
- ValidTo

Then data is inserted at a specific time point, setting the ValidFrom field. Unless explicitly removed the ValidTo remains empty (NA in our case). Then retrieving data at a particular point is simply the following pseudocode:

```
filter rows with ValidFrom < target and (ValidTo > target or ValidTo is NA)
drop the ValidTo/ValidFrom fields
return the result
```

We implemented this functionality in a small package to allow for those types of semantics easily without having to manage the additional details.

## General Concepts
### Time
Initially I thought that this package would just handle dates for the ValidTo/ValidFrom fields. This is how I've seen these solutions discussed. But it occurred to me that anything appropriately ordered could be used as versions over time. For instance, consider the following:

- v1
- v1.2
- v2
- v2.3.4

This is a perfectly good concept of "time", just as dates would be. The key is that any vibble needs a consistent ordering. 

### as_of
Within the package, I try to consistently use the term `as_of` to refer to version points. It can be thought of as a specific date (or datetime) but also a specific version. One of the nice things in R is that if it is ordered, then even if the version is not present in the vibble we can still extract data as of a specific version.


## Operations
There are relatively few operations in this package. These are outlined below to get a sense of the package functionality.

```
tmtable(df, as_of)
```
Create a new tmtable, either with or without date, as of the specific version.

```
add_snapshot(tmtable, df, as_of)
```
Add a snapshot as of a specific version. This is phrased rather specifically on purpose. You cannot "insert" data at a snapshot, only provide a full snapshot of the data frame at a specific point. Incremental insertions are not allowd. Behind the scenes, this makes the work easier:

- Remove rows not in the tibble (set the ValidTo field)
- Add rows in the tibble not in the tmtable
- Do nothing for rows in both the tibble and tmtable

```
as_of(tmtable, as_of)
```
This returns a tibble as of a specific version point. Given the implementation description, this probably seems straightforward and it mostly is. The only caveat is tibble structure over time (see below).

## Example
Consider the following motivation example. I want to build up a tibble of files within this package over time. This would allow me to see the file list at any point in the past. I may add some files, delete some files and modify some files. How does this work with respect to a tmtable?

Lets assume I get a list of files as such:
```
file_list <- fs::dir_info(".",recurse=TRUE)
```

I can create a tmtable by doing the following:
```
v <- tmtable::tmtable(file_list, as_of = lubridate::now())
```

Great, now I initialized a tmtable with a snapshot as of right now (a time/date). Suppose I then start working on the code and make a lot of changes. So I want to create a new snapshot:
```
v <- tmtable::add_snapshot(v, fs::dir_info(".", recurse=TRUE), as_of = lubridate::now())
```

What if I forgot to make a snapshot when I first started and there was just a DESCRIPTION file? Assuming it has not changed since then, let's add that snapshot in:
```
v<-tmtable::add_snapshot(v, fs::dir_info(".", glob = "DESCRIPTION"), as_of=lubridate::as_datetime("2022-03-01 01:00:00"))
```

Great, let's take a look at what we can do now that we have three different time points.

TBD

## Tibble structure over time
The tmtable idea works well for data that changes over time. But it also works for tibble structures that change over time. Let's suppose you have a tibble `v` and you add a new column to `v`. You can store this in your tmtable.

Right now, the implementation is to drop all columns with NA's when extracting a tibble in `as_of()`. That means we can store the table with all possible columns (union of all time points) and just drop columns that aren't used at a specific time. 

We may move to a more sophisticated structure since it's possible you might store a column of NA's. But not yet.

# TODO
There remains things to do with the library.

- The structure of the data has to remain the same for now. This will be easier managed via a mongo backend for now, since JSON will remove empty columns during serialization. Maybe we should just do that here (serialize to JSON
then deserialize).
- Acutally given the above, not clear how to solve this problem. As the number of columns will grow over time (assuming we just keep empty columns that have been removed), there is no obvious way to combine data from across different structures. I suppose it's still true that JSON will give you a superset of all possible columns. But you'd need to somehow deal with the similarities - maybe check for matches excluding some NA/s?
- I have an edge case I don't remember when the number of removed rows is the same as the number of rows in the data, meaning all data is removed. This doesn't seem problematic, but I clearly thought so at one point.


