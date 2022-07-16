#' @description Given a table with information over time (see [MolecularDataManager::ChangeManager()]),
#' retrieve data as of a specific time point.
#'
#' @details The design pattern is documented in many places. For one description, see
#' https://docs.microsoft.com/en-us/sql/relational-databases/tables/temporal-tables?view=sql-server-2017
#'
#' @param v A tmtable
#' @param as_of A date to construct the snapshot from (assumed YYYY-MM-DD).
#'
#' @return A data frame with contents representing a snapshot as of a specific time.
#'
#' @examples
as_of <- function(v, as_of=NULL) {
  stopifnot(any(class(v) %in% "tmtable"))

  if (is.null(as_of))
    .x <- dplyr::filter(v, is.na(ValidTo))
  else
    .x <- dplyr::filter(v, ValidFrom <= as_of & (is.na(ValidTo)  | ValidTo > as_of))

  class(.x) <- class(.x)[!class(.x) %in% "tmtable"]
}
