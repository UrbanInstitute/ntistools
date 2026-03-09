# Replace sentinel values with NA

Replaces specified sentinel values (e.g., 98 for "don't know") with
`NA`.

## Usage

``` r
recode_sentinel(data, vars, values = 98)
```

## Arguments

- data:

  A data frame.

- vars:

  A character vector of column names.

- values:

  Numeric vector of sentinel values to replace with NA. Defaults to
  `98`.

## Value

`data` with sentinel values replaced by NA.

## Examples

``` r
d <- data.frame(x = c(1, 98, 3), y = c(98, 2, 98))
recode_sentinel(d, c("x", "y"), values = 98)
#>    x  y
#> 1  1 NA
#> 2 NA  2
#> 3  3 NA
```
