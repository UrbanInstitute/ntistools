# Calculate weighted summary statistics

Calculates weighted proportions, means, or medians for a variable,
optionally within levels of a grouping variable.

## Usage

``` r
calc_summarize(svy_df, var, wt_var, grp_cols, metric)
```

## Arguments

- svy_df:

  A data frame containing the survey data.

- var:

  A string naming the variable to summarize.

- wt_var:

  A string naming the survey weight column (e.g., `"year5wt"`).

- grp_cols:

  Character vector of grouping columns. The first element is treated as
  the main grouping variable; the last as the subgroup. For a national
  (ungrouped) calculation, pass `var` as a length-1 vector (i.e.,
  `grp_cols = var`).

- metric:

  One of `"proportion"`, `"mean"`, or `"median"`.

## Value

A tibble with columns `group`, `variable`, optionally `group_level` and
`variable_level`, `count` (sum of weights), `value` (the calculated
statistic), and `metric`.

## Details

Rows where any column in `grp_cols` is `NA` are dropped before
summarising. The median branch uses an internal weighted-median helper
to avoid taking on a `matrixStats` dependency.

## Examples

``` r
d <- data.frame(
  LLTwoDisruption = c(0, 1, 1, 0, 1, 0),
  LLLost = c(1, 0, 1, 0, 0, 1),
  year5wt = c(100, 150, 200, 100, 50, 150),
  Q_A = c(1, 2, 1, 2, 1, 2)
)
calc_summarize(d, var = "Q_A", wt_var = "year5wt",
               grp_cols = c("LLTwoDisruption", "Q_A"),
               metric = "proportion")
#> # A tibble: 4 × 7
#> # Groups:   group_level [2]
#>   group_level variable_level count value variable metric     group          
#>   <chr>       <chr>          <dbl> <dbl> <chr>    <chr>      <chr>          
#> 1 0           1                100 0.286 Q_A      proportion LLTwoDisruption
#> 2 0           2                250 0.714 Q_A      proportion LLTwoDisruption
#> 3 1           1                250 0.625 Q_A      proportion LLTwoDisruption
#> 4 1           2                150 0.375 Q_A      proportion LLTwoDisruption
calc_summarize(d, var = "LLLost", wt_var = "year5wt",
               grp_cols = "LLTwoDisruption", metric = "mean")
#> # A tibble: 1 × 5
#>   count value variable metric group   
#>   <dbl> <dbl> <chr>    <chr>  <chr>   
#> 1   750   0.6 LLLost   mean   National
```
