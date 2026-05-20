# Run `calc_summarize()` across many variables and bind the results

Replaces the common `purrr::map2() |> list_rbind()` pattern of running
[`calc_summarize()`](https://urbaninstitute.github.io/ntistools/reference/calc_summarize.md)
over a named list of `variable = metric` pairs, optionally within a
single grouping variable.

## Usage

``` r
summarize_by_groups(svy_df, vars, wt_var, group_var = NULL)
```

## Arguments

- svy_df:

  A data frame containing the survey data.

- vars:

  A named character vector or named list mapping variable names to
  metrics (one of `"proportion"`, `"mean"`, `"median"`). Names are the
  variables; values are the metrics.

- wt_var:

  A string naming the survey weight column.

- group_var:

  Optional string naming a grouping variable. If `NULL` (default), runs
  a national-style (ungrouped) summary per variable.

## Value

A tibble of stacked
[`calc_summarize()`](https://urbaninstitute.github.io/ntistools/reference/calc_summarize.md)
results.

## Examples

``` r
d <- data.frame(
  SizeStrata = c(1, 1, 2, 2, 3, 3),
  LLLost = c(1, 0, 1, 0, 1, 1),
  LLDelay = c(0, 1, 1, 0, 1, 0),
  weight = c(100, 150, 200, 100, 50, 150)
)
summarize_by_groups(
  d,
  vars = c(LLLost = "proportion", LLDelay = "proportion"),
  wt_var = "weight",
  group_var = "SizeStrata"
)
#> Error in svy_df %>% dplyr::filter(dplyr::if_all(dplyr::all_of(grp_cols),     ~!is.na(.))): could not find function "%>%"
```
