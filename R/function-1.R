#' Failing function, Number 1
#'
#' Demonstrates https://github.com/hadley/dplyr/issues/2114
#'
#' @export
#' @importFrom magrittr %>%
#' @md
#'
failing_1 <- function(  ) {
  ds_1a <- data.frame(
    id               = 1L:5L,
    stringsAsFactors = FALSE
  )

  ds_1b <- dplyr::mutate_if(
    ds_1a,
    is.character,
    function(x) dplyr::coalesce(x, "-") #Replace NAs with blanks
  )

  return( ds_1b )
}

