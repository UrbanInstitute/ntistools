# Collapse Likert scales

Recodes Likert-scale values using a mapping vector. The i-th value in
`mapping` specifies what the original value i should become. Values in
`na_values` are set to NA.

## Usage

``` r
collapse_likert(data, vars, mapping = c(1L, 1L, 2L, 3L, 3L), na_values = 97)
```

## Arguments

- data:

  A data frame.

- vars:

  A character vector of column names to recode.

- mapping:

  An integer vector where position i gives the new value for original
  value i. Defaults to `c(1, 1, 2, 3, 3)` which collapses a 5-point
  Likert scale into 3 categories.

- na_values:

  Numeric vector of values to recode to NA. Defaults to `97`.

## Value

`data` with recoded columns.

## Examples

``` r
d <- data.frame(q1 = c(1, 2, 3, 4, 5, 97))
collapse_likert(d, "q1")
#>   q1
#> 1  1
#> 2  1
#> 3  2
#> 4  3
#> 5  3
#> 6 NA
```
