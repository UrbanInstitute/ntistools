skip_if_not_installed("survey")

test_that("survey_anova returns an `overall` table with expected columns", {
  set.seed(5)
  d <- data.frame(
    y = rnorm(300),
    grp = sample(c("a", "b", "c"), 300, replace = TRUE),
    w = runif(300, 0.5, 2)
  )
  res <- survey_anova(d, outcomes = "y", group_var = "grp", wt_var = "w")
  expect_named(res, "overall")
  expect_setequal(
    names(res$overall),
    c("outcome", "group_var", "statistic", "df_num", "df_den", "p_value")
  )
})

test_that("survey_anova returns pairwise contrasts when requested", {
  skip_if_not_installed("emmeans")
  set.seed(6)
  d <- data.frame(
    y = c(rnorm(100), rnorm(100, mean = 1), rnorm(100, mean = 2)),
    grp = rep(c("a", "b", "c"), each = 100),
    w = runif(300, 0.5, 2)
  )
  res <- survey_anova(d, outcomes = "y", group_var = "grp", wt_var = "w",
                     pairwise = TRUE)
  expect_true(!is.null(res$pairwise))
  expect_setequal(
    names(res$pairwise),
    c("outcome", "contrast", "estimate", "se", "df", "t_ratio", "p_value")
  )
  expect_equal(nrow(res$pairwise), 3)  # a-b, a-c, b-c
})
