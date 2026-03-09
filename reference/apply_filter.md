# Conditionally set variables to NA when a condition is not met

For each variable in `vars`, values are kept as-is when `condition` is
TRUE and set to NA otherwise. This is useful for filtering out responses
from organizations that should not answer certain questions.

## Usage

``` r
apply_filter(data, vars, condition)
```

## Arguments

- data:

  A data frame.

- vars:

  A character vector of column names to filter.

- condition:

  An unquoted expression that evaluates to a logical vector. Rows where
  this is TRUE keep their values; all other rows get NA.

## Value

`data` with filtered columns.

## Examples

``` r
d <- data.frame(keep = c(1, 0, 1), x = c(10, 20, 30))
apply_filter(d, "x", condition = keep == 1)
#>   keep  x
#> 1    1 10
#> 2    0 NA
#> 3    1 30
```
