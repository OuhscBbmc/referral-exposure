library(testthat)
context("Exposure")

censored_date <- as.Date("2016-01-01")

# If you want to try a new scenario, please add a new client, instead of modifying an existing one.  They all are testing something specific.
ds_kid_referral_input <-
  tibble::tribble(
    ~client_id, ~referral_id, ~referral_date, ~was_removed, ~removal_begin_date, ~was_returned, ~removal_end_date,
            1L,           1L,   "2014-01-01",        FALSE,       NA_character_,         FALSE,     NA_character_,
            1L,           1L,   "2014-01-01",         TRUE,        "2014-02-01",          TRUE,      "2014-04-01",
            1L,           2L,   "2015-01-01",         TRUE,        "2015-02-01",          TRUE,      "2015-06-01",
            1L,           3L,   "2016-01-01",        FALSE,       NA_character_,         FALSE,     NA_character_,

            2L,           4L,   "2014-01-01",        FALSE,       NA_character_,         FALSE,     NA_character_,
            2L,           5L,   "2014-07-01",         TRUE,        "2014-08-01",          TRUE,      "2014-10-01",
            2L,           6L,   "2015-01-01",         TRUE,        "2015-03-01",         FALSE,     NA_character_,

            3L,           7L,   "2014-01-01",        FALSE,       NA_character_,         FALSE,     NA_character_,
            3L,           8L,   "2015-01-01",        FALSE,       NA_character_,         FALSE,     NA_character_,

            4L,           9L,   "2015-01-01",        FALSE,       NA_character_,         FALSE,     NA_character_,

            5L,          10L,   "2014-08-01",         TRUE,        "2014-11-01",          TRUE,      "2014-12-01"
  )

# `preremoval_duration` addresses q6b "Does ISS lengthen the duration in the home before removal?"
# `removed_length_first` addresses "Once a child is removed, does ISS reunify families quicker?"
# `removed_length_total` addresses "Does ISS reduce total time removed?"

ds_kid_output <-
  tibble::tribble(
    ~client_id,  ~preremoval_duration, ~preremoval_duration_censored, ~was_removed_first, ~was_removed_ever, ~was_returned_first, ~was_returned_ever,
            1L,                   31L,                           31L,               TRUE,              TRUE,                TRUE,               TRUE,
            2L,           NA_integer_,                          730L,              FALSE,              TRUE,               FALSE,               TRUE,
            3L,           NA_integer_,                          730L,              FALSE,             FALSE,               FALSE,              FALSE,
            4L,           NA_integer_,                          365L,              FALSE,             FALSE,               FALSE,              FALSE,
            5L,                   92L,                           92L,               TRUE,              TRUE,                TRUE,               TRUE
  ) %>%
  dplyr::left_join(
    tibble::tribble(
      ~client_id, ~had_subsequent_referral, ~had_subsequent_removal,
              1L,                     TRUE,                    TRUE,
              2L,                     TRUE,                    TRUE,
              3L,                     TRUE,                   FALSE,
              4L,                    FALSE,                   FALSE,
              5L,                    FALSE,                   FALSE
    ),
    by = "client_id"
  ) %>%
  dplyr::left_join(
    tibble::tribble(
      ~client_id, ~unique_referral_count, ~unique_removal_count, ~unique_returned_count,
              1L,                      3,                     2,                      2,
              2L,                      3,                     2,                      1,
              3L,                      2,                     0,                      0,
              4L,                      1,                     0,                      0,
              5L,                      1,                     1,                      1
    ),
    by = "client_id"
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
check_column <- function( variable_name ) {
  d_returned <- exposure(ds_kid_referral_input, censored_date)
  expect_false(is.null(d_returned[[variable_name]]))
  # browser()
  expect_equal(d_returned[[variable_name]], ds_kid_output[[variable_name]])
}

test_that("smoke-test", {
  d_returned <- exposure(ds_kid_referral_input, censored_date)
  expect_true(!is.null(d_returned))
})
test_that("scenario-preremoval_duration", {
  # testthat::skip("In development")
  check_column("preremoval_duration")
})
test_that("scenario-preremoval_duration_censored", {
  check_column("preremoval_duration_censored")
})

test_that("scenario-was_removed_first", {
  check_column("was_removed_first")
})
test_that("scenario-was_removed_ever", {
  check_column("was_removed_ever")
})
test_that("scenario-was_returned_first", {
  check_column("was_returned_first")
})
test_that("scenario-was_returned_ever", {
  check_column("was_returned_ever")
})

test_that("scenario-had_subsequent_referral", {
  check_column("had_subsequent_referral")
})
test_that("scenario-had_subsequent_removal", {
  check_column("had_subsequent_removal")
})

test_that("scenario-unique_referral_count", {
  check_column("unique_referral_count")
})
test_that("scenario-unique_removal_count", {
  check_column("unique_removal_count")
})
test_that("scenario-unique_returned_count", {
  check_column("unique_returned_count")
})

rm(ds_kid_referral_input)
