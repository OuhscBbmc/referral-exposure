#' The main function of the package.
#'
#' Calculating exposure over multiple referrals
#'
#' @param d tibble.  See Details below. Required
#' @param censored_date Date.  The last observed date; this value calculates the censored duration. Required
#' @export
#' @importFrom magrittr %>%
#' @importFrom DBI SQL
#' @md
#'
exposure <- function( d, censored_date ) {
  exposure_parameter_check(d, censored_date)

  # browser()
  d_kid_premoval <- d %>%
    dplyr::select_("client_id", "referral_date", "was_removed", "was_returned", "removal_begin_date") %>%
    dplyr::arrange_("client_id", "referral_date", "!was_removed", "!was_returned", "removal_begin_date") %>%
    dplyr::group_by_("client_id") %>%
    dplyr::slice(1) %>%
    dplyr::mutate(
      preremoval_duration                     = as.integer(difftime(removal_begin_date, referral_date, units="days")),

      preremoval_duration_censored            = dplyr::if_else(
        !is.na(preremoval_duration),
        preremoval_duration,
        as.integer(difftime(censored_date, referral_date, units="days"))
      ),

      was_removed_first                       = was_removed,
      was_returned_first                      = was_returned
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select_("client_id", "was_removed_first", "was_returned_first", "preremoval_duration", "preremoval_duration_censored")

  d_kid_summarized <- d %>%
    dplyr::select_(
      "client_id", "was_removed", "was_returned",
      "referral_date", "removal_begin_date", "removal_end_date"
    ) %>%
    dplyr::group_by_("client_id") %>%
    dplyr::summarize(
      unique_referral_count   = dplyr::n_distinct(referral_date          , na.rm=TRUE),
      unique_removal_count    = dplyr::n_distinct(removal_begin_date     , na.rm=TRUE),
      unique_returned_count   = dplyr::n_distinct(removal_end_date       , na.rm=TRUE),
      was_removed_ever        = any(was_removed, na.rm=TRUE),
      was_returned_ever       = any(was_returned, na.rm=TRUE)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select_(
      "client_id", "was_removed_ever", "was_returned_ever",
      "unique_referral_count", "unique_removal_count", "unique_returned_count"
    )

  ds_subsequent <-
    "SELECT
      d1.client_id,
      d1.referral_date,
      d1.removal_begin_date,
      d2.referral_date         AS referral_date_subsequent,
      d2.removal_begin_date    AS removal_begin_date_subsequent
    FROM d AS d1
      LEFT JOIN d AS d2 ON
        (d1.client_id = d2.client_id)
        AND (d1.referral_date < d2.referral_date)
    ORDER BY d1.client_id, d1.referral_date
    " %>%
    DBI::SQL() %>%
    sqldf::sqldf() %>%
    dplyr::select_(
      "client_id",  "referral_date_subsequent", "removal_begin_date_subsequent"
    ) %>%
    dplyr::mutate(
      had_subsequent_referral             = !is.na(referral_date_subsequent),        # Research Q7: Reduce CPS Reports #78
      had_subsequent_removal              = !is.na(removal_begin_date_subsequent),   # Research Q8: Reduce re-entries #79

      referral_date_subsequent            = as.Date(referral_date_subsequent          , origin="1970-01-01"),
      removal_begin_date_subsequent       = as.Date(removal_begin_date_subsequent     , origin="1970-01-01")
    ) %>%
    dplyr::group_by_("client_id") %>%
    dplyr::summarize(
      had_subsequent_referral             = any(had_subsequent_referral),
      had_subsequent_removal              = any(had_subsequent_removal)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select_("client_id", "had_subsequent_referral", "had_subsequent_removal")

  d_kid <- d %>%
    dplyr::distinct_("client_id", .keep_all = FALSE) %>%
    dplyr::left_join(d_kid_premoval, by="client_id") %>%
    dplyr::left_join(d_kid_summarized , by="client_id") %>%
    dplyr::left_join(ds_subsequent , by="client_id") %>%
    dplyr::select_(
      "client_id",
      "preremoval_duration", "preremoval_duration_censored",
      "unique_referral_count", "unique_removal_count", "unique_returned_count",
      "was_removed_first", "was_removed_ever",
      "was_returned_first", "was_returned_ever",
      "had_subsequent_referral", "had_subsequent_removal"
      # "referral_date_subsequent", "removal_begin_date_subsequent"
    )

  return( d_kid )
}
