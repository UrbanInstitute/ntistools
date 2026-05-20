#' Weighted ANOVA across multiple outcomes
#'
#' Fits `survey::svyglm()` for each outcome against a categorical grouping
#' variable and runs `survey::regTermTest()`. Optionally returns pairwise
#' contrasts via `emmeans`.
#'
#' Requires the `survey` package. Pairwise contrasts also require `emmeans`.
#'
#' @param svy_df A data frame containing the survey data.
#' @param outcomes Character vector of (continuous) outcome variables.
#' @param group_var A string naming the categorical grouping variable. Will be
#'   coerced to factor.
#' @param wt_var A string naming the survey weight column.
#' @param pairwise If `TRUE`, also return pairwise contrasts from
#'   `emmeans::emmeans()`.
#' @param adjust Multiple-comparison adjustment for pairwise contrasts. See
#'   `?emmeans::summary.emmGrid`.
#' @return A list with element `overall` (one row per outcome: `outcome`,
#'   `group_var`, `statistic`, `df_num`, `df_den`, `p_value`) and, if
#'   `pairwise = TRUE`, element `pairwise` (one row per contrast: `outcome`,
#'   `contrast`, `estimate`, `se`, `df`, `t_ratio`, `p_value`).
#' @export
#' @examples
#' \dontrun{
#' survey_anova(nptrends_y6_clean,
#'              outcomes = "LLLostAmt",
#'              group_var = "SizeStrata",
#'              wt_var = "weight_year6plus",
#'              pairwise = TRUE)
#' }
survey_anova <- function(svy_df, outcomes, group_var, wt_var,
                         pairwise = FALSE, adjust = "bonferroni") {
  if (isTRUE(pairwise)) require_pkg("emmeans")
  svy_df[[group_var]] <- as.factor(svy_df[[group_var]])
  design <- build_svydesign(svy_df, wt_var)

  overall_rows <- list()
  pairwise_rows <- list()

  for (o in outcomes) {
    f <- stats::as.formula(paste0(o, " ~ ", group_var))
    model <- survey::svyglm(f, design = design)
    test <- survey::regTermTest(model, stats::as.formula(paste0("~", group_var)))
    overall_rows[[o]] <- data.frame(
      outcome = o,
      group_var = group_var,
      statistic = unname(test$Ftest),
      df_num = unname(test$df),
      df_den = unname(test$ddf),
      p_value = unname(test$p),
      stringsAsFactors = FALSE
    )

    if (isTRUE(pairwise)) {
      emm <- emmeans::emmeans(model, stats::as.formula(paste0("~", group_var)))
      pr <- as.data.frame(
        emmeans::contrast(emm, method = "pairwise", adjust = adjust)
      )
      pr$outcome <- o
      names(pr)[names(pr) == "SE"] <- "se"
      names(pr)[names(pr) == "t.ratio"] <- "t_ratio"
      names(pr)[names(pr) == "p.value"] <- "p_value"
      pairwise_rows[[o]] <- pr[, c("outcome", "contrast", "estimate", "se",
                                    "df", "t_ratio", "p_value")]
    }
  }

  result <- list(overall = dplyr::bind_rows(overall_rows))
  if (isTRUE(pairwise)) {
    result$pairwise <- dplyr::bind_rows(pairwise_rows)
  }
  result
}
