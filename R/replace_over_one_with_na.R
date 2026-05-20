#' Replace values greater than 1 with NA
#'
#' Replaces values greater than 1 in the specified columns with `NA`. Useful
#' for cleaning proportion-style columns that should be bounded at 1.
#'
#' @param data A data frame.
#' @param vars A character vector of column names.
#' @return `data` with values > 1 in `vars` replaced by NA.
#' @export
#' @examples
#' d <- data.frame(
#'   A = c(0.5, 1.2, 0.9, 2.1),
#'   B = c(1, 1.5, 0.8, 0.4)
#' )
#' replace_over_one_with_na(d, c("A", "B"))
replace_over_one_with_na <- function(data, vars) {
  dplyr::mutate(
    data,
    dplyr::across(
      dplyr::all_of(vars),
      ~ dplyr::if_else(. > 1, NA_real_, .)
    )
  )
}
