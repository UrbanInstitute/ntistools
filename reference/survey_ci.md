# Weighted confidence intervals for survey variables

Computes weighted means with confidence intervals for one or more
variables, optionally within levels of a grouping variable. A thin
wrapper around `srvyr::survey_mean(vartype = "ci")` that returns a tidy
stacked tibble.

## Usage

``` r
survey_ci(svy_df, vars, wt_var, group_var = NULL, level = 0.95)
```

## Arguments

- svy_df:

  A data frame containing the survey data.

- vars:

  Character vector of variables to estimate.

- wt_var:

  A string naming the survey weight column.

- group_var:

  Optional string naming a grouping variable.

- level:

  Confidence level (default `0.95`).

## Value

A data frame with columns `variable`, optional `group_level`,
`estimate`, `ci_lower`, `ci_upper`.

## Details

Requires the `srvyr` package to be installed.

## Examples

``` r
if (FALSE) { # \dontrun{
survey_ci(nptrends_y6_clean,
          vars = c("LLAnyDisruption", "LLLost"),
          wt_var = "weight_year6plus",
          group_var = "SizeStrata")
} # }
```
