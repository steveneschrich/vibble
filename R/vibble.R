#' Construct a vibble as of a time point from a data frame
#'
#' @description A versioned tibble (vibble) can be created from a data frame at a specific time point.
#' This function will create the additional fields necessary to be a vibble.
#'
#' @param .x A tibble/data frame to store
#' @param as_of A date or version tag to store as the timepoint.
#'
#' @return A vibble representing `.x` at the time point `as_of`.
#' @export
#'
#' @examples
#' \dontrun{
#' vibble(iris, as_of="2022-01-01")
#' }
vibble <- function(.x, as_of=lubridate::today()) {
  stopifdups(.x)

  v <- new_vibble(.x)

  if ( !(utils::hasName(.x, "ValidFrom") && utils::hasName(.x, "ValidTo"))) {
    # A vibble is a tibble with a ValidFrom and ValidTo field.
    v <- dplyr::mutate(
      .x,
      ValidFrom = as_of,
      ValidTo = type_converter(as_of)(NA)
    )
  }

  v
}


stopifdups <- function(.x) {
  stopifnot("No duplicate rows allowed in vibble." = nrow(.x)==nrow(dplyr::distinct(.x)))
}

#' Convert data frame to a vibble
#'
#' @description This function will convert the input to a vibble
#'
#' @param .x A data frame/tibble to convert to a vibble.
#' @param as_of The data/version to store the data as of.
#'
#' @return A vibble
#' @export
#'
#' @examples
as_vibble <- function(.x, as_of=lubridate::today()) {
  stopifdups(.x)

  vibble(.x, as_of)
}

#' Title
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
new_vibble <- function(x) {
  tibble::new_tibble(x, class = "tbl_vdf")
}
