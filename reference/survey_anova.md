# Weighted ANOVA across multiple outcomes

Fits [`survey::svyglm()`](https://rdrr.io/pkg/survey/man/svyglm.html)
for each outcome against a categorical grouping variable and runs
[`survey::regTermTest()`](https://rdrr.io/pkg/survey/man/regTermTest.html).
Optionally returns pairwise contrasts via `emmeans`.

## Usage

``` r
survey_anova(
  svy_df,
  outcomes,
  group_var,
  wt_var,
  pairwise = FALSE,
  adjust = "bonferroni"
)
```

## Arguments

- svy_df:

  A data frame containing the survey data.

- outcomes:

  Character vector of (continuous) outcome variables.

- group_var:

  A string naming the categorical grouping variable. Will be coerced to
  factor.

- wt_var:

  A string naming the survey weight column.

- pairwise:

  If `TRUE`, also return pairwise contrasts from
  [`emmeans::emmeans()`](https://rvlenth.github.io/emmeans/reference/emmeans.html).

- adjust:

  Multiple-comparison adjustment for pairwise contrasts. See
  [`?emmeans::summary.emmGrid`](https://rvlenth.github.io/emmeans/reference/summary.emmGrid.html).

## Value

A list with element `overall` (one row per outcome: `outcome`,
`group_var`, `statistic`, `df_num`, `df_den`, `p_value`) and, if
`pairwise = TRUE`, element `pairwise` (one row per contrast: `outcome`,
`contrast`, `estimate`, `se`, `df`, `t_ratio`, `p_value`).

## Details

Requires the `survey` package. Pairwise contrasts also require
`emmeans`.

## Examples

``` r
if (FALSE) { # \dontrun{
survey_anova(nptrends_y6_clean,
             outcomes = "LLLostAmt",
             group_var = "SizeStrata",
             wt_var = "weight_year6plus",
             pairwise = TRUE)
} # }
```
