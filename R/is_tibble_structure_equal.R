#' Determine if Two Data Frame Structures are Equal
#'
#' @details This function was extracted from dplyr (internal function), called
#' `dplyr:::is_compatible_data_frame()`.
#' @param x
#' @param y
#' @param ignore_col_order
#'
#' @return
#' @export
#'
#' @examples
is_tibble_structure_equal <- function (x, y, ignore_col_order = TRUE)
{
  nc <- ncol(x)
  if (nc != ncol(y)) {
    return(FALSE)
  }
  names_x <- names(x)
  names_y <- names(y)
  names_y_not_in_x <- setdiff(names_y, names_x)
  names_x_not_in_y <- setdiff(names_x, names_y)
  if (length(names_y_not_in_x) == 0L && length(names_x_not_in_y) ==
      0L) {
    if (!isTRUE(ignore_col_order)) {
      if (!identical(names_x, names_y)) {
        return(FALSE)
      }
    }
  }
  else {
    return(FALSE)
  }
  for (name in names_x) {
    x_i <- x[[name]]
    y_i <- y[[name]]

    if (!identical(vctrs::vec_ptype(x_i), vctrs::vec_ptype(y_i))) {
      return(FALSE)
    }
  }

  TRUE
}
