# Cleaning NTIS Data: Before and After ntistools

NTIS data-cleaning scripts tend to repeat the same
[`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)
patterns over and over: combining binary indicators, removing sentinels,
collapsing Likert scales, and so on. **ntistools** replaces each pattern
with a single, purpose-built function so your scripts are shorter,
easier to read, and less error-prone.

This vignette walks through each function, showing the verbose “before”
code alongside the concise “after” equivalent, all using a small
synthetic dataset.

## Setup

``` r
library(ntistools)
library(dplyr)

survey <- data.frame(
  # Binary geographic indicators
  GeoAreas_Local        = c(1, 0, 0, NA, 0, 1),
  GeoAreas_MultipleLocal = c(0, 0, 1, NA, 0, 0),
  GeoAreas_RegionalWithin = c(0, 0, 0, NA, 0, 0),

 # Disruption indicators
  LLLost  = c(1, 0, 1, NA, 0, 1),
  LLDelay = c(1, 1, 0, NA, 0, 1),
  LLStop  = c(0, 0, 0, NA, 0, 1),

  # ProgDem-style column (0 = no, 1 = yes primary, 2 = yes secondary, 98 = NA)
  ProgDem_Children = c(0, 1, 2, 98, 0, 1),
  ProgDem_Elders   = c(1, 0, 98, 2, 0, 1),

  # Sentinel values
  DonImportance = c(3, 1, 98, 2, 98, 4),

  # Flag-based imputation columns
  PplSrv_NumWait      = c(50, NA, 10, NA, 30, NA),
  PplSrv_NumWait_NA_X = c(0,   1,  0,  0,  0,  1),

  # Likert scales (1-5, with 97 = N/A)
  FinanceChng_Benefits = c(1, 2, 3, 4, 5, 97),

 # Parent/child regulation pattern
  Regulations          = c(1, 0, 97, 1, 0, 1),
  Regulations_Federal  = c(1, NA, NA, 0, NA, 1),
  Regulations_State    = c(0, NA, NA, 1, NA, 1),

  # Staff filter columns
  HaveStaff         = c(1, 1, 0, 1, 0, 1),
  StaffVacancies    = c(3, 1, 2, 0, 4, 1),
  BenefitsImpact    = c(2, 3, 1, 4, 2, 3)
)
```

## 1. `combine_binary()` — Grouping binary indicators

Combine several binary (0/1) columns into one using OR logic: 1 if
**any** are 1, NA if **all** are NA, 0 otherwise.

### Before

``` r
before <- survey %>%
  mutate(
    GeoAreas_Locally = case_when(
      GeoAreas_Local == 1 | GeoAreas_MultipleLocal == 1 |
        GeoAreas_RegionalWithin == 1 ~ 1,
      is.na(GeoAreas_Local) & is.na(GeoAreas_MultipleLocal) &
        is.na(GeoAreas_RegionalWithin) ~ NA,
      .default = 0
    )
  )

before %>% select(starts_with("GeoAreas"))
#>   GeoAreas_Local GeoAreas_MultipleLocal GeoAreas_RegionalWithin
#> 1              1                      0                       0
#> 2              0                      0                       0
#> 3              0                      1                       0
#> 4             NA                     NA                      NA
#> 5              0                      0                       0
#> 6              1                      0                       0
#>   GeoAreas_Locally
#> 1                1
#> 2                0
#> 3                1
#> 4               NA
#> 5                0
#> 6                1
```

### After

``` r
after <- survey %>%
  combine_binary(GeoAreas_Locally,
                 GeoAreas_Local, GeoAreas_MultipleLocal,
                 GeoAreas_RegionalWithin)

after %>% select(starts_with("GeoAreas"))
#>   GeoAreas_Local GeoAreas_MultipleLocal GeoAreas_RegionalWithin
#> 1              1                      0                       0
#> 2              0                      0                       0
#> 3              0                      1                       0
#> 4             NA                     NA                      NA
#> 5              0                      0                       0
#> 6              1                      0                       0
#>   GeoAreas_Locally
#> 1                1
#> 2                0
#> 3                1
#> 4               NA
#> 5                0
#> 6                1
```

## 2. `count_binary()` — Any / count / all from binary indicators

Creates three summary columns (`_any`, `_count`, `_all`) from a set of
binary columns in a single call.

### Before

``` r
before <- survey %>%
  mutate(
    LLDisruption_any = case_when(
      LLLost == 1 | LLDelay == 1 | LLStop == 1 ~ 1,
      is.na(LLLost) & is.na(LLDelay) & is.na(LLStop) ~ NA,
      .default = 0
    ),
    LLDisruption_count = case_when(
      is.na(LLLost) & is.na(LLDelay) & is.na(LLStop) ~ NA_real_,
      .default = rowSums(across(c(LLLost, LLDelay, LLStop),
                                ~ . == 1), na.rm = TRUE)
    ),
    LLDisruption_all = case_when(
      LLLost == 1 & LLDelay == 1 & LLStop == 1 ~ 1,
      is.na(LLLost) & is.na(LLDelay) & is.na(LLStop) ~ NA,
      .default = 0
    )
  )

before %>% select(starts_with("LL"))
#>   LLLost LLDelay LLStop LLDisruption_any LLDisruption_count LLDisruption_all
#> 1      1       1      0                1                  2                0
#> 2      0       1      0                1                  1                0
#> 3      1       0      0                1                  1                0
#> 4     NA      NA     NA               NA                 NA               NA
#> 5      0       0      0                0                  0                0
#> 6      1       1      1                1                  3                1
```

### After

``` r
after <- survey %>%
  count_binary("LLDisruption", LLLost, LLDelay, LLStop)

after %>% select(starts_with("LL"))
#>   LLLost LLDelay LLStop LLDisruption_any LLDisruption_count LLDisruption_all
#> 1      1       1      0                1                  2                0
#> 2      0       1      0                1                  1                0
#> 3      1       0      0                1                  1                0
#> 4     NA      NA     NA               NA                 NA               NA
#> 5      0       0      0                0                  0                0
#> 6      1       1      1                1                  3                1
```

## 3. `recode_binary()` — Collapse multi-level to 0/1

Recode columns where 0 = no, 1 & 2 = yes, and 98 = NA.

### Before

``` r
recode_progdem <- function(x) {
  case_when(
    x == 0 ~ 0, x == 1 ~ 1, x == 2 ~ 1,
    x == 98 ~ NA_real_, TRUE ~ NA_real_
  )
}

before <- survey %>%
  mutate(across(c(ProgDem_Children, ProgDem_Elders),
                recode_progdem))

before %>% select(starts_with("ProgDem"))
#>   ProgDem_Children ProgDem_Elders
#> 1                0              1
#> 2                1              0
#> 3                1             NA
#> 4               NA              1
#> 5                0              0
#> 6                1              1
```

### After

``` r
after <- survey %>%
  recode_binary(c("ProgDem_Children", "ProgDem_Elders"))

after %>% select(starts_with("ProgDem"))
#>   ProgDem_Children ProgDem_Elders
#> 1                0              1
#> 2                1              0
#> 3                1             NA
#> 4               NA              1
#> 5                0              0
#> 6                1              1
```

## 4. `recode_sentinel()` — Remove 98s

Replace sentinel values (e.g., 98 = “don’t know”) with NA.

### Before

``` r
before <- survey %>%
  mutate(across(
    all_of("DonImportance"),
    ~ case_when(. == 98 ~ NA, TRUE ~ .)
  ))

before %>% select(DonImportance)
#>   DonImportance
#> 1             3
#> 2             1
#> 3            NA
#> 4             2
#> 5            NA
#> 6             4
```

### After

``` r
after <- survey %>%
  recode_sentinel("DonImportance")

after %>% select(DonImportance)
#>   DonImportance
#> 1             3
#> 2             1
#> 3            NA
#> 4             2
#> 5            NA
#> 6             4
```

## 5. `impute_from_flag()` — Fill NA when a flag says “skip was valid”

When a respondent legitimately skipped a numeric question, the value is
NA but a companion flag column (e.g., `_NA_X`) is 1. Replace those NAs
with 0.

### Before

``` r
before <- survey %>%
  mutate(
    PplSrv_NumWait = case_when(
      PplSrv_NumWait_NA_X == 1 & is.na(PplSrv_NumWait) ~ 0,
      .default = PplSrv_NumWait
    )
  )

before %>% select(starts_with("PplSrv"))
#>   PplSrv_NumWait PplSrv_NumWait_NA_X
#> 1             50                   0
#> 2              0                   1
#> 3             10                   0
#> 4             NA                   0
#> 5             30                   0
#> 6              0                   1
```

### After

``` r
after <- survey %>%
  impute_from_flag("PplSrv_NumWait")

after %>% select(starts_with("PplSrv"))
#>   PplSrv_NumWait PplSrv_NumWait_NA_X
#> 1             50                   0
#> 2              0                   1
#> 3             10                   0
#> 4             NA                   0
#> 5             30                   0
#> 6              0                   1
```

## 6. `collapse_likert()` — Likert 5-point to 3-point

Collapse a 5-point Likert scale (1–5) into 3 categories (1 = low, 2 =
mid, 3 = high), with 97 set to NA.

### Before

``` r
before <- survey %>%
  mutate(
    FinanceChng_Benefits = case_match(
      FinanceChng_Benefits,
      1 ~ 1, 2 ~ 1, 3 ~ 2, 4 ~ 3, 5 ~ 3, 97 ~ NA
    )
  )
#> Warning: There was 1 warning in `mutate()`.
#> ℹ In argument: `FinanceChng_Benefits = case_match(...)`.
#> Caused by warning:
#> ! `case_match()` was deprecated in dplyr 1.2.0.
#> ℹ Please use `recode_values()` instead.

before %>% select(FinanceChng_Benefits)
#>   FinanceChng_Benefits
#> 1                    1
#> 2                    1
#> 3                    2
#> 4                    3
#> 5                    3
#> 6                   NA
```

### After

``` r
after <- survey %>%
  collapse_likert("FinanceChng_Benefits")

after %>% select(FinanceChng_Benefits)
#>   FinanceChng_Benefits
#> 1                    1
#> 2                    1
#> 3                    2
#> 4                    3
#> 5                    3
#> 6                   NA
```

## 7. `propagate_parent()` — Push parent value to children

When a parent question (e.g., `Regulations`) is 0 (“no”) or 97 (“N/A”),
propagate that value to all follow-up child columns.

### Before

``` r
before <- survey %>%
  mutate(across(
    c(Regulations_Federal, Regulations_State),
    ~ case_when(
      Regulations == 0 ~ 0,
      Regulations == 97 ~ 97,
      TRUE ~ .
    )
  ))

before %>% select(starts_with("Regulations"))
#>   Regulations Regulations_Federal Regulations_State
#> 1           1                   1                 0
#> 2           0                   0                 0
#> 3          97                  97                97
#> 4           1                   0                 1
#> 5           0                   0                 0
#> 6           1                   1                 1
```

### After

``` r
after <- survey %>%
  propagate_parent(c("Regulations_Federal", "Regulations_State"),
                   parent_var = "Regulations")

after %>% select(starts_with("Regulations"))
#>   Regulations Regulations_Federal Regulations_State
#> 1           1                   1                 0
#> 2           0                   0                 0
#> 3          97                  97                97
#> 4           1                   0                 1
#> 5           0                   0                 0
#> 6           1                   1                 1
```

## 8. `apply_filter()` — Zero-out variables for ineligible respondents

Set variables to NA for organizations that don’t meet a condition (e.g.,
no paid staff).

### Before

``` r
before <- survey %>%
  mutate(across(
    c(StaffVacancies, BenefitsImpact),
    ~ case_when(HaveStaff == 1 ~ ., .default = NA)
  ))

before %>% select(HaveStaff, StaffVacancies, BenefitsImpact)
#>   HaveStaff StaffVacancies BenefitsImpact
#> 1         1              3              2
#> 2         1              1              3
#> 3         0             NA             NA
#> 4         1              0              4
#> 5         0             NA             NA
#> 6         1              1              3
```

### After

``` r
after <- survey %>%
  apply_filter(c("StaffVacancies", "BenefitsImpact"),
               condition = HaveStaff == 1)

after %>% select(HaveStaff, StaffVacancies, BenefitsImpact)
#>   HaveStaff StaffVacancies BenefitsImpact
#> 1         1              3              2
#> 2         1              1              3
#> 3         0             NA             NA
#> 4         1              0              4
#> 5         0             NA             NA
#> 6         1              1              3
```

## 9. `label_binary()` — Convert 0/1 to descriptive labels

Turn binary indicators into human-readable strings. Values in
`na_values` (e.g., 97) map to the false label.

### Before

``` r
before <- survey %>%
  mutate(
    GeoAreas_Local = case_when(
      GeoAreas_Local == 1 ~ "Serving local areas",
      GeoAreas_Local == 0 ~ "Not serving local areas",
      .default = NA_character_
    ),
    FinanceChng_Benefits = case_when(
      FinanceChng_Benefits == 1 ~ "Benefits changed",
      FinanceChng_Benefits %in% c(0, 97) ~ "Benefits did not change",
      .default = NA_character_
    )
  )

before %>% select(GeoAreas_Local, FinanceChng_Benefits)
#>            GeoAreas_Local    FinanceChng_Benefits
#> 1     Serving local areas        Benefits changed
#> 2 Not serving local areas                    <NA>
#> 3 Not serving local areas                    <NA>
#> 4                    <NA>                    <NA>
#> 5 Not serving local areas                    <NA>
#> 6     Serving local areas Benefits did not change
```

### After

``` r
after <- survey %>%
  label_binary(
    labels = list(
      GeoAreas_Local = c("Serving local areas", "Not serving local areas"),
      FinanceChng_Benefits = c("Benefits changed", "Benefits did not change")
    ),
    na_values = 97
  )

after %>% select(GeoAreas_Local, FinanceChng_Benefits)
#>            GeoAreas_Local    FinanceChng_Benefits
#> 1     Serving local areas        Benefits changed
#> 2 Not serving local areas                    <NA>
#> 3 Not serving local areas                    <NA>
#> 4                    <NA>                    <NA>
#> 5 Not serving local areas                    <NA>
#> 6     Serving local areas Benefits did not change
```

## 10. `label_likert()` — Label collapsed Likert scales

Map numeric Likert-scale values to descriptive strings. Uses the same
`mapping` vector approach as
[`collapse_likert()`](https://urbaninstitute.github.io/ntistools/reference/collapse_likert.md),
then indexes into labels. Values in `na_values` get `na_label` (default
`"Unsure"`).

### Before

``` r
before <- survey %>%
  mutate(
    FinanceChng_Benefits = case_when(
      FinanceChng_Benefits %in% c(1, 2) ~ "Decrease",
      FinanceChng_Benefits == 3 ~ "No change",
      FinanceChng_Benefits %in% c(4, 5) ~ "Increase",
      FinanceChng_Benefits == 97 ~ "Unsure",
      .default = NA_character_
    )
  )

before %>% select(FinanceChng_Benefits)
#>   FinanceChng_Benefits
#> 1             Decrease
#> 2             Decrease
#> 3            No change
#> 4             Increase
#> 5             Increase
#> 6               Unsure
```

### After

``` r
after <- survey %>%
  label_likert("FinanceChng_Benefits",
               labels = c("Decrease", "No change", "Increase"))

after %>% select(FinanceChng_Benefits)
#>   FinanceChng_Benefits
#> 1             Decrease
#> 2             Decrease
#> 3            No change
#> 4             Increase
#> 5             Increase
#> 6               Unsure
```

## Putting it all together

In a real script, you can chain multiple ntistools calls in a single
pipeline:

``` r
cleaned <- survey %>%
  combine_binary(GeoAreas_Locally,
                 GeoAreas_Local, GeoAreas_MultipleLocal,
                 GeoAreas_RegionalWithin) %>%
  count_binary("LLDisruption", LLLost, LLDelay, LLStop) %>%
  recode_binary(c("ProgDem_Children", "ProgDem_Elders")) %>%
  recode_sentinel("DonImportance") %>%
  impute_from_flag("PplSrv_NumWait") %>%
  collapse_likert("FinanceChng_Benefits") %>%
  propagate_parent(c("Regulations_Federal", "Regulations_State"),
                   parent_var = "Regulations") %>%
  apply_filter(c("StaffVacancies", "BenefitsImpact"),
               condition = HaveStaff == 1) %>%
  label_binary(labels = list(
    GeoAreas_Locally = c("Serving locally", "Not serving locally")
  )) %>%
  label_likert("DonImportance",
               labels = c("Low", "Medium", "High"),
               mapping = c(1L, 2L, 3L, 3L),
               na_values = NULL)

glimpse(cleaned)
#> Rows: 6
#> Columns: 22
#> $ GeoAreas_Local          <dbl> 1, 0, 0, NA, 0, 1
#> $ GeoAreas_MultipleLocal  <dbl> 0, 0, 1, NA, 0, 0
#> $ GeoAreas_RegionalWithin <dbl> 0, 0, 0, NA, 0, 0
#> $ LLLost                  <dbl> 1, 0, 1, NA, 0, 1
#> $ LLDelay                 <dbl> 1, 1, 0, NA, 0, 1
#> $ LLStop                  <dbl> 0, 0, 0, NA, 0, 1
#> $ ProgDem_Children        <int> 0, 1, 1, NA, 0, 1
#> $ ProgDem_Elders          <int> 1, 0, NA, 1, 0, 1
#> $ DonImportance           <chr> "High", "Low", NA, "Medium", NA, "High"
#> $ PplSrv_NumWait          <dbl> 50, 0, 10, NA, 30, 0
#> $ PplSrv_NumWait_NA_X     <dbl> 0, 1, 0, 0, 0, 1
#> $ FinanceChng_Benefits    <int> 1, 1, 2, 3, 3, NA
#> $ Regulations             <dbl> 1, 0, 97, 1, 0, 1
#> $ Regulations_Federal     <dbl> 1, 0, 97, 0, 0, 1
#> $ Regulations_State       <dbl> 0, 0, 97, 1, 0, 1
#> $ HaveStaff               <dbl> 1, 1, 0, 1, 0, 1
#> $ StaffVacancies          <dbl> 3, 1, NA, 0, NA, 1
#> $ BenefitsImpact          <dbl> 2, 3, NA, 4, NA, 3
#> $ GeoAreas_Locally        <chr> "Serving locally", "Not serving locally", "Ser…
#> $ LLDisruption_any        <int> 1, 1, 1, NA, 0, 1
#> $ LLDisruption_count      <int> 2, 1, 1, NA, 0, 3
#> $ LLDisruption_all        <int> 0, 0, 0, NA, 0, 1
```

What used to be hundreds of lines of repetitive
[`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)
calls becomes a single, readable pipeline.
