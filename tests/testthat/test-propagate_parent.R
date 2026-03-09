test_that("propagate_parent pushes parent values to children", {
  d <- data.frame(
    parent = c(0, 1, 97, 1),
    child1 = c(NA, 1, NA, 0),
    child2 = c(NA, 0, 1, 1)
  )
  result <- propagate_parent(d, c("child1", "child2"),
                             parent_var = "parent", values = c(0, 97))
  expect_equal(result$child1, c(0, 1, 97, 0))
  expect_equal(result$child2, c(0, 0, 97, 1))
})

test_that("propagate_parent leaves children alone when parent is not in values", {
  d <- data.frame(parent = c(1, 2), child = c(5, 6))
  result <- propagate_parent(d, "child", parent_var = "parent")
  expect_equal(result$child, c(5, 6))
})

test_that("propagate_parent works with single value", {
  d <- data.frame(p = c(0, 1), c1 = c(NA, 3))
  result <- propagate_parent(d, "c1", parent_var = "p", values = 0)
  expect_equal(result$c1, c(0, 3))
})
