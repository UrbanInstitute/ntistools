# Count how many binary indicators are active

Creates `{prefix}_any` (1 if any are 1), `{prefix}_count` (number of
1s), and `{prefix}_all` (1 if all are 1) from a set of binary columns.
All three are NA when every source column is NA.

## Usage

``` r
count_binary(data, prefix, ...)
```

## Arguments

- data:

  A data frame.

- prefix:

  A string used to name the output columns.

- ...:

  Unquoted names of binary (0/1) columns.

## Value

`data` with three new columns added.

## Examples

``` r
d <- data.frame(x = c(1, 0, NA), y = c(1, 1, NA), z = c(0, 1, NA))
count_binary(d, "xyz", x, y, z)
#>    x  y  z xyz_any xyz_count xyz_all
#> 1  1  1  0       1         2       0
#> 2  0  1  1       1         2       0
#> 3 NA NA NA      NA        NA      NA
```
