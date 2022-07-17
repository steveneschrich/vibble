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
    #return(c(x = glue::glue("Different number of columns: {nc} vs {ncol(y)}.")))
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
        #return(c(x = "Same column names, but different order."))
      }
    }
  }
  else {
    msg <- c()
    if (length(names_y_not_in_x)) {
      wrong <- glue::glue_collapse(glue::glue("`{names_y_not_in_x}`"),
                             sep = ", ")
      msg <- c(msg, x = glue::glue("Cols in `y` but not `x`: {wrong}."))
    }
    if (length(names_x_not_in_y)) {
      wrong <- glue::glue_collapse(glue::glue("`{names_x_not_in_y}`"),
                             sep = ", ")
      msg <- c(msg, x = glue::glue("Cols in `x` but not `y`: {wrong}."))
    }
    #return(msg)
    return(FALSE)
  }
  msg <- c()
  for (name in names_x) {
    x_i <- x[[name]]
    y_i <- y[[name]]

    if (!identical(vctrs::vec_ptype(x_i), vctrs::vec_ptype(y_i))) {
      msg <- c(msg, x = glue::glue("Different types for column `{name}`: {vctrs::vec_ptype_full(x_i)} vs {vctrs::vec_ptype_full(y_i)}."))
    }

  }
  if (length(msg)) {
    #return(msg)
    return(FALSE)
  }
  TRUE
}
