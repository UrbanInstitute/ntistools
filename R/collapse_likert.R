#' Collapse Likert scales
#'
#' Recodes Likert-scale values using a mapping vector. The i-th value in
#' `mapping` specifies what the original value i should become. Values in
#' `na_values` are set to NA.
#'
#' @param data A data frame.
#' @param vars A character vector of column names to recode.
#' @param mapping An integer vector where position i gives the new value for
#'   original value i. Defaults to `c(1, 1, 2, 3, 3)` which collapses a
#'   5-point Likert scale into 3 categories.
#' @param na_values Numeric vector of values to recode to NA.
#'   Defaults to `97`.
#' @return `data` with recoded columns.
#' @export
#' @examples
#' d <- data.frame(q1 = c(1, 2, 3, 4, 5, 97))
#' collapse_likert(d, "q1")
collapse_likert <- function(data, vars, mapping = c(1L, 1L, 2L, 3L, 3L),
                            na_values = 97) {
  # Build a named vector for case_match: original value -> new value
  match_from <- seq_along(mapping)
  match_to <- as.integer(mapping)

  data <- dplyr::mutate(
    data,
    dplyr::across(
      dplyr::all_of(vars),
      function(x) {
        result <- match_to[match(x, match_from)]
        result[x %in% na_values] <- NA_integer_
        result
      }
    )
  )

  data
}
