library(testthat)
context("Failing Functions")

test_that("Failing-1", {
  d_returned <- failing_1()
  expect_true(!is.null(d_returned))
})
