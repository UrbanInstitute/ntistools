#' Weighted confidence intervals for survey variables
#'
#' Computes weighted means with confidence intervals for one or more variables,
#' optionally within levels of a grouping variable. A thin wrapper around
#' `srvyr::survey_mean(vartype = "ci")` that returns a tidy stacked tibble.
#'
#' Requires the `srvyr` package to be installed.
#'
#' @param svy_df A data frame containing the survey data.
#' @param vars Character vector of variables to estimate.
#' @param wt_var A string naming the survey weight column.
#' @param group_var Optional string naming a grouping variable.
#' @param level Confidence level (default `0.95`).
#' @return A data frame with columns `variable`, optional `group_level`,
#'   `estimate`, `ci_lower`, `ci_upper`.
#' @export
#' @examples
#' \dontrun{
#' survey_ci(nptrends_y6_clean,
#'           vars = c("LLAnyDisruption", "LLLost"),
#'           wt_var = "weight_year6plus",
#'           group_var = "SizeStrata")
#' }
survey_ci <- function(svy_df, vars, wt_var, group_var = NULL, level = 0.95) {
  require_pkg("srvyr")

  design <- srvyr::as_survey_design(
    svy_df,
    weights = !!rlang::sym(wt_var)
  )

  results <- lapply(vars, function(v) {
    d <- design
    if (!is.null(group_var)) {
      d <- srvyr::group_by(d, !!rlang::sym(group_var))
    }
    out <- srvyr::summarise(
      d,
      estimate = srvyr::survey_mean(
        !!rlang::sym(v),
        vartype = "ci",
        level = level,
        na.rm = TRUE
      )
    )
    out$variable <- v
    if (!is.null(group_var)) {
      names(out)[names(out) == group_var] <- "group_level"
      out$group_level <- as.character(out$group_level)
      out$group_var <- group_var
    }
    names(out)[names(out) == "estimate_low"] <- "ci_lower"
    names(out)[names(out) == "estimate_upp"] <- "ci_upper"
    out
  })

  dplyr::bind_rows(results)
}
