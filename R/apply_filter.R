#' Conditionally set variables to NA when a condition is not met
#'
#' For each variable in `vars`, values are kept as-is when `condition` is TRUE
#' and set to NA otherwise. This is useful for filtering out responses from
#' organizations that should not answer certain questions.
#'
#' @param data A data frame.
#' @param vars A character vector of column names to filter.
#' @param condition An unquoted expression that evaluates to a logical vector.
#'   Rows where this is TRUE keep their values; all other rows get NA.
#' @return `data` with filtered columns.
#' @export
#' @examples
#' d <- data.frame(keep = c(1, 0, 1), x = c(10, 20, 30))
#' apply_filter(d, "x", condition = keep == 1)
apply_filter <- function(data, vars, condition) {
  cond <- rlang::enquo(condition)

  data <- dplyr::mutate(
    data,
    dplyr::across(
      dplyr::all_of(vars),
      ~ dplyr::if_else(!!cond, ., NA)
    )
  )

  data
}
