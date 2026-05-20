#' Weighted chi-square tests for variable pairs
#'
#' Runs `survey::svychisq()` over pairs of categorical variables and returns a
#' tidy stacked tibble of test statistics.
#'
#' Requires the `survey` package to be installed.
#'
#' @param svy_df A data frame containing the survey data.
#' @param var_pairs A data frame with two columns naming the variable pairs to
#'   test (e.g., `data.frame(var1 = c("SizeStrata"), var2 = c("LLLost"))`).
#' @param wt_var A string naming the survey weight column.
#' @return A data frame with columns `var1`, `var2`, `statistic`, `df`,
#'   `p_value`.
#' @export
#' @examples
#' \dontrun{
#' pairs <- data.frame(
#'   var1 = c("SizeStrata", "ntmaj12"),
#'   var2 = c("LLAnyDisruption", "LLAnyDisruption")
#' )
#' survey_chisq(nptrends_y6_clean, pairs, wt_var = "weight_year6plus")
#' }
survey_chisq <- function(svy_df, var_pairs, wt_var) {
  if (ncol(var_pairs) < 2) {
    stop("`var_pairs` must have at least two columns (variable pairs).",
         call. = FALSE)
  }
  design <- build_svydesign(svy_df, wt_var)

  out <- lapply(seq_len(nrow(var_pairs)), function(i) {
    v1 <- as.character(var_pairs[[1]][i])
    v2 <- as.character(var_pairs[[2]][i])
    f <- stats::as.formula(paste0("~", v1, " + ", v2))
    res <- survey::svychisq(f, design)
    data.frame(
      var1 = v1,
      var2 = v2,
      statistic = unname(res$statistic),
      df = unname(res$parameter[1]),
      p_value = unname(res$p.value),
      stringsAsFactors = FALSE
    )
  })

  dplyr::bind_rows(out)
}
