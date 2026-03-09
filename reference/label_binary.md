# Label binary columns with descriptive strings

Converts 0/1 columns into character columns using named label pairs.
Values in `true_values` get the first label, values in `false_values`
get the second label, and everything else becomes `NA_character_`.

## Usage

``` r
label_binary(data, labels, true_values = 1, false_values = 0, na_values = NULL)
```

## Arguments

- data:

  A data frame.

- labels:

  A named list where each element is a length-2 character vector
  `c("true label", "false label")`, keyed by column name.

- true_values:

  Numeric vector of values that map to the true (first) label. Defaults
  to `1`.

- false_values:

  Numeric vector of values that map to the false (second) label.
  Defaults to `0`.

- na_values:

  Optional numeric vector of additional values to map to the false label
  (e.g., `97` for "not applicable"). Defaults to `NULL`.

## Value

`data` with labeled columns.

## Examples

``` r
d <- data.frame(x = c(1, 0, NA, 97))
label_binary(d,
  labels = list(x = c("Yes", "No")),
  na_values = 97
)
#>      x
#> 1  Yes
#> 2   No
#> 3 <NA>
#> 4   No
```
