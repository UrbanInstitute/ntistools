test_that("impute_from_flag replaces NA with 0 when flag is 1", {
  d <- data.frame(x = c(1, NA, 3, NA), x_NA_X = c(0, 1, 0, 0))
  result <- impute_from_flag(d, "x")
  expect_equal(result$x, c(1, 0, 3, NA))
})

test_that("impute_from_flag uses custom suffix and value", {
  d <- data.frame(val = c(NA, NA, 5), val_flag = c(1, 0, 0))
  result <- impute_from_flag(d, "val", flag_suffix = "_flag", impute_value = -1)
  expect_equal(result$val, c(-1, NA, 5))
})

test_that("impute_from_flag warns when flag column not found", {
  d <- data.frame(x = c(1, NA))
  expect_warning(impute_from_flag(d, "x"), "not found")
})

test_that("impute_from_flag handles multiple vars", {
  d <- data.frame(
    a = c(NA, 2), a_NA_X = c(1, 0),
    b = c(NA, NA), b_NA_X = c(0, 1)
  )
  result <- impute_from_flag(d, c("a", "b"))
  expect_equal(result$a, c(0, 2))
  expect_equal(result$b, c(NA, 0))
})
