skip_if_not_installed("survey")

test_that("survey_chisq returns one row per pair with expected columns", {
  set.seed(3)
  d <- data.frame(
    a = sample(c("x", "y", "z"), 200, replace = TRUE),
    b = sample(c(0, 1), 200, replace = TRUE),
    c = sample(c(0, 1), 200, replace = TRUE),
    w = runif(200, 0.5, 2)
  )
  pairs <- data.frame(var1 = c("a", "a"), var2 = c("b", "c"),
                      stringsAsFactors = FALSE)
  out <- survey_chisq(d, pairs, wt_var = "w")
  expect_equal(nrow(out), 2)
  expect_setequal(names(out),
                  c("var1", "var2", "statistic", "df", "p_value"))
  expect_true(all(out$p_value >= 0 & out$p_value <= 1))
})

test_that("survey_chisq errors on bad var_pairs", {
  expect_error(
    survey_chisq(data.frame(a = 1, w = 1),
                 var_pairs = data.frame(var1 = "a"), wt_var = "w"),
    "at least two columns"
  )
})
