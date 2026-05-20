#' Run `calc_summarize()` across many variables and bind the results
#'
#' Replaces the common `purrr::map2() |> list_rbind()` pattern of running
#' [calc_summarize()] over a named list of `variable = metric` pairs, optionally
#' within a single grouping variable.
#'
#' @param svy_df A data frame containing the survey data.
#' @param vars A named character vector or named list mapping variable names to
#'   metrics (one of `"proportion"`, `"mean"`, `"median"`). Names are the
#'   variables; values are the metrics.
#' @param wt_var A string naming the survey weight column.
#' @param group_var Optional string naming a grouping variable. If `NULL`
#'   (default), runs a national-style (ungrouped) summary per variable.
#' @return A tibble of stacked [calc_summarize()] results.
#' @export
#' @examples
#' d <- data.frame(
#'   SizeStrata = c(1, 1, 2, 2, 3, 3),
#'   LLLost = c(1, 0, 1, 0, 1, 1),
#'   LLDelay = c(0, 1, 1, 0, 1, 0),
#'   weight = c(100, 150, 200, 100, 50, 150)
#' )
#' summarize_by_groups(
#'   d,
#'   vars = c(LLLost = "proportion", LLDelay = "proportion"),
#'   wt_var = "weight",
#'   group_var = "SizeStrata"
#' )
summarize_by_groups <- function(svy_df, vars, wt_var, group_var = NULL) {
  if (is.null(names(vars)) || any(names(vars) == "")) {
    stop("`vars` must be a named vector or list (variable = metric).",
         call. = FALSE)
  }

  var_names <- names(vars)
  metrics <- unlist(vars, use.names = FALSE)

  results <- Map(
    function(v, m) {
      grp_cols <- if (is.null(group_var)) v else c(group_var, v)
      calc_summarize(
        svy_df = svy_df,
        var = v,
        wt_var = wt_var,
        grp_cols = grp_cols,
        metric = m
      )
    },
    var_names,
    metrics
  )

  dplyr::bind_rows(results)
}
