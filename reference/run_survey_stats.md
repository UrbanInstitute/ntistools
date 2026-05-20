# Run a bulk batch of weighted survey statistics

Drives
[`survey_ci()`](https://urbaninstitute.github.io/ntistools/reference/survey_ci.md),
[`survey_chisq()`](https://urbaninstitute.github.io/ntistools/reference/survey_chisq.md),
[`survey_ttest()`](https://urbaninstitute.github.io/ntistools/reference/survey_ttest.md),
and
[`survey_anova()`](https://urbaninstitute.github.io/ntistools/reference/survey_anova.md)
over one or more datasets and writes the results to CSV. Each spec is a
data frame describing the jobs for that analysis type; results from all
jobs of a given type are stacked into one CSV (or merged into a single
combined CSV if `combined = TRUE`).

## Usage

``` r
run_survey_stats(
  datasets,
  ci_spec = NULL,
  chisq_spec = NULL,
  ttest_spec = NULL,
  anova_spec = NULL,
  output_dir = NULL,
  combined = FALSE
)
```

## Arguments

- datasets:

  Named list of data frames. Spec rows reference datasets by name via a
  `dataset` column.

- ci_spec:

  Optional data frame of CI jobs. Required columns: `dataset`,
  `variable`, `wt_var`. Optional: `group_var`.

- chisq_spec:

  Optional data frame of chi-square jobs. Required columns: `dataset`,
  `var1`, `var2`, `wt_var`.

- ttest_spec:

  Optional data frame of t-test jobs. Required columns: `dataset`,
  `outcome`, `group_var`, `wt_var`.

- anova_spec:

  Optional data frame of ANOVA jobs. Required columns: `dataset`,
  `outcome`, `group_var`, `wt_var`. Optional: `pairwise` (logical).

- output_dir:

  Directory to write CSVs to. If `NULL`, results are not written; only
  returned.

- combined:

  If `TRUE`, write a single `survey_stats.csv` with an `analysis` column
  instead of one CSV per analysis type. Pairwise ANOVA contrasts are
  always written separately when present.

## Value

A named list of result data frames (`ci`, `chisq`, `ttest`,
`anova_overall`, optionally `anova_pairwise`). The same data is written
to disk when `output_dir` is supplied.

## Examples

``` r
if (FALSE) { # \dontrun{
run_survey_stats(
  datasets = list(y6 = nptrends_y6_clean),
  ci_spec = data.frame(
    dataset = "y6",
    variable = c("LLAnyDisruption", "LLLost"),
    wt_var = "weight_year6plus",
    group_var = "SizeStrata"
  ),
  chisq_spec = data.frame(
    dataset = "y6",
    var1 = "SizeStrata", var2 = "LLAnyDisruption",
    wt_var = "weight_year6plus"
  ),
  output_dir = "stats_out"
)
} # }
```
