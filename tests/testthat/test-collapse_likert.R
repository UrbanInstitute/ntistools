test_that("collapse_likert applies default 5-to-3 mapping", {
  d <- data.frame(q = c(1, 2, 3, 4, 5))
  result <- collapse_likert(d, "q")
  expect_equal(result$q, c(1L, 1L, 2L, 3L, 3L))
})

test_that("collapse_likert recodes na_values to NA", {
  d <- data.frame(q = c(1, 97, 5))
  result <- collapse_likert(d, "q")
  expect_equal(result$q, c(1L, NA_integer_, 3L))
})

test_that("collapse_likert uses custom mapping", {
  d <- data.frame(q = c(1, 2, 3))
  result <- collapse_likert(d, "q", mapping = c(10L, 20L, 30L))
  expect_equal(result$q, c(10L, 20L, 30L))
})

test_that("collapse_likert handles values outside mapping range", {
  d <- data.frame(q = c(1, 6))
  result <- collapse_likert(d, "q")
  expect_equal(result$q, c(1L, NA_integer_))
})
