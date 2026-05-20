#' Run a bulk batch of weighted survey statistics
#'
#' Drives [survey_ci()], [survey_chisq()], [survey_ttest()], and
#' [survey_anova()] over one or more datasets and writes the results to CSV.
#' Each spec is a data frame describing the jobs for that analysis type;
#' results from all jobs of a given type are stacked into one CSV (or merged
#' into a single combined CSV if `combined = TRUE`).
#'
#' @param datasets Named list of data frames. Spec rows reference datasets by
#'   name via a `dataset` column.
#' @param ci_spec Optional data frame of CI jobs. Required columns: `dataset`,
#'   `variable`, `wt_var`. Optional: `group_var`.
#' @param chisq_spec Optional data frame of chi-square jobs. Required columns:
#'   `dataset`, `var1`, `var2`, `wt_var`.
#' @param ttest_spec Optional data frame of t-test jobs. Required columns:
#'   `dataset`, `outcome`, `group_var`, `wt_var`.
#' @param anova_spec Optional data frame of ANOVA jobs. Required columns:
#'   `dataset`, `outcome`, `group_var`, `wt_var`. Optional: `pairwise`
#'   (logical).
#' @param output_dir Directory to write CSVs to. If `NULL`, results are not
#'   written; only returned.
#' @param combined If `TRUE`, write a single `survey_stats.csv` with an
#'   `analysis` column instead of one CSV per analysis type. Pairwise ANOVA
#'   contrasts are always written separately when present.
#' @return A named list of result data frames (`ci`, `chisq`, `ttest`,
#'   `anova_overall`, optionally `anova_pairwise`). The same data is written to
#'   disk when `output_dir` is supplied.
#' @export
#' @examples
#' \dontrun{
#' run_survey_stats(
#'   datasets = list(y6 = nptrends_y6_clean),
#'   ci_spec = data.frame(
#'     dataset = "y6",
#'     variable = c("LLAnyDisruption", "LLLost"),
#'     wt_var = "weight_year6plus",
#'     group_var = "SizeStrata"
#'   ),
#'   chisq_spec = data.frame(
#'     dataset = "y6",
#'     var1 = "SizeStrata", var2 = "LLAnyDisruption",
#'     wt_var = "weight_year6plus"
#'   ),
#'   output_dir = "stats_out"
#' )
#' }
run_survey_stats <- function(datasets,
                             ci_spec = NULL,
                             chisq_spec = NULL,
                             ttest_spec = NULL,
                             anova_spec = NULL,
                             output_dir = NULL,
                             combined = FALSE) {
  if (!is.list(datasets) || is.null(names(datasets))) {
    stop("`datasets` must be a named list of data frames.", call. = FALSE)
  }

  get_data <- function(name) {
    if (!name %in% names(datasets)) {
      stop(sprintf("Dataset '%s' not found in `datasets`.", name), call. = FALSE)
    }
    datasets[[name]]
  }

  results <- list()

  if (!is.null(ci_spec)) {
    rows <- lapply(seq_len(nrow(ci_spec)), function(i) {
      r <- ci_spec[i, , drop = FALSE]
      out <- survey_ci(
        svy_df = get_data(r$dataset),
        vars = r$variable,
        wt_var = r$wt_var,
        group_var = if ("group_var" %in% names(r) && !is.na(r$group_var)) r$group_var else NULL
      )
      out$dataset <- r$dataset
      out
    })
    results$ci <- dplyr::bind_rows(rows)
  }

  if (!is.null(chisq_spec)) {
    rows <- lapply(seq_len(nrow(chisq_spec)), function(i) {
      r <- chisq_spec[i, , drop = FALSE]
      out <- survey_chisq(
        svy_df = get_data(r$dataset),
        var_pairs = data.frame(var1 = r$var1, var2 = r$var2,
                                stringsAsFactors = FALSE),
        wt_var = r$wt_var
      )
      out$dataset <- r$dataset
      out
    })
    results$chisq <- dplyr::bind_rows(rows)
  }

  if (!is.null(ttest_spec)) {
    rows <- lapply(seq_len(nrow(ttest_spec)), function(i) {
      r <- ttest_spec[i, , drop = FALSE]
      out <- survey_ttest(
        svy_df = get_data(r$dataset),
        outcomes = r$outcome,
        group_var = r$group_var,
        wt_var = r$wt_var
      )
      out$dataset <- r$dataset
      out
    })
    results$ttest <- dplyr::bind_rows(rows)
  }

  if (!is.null(anova_spec)) {
    overall_rows <- list()
    pairwise_rows <- list()
    for (i in seq_len(nrow(anova_spec))) {
      r <- anova_spec[i, , drop = FALSE]
      pw <- "pairwise" %in% names(r) && isTRUE(r$pairwise)
      res <- survey_anova(
        svy_df = get_data(r$dataset),
        outcomes = r$outcome,
        group_var = r$group_var,
        wt_var = r$wt_var,
        pairwise = pw
      )
      res$overall$dataset <- r$dataset
      overall_rows[[i]] <- res$overall
      if (pw && !is.null(res$pairwise)) {
        res$pairwise$dataset <- r$dataset
        pairwise_rows[[i]] <- res$pairwise
      }
    }
    results$anova_overall <- dplyr::bind_rows(overall_rows)
    if (length(pairwise_rows) > 0) {
      results$anova_pairwise <- dplyr::bind_rows(pairwise_rows)
    }
  }

  if (!is.null(output_dir)) {
    if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
    if (isTRUE(combined)) {
      tagged <- list()
      if (!is.null(results$ci)) {
        results$ci$analysis <- "ci"; tagged$ci <- results$ci
      }
      if (!is.null(results$chisq)) {
        results$chisq$analysis <- "chisq"; tagged$chisq <- results$chisq
      }
      if (!is.null(results$ttest)) {
        results$ttest$analysis <- "ttest"; tagged$ttest <- results$ttest
      }
      if (!is.null(results$anova_overall)) {
        results$anova_overall$analysis <- "anova"
        tagged$anova <- results$anova_overall
      }
      utils::write.csv(
        dplyr::bind_rows(tagged),
        file = file.path(output_dir, "survey_stats.csv"),
        row.names = FALSE
      )
      if (!is.null(results$anova_pairwise)) {
        utils::write.csv(
          results$anova_pairwise,
          file = file.path(output_dir, "anova_pairwise.csv"),
          row.names = FALSE
        )
      }
    } else {
      write_if <- function(df, name) {
        if (!is.null(df)) {
          utils::write.csv(
            df,
            file = file.path(output_dir, paste0(name, ".csv")),
            row.names = FALSE
          )
        }
      }
      write_if(results$ci, "ci")
      write_if(results$chisq, "chisq")
      write_if(results$ttest, "ttest")
      write_if(results$anova_overall, "anova_overall")
      write_if(results$anova_pairwise, "anova_pairwise")
    }
  }

  results
}
