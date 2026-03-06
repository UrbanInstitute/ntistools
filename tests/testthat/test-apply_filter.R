test_that("apply_filter sets values to NA when condition is FALSE", {
  d <- data.frame(keep = c(1, 0, 1), x = c(10, 20, 30), y = c(4, 5, 6))
  result <- apply_filter(d, c("x", "y"), condition = keep == 1)
  expect_equal(result$x, c(10, NA, 30))
  expect_equal(result$y, c(4, NA, 6))
})

test_that("apply_filter keeps all when condition is always TRUE", {
  d <- data.frame(flag = c(1, 1), x = c(10, 20))
  result <- apply_filter(d, "x", condition = flag == 1)
  expect_equal(result$x, c(10, 20))
})

test_that("apply_filter NAs all when condition is always FALSE", {
  d <- data.frame(flag = c(0, 0), x = c(10, 20))
  result <- apply_filter(d, "x", condition = flag == 1)
  expect_equal(result$x, c(NA_real_, NA_real_))
})
