library(testthat)
context("Exposure")

ds_plain <-
  tibble::tribble(
    ~client_id, ~referral_id, ~referral_date, ~removal_begin_date,
    1L,           1L,   "2016-01-01",       NA_character_,
    1L,           2L,   "2015-01-01",        "2015-02-01",
    1L,           3L,   "2014-01-01",       NA_character_,
    1L,           3L,   "2014-01-01",        "2015-01-01",
    2L,           4L,   "2015-01-01",        "2015-03-01",
    2L,           5L,   "2014-01-01",        "2014-02-01",
    3L,           6L,   "2015-01-01",       NA_character_,
    3L,           7L,   "2014-01-01",       NA_character_,
    4L,           8L,   "2014-01-01",       NA_character_,
    5L,           9L,   "2014-01-01",        "2015-01-01"
  ) %>%
  dplyr::mutate(
    referral_date         = as.Date(referral_date),
    removal_begin_date    = as.Date(removal_begin_date)
  )


test_that("smoke-test", {
  d_returned <- exposure(ds_plain)
  expect_true(!is.null(d_returned))
})

rm(ds_plain)
