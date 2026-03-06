#' Replace NA with a value when a flag column indicates the skip is valid
#'
#' For each variable in `vars`, looks for a corresponding flag column named
#' `{var}{flag_suffix}`. Where the original variable is NA and the flag equals
#' 1, the value is replaced with `impute_value` (default 0).
#'
#' @param data A data frame.
#' @param vars A character vector of column names to impute.
#' @param flag_suffix String appended to each variable name to find the flag
#'   column. Defaults to `"_NA_X"`.
#' @param impute_value Value to impute when the flag is 1 and the variable is
#'   NA. Defaults to `0`.
#' @return `data` with imputed values.
#' @export
#' @examples
#' d <- data.frame(x = c(1, NA, 3), x_NA_X = c(0, 1, 0))
#' impute_from_flag(d, "x")
impute_from_flag <- function(data, vars, flag_suffix = "_NA_X",
                             impute_value = 0) {
  for (v in vars) {
    flag_col <- paste0(v, flag_suffix)
    if (!flag_col %in% names(data)) {
      rlang::warn(paste0("Flag column '", flag_col, "' not found; skipping '", v, "'."))
      next
    }
    data <- dplyr::mutate(
      data,
      !!v := dplyr::case_when(
        is.na(.data[[v]]) & .data[[flag_col]] == 1 ~ impute_value,
        .default = .data[[v]]
      )
    )
  }

  data
}
