#' Passing function, Number 2
#'
#' Demonstrates https://github.com/hadley/dplyr/issues/2114
#'
#' @export
#' @importFrom magrittr %>%
#' @md
#'

passing_2 <- function( ) {
  ds_2a <- data.frame(
    id               = 1L:5L,
    name             = c("a", "b", NA_character_, "c", "d"),
    stringsAsFactors = FALSE
  )
  ds_2b <- dplyr::mutate_if(
    ds_2a,
    is.character,
    function(x) dplyr::coalesce(x, "-") #Replace NAs with blanks
  )

  return( ds_2b )
}

