test_that("summarize_by_groups runs calc_summarize across vars and binds rows", {
  d <- data.frame(
    SizeStrata = c(1, 1, 2, 2),
    LLLost = c(1, 0, 1, 0),
    LLDelay = c(0, 1, 1, 0),
    w = c(10, 10, 10, 10)
  )
  result <- summarize_by_groups(
    d,
    vars = c(LLLost = "proportion", LLDelay = "proportion"),
    wt_var = "w",
    group_var = "SizeStrata"
  )
  expect_setequal(unique(result$variable), c("LLLost", "LLDelay"))
  expect_true(all(c("group_level", "variable_level") %in% names(result)))
})

test_that("summarize_by_groups handles national (ungrouped) calls", {
  d <- data.frame(
    LLLost = c(1, 0, 1, 0),
    w = c(10, 10, 10, 10)
  )
  result <- summarize_by_groups(
    d,
    vars = c(LLLost = "proportion"),
    wt_var = "w"
  )
  expect_true("National" %in% result$group)
})

test_that("summarize_by_groups errors on unnamed `vars`", {
  expect_error(
    summarize_by_groups(data.frame(x = 1), vars = c("proportion"),
                        wt_var = "w"),
    "must be a named"
  )
})
