library(testthat)
context("Failing Functions")

test_that("Failing-1", {
  d_returned <- failing_1()
  expect_true(!is.null(d_returned))
})

test_that("Failing-1-caught", {
  expected_message <- "Vector 1 has type 'character' not 'integer'"
  expect_error(failing_1(), expected_message, fixed=TRUE)
})

test_that("Passing-2", {
  d_returned <- passing_2()
  expect_true(!is.null(d_returned))
})

# test_that("Failing-3", {
#   d_returned <- failing_3()
#   expect_true(!is.null(d_returned))
# })
