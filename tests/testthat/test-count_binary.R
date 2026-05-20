test_that("count_binary creates _any, _count, and _all columns", {
  d <- data.frame(x = c(1, 0, NA), y = c(1, 1, NA), z = c(0, 1, NA))
  result <- count_binary(d, "test", x, y, z)
  expect_equal(result$test_any, c(1L, 1L, NA_integer_))
  expect_equal(result$test_count, c(2L, 2L, NA_integer_))
  expect_equal(result$test_all, c(0L, 0L, NA_integer_))
})

test_that("count_binary _all is 1 when all are 1", {
  d <- data.frame(x = c(1, 1), y = c(1, 0))
  result <- count_binary(d, "t", x, y)
  expect_equal(result$t_all, c(1L, 0L))
  expect_equal(result$t_count, c(2L, 1L))
})

test_that("count_binary handles all zeros", {
  d <- data.frame(a = c(0, 0), b = c(0, 0))
  result <- count_binary(d, "z", a, b)
  expect_equal(result$z_any, c(0L, 0L))
  expect_equal(result$z_count, c(0L, 0L))
})
