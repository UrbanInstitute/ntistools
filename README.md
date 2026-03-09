# ntistools <a href="https://urbaninstitute.github.io/ntistools/"><img src="man/figures/logo.png" align="right" height="139" alt="ntistools website" /></a>

<!-- badges: start -->
[![R-CMD-check](https://github.com/UrbanInstitute/ntistools/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/UrbanInstitute/ntistools/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**ntistools** provides reusable data-cleaning functions for wrangling
[Nonprofit Trends and Impacts Survey (NTIS)](https://www.urban.org/partnering-understand-long-term-trends-nonprofit-sector)
data. It replaces repetitive `dplyr::case_when()` and `dplyr::across()` patterns
common in NTIS analysis scripts with purpose-built, pipe-friendly functions.

Developed and maintained by the [Urban Institute](https://www.urban.org/).

## Installation

Install the development version from GitHub:

```r
# install.packages("pak")
pak::pak("UrbanInstitute/ntistools")
```

Or using `remotes`:

```r
# install.packages("remotes")
remotes::install_github("UrbanInstitute/ntistools")
```

## Functions

ntistools exports 10 functions organized into four categories:

### Recode and collapse

| Function | Description |
|---|---|
| `recode_binary()` | Collapse multi-level values into 0/1 (e.g., 0 = no, 1&2 = yes, 98 = NA) |
| `recode_sentinel()` | Replace sentinel values (e.g., 98 = "don't know") with `NA` |
| `collapse_likert()` | Collapse a 5-point Likert scale into 3 categories |

### Label

| Function | Description |
|---|---|
| `label_binary()` | Convert 0/1 columns to descriptive strings (e.g., `"Yes"` / `"No"`) |
| `label_likert()` | Map Likert-scale values to descriptive strings (e.g., `"Decrease"` / `"No change"` / `"Increase"`) |

### Combine and count

| Function | Description |
|---|---|
| `combine_binary()` | OR-combine several 0/1 columns into one (1 if any = 1, NA if all NA, else 0) |
| `count_binary()` | Create `_any`, `_count`, and `_all` summary columns from binary indicators |

### Impute, propagate, and filter

| Function | Description |
|---|---|
| `impute_from_flag()` | Replace NA with a value when a companion flag column indicates a valid skip |
| `propagate_parent()` | Push a parent question's value (e.g., 0 or 97) to all child columns |
| `apply_filter()` | Set variables to NA for respondents who don't meet a condition |

## Usage

```r
library(ntistools)
library(dplyr)

cleaned <- raw_survey |>
  recode_binary(c("ProgDem_Children", "ProgDem_Elders")) |>
  recode_sentinel(c("DonImportance", "PrgSrvc_Suspend")) |>
  impute_from_flag("PplSrv_NumWait") |>
  combine_binary(GeoAreas_Locally,
                 GeoAreas_Local, GeoAreas_MultipleLocal,
                 GeoAreas_RegionalWithin) |>
  collapse_likert("FinanceChng_Benefits") |>
  label_binary(labels = list(
    GeoAreas_Locally = c("Serving locally", "Not serving locally")
  )) |>
  label_likert("FinanceChng_Benefits",
               labels = c("Decrease", "No change", "Increase")) |>
  propagate_parent(c("Regulations_Federal", "Regulations_State"),
                   parent_var = "Regulations") |>
  apply_filter(c("StaffVacancies", "BenefitsImpact"),
               condition = HaveStaff == 1)
```

See `vignette("before-and-after")` for side-by-side comparisons of verbose
`case_when()` code and the equivalent ntistools calls.

## NTIS sentinel value conventions

NTIS uses numeric sentinel values to represent special responses:

- **98** = "Don't know"
- **97** = "Not applicable"
- **0** = "None" (context-dependent)

Many ntistools functions have defaults that reflect these conventions (e.g.,
`recode_sentinel()` defaults to replacing 98 with NA, `collapse_likert()` treats
97 as NA).

## Contributing

This package is maintained by the Urban Institute. If you find a bug or want to
suggest a feature, please
[open an issue](https://github.com/UrbanInstitute/ntistools/issues).

## License

MIT
