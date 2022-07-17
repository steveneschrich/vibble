#' Function Factory for Type Conversion
#'
#' @description A variable can contain any type of value such as logical, numeric or character. This
#' function determines the type of a variable and returns the `as.type()` function corresponding
#' to that type.
#'
#' @details Variables can contain different types and there is sometimes a need to create other variables
#' of the same type. There are probably better ways to do this in R, but this approach is to simply
#' inspect the variable type and use the corresponding `as.type()` function.
#'
#' This is (currently) a brittle function as there are only a few different types defined:
#'
#' - character
#' - logical
#' - numeric
#' - Date
#' - POSIXct
#'
#' The default type converter (if the type is supported) is currently just `[base::as.character()]`.
#'
#' @param x A single value, list, or vector of values to determine the conversion function for.
#'
#' @return A function that converts arguments to the matched type (e.g, [base::as.character()])
#' @export
#'
#' @examples
#' \dontrun{
#'   # This returns `as.numeric()`
#'   type_converter(1)
#' }
type_converter <- function(x) {
  if ( is.list(x) && length(x) > 0 ) x<-x[[1]]
  val <- class(x)[1]

  switch(
    class(x)[1],
    "character" = as.character,
    "logical" = as.logical,
    "numeric" = as.numeric,
    "Date" = lubridate::as_date,
    "POSIXct" = lubridate::as_datetime,
    as.character
  )
}
