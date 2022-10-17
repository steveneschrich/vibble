#' Extract a data frame from a vibble as of a certain version
#'
#' @description Given a table with information over time,
#' retrieve data as of a specific time point. Note the time point (version)
#' need not exist in the data.
#'
#' @details The design pattern is documented in many places. For one description, see
#' https://docs.microsoft.com/en-us/sql/relational-databases/tables/temporal-tables?view=sql-server-2017
#'
#' The idea behind the vibble is to store versions of the same data as it evolves
#' over time or over versions. The purpose of this function is to retrieve a
#' version of the data as it looked at the given version (`as_of`).
#'
#' This implies
#' (correctly) that the `as_of` need not be explicitly in the data but rather a
#' version that would have existed is returned (that is, the version just earlier
#' than the requested `as_of`). The parameter `exact` can control this behavior. To
#' make things clearer, the function [at()] can be used for exact matches. That is,
#' when `exact` is `TRUE` then the result of requesting a version not present is an
#' empty data frame.
#'
#' @param v A vibble
#' @param as_of A date to construct the snapshot from (assumed YYYY-MM-DD).
#' @param exact Is `as_of` the exact version to use, or should we find the closest previous
#' version to `as_of`. When using a date, this will find the date version in the vibble that
#' is one version older.
#' @return A data frame with contents representing a snapshot as of a specific time.
#'
#' @importFrom rlang .data
#'
#' @export
#' @examples
#' \dontrun{
#' vibble::as_of(vibble::vibble(iris, as_of="20220101"),"20220101")
#' }
as_of <- function(v, as_of=NULL, exact = FALSE) {
  stopifnot(is_vibble(v))

  if (nrow(v) == 0)
    return(tibble::tibble())

  # Select the target version to extract:
  #
  #   as_of means either NULL (currently valid) or a specific time point.
  #    - If as_of is NULL, use the most recent timepoint
  #    - If as_of is a valid version, use it
  #    - If as_of is not a valid version, use the version just prior to it
  vers <- versions(v)
  stopifnot(is.null(as_of) || class(as_of)==class(vers))

  target <- NA
  if (is.null(as_of)) {
    target <- vers[length(vers)]
  } else if ( as_of %in% vers) {
    target <- as_of
  } else if ( !exact && as_of > min(vers) ) {
    target <- vers[max(which(vers < as_of))]
  } else if ( !exact) {
    warning(sprintf("Prehistoric Date detected: requested version (%s) earlier than first version (%s).",
                    as_of, min(vers)))
  }

  # We extract data to individual rows and then filter on rows with the same version id
  # as target.
  x <- dplyr::mutate(
    v,
    vlist = purrr::map(.data$vlist, ~.x[which(.x %in% target)])
  ) |>
    tidyr::unchop(cols="vlist") |>
    dplyr::filter(!is.na(.data$vlist)) |>
    dplyr::select(-.data$vlist)


  # One of the aspects of the vibble is the idea that the structure can change over time. That
  # is, columns can be added or removed. Since we store the full contents in a table, this means
  # that at any given time point the set of valid columns can be different. For the time being,
  # we simply assume that any completely empty (NA) column when subsetting is one of these columns.
  # Hence, these are removed.
  #
  x <- dplyr::select_if(x, ~!all(is.na(.)))

  # Since the unnest results in a tibble, not vibble, there is no class change required. So
  # we are done.

  x
}

#' @describeIn as_of Exact match to a version/date rather than inexact.
#' @param ... Parameters to pass to [as_of()]
#' @export
at <- function(v, ...) {
  as_of(v, exact = TRUE, ...)
}
