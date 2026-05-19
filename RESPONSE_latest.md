# Latest Codex Response Summary

- Entry ID: `20260519T195614Z`
- Recorded: `2026-05-19T20:02:57+00:00`

Implemented the clean `mts_*` rename.

Renamed exports:
- `plot_mts()` -> `mts_plot()`
- `lines_mts()` -> `mts_lines()`
- `abline_mts()` -> `mts_abline()`
- `legend_mts()` -> `mts_legend()`
- `set_mts_panel()` -> `mts_set_panel()`
- `plot_mts_overlay()` -> `mts_plot_overlay()`

Updated package code, roxygen examples, package-level docs, generated `.Rd` files, tests, and `NAMESPACE`. No backwards-compatibility aliases were kept. Documentation references to the possible future helper now use `mts_add_to_panel()`.

Files changed:
- `NAMESPACE`
- `R/earnmisc-package.R`
- `R/mts_plot.R`
- `tests/testthat/test-mts_plot.R`
- `man/earnmisc-package.Rd`
- added new `man/mts_*.Rd` help files
- removed old `man/*_mts*.Rd` help files for the old names

Tests revised:
- Updated all mts workflow tests to use the new names.
- Added export checks confirming the new names are exported and the old names are not.
- Added a workflow check covering `mts_plot()`, `mts_lines()`, `mts_abline()`, `mts_set_panel()`, and `mts_legend()`.

Verification:
- `make document`: completed and regenerated `NAMESPACE`/help files.
- `make test`: passed.
- `make check`: passed, `Status: OK`. It printed repository-index warnings from unavailable CRAN/Bioconductor URLs, but the check completed successfully.

I also searched package source, tests, generated help, and metadata for the old names; no old public-name references remain there. Existing unrelated changes in `PROMPTS_used.md` and `PROMPT_latest.md` were left untouched.
