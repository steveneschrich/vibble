#' Title
#'
#' @param .x
#' @param as_of
#'
#' @return
#' @export
#'
#' @examples
vibble <- function(.x, as_of) {
  v <- dplyr::mutate(.x,
      ValidFrom = as_of,
      ValidTo = as_of
    )

  class(v) <-c("vibble",v)
}
