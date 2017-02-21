#' The main function of the package.
#'
#' Calculating exposure over multiple referrals
#'
#' @param d tibble.  See Details below. Required
#' @param censored_date Date.  The last observed date; this value calculates the censored duration. Required
#' @export
#' @importFrom magrittr %>%
#' @md
#'
exposure <- function( d, censored_date ) {
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

  # browser()
  d_kid_premoval <- d %>%
    dplyr::select_("client_id", "referral_date", "was_removed", "removal_begin_date") %>%
    dplyr::arrange_("client_id", "referral_date", "!was_removed", "removal_begin_date") %>%
    dplyr::group_by_("client_id") %>%
    dplyr::slice(1) %>%
    dplyr::mutate(
      preremoval_duration                     = as.integer(difftime(removal_begin_date, referral_date, units="days")),

      preremoval_duration_censored            = dplyr::if_else(
        !is.na(preremoval_duration),
        preremoval_duration,
        as.integer(difftime(censored_date, referral_date, units="days"))
      ),

      was_removed_first                       = was_removed
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select_("client_id", "was_removed_first", "preremoval_duration", "preremoval_duration_censored")

  d_kid_removed <- d %>%
    dplyr::select_("client_id", "was_removed") %>%
    dplyr::group_by_("client_id") %>%
    dplyr::summarize(
      was_removed_ever = any(was_removed, na.rm=TRUE)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select_("client_id", "was_removed_ever")

  d_kid <- d %>%
    dplyr::distinct_("client_id", .keep_all = FALSE) %>%
    dplyr::left_join(d_kid_premoval, by="client_id") %>%
    dplyr::left_join(d_kid_removed , by="client_id") %>%
    dplyr::select_(
      "client_id",  "preremoval_duration", "preremoval_duration_censored", "was_removed_first", "was_removed_ever"
    )

  return( d_kid )
}
