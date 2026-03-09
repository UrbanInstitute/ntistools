#' Replace sentinel values with NA
#'
#' Replaces specified sentinel values (e.g., 98 for "don't know") with `NA`.
#'
#' @param data A data frame.
#' @param vars A character vector of column names.
#' @param values Numeric vector of sentinel values to replace with NA.
#'   Defaults to `98`.
#' @return `data` with sentinel values replaced by NA.
#' @export
#' @examples
#' d <- data.frame(x = c(1, 98, 3), y = c(98, 2, 98))
#' recode_sentinel(d, c("x", "y"), values = 98)
recode_sentinel <- function(data, vars, values = 98) {
  data <- dplyr::mutate(
    data,
    dplyr::across(
      dplyr::all_of(vars),
      ~ dplyr::if_else(. %in% values, NA, .)
    )
  )

  data
}
