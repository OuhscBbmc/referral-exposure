#' The main function of the package.
#'
#' Calculating exposure over multiple referrals
#'
#' @param d tibble.  See Details below. Required
#' @export
#' @importFrom magrittr %>%
#' @md
#'
exposure <- function( d ) {
  if( !inherits(d, "tbl", which = FALSE) ) stop("The `d` parameter must inherit from `tibble::tbl`.")

  required_columns <- c(
    client_id           = "character",
    referral_id         = "character",
    referral_date       = "Date",
    removal_begin_date  = "Date"
  )

  for( i in seq_along(required_columns) ) {
    message_name <- sprintf("The column `%s` is not present in the tibble::tbl.", names(required_columns)[i])
    if( !(names(required_columns)[i] %in% colnames(d)) ) stop(message_name)

    message_type <- sprintf("The column `%s` is data type `%s`, but should have `%s`.", names(required_columns)[i], class(d[[i]]), required_columns[i])
    if( required_columns[i] != class(d[[names(required_columns[i])]]) ) stop(message_type)
  }



  return( d )
}
