#' Label Likert-scale columns with descriptive strings
#'
#' Maps numeric Likert-scale values to descriptive labels using the same
#' `mapping` vector approach as [collapse_likert()], then indexes into `labels`
#' to produce character output. Values in `na_values` are mapped to `na_label`
#' instead of `NA`.
#'
#' @param data A data frame.
#' @param vars A character vector of column names to label.
#' @param labels A character vector of labels, one per collapsed category.
#'   Length must equal `max(mapping)`. For example,
#'   `c("Decrease", "No change", "Increase")`.
#' @param mapping An integer vector where position i gives the collapsed
#'   category for original value i. Defaults to `c(1L, 1L, 2L, 3L, 3L)`.
#' @param na_values Numeric vector of values to map to `na_label`.
#'   Defaults to `97`.
#' @param na_label Character string used for values in `na_values`.
#'   Defaults to `"Unsure"`.
#' @return `data` with labeled columns.
#' @export
#' @examples
#' d <- data.frame(q1 = c(1, 2, 3, 4, 5, 97))
#' label_likert(d, "q1",
#'   labels = c("Decrease", "No change", "Increase")
#' )
label_likert <- function(data, vars, labels,
                         mapping = c(1L, 1L, 2L, 3L, 3L),
                         na_values = 97, na_label = "Unsure") {
  match_from <- seq_along(mapping)
  match_to <- as.integer(mapping)

  data <- dplyr::mutate(
    data,
    dplyr::across(
      dplyr::all_of(vars),
      function(x) {
        idx <- match_to[match(x, match_from)]
        result <- labels[idx]
        result[x %in% na_values] <- na_label
        result
      }
    )
  )

  data
}
