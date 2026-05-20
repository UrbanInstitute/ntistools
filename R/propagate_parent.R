#' Push parent variable's special values to child columns
#'
#' When a parent variable has one of the specified values (e.g., 0 or 97), set
#' that same value in all child columns. This is useful when a parent question
#' gates a set of follow-up questions.
#'
#' @param data A data frame.
#' @param vars A character vector of child column names.
#' @param parent_var A string giving the name of the parent column.
#' @param values Numeric vector of parent values to propagate to children.
#'   Defaults to `c(0, 97)`.
#' @return `data` with child columns updated.
#' @export
#' @examples
#' d <- data.frame(parent = c(0, 1, 97, 1), child1 = c(NA, 1, NA, 0))
#' propagate_parent(d, "child1", parent_var = "parent", values = c(0, 97))
propagate_parent <- function(data, vars, parent_var, values = c(0, 97)) {
  data <- dplyr::mutate(
    data,
    dplyr::across(
      dplyr::all_of(vars),
      ~ dplyr::case_when(
        .data[[parent_var]] %in% values ~ .data[[parent_var]],
        .default = .
      )
    )
  )

  data
}
