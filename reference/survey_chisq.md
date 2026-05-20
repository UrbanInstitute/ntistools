# Weighted chi-square tests for variable pairs

Runs
[`survey::svychisq()`](https://rdrr.io/pkg/survey/man/svychisq.html)
over pairs of categorical variables and returns a tidy stacked tibble of
test statistics.

## Usage

``` r
survey_chisq(svy_df, var_pairs, wt_var)
```

## Arguments

- svy_df:

  A data frame containing the survey data.

- var_pairs:

  A data frame with two columns naming the variable pairs to test (e.g.,
  `data.frame(var1 = c("SizeStrata"), var2 = c("LLLost"))`).

- wt_var:

  A string naming the survey weight column.

## Value

A data frame with columns `var1`, `var2`, `statistic`, `df`, `p_value`.

## Details

Requires the `survey` package to be installed.

## Examples

``` r
if (FALSE) { # \dontrun{
pairs <- data.frame(
  var1 = c("SizeStrata", "ntmaj12"),
  var2 = c("LLAnyDisruption", "LLAnyDisruption")
)
survey_chisq(nptrends_y6_clean, pairs, wt_var = "weight_year6plus")
} # }
```
