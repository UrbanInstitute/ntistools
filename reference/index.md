# Package index

## Recode & Collapse

Transform numeric survey codes into standardized values.

- [`recode_binary()`](https://urbaninstitute.github.io/ntistools/reference/recode_binary.md)
  : Collapse categories into 0/1
- [`recode_sentinel()`](https://urbaninstitute.github.io/ntistools/reference/recode_sentinel.md)
  : Replace sentinel values with NA
- [`collapse_likert()`](https://urbaninstitute.github.io/ntistools/reference/collapse_likert.md)
  : Collapse Likert scales

## Label

Convert numeric codes to human-readable strings.

- [`label_binary()`](https://urbaninstitute.github.io/ntistools/reference/label_binary.md)
  : Label binary columns with descriptive strings
- [`label_likert()`](https://urbaninstitute.github.io/ntistools/reference/label_likert.md)
  : Label Likert-scale columns with descriptive strings

## Combine & Count

Aggregate multiple binary indicators into summary columns.

- [`combine_binary()`](https://urbaninstitute.github.io/ntistools/reference/combine_binary.md)
  : Combine binary indicators with OR logic
- [`count_binary()`](https://urbaninstitute.github.io/ntistools/reference/count_binary.md)
  : Count how many binary indicators are active

## Impute & Propagate

Fill or override values based on flag or parent columns.

- [`impute_from_flag()`](https://urbaninstitute.github.io/ntistools/reference/impute_from_flag.md)
  : Replace NA with a value when a flag column indicates the skip is
  valid
- [`propagate_parent()`](https://urbaninstitute.github.io/ntistools/reference/propagate_parent.md)
  : Push parent variable's special values to child columns

## Filter

Conditionally set variables to NA for ineligible respondents.

- [`apply_filter()`](https://urbaninstitute.github.io/ntistools/reference/apply_filter.md)
  : Conditionally set variables to NA when a condition is not met
