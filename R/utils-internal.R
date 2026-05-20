# Internal helpers. Not exported.

require_pkg <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(
      sprintf(
        "Package '%s' is required for this function. Install with install.packages('%s').",
        pkg, pkg
      ),
      call. = FALSE
    )
  }
}

build_svydesign <- function(svy_df, wt_var) {
  require_pkg("survey")
  survey::svydesign(
    ids = ~1,
    data = svy_df,
    weights = stats::as.formula(paste0("~", wt_var))
  )
}
