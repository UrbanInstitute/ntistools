# Weighted Survey Statistics with ntistools

## Overview

After cleaning NTIS data with the recode / label / combine functions,
the next step in most analyses is *weighted inference*: confidence
intervals, chi-square tests of association, t-tests across two groups,
and ANOVA across many groups. The `survey` and `srvyr` packages provide
the underlying machinery, but the calls are verbose and the outputs are
not tidy — making it tedious to run the same test over many variables
and stack the results into a single CSV.

ntistools provides five functions that wrap these patterns:

| Function | Wraps | Use when |
|----|----|----|
| [`survey_ci()`](https://urbaninstitute.github.io/ntistools/reference/survey_ci.md) | `srvyr::survey_mean(vartype = "ci")` | You want weighted means + CIs for many variables, optionally by a group. |
| [`survey_chisq()`](https://urbaninstitute.github.io/ntistools/reference/survey_chisq.md) | [`survey::svychisq()`](https://rdrr.io/pkg/survey/man/svychisq.html) | You want pairwise tests of association across many variable pairs. |
| [`survey_ttest()`](https://urbaninstitute.github.io/ntistools/reference/survey_ttest.md) | [`survey::svyttest()`](https://rdrr.io/pkg/survey/man/svyttest.html) | You want a t-test of each of several outcomes against a binary group. |
| [`survey_anova()`](https://urbaninstitute.github.io/ntistools/reference/survey_anova.md) | [`survey::svyglm()`](https://rdrr.io/pkg/survey/man/svyglm.html) + [`survey::regTermTest()`](https://rdrr.io/pkg/survey/man/regTermTest.html), optionally `emmeans` | You want a global F-test (and optional pairwise contrasts) for each outcome against a multi-level group. |
| [`run_survey_stats()`](https://urbaninstitute.github.io/ntistools/reference/run_survey_stats.md) | All of the above | You want to drive all four from spec data frames and write CSVs. |

All five return tidy data frames with one row per result, so they stack
cleanly with
[`dplyr::bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html)
or write straight to CSV.

> **Optional dependencies.** `survey`, `srvyr`, and `emmeans` are listed
> in `Suggests`. The functions load them lazily and emit a clear install
> hint if a package is missing — you only need to install what you use.

## Setup

``` r

library(ntistools)
library(dplyr)

set.seed(1)
n <- 200
svy <- data.frame(
  SizeStrata        = sample(c("Small", "Medium", "Large"), n, replace = TRUE),
  census_urban_area = sample(c("Urban", "Rural"), n, replace = TRUE),
  LLAnyDisruption   = rbinom(n, 1, 0.45),
  LLLost            = rbinom(n, 1, 0.30),
  LLLostAmt         = round(rlnorm(n, log(20000), 0.6)),
  weight_year6plus  = runif(n, 0.5, 3)
)
head(svy)
#>   SizeStrata census_urban_area LLAnyDisruption LLLost LLLostAmt
#> 1      Small             Rural               0      1     12963
#> 2      Large             Rural               0      0     13711
#> 3      Small             Urban               0      1      6726
#> 4     Medium             Urban               0      0     17118
#> 5      Small             Urban               0      0     24447
#> 6      Large             Urban               0      0      8495
#>   weight_year6plus
#> 1        0.6916130
#> 2        0.7743638
#> 3        2.3856681
#> 4        1.2614969
#> 5        2.3095241
#> 6        1.0808251
```

## `survey_ci()` — weighted means with confidence intervals

Pass a character vector of variables and a weight column. Optionally
pass a `group_var` to break the estimates out by a categorical column.

``` r

survey_ci(
  svy,
  vars   = c("LLAnyDisruption", "LLLost"),
  wt_var = "weight_year6plus"
)
#> # A tibble: 2 × 4
#>   estimate ci_lower ci_upper variable       
#>      <dbl>    <dbl>    <dbl> <chr>          
#> 1    0.465    0.389    0.541 LLAnyDisruption
#> 2    0.330    0.259    0.402 LLLost
```

Group by `SizeStrata` to get one row per (variable, group level):

``` r

survey_ci(
  svy,
  vars      = c("LLAnyDisruption", "LLLost"),
  wt_var    = "weight_year6plus",
  group_var = "SizeStrata"
)
#> # A tibble: 6 × 6
#>   group_level estimate ci_lower ci_upper variable        group_var 
#>   <chr>          <dbl>    <dbl>    <dbl> <chr>           <chr>     
#> 1 Large          0.512    0.378    0.647 LLAnyDisruption SizeStrata
#> 2 Medium         0.446    0.318    0.574 LLAnyDisruption SizeStrata
#> 3 Small          0.444    0.313    0.576 LLAnyDisruption SizeStrata
#> 4 Large          0.302    0.179    0.425 LLLost          SizeStrata
#> 5 Medium         0.303    0.187    0.418 LLLost          SizeStrata
#> 6 Small          0.385    0.255    0.514 LLLost          SizeStrata
```

Use `level` to change the CI width (default `0.95`).

## `survey_chisq()` — chi-square over variable pairs

Pass a two-column data frame describing the pairs to test. One row of
output per pair.

``` r

pairs <- data.frame(
  var1 = c("SizeStrata",        "census_urban_area"),
  var2 = c("LLAnyDisruption",   "LLAnyDisruption")
)
survey_chisq(svy, pairs, wt_var = "weight_year6plus")
#>                var1            var2  statistic       df   p_value
#> 1        SizeStrata LLAnyDisruption 0.32192985 1.997556 0.7246722
#> 2 census_urban_area LLAnyDisruption 0.03370338 1.000000 0.8545261
```

The output columns are `var1`, `var2`, `statistic`, `df`, `p_value` — no
extra unnesting required.

## `survey_ttest()` — t-tests across many outcomes

Pass a character vector of outcomes and a single binary grouping
variable. One row of output per outcome.

``` r

survey_ttest(
  svy,
  outcomes  = c("LLLostAmt", "LLAnyDisruption"),
  group_var = "census_urban_area",
  wt_var    = "weight_year6plus"
)
#>           outcome         group_var      estimate  statistic  df   p_value
#> 1       LLLostAmt census_urban_area -326.91979420 -0.1538494 198 0.8778852
#> 2 LLAnyDisruption census_urban_area    0.01415801  0.1836030 198 0.8545128
#>        ci_lower     ci_upper
#> 1 -4517.3263245 3863.4867361
#> 2    -0.1379084    0.1662244
```

## `survey_anova()` — ANOVA across many outcomes, optional pairwise

For categorical groups with more than two levels. The grouping variable
is coerced to a factor automatically.

``` r

survey_anova(
  svy,
  outcomes  = "LLLostAmt",
  group_var = "SizeStrata",
  wt_var    = "weight_year6plus"
)
#> $overall
#>     outcome  group_var statistic df_num df_den   p_value
#> 1 LLLostAmt SizeStrata 0.6058261      2    197 0.5466368
```

The return value is a list. With `pairwise = TRUE`, it gains a
`$pairwise` element with `emmeans`-style contrasts (requires the
`emmeans` package):

``` r

res <- survey_anova(
  svy,
  outcomes  = "LLLostAmt",
  group_var = "SizeStrata",
  wt_var    = "weight_year6plus",
  pairwise  = TRUE,
  adjust    = "bonferroni"
)
res$pairwise
#>     outcome       contrast   estimate       se  df    t_ratio   p_value
#> 1 LLLostAmt Large - Medium  -730.3675 2367.289 197 -0.3085248 1.0000000
#> 2 LLLostAmt  Large - Small -2988.6972 2784.111 197 -1.0734835 0.8531022
#> 3 LLLostAmt Medium - Small -2258.3297 2636.920 197 -0.8564270 1.0000000
```

## `run_survey_stats()` — bulk-run everything and write CSVs

When you want to run dozens of these tests across one or more datasets,
describe the jobs as spec data frames and let
[`run_survey_stats()`](https://urbaninstitute.github.io/ntistools/reference/run_survey_stats.md)
drive them. Each spec references a dataset by name from the `datasets`
list.

``` r

out <- run_survey_stats(
  datasets   = list(y6 = svy),

  ci_spec    = data.frame(
    dataset   = "y6",
    variable  = c("LLAnyDisruption", "LLLost"),
    wt_var    = "weight_year6plus",
    group_var = "SizeStrata"
  ),

  chisq_spec = data.frame(
    dataset = "y6",
    var1    = c("SizeStrata", "census_urban_area"),
    var2    = c("LLAnyDisruption", "LLLost"),
    wt_var  = "weight_year6plus"
  ),

  ttest_spec = data.frame(
    dataset   = "y6",
    outcome   = c("LLLostAmt"),
    group_var = "census_urban_area",
    wt_var    = "weight_year6plus"
  ),

  anova_spec = data.frame(
    dataset   = "y6",
    outcome   = "LLLostAmt",
    group_var = "SizeStrata",
    wt_var    = "weight_year6plus"
  )
)

names(out)
#> [1] "ci"            "chisq"         "ttest"         "anova_overall"
out$ci
#> # A tibble: 6 × 7
#>   group_level estimate ci_lower ci_upper variable        group_var  dataset
#>   <chr>          <dbl>    <dbl>    <dbl> <chr>           <chr>      <chr>  
#> 1 Large          0.512    0.378    0.647 LLAnyDisruption SizeStrata y6     
#> 2 Medium         0.446    0.318    0.574 LLAnyDisruption SizeStrata y6     
#> 3 Small          0.444    0.313    0.576 LLAnyDisruption SizeStrata y6     
#> 4 Large          0.302    0.179    0.425 LLLost          SizeStrata y6     
#> 5 Medium         0.303    0.187    0.418 LLLost          SizeStrata y6     
#> 6 Small          0.385    0.255    0.514 LLLost          SizeStrata y6
```

Pass `output_dir = "stats_out"` to write one CSV per analysis type
(`ci.csv`, `chisq.csv`, `ttest.csv`, `anova_overall.csv`, and
`anova_pairwise.csv` when applicable). Pass `combined = TRUE` to write a
single `survey_stats.csv` with an `analysis` column tagging each row.

### Running across multiple datasets

The `datasets` argument is a *named list*, and each spec row picks the
dataset by name via the `dataset` column. To mix year-6 and year-5 jobs,
hand both data frames to
[`run_survey_stats()`](https://urbaninstitute.github.io/ntistools/reference/run_survey_stats.md)
and reference them in the spec:

``` r

run_survey_stats(
  datasets = list(
    y6 = nptrends_y6_clean,
    y5 = nptrends_y5_clean
  ),
  ci_spec = data.frame(
    dataset   = c("y6", "y6", "y5"),
    variable  = c("LLAnyDisruption", "LLLost", "LLAnyDisruption"),
    wt_var    = c("weight_year6plus", "weight_year6plus", "year5wt"),
    group_var = c("SizeStrata", "SizeStrata", NA)
  ),
  output_dir = "stats_out",
  combined   = TRUE
)
```

`group_var` is optional in `ci_spec`; leave it as `NA` for a national
(ungrouped) estimate.

## When to use which

- **Descriptive summaries** (proportions, means, medians per group, no
  CIs): use
  [`calc_summarize()`](https://urbaninstitute.github.io/ntistools/reference/calc_summarize.md)
  /
  [`summarize_by_groups()`](https://urbaninstitute.github.io/ntistools/reference/summarize_by_groups.md).
  See
  [`vignette("before-and-after")`](https://urbaninstitute.github.io/ntistools/articles/before-and-after.md).
- **Descriptive summaries with confidence intervals**: use
  [`survey_ci()`](https://urbaninstitute.github.io/ntistools/reference/survey_ci.md).
- **Test of association between two categorical variables**:
  [`survey_chisq()`](https://urbaninstitute.github.io/ntistools/reference/survey_chisq.md).
- **Compare a continuous (or 0/1) outcome across two groups**:
  [`survey_ttest()`](https://urbaninstitute.github.io/ntistools/reference/survey_ttest.md).
- **Compare a continuous outcome across 3+ groups**:
  [`survey_anova()`](https://urbaninstitute.github.io/ntistools/reference/survey_anova.md),
  with `pairwise = TRUE` if you want post-hoc contrasts.
- **A whole battery of the above at once**:
  [`run_survey_stats()`](https://urbaninstitute.github.io/ntistools/reference/run_survey_stats.md).
