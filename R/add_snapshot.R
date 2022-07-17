#' Add a snapshot
#'
#' @description Given a data frame, update the tmtable by adding new rows
#' and documenting removed rows. Changed rows show up as removed rows (existing data)
#' and added rows (new data).
#'
#' @details
#' The algorithm involves comparing the \code{v} and
#' \code{newtbl} for differences and annotating them accordingly.
#'
#' The convention is to leave ValidTo as NA when the entry is valid as of the last update. That
#' is, at any time in the future unless more information is provided we assume it is valid.
#'
#' There are several considerations:
#'
#' \itemize{
#'   \item Rows in common have an updated ValidTo. If the ValidTo is NA, it is kept as such. If the
#'    ValidTo has a time less than as_of, it is updated to as_of.
#'   \item Rows not in the new table have a ValidTo set to as_of.
#'   \item Rows in the new table, but not in the old table, have a ValidFrom
#'   set to as_of. The ValidTo is set to NA.
#' }
#'
#' @param v A vibble
#' @param snapshot A new table with the same structure as vibble (without version data).
#' @param as_of A date to update information as of (YYYY-MM-DD format).
#'
#' @return An updated vibble with newtbl merged in.
#'
#' @importFrom rlang .data
#'
#' @export
#' @examples
#' \dontrun{
#' vibble::add_snapshot(vibble::vibble(iris, as_of="2022-01-01"), iris[1:10,], as_of
#' }
add_snapshot <- function(v, snapshot, as_of = lubridate::now()) {

  # The snapshot should not have a ValidFrom/ValidTo or be a vibble already.
  stopifdups(snapshot)
  stopifnot(!class(snapshot) %in% "vibble")
  stopifnot(!any(colnames(snapshot) %in% c("ValidFrom","ValidTo")))

  # Choose function based on if v and snapshot have the same structure
  if ( is_tibble_structure_equal(dplyr::select(v, -"ValidFrom", -"ValidTo"), snapshot) ) {
    ut <- add_snapshot_with_same_structure(v, snapshot, as_of)
  } else {
    ut <- add_snapshot_with_different_structure(v, snapshot, as_of)
  }


  ut

}

#' Add snapshot with same structure to vibble
#'
#' @param v
#' @param snapshot
#' @param as_of
#'
#' @return
#' @export
#'
#' @importFrom rlang .data
#' @examples
add_snapshot_with_same_structure <- function(v, snapshot, as_of) {

  # Fields to join on include everything but ValidTo and ValidFrom
  common_fields <- intersect(colnames(v), colnames(snapshot))


  # Rows in common
  common_rows <- dplyr::inner_join(v, snapshot, by=common_fields) |>
    # Updated ValidTo: note we have to manually set the class back to Date since ifelse can't
    # always guess types. Note that NA's are kept as NA meaning they are valid.
    dplyr::mutate(
      ValidTo = ifelse(.data$ValidTo < as_of, as_of, .data$ValidTo),
      ValidTo = type_converter(as_of)(.data$ValidTo)
    )

  # New rows are those rows in newer table not in the original table.
  new_rows <- dplyr::anti_join(snapshot, v, by = common_fields) |>
    dplyr::mutate(
      ValidFrom = as_of,
      ValidTo = type_converter(as_of)(NA)
    )
  # Removed rows are in the original table but not in the newer table.
  removed_rows <- dplyr::anti_join(v, snapshot, by = common_fields) |>
    dplyr::mutate(
      ValidTo = as_of
    )

  # Combine different conditions together into new table
  .x <- dplyr::bind_rows(
    common_rows,
    new_rows,
    removed_rows
  )

  .x
}



#' Add snapshot with different structure to vibble
#'
#' @details This function assumes that the vibble and the snapshot have different structures. As such,
#' there is no way to reuse data from prior time points; everything is invalidated for `as_of` point.
#'
#' The function does have to conform the structure, which conveniently [dplyr::bind_rows()] does without
#' a problem.
#'
#' @param v
#' @param snapshot
#' @param as_of
#'
#' @return
#' @export
#'
#' @importFrom rlang .data
#' @examples
add_snapshot_with_different_structure <- function(v, snapshot, as_of) {

  # First, all of v is not valid past as_of
  # NB: If we want an "insert between" then this should actually check for na or <
  v <- dplyr::mutate(v, ValidTo = ifelse(is.na(.data$ValidTo), as_of, .data$ValidTo))

  # The snapshot is ValidFrom the as_of point
  snapshot <- dplyr::mutate(snapshot, ValidFrom = as_of)

  # Now we can combine the two sets. Note that bind_rows takes care of two important things:
  # matching column names between the two (if they are out of order) and filling in missing
  # columns with NA's. This is exactly the behavior we need, since the result needs to be
  # a union of all columns, with NA's filled in as needed.
  .x <- dplyr::bind_rows(v, snapshot)

  .x

}

