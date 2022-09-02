#' Add a snapshot
#'
#' @description Given a data frame, update the vibble by adding a snapshot at the
#' current version point.
#'
#' @details
#' The algorithm involves adding a new version of all rows, then combining identical rows
#' so that versions are listed together (in a vlist).
#'
#' @param v A vibble
#' @param snapshot A new table with the same structure as vibble (without version data).
#' @param as_of A date/version
#'
#' @return An updated vibble with newtbl merged in.
#'
#' @importFrom rlang .data
#'
#' @export
#' @examples
#' \dontrun{
#' vibble::add_snapshot(vibble::vibble(iris, as_of="2022-01-01"), iris[1:10,], as_of="2022-01-02")
#' }
add_snapshot <- function(v, snapshot, as_of = lubridate::now()) {

  # Assert v is a vibble
  stopifnot(is_vibble(v))

  if ( !utils::hasName(snapshot, "vlist")) {
    # Add as_of tag to snapshot (as vlist)
    snapshot <- dplyr::mutate(snapshot, vlist = list(as_of))
  }

  # Update approach for combining. This ws determined to be significantly faster in large
  # scale settings. The logic is to combine the data (existing vibble and snapshot). Then
  # we can combine duplicate rows using tidyr::chop.
  ut <- tidyr::chop(dplyr::bind_rows(v, snapshot), cols = "vlist")

  # chop just combines the initial list (which can be long) and a one element list
  # into a wrapping list. This needs to be flattened/unboxed which is done below.
  ut <- dplyr::mutate(ut, vlist = purrr::map(.data$vlist, unlist))



  new_vibble(ut)

}

#' Add a snapshot
#'
#' @description Given a data frame, update the vibble by adding a snapshot at the
#' current version point.
#'
#' @details
#' The algorithm involves adding a new version of all rows, then combining identical rows
#' so that versions are listed together (in a vlist).
#'
#' @param v A vibble
#' @param snapshot A new table with the same structure as vibble (without version data).
#' @param as_of A date/version
#'
#' @return An updated vibble with newtbl merged in.
#'
#' @importFrom rlang .data
#'
#' @export
#' @examples
#' \dontrun{
#' vibble::add_snapshot(vibble::vibble(iris, as_of="2022-01-01"), iris[1:10,], as_of="2022-01-02")
#' }
add_snapshot.data_frame <- function(v, snapshot, as_of = lubridate::now()) {

  # Add as_of tag to snapshot (as vid)
  snapshot <- dplyr::mutate(snapshot, vlist = list(as_of))

  # Combine  original data (v) and snapshot
  v <- dplyr::bind_rows(v, snapshot)

  v
}

# NB: Add in  S3 dispatch.
