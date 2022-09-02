#' Return list of versions
#'
#' @param v A vibble
#'
#' @return A sorted list of versions in the vibble.
#' @export
#'
#' @examples
#' if (FALSE) {
#'    versions(vibble::vibble(iris))
#' }
versions <- function(v) {
  stopifnot(is_vibble(v))

  vers <- c()
  if ( nrow(v) > 0) {
    vers <- do.call("c",v$vlist) |>
      unique() |>
      sort()
  }

  vers
}
