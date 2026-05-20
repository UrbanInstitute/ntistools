skip_if_not_installed("survey")

test_that("survey_ttest returns one row per outcome with expected columns", {
  set.seed(4)
  d <- data.frame(
    y1 = rnorm(200),
    y2 = rnorm(200, mean = 0.5),
    grp = sample(c(0, 1), 200, replace = TRUE),
    w = runif(200, 0.5, 2)
  )
  out <- survey_ttest(d, outcomes = c("y1", "y2"),
                     group_var = "grp", wt_var = "w")
  expect_equal(nrow(out), 2)
  expect_setequal(
    names(out),
    c("outcome", "group_var", "estimate", "statistic", "df", "p_value",
      "ci_lower", "ci_upper")
  )
  expect_true(all(out$ci_lower <= out$estimate))
  expect_true(all(out$estimate <= out$ci_upper))
})
