# Collapse categories into 0/1

Recodes a set of columns so that values in `ones` become 1, values in
`zeros` become 0, and values in `na_values` become NA.

## Usage

``` r
recode_binary(data, vars, ones = c(1, 2), zeros = 0, na_values = 98)
```

## Arguments

- data:

  A data frame.

- vars:

  A character vector of column names to recode.

- ones:

  Numeric vector of values to recode to 1. Defaults to `c(1, 2)`.

- zeros:

  Numeric vector of values to recode to 0. Defaults to `0`.

- na_values:

  Numeric vector of values to recode to NA. Defaults to `98`.

## Value

`data` with recoded columns.

## Examples

``` r
d <- data.frame(x = c(0, 1, 2, 98))
recode_binary(d, "x")
#>    x
#> 1  0
#> 2  1
#> 3  1
#> 4 NA
```
