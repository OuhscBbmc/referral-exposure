library(testthat)
context("Exposure Errors")

test_that("exposure - inherit error - data.frame", {
  #The dataset by itself is fine.  The problem is that it doesn't inherit from tibble.
  d <- data.frame(id=seq_along(letters), names=letters, stringsAsFactors=FALSE)

  expect_error(exposure(d), "The `d` parameter must inherit from `tibble::tbl`.", fixed=TRUE)
})
