#' Check the parameters to exposure
#'
#' Make sure the parameters are what the `exposure()` function expects.
#'
#' @param d tibble.  See Details below. Required
#' @param censored_date Date.  The last observed date; this value calculates the censored duration. Required
#' @export
#' @md
#'
exposure_parameter_check <- function( d, censored_date ) {
  if( !inherits(d, "tbl", which = FALSE) ) stop("The `d` parameter must inherit from `tibble::tbl`.")
  if( missing(censored_date) | is.null(censored_date) ) stop("The `censored_date` parameter must not be missing.")
  if( class(censored_date) != "Date" ) stop("The `censored_date` parameter must be a date data type.")

  required_columns <- c(
    client_id           = "character",
    referral_id         = "character",
    referral_date       = "Date",
    was_removed         = "logical",
    removal_begin_date  = "Date"
  )

  for( i in seq_along(required_columns) ) {
    message_name <- sprintf("The column `%s` is not present in the tibble::tbl.", names(required_columns)[i])
    if( !(names(required_columns)[i] %in% colnames(d)) ) stop(message_name)

    message_type <- sprintf("The column `%s` is data type `%s`, but should have `%s`.", names(required_columns)[i], class(d[[i]]), required_columns[i])
    if( required_columns[i] != class(d[[names(required_columns[i])]]) ) stop(message_type)
  }
}
