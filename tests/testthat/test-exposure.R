library(testthat)
context("Exposure")

censored_date <- as.Date("2016-01-01")

ds_kid_referral_input <-
  tibble::tribble(
    ~client_id, ~referral_id, ~referral_date, ~was_removed, ~removal_begin_date,
            1L,           1L,   "2014-01-01",        FALSE,       NA_character_,
            1L,           1L,   "2014-01-01",         TRUE,        "2014-02-01",
            1L,           2L,   "2015-01-01",         TRUE,        "2015-02-01",
            1L,           3L,   "2016-01-01",        FALSE,       NA_character_,

            2L,           4L,   "2014-01-01",         TRUE,       NA_character_,
            2L,           5L,   "2014-07-01",         TRUE,        "2014-02-01",
            2L,           6L,   "2015-01-01",         TRUE,        "2015-03-01",

            3L,           7L,   "2014-01-01",        FALSE,       NA_character_,
            3L,           8L,   "2015-01-01",        FALSE,       NA_character_,

            4L,           9L,   "2015-01-01",        FALSE,       NA_character_,

            5L,          10L,   "2014-08-01",         TRUE,        "2015-01-01"
  )

# `preremoval_duration` addresses q6b "Does ISS lengthen the duration in the home before removal?"
# `removed_length_first` addresses "Once a child is removed, does ISS reunify families quicker?"
# `removed_length_total` addresses "Does ISS reduce total time removed?"

ds_kid_output <-
  tibble::tribble(
    ~client_id,  ~preremoval_duration, ~preremoval_duration_censored, ~was_removed_first, ~was_removed_ever,
            1L,                   31L,                           31L,               TRUE,              TRUE,
            2L,                  365L,                          365L,              FALSE,              TRUE,
            3L,           NA_integer_,                          730L,              FALSE,             FALSE,
            4L,           NA_integer_,                          365L,              FALSE,             FALSE,
            5L,                   63L,                           63L,               TRUE,              TRUE
  ) %>%  dplyr::mutate(
    client_id             = as.character(client_id)
  )

ds_kid_referral_input <- ds_kid_referral_input %>%
  dplyr::mutate(
    client_id             = as.character(client_id),
    referral_id           = as.character(referral_id),
    referral_date         = as.Date(referral_date),
    removal_begin_date    = as.Date(removal_begin_date)
  )

test_that("smoke-test", {
  d_returned <- exposure(ds_kid_referral_input)
  expect_true(!is.null(d_returned))
})

test_that("scenario-preremoval_duration", {
  testthat::skip("In development")
  d_returned <- exposure(ds_kid_referral_input)
  expect_false(is.null(d_returned$preremoval_duration))
  expect_equal(d_returned$preremoval_duration, ds_kid_output$preremoval_duration)
})

rm(ds_kid_referral_input)
