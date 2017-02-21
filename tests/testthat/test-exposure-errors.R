library(testthat); library(magrittr)
context("Exposure Errors")

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
    client_id             = as.character(client_id),
    referral_id           = as.character(referral_id),
    referral_date         = as.Date(referral_date),
    removal_begin_date    = as.Date(removal_begin_date)
  )


test_that("exposure - inherit error - data.frame", {
  #The dataset by itself is fine.  The problem is that it doesn't inherit from tibble.
  d <- data.frame(id=seq_along(letters), names=letters, stringsAsFactors=FALSE)

  expect_error(exposure(d), "The `d` parameter must inherit from `tibble::tbl`.", fixed=TRUE)
})

test_that("exposure - missing columns", {
  # For each column, create a copy of the tbl that's missing the column.

  for( i in seq_along(ds_plain) ) {
    column_name <- colnames(ds_plain)[i]
    ds_missing_column <- ds_plain
    ds_missing_column[[column_name]] <- NULL

    error_message <- sprintf("The column `%s` is not present in the tibble::tbl.", colnames(ds_plain)[i])
    expect_error(exposure(ds_missing_column), error_message, fixed=TRUE)
  }
})

test_that("exposure - bad column type", {
  # For each column, create a copy of the tbl that's has a column of the incorrect data type.

  ds_bad_type <- dplyr::mutate(ds_plain, client_id = as.integer(client_id))
  expect_error(exposure(ds_bad_type), "The column `client_id` is data type `integer`, but should have `character`.", fixed=TRUE)

  ds_bad_type <- dplyr::mutate(ds_plain, referral_id = as.integer(referral_id))
  expect_error(exposure(ds_bad_type), "The column `referral_id` is data type `integer`, but should have `character`.", fixed=TRUE)

  ds_bad_type <- dplyr::mutate(ds_plain, referral_date = as.character(referral_date))
  expect_error(exposure(ds_bad_type), "The column `referral_date` is data type `character`, but should have `Date`.", fixed=TRUE)

  ds_bad_type <- dplyr::mutate(ds_plain, removal_begin_date=as.character(removal_begin_date))
  expect_error(exposure(ds_bad_type), "The column `removal_begin_date` is data type `character`, but should have `Date`.", fixed=TRUE)
})

rm(ds_plain)
