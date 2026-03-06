#' Combine binary indicators with OR logic
#'
#' Given several 0/1 columns, create a new column that is 1 if *any* source
#' column is 1, NA if *all* source columns are NA, and 0 otherwise.
#'
#' @param data A data frame.
#' @param new_col Unquoted name for the new column.
#' @param ... Unquoted names of binary (0/1) columns to combine.
#' @return `data` with the new column added.
#' @export
#' @examples
#' d <- data.frame(a = c(0, 1, NA, 0), b = c(0, 0, NA, 1))
#' combine_binary(d, ab, a, b)
combine_binary <- function(data, new_col, ...) {
  cols <- rlang::enquos(...)
  new_col <- rlang::enquo(new_col)

  data <- dplyr::mutate(
    data,
    !!new_col := {
      mat <- dplyr::across(c(!!!cols))
      dplyr::case_when(
        rowSums(mat == 1, na.rm = TRUE) > 0 ~ 1L,
        rowSums(is.na(mat)) == ncol(mat) ~ NA_integer_,
        .default = 0L
      )
    }
  )

  data
}
