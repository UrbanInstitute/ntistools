test_that("label_binary maps 1 to true label and 0 to false label", {
  d <- data.frame(x = c(1, 0, 1, 0))
  result <- label_binary(d, labels = list(x = c("Yes", "No")))
  expect_equal(result$x, c("Yes", "No", "Yes", "No"))
})

test_that("label_binary maps NA input to NA_character_", {
  d <- data.frame(x = c(1, NA, 0))
  result <- label_binary(d, labels = list(x = c("Yes", "No")))
  expect_equal(result$x, c("Yes", NA_character_, "No"))
})

test_that("label_binary maps na_values to false label", {
  d <- data.frame(x = c(1, 0, 97))
  result <- label_binary(d,
    labels = list(x = c("Did it", "Did not do it")),
    na_values = 97
  )
  expect_equal(result$x, c("Did it", "Did not do it", "Did not do it"))
})

test_that("label_binary handles multiple columns", {
  d <- data.frame(a = c(1, 0), b = c(0, 1))
  result <- label_binary(d, labels = list(
    a = c("A yes", "A no"),
    b = c("B yes", "B no")
  ))
  expect_equal(result$a, c("A yes", "A no"))
  expect_equal(result$b, c("B no", "B yes"))
})

test_that("label_binary warns when column not found", {
  d <- data.frame(x = c(1, 0))
  expect_warning(
    label_binary(d, labels = list(missing = c("Yes", "No"))),
    "not found"
  )
})

test_that("label_binary respects custom true_values and false_values", {
  d <- data.frame(x = c(1, 2, 3, 4))
  result <- label_binary(d,
    labels = list(x = c("High", "Low")),
    true_values = c(1, 2),
    false_values = c(3, 4)
  )
  expect_equal(result$x, c("High", "High", "Low", "Low"))
})
