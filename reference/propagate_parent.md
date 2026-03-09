# Push parent variable's special values to child columns

When a parent variable has one of the specified values (e.g., 0 or 97),
set that same value in all child columns. This is useful when a parent
question gates a set of follow-up questions.

## Usage

``` r
propagate_parent(data, vars, parent_var, values = c(0, 97))
```

## Arguments

- data:

  A data frame.

- vars:

  A character vector of child column names.

- parent_var:

  A string giving the name of the parent column.

- values:

  Numeric vector of parent values to propagate to children. Defaults to
  `c(0, 97)`.

## Value

`data` with child columns updated.

## Examples

``` r
d <- data.frame(parent = c(0, 1, 97, 1), child1 = c(NA, 1, NA, 0))
propagate_parent(d, "child1", parent_var = "parent", values = c(0, 97))
#>   parent child1
#> 1      0      0
#> 2      1      1
#> 3     97     97
#> 4      1      0
```
