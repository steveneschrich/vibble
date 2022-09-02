#' Construct a vibble as of a time point from a data frame
#'
#' @description A versioned tibble (vibble) can be created from a data frame at a specific time point.
#' This function will create this data structure (type `tbl_vdf`).
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
vibble <- function(.x = tibble::tibble(), as_of=lubridate::today()) {

  v <- .x

  if ( nrow(v) > 0 ) {

    # If v has a vlist, this is already in the right form but may not be consolidated (i.e.,
    # duplicate rows with different vlist values). We can run through everything below
    # other than setting the vlist variable, so special-case that action.
    if ( !utils::hasName(v, "vlist")) {
      # A vibble is a tibble with a vlist field.
      v <- dplyr::mutate(v, vlist = as_of)
    }

    # At this point, we have a bunch of entries with vlist. Collapse all versions into
    # the same record. Note that tidyr::chop is fast for this, but we have to unbox the
    # vctrs:: type back to plain old lists (for type consistency).
    v <- tidyr::chop(v, .data$vlist) |>
      dplyr::mutate(vlist = purrr::map(.data$vlist, unlist))
  }
  # Return a vibble with the contents.
  new_vibble(v)
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
as_vibble <- function(.x, as_of=lubridate::today()) {

  vibble(.x, as_of)
}

#' Vibble constructor
#'
#' @param x A tibble-like object
#'
#' @return A vibble representing the data
#' @export
#'
new_vibble <- function(x) {
  tibble::new_tibble(x, class = "tbl_vdf")
}
