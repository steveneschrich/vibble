#' Add a snapshot
#'
#' @description Given a data frame, update the tmtable by adding new rows
#' and documenting removed rows. Changed rows show up as removed rows (existing data)
#' and added rows (new data).
#'
#' @details
#' The algorithm involves comparing the \code{tbl} and
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
#'
#' @param newtbl A new table with the same structure as TemporalTable (without temporal data).
#' @param as_of A date to update information as of (YYYY-MM-DD format).
#'
#' @return An updated tbl with newtbl merged in.
#'
#' @examples
add_snapshot <- function(newtbl, as_of = lubridate::now()) {
  tbl <- self$tbl
  #as_of <- lubridate::ymd(as_of, tz="UTC")
  #TODO: if (!is.POSIXct) convert, assuming tz="UTC" perhaps?
  assertthat::assert_that(lubridate::is.POSIXct(as_of))

  # If newtbl has ValidFrom and ValidTo, remove them.
  # NB: We may want to keep these and do something with them
  if ("ValidFrom" %in% colnames(newtbl))
    newtbl <- dplyr::select(newtbl, -ValidFrom)
  if ("ValidTo" %in% colnames(newtbl))
    newtbl <- dplyr::select(newtbl, -ValidTo)

  # Note: If the structure has changed then everything is different. We don't handle that yet.
  assertthat::assert_that(length(intersect(colnames(tbl),colnames(newtbl)))==length(colnames(tbl))-2)

  # Fields to join on include everything but ValidTo and ValidFrom
  common_fields <- colnames(tbl)[!colnames(tbl) %in% c("ValidFrom","ValidTo")]

  # Rows in common
  common_rows <- dplyr::inner_join(tbl, newtbl, by=common_fields) %>%
    # Updated ValidTo: note we have to manually set the class back to Date since ifelse can't
    # always guess types. Note that NA's are kept as NA meaning they are valid.
    dplyr::mutate(
      ValidTo = dplyr::if_else(ValidTo < as_of, as_of, ValidTo)
    )

  # New rows are those rows in newer table not in the original table.
  new_rows <- dplyr::anti_join(newtbl, tbl, by = common_fields) %>%
    dplyr::mutate(
      ValidFrom = as_of,
      ValidTo = lubridate::NA_POSIXct_
    )
  # Removed rows are in the original table but not in the newer table.
  removed_rows <- dplyr::anti_join(tbl, newtbl, by = common_fields) %>%
    dplyr::mutate(
      ValidTo = as_of
    )
  if (nrow(removed_rows) == nrow(tbl)) {
    message("Assuming new table does not include old information, so not marking old data as removed.")
    removed_rows<-NULL
  }

  # Combine different conditions together into new table
  self$tbl <- dplyr::bind_rows(
    common_rows,
    new_rows,
    removed_rows
  )

  self
}
