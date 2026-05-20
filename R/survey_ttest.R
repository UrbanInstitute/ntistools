#' Weighted t-tests across multiple outcomes
#'
#' Runs `survey::svyttest()` for each outcome against a single binary grouping
#' variable, returning a tidy stacked tibble.
#'
#' Requires the `survey` package to be installed.
#'
#' @param svy_df A data frame containing the survey data.
#' @param outcomes Character vector of outcome variables.
#' @param group_var A string naming the (binary) grouping variable.
#' @param wt_var A string naming the survey weight column.
#' @return A data frame with one row per outcome: `outcome`, `group_var`,
#'   `estimate` (mean difference), `statistic` (t), `df`, `p_value`,
#'   `ci_lower`, `ci_upper`.
#' @export
#' @examples
#' \dontrun{
#' survey_ttest(nptrends_y6_clean,
#'              outcomes = c("LLLostAmt", "LLDelayWeeks1to6Median"),
#'              group_var = "census_urban_area",
#'              wt_var = "weight_year6plus")
#' }
survey_ttest <- function(svy_df, outcomes, group_var, wt_var) {
  design <- build_svydesign(svy_df, wt_var)

  out <- lapply(outcomes, function(o) {
    f <- stats::as.formula(paste0(o, " ~ ", group_var))
    res <- survey::svyttest(f, design)
    data.frame(
      outcome = o,
      group_var = group_var,
      estimate = unname(res$estimate),
      statistic = unname(res$statistic),
      df = unname(res$parameter),
      p_value = unname(res$p.value),
      ci_lower = res$conf.int[1],
      ci_upper = res$conf.int[2],
      stringsAsFactors = FALSE
    )
  })

  dplyr::bind_rows(out)
}
