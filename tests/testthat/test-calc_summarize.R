test_that("calc_summarize computes weighted proportions within groups", {
  d <- data.frame(
    grp = c(1, 1, 1, 2, 2),
    Q = c(1, 1, 2, 1, 2),
    w = c(10, 20, 70, 50, 50)
  )
  result <- calc_summarize(d, var = "Q", wt_var = "w",
                           grp_cols = c("grp", "Q"), metric = "proportion")
  expect_setequal(
    names(result),
    c("group_level", "variable_level", "count", "value", "variable",
      "metric", "group")
  )
  grp1 <- result[result$group_level == "1", ]
  expect_equal(sum(grp1$value), 1)
  expect_equal(grp1$value[grp1$variable_level == "1"], 30 / 100)
})

test_that("calc_summarize computes weighted means within groups", {
  d <- data.frame(
    grp = c(1, 1, 2, 2),
    x = c(0, 1, 0, 1),
    w = c(1, 3, 2, 2)
  )
  result <- calc_summarize(d, var = "x", wt_var = "w",
                           grp_cols = c("grp", "x"), metric = "mean")
  expect_equal(result$value[result$group_level == "1"], 3 / 4)
  expect_equal(result$value[result$group_level == "2"], 2 / 4)
})

test_that("calc_summarize computes weighted medians (national)", {
  d <- data.frame(
    x = c(1, 2, 3, 4),
    w = c(1, 1, 5, 1)
  )
  result <- calc_summarize(d, var = "x", wt_var = "w",
                           grp_cols = "x", metric = "median")
  expect_equal(result$value, 3)
})

test_that("calc_summarize drops rows with NA in any grouping column", {
  d <- data.frame(
    grp = c(1, 1, NA, 2),
    Q = c(1, 2, 1, 2),
    w = c(10, 20, 30, 40)
  )
  result <- calc_summarize(d, var = "Q", wt_var = "w",
                           grp_cols = c("grp", "Q"), metric = "proportion")
  expect_false(any(is.na(result$group_level)))
})

test_that("calc_summarize errors on unknown metric", {
  d <- data.frame(grp = 1, x = 1, w = 1)
  expect_error(
    calc_summarize(d, "x", "w", "grp", metric = "sum"),
    "must be one of"
  )
})
