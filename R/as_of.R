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
#'
#' @return A data frame with contents representing a snapshot as of a specific time.
#'
#' @importFrom rlang .data
#'
#' @export
#' @examples
#' \dontrun{
#' vibble::as_of(vibble::vibble(iris, as_of="20220101"),"20220101")
#' }
as_of <- function(v, as_of=NULL) {
  stopifnot(any(class(v) %in% "vibble"))

  # as_of means either NULL (currently valid) or a specific time point.
  if (is.null(as_of))
    .x <- dplyr::filter(v, is.na(.data$ValidTo))
  else
    .x <- dplyr::filter(v, .data$ValidFrom <= as_of & (is.na(.data$ValidTo)  | .data$ValidTo > as_of))



  # The purpose of this function is to provide a snapshot. Therefore the indicator columns (ValidTo and
  # ValidFrom) should be removed to masquerade as a simple data frame/tibble.
  .x <- dplyr::select(.x, -.data$ValidTo, -.data$ValidFrom)

  # One of the aspects of the vibble is the idea that the structure can change over time. That
  # is, columns can be added or removed. Since we store the full contents in a table, this means
  # that at any given time point the set of valid columns can be different. For the time being,
  # we simply assume that any completely empty (NA) column when subsetting is one of these columns.
  # Hence, these are removed.
  .x <- janitor::remove_empty(.x, which = c("cols"))

  # The final step of returning a non-vibble object is to remove the class type that
  # distinguishes it.
  class(.x) <- class(.x)[!class(.x) %in% "vibble"]

  .x
}
