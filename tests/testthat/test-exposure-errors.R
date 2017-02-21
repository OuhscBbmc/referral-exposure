library(testthat)
context("Exposure Errors")

test_that("exposure - inherit error - data.frame", {
  d <- data.frame(id=seq_along(letters), names=letters, stringsAsFactors=FALSE) #These aren't really dirty.  And should have no conversion problems

  expect_error(exposure(d), "The `d` parameter must inherit from `tibble::tbl`.", fixed=TRUE)

})
