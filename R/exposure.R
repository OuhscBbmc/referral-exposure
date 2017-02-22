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
      referral_date_subsequent            = as.Date(referral_date_subsequent          , origin="1970-01-01"),
      removal_begin_date_subsequent       = as.Date(removal_begin_date_subsequent     , origin="1970-01-01")
    )

  d_kid <- d %>%
    dplyr::distinct_("client_id", .keep_all = FALSE) %>%
    dplyr::left_join(d_kid_premoval, by="client_id") %>%
    dplyr::left_join(d_kid_removed , by="client_id") %>%
    # dplyr::left_join(ds_subsequent , by="client_id") %>%
    dplyr::select_(
      "client_id",
      "preremoval_duration", "preremoval_duration_censored",
      "was_removed_first", "was_removed_ever"
      # "referral_date_subsequent", "removal_begin_date_subsequent"
    )

  return( d_kid )
}
