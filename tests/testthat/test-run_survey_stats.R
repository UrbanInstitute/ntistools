skip_if_not_installed("survey")
skip_if_not_installed("srvyr")

test_that("run_survey_stats returns expected list pieces and writes CSVs", {
  set.seed(7)
  d <- data.frame(
    x = rbinom(200, 1, 0.4),
    grp = sample(c("a", "b"), 200, replace = TRUE),
    pair_a = sample(c(0, 1), 200, replace = TRUE),
    pair_b = sample(c(0, 1), 200, replace = TRUE),
    w = runif(200, 0.5, 2)
  )
  out_dir <- tempfile("stats_")
  results <- run_survey_stats(
    datasets = list(d = d),
    ci_spec = data.frame(dataset = "d", variable = "x", wt_var = "w",
                          group_var = "grp", stringsAsFactors = FALSE),
    chisq_spec = data.frame(dataset = "d", var1 = "pair_a", var2 = "pair_b",
                             wt_var = "w", stringsAsFactors = FALSE),
    output_dir = out_dir
  )
  expect_true(!is.null(results$ci))
  expect_true(!is.null(results$chisq))
  expect_true(file.exists(file.path(out_dir, "ci.csv")))
  expect_true(file.exists(file.path(out_dir, "chisq.csv")))
})

test_that("run_survey_stats combined mode writes a single CSV", {
  set.seed(8)
  d <- data.frame(
    x = rbinom(200, 1, 0.4),
    w = runif(200, 0.5, 2)
  )
  out_dir <- tempfile("stats_")
  run_survey_stats(
    datasets = list(d = d),
    ci_spec = data.frame(dataset = "d", variable = "x", wt_var = "w",
                          stringsAsFactors = FALSE),
    output_dir = out_dir,
    combined = TRUE
  )
  expect_true(file.exists(file.path(out_dir, "survey_stats.csv")))
})

test_that("run_survey_stats errors when spec references unknown dataset", {
  expect_error(
    run_survey_stats(
      datasets = list(d = data.frame(x = 1, w = 1)),
      ci_spec = data.frame(dataset = "missing", variable = "x", wt_var = "w",
                            stringsAsFactors = FALSE)
    ),
    "not found"
  )
})
