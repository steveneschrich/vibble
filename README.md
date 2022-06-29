# vibble
A versioned tibble. This package provides a mechanism for a tibble that could change over time. Hence the name vibble.

Some applications need to have a table of data that can potentially change (rows or columns) over time. We can version the individual tables and stored them as files, list of tables, or other schemes. The goal of this package is to create an object (vibble) that is not far-removed from a tibble. Then, one can add snapshots at particular time points (or version point) and retrieve these snapshots at need. There is overhead for storing this additional information but the benefits of simpler user experience are thought to outweigh the costs in this package.

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
vibble(tibble, as_of)
```
Create a new vibble, either with or without date, as of the specific version.

```
add_snapshot(vibble, tibble, as_of)
```
Add a snapshot as of a specific version. This is phrased rather specifically on purpose. You cannot "insert" data at a snapshot, only provide a full snapshot of the tibble at a specific point. Incremental insertions are not allowd. Behind the scenes, this makes the work easier:

- Remove rows not in the tibble (set the ValidTo field)
- Add rows in the tibble not in the vibble
- Do nothing for rows in both the tibble and vibble

```
as_of(vibble, as_of)
```
This returns a tibble as of a specific version point. Given the implementation description, this probably seems straightforward and it mostly is. The only caveat is tibble structure over time (see below).

## Example
Consider the following motivation example. I want to build up a tibble of files within this package over time. This would allow me to see the file list at any point in the past. I may add some files, delete some files and modify some files. How does this work with respect to a vibble?

Lets assume I get a list of files as such:
```
file_list <- fs::dir_info(".",recurse=TRUE)
```

I can create a vibble by doing the following:
```
v <- vibble::vibble(file_list, as_of = lubridate::now())
```

Great, now I initialized a vibble with a snapshot as of right now (a time/date). Suppose I then start working on the code and make a lot of changes. So I want to create a new snapshot:
```
v <- vibble::add_snapshot(v, fs::dir_info(".", recurse=TRUE), as_of = lubridate::now())
```

What if I forgot to make a snapshot when I first started and there was just a DESCRIPTION file? Assuming it has not changed since then, let's add that snapshot in:
```
v<-vibble::add_snapshot(v, fs::dir_info(".", glob = "DESCRIPTION"), as_of=lubridate::as_datetime("2022-03-01 01:00:00"))
```

Great, let's take a look at what we can do now that we have three different time points.

TBD

## Tibble structure over time
The vibble idea works well for data that changes over time. But it also works for tibble structures that change over time. Let's suppose you have a tibble `v` and you add a new column to `v`. You can store this in your vibble.

Right now, the implementation is to drop all columns with NA's when extracting a tibble in `as_of()`. That means we can store the table with all possible columns (union of all time points) and just drop columns that aren't used at a specific time. 

We may move to a more sophisticated structure since it's possible you might store a column of NA's. But not yet.
