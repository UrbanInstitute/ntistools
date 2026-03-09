test_that("label_likert maps 5-point scale to 3 labels", {
  d <- data.frame(q1 = c(1, 2, 3, 4, 5))
  result <- label_likert(d, "q1",
    labels = c("Decrease", "No change", "Increase")
  )
  expect_equal(result$q1, c("Decrease", "Decrease", "No change",
                            "Increase", "Increase"))
})

test_that("label_likert maps na_values to na_label", {
  d <- data.frame(q1 = c(3, 97, 5))
  result <- label_likert(d, "q1",
    labels = c("Decrease", "No change", "Increase")
  )
  expect_equal(result$q1, c("No change", "Unsure", "Increase"))
})

test_that("label_likert maps true NA to NA_character_", {
  d <- data.frame(q1 = c(1, NA, 5))
  result <- label_likert(d, "q1",
    labels = c("Decrease", "No change", "Increase")
  )
  expect_equal(result$q1, c("Decrease", NA_character_, "Increase"))
})

test_that("label_likert handles multiple columns", {
  d <- data.frame(a = c(1, 3, 5), b = c(2, 4, 97))
  result <- label_likert(d, c("a", "b"),
    labels = c("Low", "Mid", "High")
  )
  expect_equal(result$a, c("Low", "Mid", "High"))
  expect_equal(result$b, c("Low", "High", "Unsure"))
})

test_that("label_likert uses custom mapping", {
  d <- data.frame(q1 = c(1, 2, 3))
  result <- label_likert(d, "q1",
    labels = c("Bad", "Good"),
    mapping = c(1L, 2L, 2L),
    na_values = NULL
  )
  expect_equal(result$q1, c("Bad", "Good", "Good"))
})

test_that("label_likert uses custom na_label", {
  d <- data.frame(q1 = c(1, 97))
  result <- label_likert(d, "q1",
    labels = c("Decrease", "No change", "Increase"),
    na_label = "Not applicable"
  )
  expect_equal(result$q1, c("Decrease", "Not applicable"))
})
