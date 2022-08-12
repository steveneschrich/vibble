#' Extract a data frame from a vibble as of a certain version
#'
#' @description Given a table with information over time,
#' retrieve data as of a specific time point.
#'
#' @details The design pattern is documented in many places. For one description, see
#' https://docs.microsoft.com/en-us/sql/relational-databases/tables/temporal-tables?view=sql-server-2017
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
as_of <- function(v, as_of=NULL, exact = TRUE) {
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
  } else if ( !exact ) {
    target <- vers[max(which(vers < as_of))]
  }

  # We extract data to individual rows and then filter on rows with the same version id
  # as target.
  x <- dplyr::mutate(
    v,
    has_target = purrr::map_lgl(.data$vlist, ~any(.x %in% target)),
    vlist = purrr::map(.data$vlist, ~.x[which(.x %in% target)])
  ) |>
    dplyr::filter(.data$has_target) |>
    tidyr::unchop(.data$vlist) |>
    dplyr::select(-.data$vlist, -.data$has_target)


  # One of the aspects of the vibble is the idea that the structure can change over time. That
  # is, columns can be added or removed. Since we store the full contents in a table, this means
  # that at any given time point the set of valid columns can be different. For the time being,
  # we simply assume that any completely empty (NA) column when subsetting is one of these columns.
  # Hence, these are removed.
  #
  x <- janitor::remove_empty(x, which = c("cols"))

  # Since the unnest results in a tibble, not vibble, there is no class change required. So
  # we are done.

  x
}
