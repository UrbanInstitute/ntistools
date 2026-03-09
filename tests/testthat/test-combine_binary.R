test_that("combine_binary returns 1 when any source is 1", {
  d <- data.frame(a = c(1, 0, 0), b = c(0, 0, 1))
  result <- combine_binary(d, ab, a, b)
  expect_equal(result$ab, c(1L, 0L, 1L))
})

test_that("combine_binary returns NA when all sources are NA", {
  d <- data.frame(a = c(NA, 1, NA), b = c(NA, 0, 0))
  result <- combine_binary(d, ab, a, b)
  expect_equal(result$ab, c(NA_integer_, 1L, 0L))
})

test_that("combine_binary returns 0 when all sources are 0", {
  d <- data.frame(a = c(0, 0), b = c(0, 0), c = c(0, 0))
  result <- combine_binary(d, abc, a, b, c)
  expect_equal(result$abc, c(0L, 0L))
})

test_that("combine_binary handles mix of NA and 1", {

  d <- data.frame(a = c(NA, NA), b = c(1, NA))
  result <- combine_binary(d, ab, a, b)
  expect_equal(result$ab, c(1L, NA_integer_))
})

test_that("combine_binary strict_na returns NA when any source is NA and no 1", {
  d <- data.frame(a = c(0, NA, 1), b = c(NA, NA, NA))
  result <- combine_binary(d, ab, a, b, strict_na = TRUE)
  expect_equal(result$ab, c(NA_integer_, NA_integer_, 1L))
})

test_that("combine_binary strict_na = FALSE (default) returns 0 for mix of 0 and NA", {
  d <- data.frame(a = c(0, NA), b = c(NA, NA))
  result <- combine_binary(d, ab, a, b)
  expect_equal(result$ab, c(0L, NA_integer_))
})
