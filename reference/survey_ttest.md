# Weighted t-tests across multiple outcomes

Runs
[`survey::svyttest()`](https://rdrr.io/pkg/survey/man/svyttest.html) for
each outcome against a single binary grouping variable, returning a tidy
stacked tibble.

## Usage

``` r
survey_ttest(svy_df, outcomes, group_var, wt_var)
```

## Arguments

- svy_df:

  A data frame containing the survey data.

- outcomes:

  Character vector of outcome variables.

- group_var:

  A string naming the (binary) grouping variable.

- wt_var:

  A string naming the survey weight column.

## Value

A data frame with one row per outcome: `outcome`, `group_var`,
`estimate` (mean difference), `statistic` (t), `df`, `p_value`,
`ci_lower`, `ci_upper`.

## Details

Requires the `survey` package to be installed.

## Examples

``` r
if (FALSE) { # \dontrun{
survey_ttest(nptrends_y6_clean,
             outcomes = c("LLLostAmt", "LLDelayWeeks1to6Median"),
             group_var = "census_urban_area",
             wt_var = "weight_year6plus")
} # }
```
