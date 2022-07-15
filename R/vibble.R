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


as_vibble <- function(.x, as_of) {
  if (!all(c("ValidFrom","ValidTo") %in% colnames(.x)))
    vibble(.x, as_of)
  else if (null)
    addsnapshot
  else
    ?
}
