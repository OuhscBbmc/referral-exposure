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
  exposure_parameter_check(d, censored_date)

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
