#' Label binary columns with descriptive strings
#'
#' Converts 0/1 columns into character columns using named label pairs.
#' Values in `true_values` get the first label, values in `false_values` get
#' the second label, and everything else becomes `NA_character_`.
#'
#' @param data A data frame.
#' @param labels A named list where each element is a length-2 character vector
#'   `c("true label", "false label")`, keyed by column name.
#' @param true_values Numeric vector of values that map to the true (first)
#'   label. Defaults to `1`.
#' @param false_values Numeric vector of values that map to the false (second)
#'   label. Defaults to `0`.
#' @param na_values Optional numeric vector of additional values to map to the
#'   false label (e.g., `97` for "not applicable"). Defaults to `NULL`.
#' @return `data` with labeled columns.
#' @export
#' @examples
#' d <- data.frame(x = c(1, 0, NA, 97))
#' label_binary(d,
#'   labels = list(x = c("Yes", "No")),
#'   na_values = 97
#' )
label_binary <- function(data, labels, true_values = 1, false_values = 0,
                         na_values = NULL) {
  all_false <- c(false_values, na_values)

  for (col_name in names(labels)) {
    if (!col_name %in% names(data)) {
      rlang::warn(paste0("Column '", col_name, "' not found; skipping."))
      next
    }
    true_label <- labels[[col_name]][[1]]
    false_label <- labels[[col_name]][[2]]

    data <- dplyr::mutate(
      data,
      !!col_name := dplyr::case_when(
        .data[[col_name]] %in% true_values ~ true_label,
        .data[[col_name]] %in% all_false ~ false_label,
        .default = NA_character_
      )
    )
  }

  data
}
