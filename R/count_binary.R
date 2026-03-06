#' Count how many binary indicators are active
#'
#' Creates `{prefix}_any` (1 if any are 1), `{prefix}_count` (number of 1s),
#' and `{prefix}_all` (1 if all are 1) from a set of binary columns. All three
#' are NA when every source column is NA.
#'
#' @param data A data frame.
#' @param prefix A string used to name the output columns.
#' @param ... Unquoted names of binary (0/1) columns.
#' @return `data` with three new columns added.
#' @export
#' @examples
#' d <- data.frame(x = c(1, 0, NA), y = c(1, 1, NA), z = c(0, 1, NA))
#' count_binary(d, "xyz", x, y, z)
count_binary <- function(data, prefix, ...) {
  cols <- rlang::enquos(...)
  any_name <- paste0(prefix, "_any")
  count_name <- paste0(prefix, "_count")
  all_name <- paste0(prefix, "_all")

  data <- dplyr::mutate(
    data,
    !!any_name := {
      mat <- dplyr::across(c(!!!cols))
      all_na <- rowSums(is.na(mat)) == ncol(mat)
      dplyr::if_else(all_na, NA_integer_,
                     as.integer(rowSums(mat == 1, na.rm = TRUE) > 0))
    },
    !!count_name := {
      mat <- dplyr::across(c(!!!cols))
      all_na <- rowSums(is.na(mat)) == ncol(mat)
      dplyr::if_else(all_na, NA_integer_,
                     as.integer(rowSums(mat == 1, na.rm = TRUE)))
    },
    !!all_name := {
      mat <- dplyr::across(c(!!!cols))
      all_na <- rowSums(is.na(mat)) == ncol(mat)
      n_ones <- rowSums(mat == 1, na.rm = TRUE)
      dplyr::if_else(all_na, NA_integer_,
                     as.integer(n_ones == ncol(mat)))
    }
  )

  data
}
