#' Calculate weighted summary statistics
#'
#' Calculates weighted proportions, means, or medians for a variable, optionally
#' within levels of a grouping variable.
#'
#' @param svy_df A data frame containing the survey data.
#' @param var A string naming the variable to summarize.
#' @param wt_var A string naming the survey weight column (e.g., `"year5wt"`).
#' @param grp_cols Character vector of grouping columns. The first element is
#'   treated as the main grouping variable; the last as the subgroup. For a
#'   national (ungrouped) calculation, pass `var` as a length-1 vector
#'   (i.e., `grp_cols = var`).
#' @param metric One of `"proportion"`, `"mean"`, or `"median"`.
#' @return A tibble with columns `group`, `variable`, optionally
#'   `group_level` and `variable_level`, `count` (sum of weights), `value`
#'   (the calculated statistic), and `metric`.
#' @details Rows where any column in `grp_cols` is `NA` are dropped before
#'   summarising. The median branch uses an internal weighted-median helper to
#'   avoid taking on a `matrixStats` dependency.
#' @export
#' @examples
#' d <- data.frame(
#'   LLTwoDisruption = c(0, 1, 1, 0, 1, 0),
#'   LLLost = c(1, 0, 1, 0, 0, 1),
#'   year5wt = c(100, 150, 200, 100, 50, 150),
#'   Q_A = c(1, 2, 1, 2, 1, 2)
#' )
#' calc_summarize(d, var = "Q_A", wt_var = "year5wt",
#'                grp_cols = c("LLTwoDisruption", "Q_A"),
#'                metric = "proportion")
#' calc_summarize(d, var = "LLLost", wt_var = "year5wt",
#'                grp_cols = "LLTwoDisruption", metric = "mean")
calc_summarize <- function(svy_df, var, wt_var, grp_cols, metric) {
  group <- utils::head(grp_cols, -1)
  group_level <- grp_cols[1]

  svy_grouped_df <- svy_df %>%
    dplyr::filter(dplyr::if_all(dplyr::all_of(grp_cols), ~ !is.na(.)))

  if (metric == "proportion") {
    svy_summarized_df <- svy_grouped_df %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(grp_cols))) %>%
      dplyr::summarise(
        count = sum(.data[[wt_var]], na.rm = TRUE),
        .groups = "drop"
      ) %>%
      dplyr::group_by(!!!rlang::syms(group)) %>%
      dplyr::mutate(
        value = .data$count / sum(.data$count),
        variable = var,
        metric = metric
      ) %>%
      dplyr::rename(variable_level = !!rlang::sym(var)) %>%
      dplyr::mutate(variable_level = as.character(.data$variable_level))
  } else if (metric == "mean") {
    svy_summarized_df <- svy_grouped_df %>%
      dplyr::group_by(!!!rlang::syms(group)) %>%
      dplyr::summarise(
        count = sum(.data[[wt_var]], na.rm = TRUE),
        value = stats::weighted.mean(.data[[var]], .data[[wt_var]], na.rm = TRUE),
        .groups = "drop"
      ) %>%
      dplyr::mutate(variable = var, metric = metric)
  } else if (metric == "median") {
    svy_summarized_df <- svy_grouped_df %>%
      dplyr::group_by(!!!rlang::syms(group)) %>%
      dplyr::summarise(
        count = sum(.data[[wt_var]], na.rm = TRUE),
        value = weighted_median(.data[[var]], .data[[wt_var]], na.rm = TRUE),
        .groups = "drop"
      ) %>%
      dplyr::mutate(variable = var, metric = metric)
  } else {
    stop("`metric` must be one of 'proportion', 'mean', or 'median'.",
         call. = FALSE)
  }

  svy_summarized_df <- svy_summarized_df %>%
    dplyr::mutate(group = ifelse(length(group) == 0, "National", group))

  if (length(grp_cols) > 1) {
    svy_summarized_df <- svy_summarized_df %>%
      dplyr::rename(group_level = !!rlang::sym(group_level)) %>%
      dplyr::mutate(group_level = as.character(.data$group_level))
  }

  svy_summarized_df
}

# Weighted median using the standard linear-interpolation definition.
# Internal — not exported.
weighted_median <- function(x, w, na.rm = FALSE) {
  if (length(x) != length(w)) {
    stop("`x` and `w` must have the same length.", call. = FALSE)
  }
  if (isTRUE(na.rm)) {
    keep <- !is.na(x) & !is.na(w)
    x <- x[keep]
    w <- w[keep]
  }
  if (length(x) == 0 || sum(w) == 0) return(NA_real_)
  if (any(w < 0)) stop("Negative weights are not allowed.", call. = FALSE)

  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cw <- cumsum(w) / sum(w)
  # Smallest x whose cumulative weight reaches 0.5.
  x[which(cw >= 0.5)[1]]
}
