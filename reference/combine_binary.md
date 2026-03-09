# Combine binary indicators with OR logic

Given several 0/1 columns, create a new column that is 1 if *any* source
column is 1, NA if *all* source columns are NA, and 0 otherwise.

## Usage

``` r
combine_binary(data, new_col, ..., strict_na = FALSE)
```

## Arguments

- data:

  A data frame.

- new_col:

  Unquoted name for the new column.

- ...:

  Unquoted names of binary (0/1) columns to combine.

- strict_na:

  Logical. When `TRUE`, return NA if *any* source column is NA (unless
  at least one source is 1). When `FALSE` (default), return NA only when
  *all* source columns are NA.

## Value

`data` with the new column added.

## Examples

``` r
d <- data.frame(a = c(0, 1, NA, 0), b = c(0, 0, NA, 1))
combine_binary(d, ab, a, b)
#>    a  b ab
#> 1  0  0  0
#> 2  1  0  1
#> 3 NA NA NA
#> 4  0  1  1

# strict_na: NA poisons the result unless a 1 is present
d2 <- data.frame(a = c(0, NA), b = c(NA, NA))
combine_binary(d2, ab, a, b, strict_na = TRUE)
#>    a  b ab
#> 1  0 NA NA
#> 2 NA NA NA
```
