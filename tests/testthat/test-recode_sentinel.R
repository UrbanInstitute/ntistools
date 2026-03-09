test_that("recode_sentinel replaces 98 with NA by default", {
  d <- data.frame(x = c(1, 98, 3), y = c(98, 2, 98))
  result <- recode_sentinel(d, c("x", "y"))
  expect_equal(result$x, c(1, NA, 3))
  expect_equal(result$y, c(NA, 2, NA))
})

test_that("recode_sentinel handles multiple sentinel values", {
  d <- data.frame(x = c(1, 97, 98, 3))
  result <- recode_sentinel(d, "x", values = c(97, 98))
  expect_equal(result$x, c(1, NA, NA, 3))
})

test_that("recode_sentinel leaves non-sentinel values unchanged", {
  d <- data.frame(x = c(1, 2, 3))
  result <- recode_sentinel(d, "x", values = 98)
  expect_equal(result$x, c(1, 2, 3))
})
