# Label Likert-scale columns with descriptive strings

Maps numeric Likert-scale values to descriptive labels using the same
`mapping` vector approach as
[`collapse_likert()`](https://urbaninstitute.github.io/ntistools/reference/collapse_likert.md),
then indexes into `labels` to produce character output. Values in
`na_values` are mapped to `na_label` instead of `NA`.

## Usage

``` r
label_likert(
  data,
  vars,
  labels,
  mapping = c(1L, 1L, 2L, 3L, 3L),
  na_values = 97,
  na_label = "Unsure"
)
```

## Arguments

- data:

  A data frame.

- vars:

  A character vector of column names to label.

- labels:

  A character vector of labels, one per collapsed category. Length must
  equal `max(mapping)`. For example,
  `c("Decrease", "No change", "Increase")`.

- mapping:

  An integer vector where position i gives the collapsed category for
  original value i. Defaults to `c(1L, 1L, 2L, 3L, 3L)`.

- na_values:

  Numeric vector of values to map to `na_label`. Defaults to `97`.

- na_label:

  Character string used for values in `na_values`. Defaults to
  `"Unsure"`.

## Value

`data` with labeled columns.

## Examples

``` r
d <- data.frame(q1 = c(1, 2, 3, 4, 5, 97))
label_likert(d, "q1",
  labels = c("Decrease", "No change", "Increase")
)
#>          q1
#> 1  Decrease
#> 2  Decrease
#> 3 No change
#> 4  Increase
#> 5  Increase
#> 6    Unsure
```
