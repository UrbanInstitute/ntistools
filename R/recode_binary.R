#' Collapse categories into 0/1
#'
#' Recodes a set of columns so that values in `ones` become 1, values in
#' `zeros` become 0, and values in `na_values` become NA.
#'
#' @param data A data frame.
#' @param vars A character vector of column names to recode.
#' @param ones Numeric vector of values to recode to 1.
#'   Defaults to `c(1, 2)`.
#' @param zeros Numeric vector of values to recode to 0.
#'   Defaults to `0`.
#' @param na_values Numeric vector of values to recode to NA.
#'   Defaults to `98`.
#' @return `data` with recoded columns.
#' @export
#' @examples
#' d <- data.frame(x = c(0, 1, 2, 98))
#' recode_binary(d, "x")
recode_binary <- function(data, vars, ones = c(1, 2), zeros = 0,
                          na_values = 98) {
  data <- dplyr::mutate(
    data,
    dplyr::across(
      dplyr::all_of(vars),
      ~ dplyr::case_when(
        . %in% ones ~ 1L,
        . %in% zeros ~ 0L,
        . %in% na_values ~ NA_integer_,
        .default = NA_integer_
      )
    )
  )

  data
}
