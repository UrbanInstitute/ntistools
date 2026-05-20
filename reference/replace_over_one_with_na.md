# Replace values greater than 1 with NA

Replaces values greater than 1 in the specified columns with `NA`.
Useful for cleaning proportion-style columns that should be bounded at
1.

## Usage

``` r
replace_over_one_with_na(data, vars)
```

## Arguments

- data:

  A data frame.

- vars:

  A character vector of column names.

## Value

`data` with values \> 1 in `vars` replaced by NA.

## Examples

``` r
d <- data.frame(
  A = c(0.5, 1.2, 0.9, 2.1),
  B = c(1, 1.5, 0.8, 0.4)
)
replace_over_one_with_na(d, c("A", "B"))
#>     A   B
#> 1 0.5 1.0
#> 2  NA  NA
#> 3 0.9 0.8
#> 4  NA 0.4
```
