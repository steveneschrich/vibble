#' Test is the object is a vibble
#'
#' @description This function returns `TRUE` for vibbles and `FALSE` for all other objects,
#' including tibbles and regular data frames.
#'
#' @param x An object
#'
#' @return `TRUE` if the object inherits from the `tbl_vdf` class.
#' @export
#'
is_vibble <- function(x) {
  inherits(x, "tbl_vdf")
}
