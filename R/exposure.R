#' The main function of the package.
#'
#' Calculating exposure over multiple referrals
#'
#' @param d tibble.  See Details below. Required
#' @export
#' @md
#'
exposure <- function( d ) {
  if( !inherits(d, "tbl", which = FALSE) ) stop("The `d` parameter must inherit from `tibble::tbl`.")
  return( d )
}
