#' Add a snapshot
#'
#' @description Given a data frame, update the vibble by adding a snapshot at the
#' current version point.
#'
#' @details
#' The algorithm involves adding a new version of all rows, then combining identical rows
#' so that versions are listed together (in a vlist).
#'
#' @param v A vibble
#' @param snapshot A new table with the same structure as vibble (without version data).
#' @param as_of A date/version
#'
#' @return An updated vibble with newtbl merged in.
#'
#' @importFrom rlang .data
#'
#' @export
#' @examples
#' \dontrun{
#' vibble::add_snapshot(vibble::vibble(iris, as_of="2022-01-01"), iris[1:10,], as_of="2022-01-02")
#' }
add_snapshot <- function(v, snapshot, as_of = lubridate::now()) {

  # Assert v is a vibble and snapshot does not contain our key fields.
  stopifnot(is_vibble(v))
  stopifnot(!any(colnames(snapshot) %in% c("vlist","vid")))

  # Add as_of tag to snapshot (as vid)
  snapshot <- dplyr::mutate(snapshot, vid = as_of)

  # Now we can combine the two sets.
  # These steps combine the v and snapshot into a single, new vibble.
  #  - Unnest the versions for each row (so there are multiple rows, one for each version)
  #  - Combine with snapshot (new set of versions)
  #  - Nest the results so that vid's are combined into a list
  #  - Wrap this in a vibble (nest/unnest uses tibbles)

  # Special-case an empty vibble, we cannot unnest it to a vid. And we don't know what
  # type vid will be, so leave it empty. Otherwise, just unnest the vibble into duplicate
  # rows with different vid's.
  if (nrow(v) == 0) {
    ut <- NULL
  } else {
    ut <- tidyr::unchop(v, "vlist") |> dplyr::rename(vid = .data$vlist)
  }

  ut <- ut |>
    # Note that bind_rows takes care of two important things:
    # matching column names between the two (if they are out of order) and filling in missing
    # columns with NA's. This is exactly the behavior we need, since the result needs to be
    # a union of all columns, with NA's filled in as needed.
    dplyr::bind_rows(snapshot) |>
    tidyr::chop("vid") |>
    dplyr::rename(vlist = .data$vid) |>
    new_vibble()

  ut

}


