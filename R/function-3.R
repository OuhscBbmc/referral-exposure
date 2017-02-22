#' Failing function, Number 3
#'
#' Demonstrates https://github.com/hadley/dplyr/issues/2114
#'
#' @export
#' @importFrom magrittr %>%
#' @md
#'
failing_3 <- function(  ) {
  # Hadley's example from https://github.com/hadley/dplyr/issues/2114#issuecomment-281652615

  ds_3a <- tibble::tibble(id = 1:5)

  ds_3b <- dplyr::mutate_if(ds_3a, is.character, dplyr::coalesce, "-")

  return( ds_3a )
}
