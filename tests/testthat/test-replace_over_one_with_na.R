test_that("replace_over_one_with_na replaces values > 1 with NA", {
  d <- data.frame(A = c(0.5, 1.2, 0.9, 2.1), B = c(1, 1.5, 0.8, 0.4))
  result <- replace_over_one_with_na(d, c("A", "B"))
  expect_equal(result$A, c(0.5, NA, 0.9, NA))
  expect_equal(result$B, c(1, NA, 0.8, 0.4))
})

test_that("replace_over_one_with_na leaves untouched columns alone", {
  d <- data.frame(A = c(0.5, 1.2), B = c(2, 3))
  result <- replace_over_one_with_na(d, "A")
  expect_equal(result$B, c(2, 3))
})

test_that("replace_over_one_with_na preserves NA inputs", {
  d <- data.frame(A = c(0.5, NA, 1.2))
  result <- replace_over_one_with_na(d, "A")
  expect_equal(result$A, c(0.5, NA, NA))
})
