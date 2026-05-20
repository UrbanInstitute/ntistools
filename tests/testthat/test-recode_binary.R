test_that("recode_binary applies default mapping", {
  d <- data.frame(x = c(0, 1, 2, 98))
  result <- recode_binary(d, "x")
  expect_equal(result$x, c(0L, 1L, 1L, NA_integer_))
})

test_that("recode_binary uses custom ones/zeros/na_values", {
  d <- data.frame(x = c(3, 4, 5, 99))
  result <- recode_binary(d, "x", ones = c(3, 4), zeros = 5, na_values = 99)
  expect_equal(result$x, c(1L, 1L, 0L, NA_integer_))
})

test_that("recode_binary works on multiple columns", {
  d <- data.frame(a = c(0, 1, 2), b = c(2, 98, 0))
  result <- recode_binary(d, c("a", "b"))
  expect_equal(result$a, c(0L, 1L, 1L))
  expect_equal(result$b, c(1L, NA_integer_, 0L))
})
