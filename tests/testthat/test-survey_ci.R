skip_if_not_installed("srvyr")

test_that("survey_ci returns expected columns and rows", {
  set.seed(1)
  d <- data.frame(
    x = rbinom(200, 1, 0.4),
    y = rbinom(200, 1, 0.6),
    grp = sample(c("a", "b"), 200, replace = TRUE),
    w = runif(200, 0.5, 2)
  )
  out <- survey_ci(d, vars = c("x", "y"), wt_var = "w")
  expect_setequal(out$variable, c("x", "y"))
  expect_true(all(c("estimate", "ci_lower", "ci_upper") %in% names(out)))
  expect_true(all(out$ci_lower <= out$estimate))
  expect_true(all(out$estimate <= out$ci_upper))
})

test_that("survey_ci supports a grouping variable", {
  set.seed(2)
  d <- data.frame(
    x = rbinom(200, 1, 0.4),
    grp = sample(c("a", "b"), 200, replace = TRUE),
    w = runif(200, 0.5, 2)
  )
  out <- survey_ci(d, vars = "x", wt_var = "w", group_var = "grp")
  expect_true("group_level" %in% names(out))
  expect_setequal(out$group_level, c("a", "b"))
  expect_equal(unique(out$group_var), "grp")
})
