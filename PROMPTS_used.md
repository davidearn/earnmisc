# Codex Prompt Log

Entries are append-only by default. Edit by hand if needed.


## 2026-05-09T18:09:41+00:00 — `20260509T180941Z`

<!-- codex-workflow-entry: 20260509T180941Z -->

### Prompt

I want to create the initial skeleton and first implementation of a new R package called `earnmisc`.

Please read `AGENTS.md` first and follow it closely.

Goal for this first pass:
- Create a lean R package skeleton.
- Implement the initial general-purpose utilities.
- Add roxygen2 documentation.
- Add testthat tests.
- Ensure package-level help `?earnmisc` works.
- Keep dependencies minimal.

Initial exported functions to implement:

```r
okabe_ito_colours()
okabe_ito_palette()
xys_line()
```

Also consider implementing these if the design is simple and general-purpose:

```r
named_par_usr()
named_par_mar()
plot_metadata()
```

Do not over-engineer. It is fine to leave plot metadata helpers minimal if the reference code suggests too much package-specific complexity.

Important style requirements:
- Function names use underscores.
- Function arguments and local non-function object names use dots.
- Comments at the start of lines begin with `##`.
- End-of-line comments begin with `#`.
- Use Canadian spelling in documentation, comments, messages, and warnings.
- Prefer base R, `graphics`, `grDevices`, and `utils`.
- Avoid tidyverse dependencies.
- Use roxygen2.
- Use testthat.
- Export only generally useful utilities.

For `xys_line()`:

```r
xys_line(x, y, slope, ...)
```

should call something equivalent to:

```r
graphics::abline(a = y - slope * x, b = slope, ...)
```

and should invisibly return something useful, preferably:

```r
c(intercept = y - slope * x, slope = slope)
```

For Okabe--Ito colours:
- Provide the standard Okabe--Ito colourblind-friendly palette.
- Use these names:

```text
black
orange
sky_blue
bluish_green
yellow
blue
vermillion
reddish_purple
```

- Provide a function returning the full named palette.
- Provide a function returning the first `n` colours.
- Support `alpha` cleanly if possible, using `grDevices::adjustcolor()`.

Repository notes:
- `reference-code/` may contain useful reference material, but it is for inspection only.
- Do not copy code blindly from `reference-code/`.
- Reimplement clean, general-purpose versions suitable for `earnmisc`.
- Ensure `reference-code/` is ignored by Git and excluded from R package builds.
- The repository may contain `tools/` and `Makefile` copied from `agemortr`; these are development workflow files, not package functionality.
- Do not modify `tools/` unless necessary.
- Do not run `make prompt`, `make response`, or `make record.commit`.
- Do not create Git commits.

Please create or update these files as appropriate:

```text
DESCRIPTION
NAMESPACE
R/earnmisc-package.R
R/okabe_ito.R
R/xys_line.R
R/plot_metadata.R
tests/testthat.R
tests/testthat/test-okabe_ito.R
tests/testthat/test-xys_line.R
tests/testthat/test-plot_metadata.R
.Rbuildignore
.gitignore
README.md
```

Verification:
- If the Makefile exists and the relevant targets are usable, run:

```sh
make document
make test
make check
```

- If Makefile targets are not yet usable, run the closest direct R equivalents, such as:

```sh
Rscript -e 'roxygen2::roxygenise()'
Rscript -e 'testthat::test_local()'
R CMD check .
```

Please report:
1. What files you created or changed.
2. What functions were implemented and exported.
3. What tests were added.
4. What verification commands were run and their results.
5. Any assumptions or TODOs.

### Response Summary

<!-- codex-workflow-response-start: 20260509T180941Z -->
Implemented the initial `earnmisc` R package skeleton and first utility set.

**Changed/Created**
- Package metadata: [DESCRIPTION](/Users/earn/r/earnmisc/DESCRIPTION), [LICENSE](/Users/earn/r/earnmisc/LICENSE)
- R sources: [R/earnmisc-package.R](/Users/earn/r/earnmisc/R/earnmisc-package.R), [R/okabe_ito.R](/Users/earn/r/earnmisc/R/okabe_ito.R), [R/xys_line.R](/Users/earn/r/earnmisc/R/xys_line.R), [R/plot_metadata.R](/Users/earn/r/earnmisc/R/plot_metadata.R)
- Generated docs/namespace: [NAMESPACE](/Users/earn/r/earnmisc/NAMESPACE), `man/*.Rd`
- Tests: [tests/testthat.R](/Users/earn/r/earnmisc/tests/testthat.R), plus focused test files for colours, `xys_line()`, and plot metadata
- Package hygiene: [.Rbuildignore](/Users/earn/r/earnmisc/.Rbuildignore), [.gitignore](/Users/earn/r/earnmisc/.gitignore), [README.md](/Users/earn/r/earnmisc/README.md)

**Exported Functions**
- `okabe_ito_colours()`
- `okabe_ito_palette()`
- `xys_line()`
- `named_par_usr()`
- `named_par_mar()`
- `plot_metadata()`

`?earnmisc` is supported through generated package-level documentation with alias `earnmisc`.

**Tests Added**
- Okabe-Ito palette names, values, alpha handling, first-`n` palette selection, and input validation.
- `xys_line()` intercept/slope invisible return and scalar input validation.
- Plot metadata helper names, types, lengths, and returned list structure.

**Verification**
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

During `R CMD check`, R printed repository access warnings while checking dependencies because network access is unavailable/restricted, but the check completed cleanly with `Status: OK`.

**Assumptions/TODOs**
- Used `MIT + file LICENSE` with the R-standard MIT license stub.
- Kept plot metadata helpers minimal and general-purpose.
- No commits were created, and prompt/response workflow targets were not run.
<!-- codex-workflow-response-end: 20260509T180941Z -->

### Commit

<!-- codex-workflow-commit-start: 20260509T180941Z -->
- Recorded: `2026-05-09T18:13:15+00:00`
- Hash: `3d693b882b69f9d36da22d66553e6b43990781c5`
- Subject: Initialize earnmisc package skeleton and utility functions
<!-- codex-workflow-commit-end: 20260509T180941Z -->

## 2026-05-09T18:35:21+00:00 — `20260509T183521Z`

<!-- codex-workflow-entry: 20260509T183521Z -->

### Prompt

Please revise the initial `earnmisc` implementation based on the following API and documentation requests.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/` unless explicitly necessary.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Okabe--Ito colours

The package should support both the original Okabe--Ito palette and an extended Okabe--Ito-style palette, as in the reference code.

Please inspect the relevant reference code in:

```text
reference-code/okabe_ito_from_gaemr.R
```

Use it for guidance only. Do not copy blindly.

Requirements:
- Make the original Okabe--Ito colours available.
- Make the extended Okabe--Ito colours available.
- Documentation should clearly distinguish the original palette from the extended palette.
- The default behaviour should remain simple and unsurprising.
- Preserve clear, stable names for colours.
- Continue to support alpha cleanly using `grDevices::adjustcolor()` if already implemented.
- Add or revise tests for original palette, extended palette, names, values, alpha handling, and input validation.

Please decide the cleanest API, but prefer keeping the existing names if possible:

```r
okabe_ito_colours()
okabe_ito_palette()
```

For example, it might be reasonable for one or both functions to have an argument such as `extended = FALSE`, but choose the cleanest design and document it clearly.

## Named graphics parameters

Please add a general helper:

```r
named_par_list()
```

This should return the full output of `graphics::par(no.readonly = TRUE)` or equivalent, but with vector-valued entries named sensibly where possible.

Requirements:
- Preserve all standard `par()` entries.
- Add names to common vector entries such as `usr`, `mar`, `oma`, `mai`, `omi`, `pin`, `plt`, `fig`, and similar where sensible.
- Avoid over-engineering.
- Keep the helper general-purpose.
- Export it if it is useful as a standalone utility.
- Add roxygen2 documentation and tests.

The existing helpers:

```r
named_par_usr()
named_par_mar()
```

should either use `named_par_list()` internally where appropriate, or remain as simple focused helpers if that is cleaner.

## `plot_metadata()`

Revise `plot_metadata()` so that it includes the named full par list produced by `named_par_list()`.

For example, the returned metadata should include something like:

```r
par.list
```

where `par.list` is the named list returned by `named_par_list()`.

Please keep `plot_metadata()` general-purpose and not tied to `agemortr`.

Update documentation and tests accordingly.

## `xys_line()` vectorisation

Please check whether `xys_line()` currently supports vector input.

It should support vector arguments.

Required behaviour:

```r
xys_line(0, c(0.1, -0.1), 1)
```

should draw two parallel lines with intercepts `0.1` and `-0.1`.

If more than one of `x`, `y`, and `slope` is a vector, then all combinations should be plotted.

For example, conceptually:

```r
xys_line(x = c(0, 1), y = c(0.1, -0.1), slope = c(1, 2))
```

should plot every combination of `x`, `y`, and `slope`.

Requirements:
- Use a clear and predictable implementation, probably based on `expand.grid()` or equivalent base R code.
- Call `graphics::abline()` once per line.
- Return the intercept and slope values invisibly in a useful structure.
- For a scalar call, preserve the existing simple return if possible, or document any intentional change.
- For vectorised calls, return enough information to identify all plotted lines.
- Add examples showing scalar and vector use.
- Add tests for scalar input, one vector argument, and multiple vector arguments.
- Avoid brittle graphics-device tests; test the computed return values.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

If any Makefile targets are unavailable, use the closest direct R equivalents.

Please report:
1. What design choices you made.
2. What files you changed.
3. What functions were added or revised.
4. What tests were added or revised.
5. What verification commands you ran and their results.
6. Any remaining TODOs or questions.

### Response Summary

<!-- codex-workflow-response-start: 20260509T183521Z -->
Implemented the requested revisions.

**Design Choices**
- `okabe_ito_colours(extended = FALSE, alpha = NULL)` now returns the original 8-colour palette by default.
- `extended = TRUE` appends `grey = "#999999"` and `amber = "#EECC66"`.
- `okabe_ito_palette()` keeps the same name and adds `extended`, with the default `n` matching the selected palette.
- `xys_line()` now expands all combinations of `x`, `y`, and `slope` using `expand.grid()` and calls `graphics::abline()` once per line.
- Scalar `xys_line()` calls preserve the previous invisible return shape: `c(intercept = ..., slope = ...)`.
- Vectorised `xys_line()` calls invisibly return a data frame with `x`, `y`, `slope`, and `intercept`.
- Added exported `named_par_list()`, used by `named_par_usr()`, `named_par_mar()`, and `plot_metadata()`.

The requested `reference-code/okabe_ito_from_gaemr.R` was not present. I used the available equivalent, `reference-code/colours_from_gaemr.R`, as guidance.

**Files Changed**
- [R/okabe_ito.R](/Users/earn/r/earnmisc/R/okabe_ito.R)
- [R/xys_line.R](/Users/earn/r/earnmisc/R/xys_line.R)
- [R/plot_metadata.R](/Users/earn/r/earnmisc/R/plot_metadata.R)
- [R/earnmisc-package.R](/Users/earn/r/earnmisc/R/earnmisc-package.R)
- [NAMESPACE](/Users/earn/r/earnmisc/NAMESPACE)
- `man/*.Rd`, including new `man/named_par_list.Rd`
- [tests/testthat/test-okabe_ito.R](/Users/earn/r/earnmisc/tests/testthat/test-okabe_ito.R)
- [tests/testthat/test-xys_line.R](/Users/earn/r/earnmisc/tests/testthat/test-xys_line.R)
- [tests/testthat/test-plot_metadata.R](/Users/earn/r/earnmisc/tests/testthat/test-plot_metadata.R)

**Functions Added/Revised**
- Added/exported: `named_par_list()`
- Revised: `okabe_ito_colours()`, `okabe_ito_palette()`, `xys_line()`, `named_par_usr()`, `named_par_mar()`, `plot_metadata()`

**Tests**
- Added coverage for original and extended Okabe-Ito palettes, names, values, alpha handling, and validation.
- Added `xys_line()` tests for scalar input, one vector argument, and all combinations of multiple vector arguments.
- Added `named_par_list()` tests checking preservation of `par(no.readonly = TRUE)` entries and names for common vector parameters.
- Updated `plot_metadata()` tests to verify `par.list` comes from the named full par list.

**Verification**
- `make document`: passed.
- `make test`: passed.
- `make check`: passed, `Status: OK`.

There were pre-existing unrelated dirty files: `PROMPT_latest.md`, `PROMPTS_used.md`, and `sandbox/`. I left them alone.
<!-- codex-workflow-response-end: 20260509T183521Z -->

### Commit

<!-- codex-workflow-commit-start: 20260509T183521Z -->
- Recorded: `2026-05-09T18:39:39+00:00`
- Hash: `69fcd7f9283301112ddae7e4b171b55577b83cdd`
- Subject: Add extended palettes and vectorised plotting helpers
<!-- codex-workflow-commit-end: 20260509T183521Z -->

## 2026-05-09T18:53:11+00:00 — `20260509T185311Z`

<!-- codex-workflow-entry: 20260509T185311Z -->

### Prompt

Please fix two issues in `xys_line()`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Problem 1: graphical parameters are not vectorised correctly

Currently, `xys_line()` ignores all but the first component of vector graphical parameters such as `col`, `lty`, and possibly `lwd`.

For example:

```r
plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))
xys_line(0, c(0.1, -0.1), 1,
         col = c("blue", "red"),
         lty = c("solid", "dotted"))
```

should draw one solid blue line and one dotted red line, but currently both lines are solid blue.

Please revise `xys_line()` so that graphical parameters supplied through `...` are handled sensibly when multiple lines are drawn.

Requirements:
- If a graphical parameter in `...` has length 1, recycle it for all lines.
- If a graphical parameter in `...` has length equal to the number of lines, use the corresponding element for each line.
- Use R’s ordinary recycling rules where appropriate.
- Pass the correct scalar graphical parameters to each individual `graphics::abline()` call.
- Preserve existing scalar behaviour.

This should work for common `abline()` graphical parameters such as:

```r
col
lty
lwd
```

but the implementation should not be unnecessarily restricted to only these names.

## Problem 2: infinite slopes should work

Currently, `xys_line()` crashes when `slope = Inf`.

A call such as:

```r
xys_line(0.5, 0, Inf)
```

should draw a vertical line through `x = 0.5`, equivalent to:

```r
graphics::abline(v = 0.5)
```

Requirements:
- `slope = Inf` should draw a vertical line at `x`.
- `slope = -Inf` should also draw a vertical line at `x`.
- For infinite slopes, `y` is irrelevant for plotting but should still be accepted for API consistency.
- The invisible return value should remain useful.
- For a scalar infinite-slope call, return something sensible and documented, for example:

```r
c(intercept = NA_real_, slope = Inf)
```

or include `x` if that is cleaner. Choose and document the design.
- For vectorised calls, include enough information in the returned data frame to identify vertical lines, including `x`, `y`, `slope`, and `intercept`, with `intercept = NA_real_` for vertical lines.
- Mixed finite and infinite slopes should work.

Examples that should work:

```r
plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))
xys_line(0, c(0.1, -0.1), 1,
         col = c("blue", "red"),
         lty = c("solid", "dotted"))

plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))
xys_line(c(-0.5, 0.5), 0, Inf,
         col = c("blue", "red"),
         lty = c("solid", "dotted"))

plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))
xys_line(0, 0, c(1, Inf),
         col = c("blue", "red"),
         lty = c("solid", "dotted"))
```

## Tests

Please add or revise tests for:
- vectorised `col`;
- vectorised `lty`;
- vectorised `lwd` if straightforward;
- scalar finite slope;
- scalar infinite slope;
- vectorised infinite slopes;
- mixed finite and infinite slopes;
- the invisible return values.

Avoid brittle graphics-device or image-comparison tests. Prefer testing the computed return values. If testing propagation of graphical parameters requires mocking or refactoring, keep the implementation simple and do not introduce heavy dependencies.

## Documentation

Please update roxygen2 documentation and examples for `xys_line()` to show:
- vectorised `x`, `y`, and `slope`;
- vectorised graphical parameters such as `col` and `lty`;
- infinite slopes for vertical lines.

Keep examples lightweight and check-friendly.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What bug caused graphical parameters to use only the first value.
2. How vector graphical parameters are now handled.
3. How infinite slopes are now handled.
4. What files changed.
5. What tests were added or revised.
6. What verification commands were run and their results.

### Response Summary

<!-- codex-workflow-response-start: 20260509T185311Z -->
Fixed `xys_line()`.

The graphical-parameter bug came from passing the full `...` unchanged to each scalar `graphics::abline()` call. Since each call draws one line, graphics parameters like `col = c("blue", "red")` were effectively treated as scalar and only the first value was used.

Now `xys_line()` expands graphical parameters once per line:
- length-1 values are recycled for every line;
- length-`n` values are matched line-by-line;
- non-multiple lengths use ordinary recycling with a warning;
- each `abline()` call receives scalar line-specific parameters.

Infinite slopes now work:
- `slope = Inf` and `slope = -Inf` call `graphics::abline(v = x, ...)`;
- scalar infinite-slope calls invisibly return `c(intercept = NA_real_, slope = Inf)`;
- vectorised returns include `x`, `y`, `slope`, and `intercept`, with `intercept = NA_real_` for vertical lines;
- mixed finite and infinite slopes are handled in the same call.

Changed files:
- [R/xys_line.R](/Users/earn/r/earnmisc/R/xys_line.R)
- [tests/testthat/test-xys_line.R](/Users/earn/r/earnmisc/tests/testthat/test-xys_line.R)
- [man/xys_line.Rd](/Users/earn/r/earnmisc/man/xys_line.Rd)

Tests added/revised for scalar finite slope, scalar infinite slope, vectorised `col`, `lty`, `lwd`, scalar graphical-parameter recycling, vectorised infinite slopes, mixed finite/infinite slopes, and invisible return values.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

I left the pre-existing unrelated dirty files alone: `PROMPT_latest.md`, `PROMPTS_used.md`, and `sandbox/explore.R`.
<!-- codex-workflow-response-end: 20260509T185311Z -->

### Commit

<!-- codex-workflow-commit-start: 20260509T185311Z -->
- Recorded: `2026-05-09T18:55:56+00:00`
- Hash: `5220ec47776a8173d3245668d1745643d2e10139`
- Subject: Fix xys_line graphical parameter recycling and vertical lines
<!-- codex-workflow-commit-end: 20260509T185311Z -->

## 2026-05-09T19:35:06+00:00 — `20260509T193506Z`

<!-- codex-workflow-entry: 20260509T193506Z -->

### Prompt

Please revise the Okabe--Ito colour helpers in `earnmisc`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Required changes

### Default to the extended palette

Change the default behaviour so that the extended Okabe--Ito palette is used by default.

Specifically:

```r
okabe_ito_colours()
okabe_ito_palette()
```

should use `extended = TRUE` by default.

Documentation should clearly explain:
- the first 8 colours are the original Okabe--Ito colourblind-friendly palette;
- additional colours are extensions used for convenience;
- users can request only the original palette with `extended = FALSE`.

Please update tests accordingly.

### Export convenient colour constants

Export convenient named colour constants following the existing `gaemr` style.

Please create and export objects such as:

```r
oi.black
oi.orange
oi.sky_blue
oi.bluish_green
oi.yellow
oi.blue
oi.vermillion
oi.reddish_purple
oi.grey
oi.amber
```

These should be character strings containing the corresponding hex colours.

Requirements:
- Export these objects.
- Document them together in a single roxygen2 help topic, probably something like `?oi_colours`.
- Keep the names stable.
- Ensure these objects agree exactly with `okabe_ito_colours(extended = TRUE)`.
- Add tests.

Do not add support for quoted pseudo-colour names such as:

```r
col = "oi.orange"
```

The intended plotting idiom is:

```r
col = oi.orange
```

where `oi.orange` evaluates to a valid R colour string.

### Add alpha helper functions

Please add clean helpers for alpha-adjusted colours without creating many exported alpha-specific objects.

Preferred API:

```r
oi_alpha(colour, alpha)
oi_colour(name, alpha = NULL, extended = TRUE)
```

Suggested behaviour:

```r
oi_alpha(oi.orange, 0.023)
oi_colour("orange", alpha = 0.023)
oi_colour("sky_blue", alpha = 0.4)
```

Requirements for `oi_alpha()`:
- Accept one or more actual R colour values, such as `oi.orange`, `"#E69F00"`, or `"orange"`.
- Accept `alpha`.
- Use `grDevices::adjustcolor()`.
- Return alpha-adjusted colours.
- Validate `alpha` sensibly.

Requirements for `oi_colour()`:
- Accept one or more Okabe--Ito palette colour names, such as `"orange"` or `"sky_blue"`.
- Do not treat strings like `"oi.orange"` as special.
- Use names from `okabe_ito_colours(extended = extended)`.
- Support `alpha = NULL` for unmodified colours.
- Support numeric `alpha` using `oi_alpha()`.
- Return named colours where sensible.
- Give clear errors for unknown names.
- Add lightweight examples.

Do not create exported objects such as `oi.orange.023`. Instead, document that:

```r
oi_alpha(oi.orange, 0.023)
```

or

```r
oi_colour("orange", alpha = 0.023)
```

is the supported way to obtain an alpha-adjusted version.

## Documentation

Update roxygen2 documentation for:
- `okabe_ito_colours()`;
- `okabe_ito_palette()`;
- the exported `oi.*` colour constants;
- `oi_alpha()`;
- `oi_colour()`.

Documentation should use Canadian spelling.

Examples should be lightweight and check-friendly.

## Tests

Please add or revise tests for:
- default extended palette behaviour;
- `extended = FALSE`;
- exported `oi.*` constants;
- consistency between constants and `okabe_ito_colours(extended = TRUE)`;
- `oi_alpha()`;
- `oi_colour()`;
- alpha validation;
- unknown colour-name errors;
- ensuring `"oi.orange"` is not treated as a valid palette colour name.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What API changes you made.
2. What colour constants were exported.
3. How alpha-adjusted colours are now obtained.
4. What files changed.
5. What tests were added or revised.
6. What verification commands were run and their results.

### Response Summary

<!-- codex-workflow-response-start: 20260509T193506Z -->
Implemented the Okabe-Ito revisions.

API changes:
- `okabe_ito_colours()` now defaults to `extended = TRUE`.
- `okabe_ito_palette()` now defaults to the extended palette and returns 10 colours by default.
- `extended = FALSE` returns only the original 8-colour Okabe-Ito palette.
- Added `oi_alpha(colour, alpha)` for alpha-adjusting actual R colour values.
- Added `oi_colour(name, alpha = NULL, extended = TRUE)` for selecting palette colours by palette name.

Exported constants:
`oi.black`, `oi.orange`, `oi.sky_blue`, `oi.bluish_green`, `oi.yellow`, `oi.blue`, `oi.vermillion`, `oi.reddish_purple`, `oi.grey`, `oi.amber`.

Alpha-adjusted colours are now obtained with:
```r
oi_alpha(oi.orange, 0.023)
oi_colour("orange", alpha = 0.023)
```
No pseudo-colour strings like `"oi.orange"` are supported.

Changed files:
- [R/okabe_ito.R](/Users/earn/r/earnmisc/R/okabe_ito.R)
- [tests/testthat/test-okabe_ito.R](/Users/earn/r/earnmisc/tests/testthat/test-okabe_ito.R)
- [NAMESPACE](/Users/earn/r/earnmisc/NAMESPACE)
- generated docs: `man/okabe_ito_colours.Rd`, `man/okabe_ito_palette.Rd`, `man/oi_colours.Rd`, `man/oi_alpha.Rd`, `man/oi_colour.Rd`

Tests added/revised for:
- extended palette as default;
- `extended = FALSE`;
- exported `oi.*` constants;
- constant/palette consistency;
- `oi_alpha()`;
- `oi_colour()`;
- alpha validation;
- unknown colour names;
- `"oi.orange"` not being treated as a palette name.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

I left the pre-existing unrelated dirty files alone: `PROMPT_latest.md`, `PROMPTS_used.md`, and `sandbox/explore.R`.
<!-- codex-workflow-response-end: 20260509T193506Z -->

### Commit

<!-- codex-workflow-commit-start: 20260509T193506Z -->
- Recorded: `2026-05-09T19:42:06+00:00`
- Hash: `d226a32c5e0290eb4df60fec67ac9f792f088620`
- Subject: Add Okabe-Ito constants and alpha helpers
<!-- codex-workflow-commit-end: 20260509T193506Z -->

## 2026-05-09T22:52:07+00:00 — `20260509T225207Z`

<!-- codex-workflow-entry: 20260509T225207Z -->

### Prompt

Please revise the proposed `nice_text()` design so that `earnmisc` ships with default TeX macro and ignore-command files.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add `nice_text()` to `earnmisc`, with package-supplied default TeX support files.

The package should include default files that can be maintained over time:

```text
inst/tex/default-macros.tex
inst/tex/default-ignore-commands.txt
```

These files should provide the basic TeX macro expansion and ignore-command behaviour that most users of `nice_text()` will want, without requiring them to configure anything.

Users should also be able to supply their own files, either replacing the package defaults or appending to them.

## Main API

Please implement and export:

```r
nice_text(
  x,
  use.tikz = NULL,
  macros.file = NULL,
  ignore.file = NULL,
  append.macros = TRUE,
  append.ignore = TRUE,
  warn = TRUE
)
```

Use this exact API unless there is a strong reason to adjust it.

## Default package files

Add package default files:

```text
inst/tex/default-macros.tex
inst/tex/default-ignore-commands.txt
```

After installation, these should be accessed with:

```r
system.file("tex", "default-macros.tex", package = "earnmisc")
system.file("tex", "default-ignore-commands.txt", package = "earnmisc")
```

The default macro file should include a small, conservative set of generally useful macros, for example definitions related to common plot-label notation. Include `\Rn` support if the underlying macros are defined, for example:

```tex
\newcommand{\R}{\mathcal R}
\newcommand{\Rn}{\R_0}
```

The default ignore-command file should include common TeX commands that should be removed or simplified for non-tikz graphics devices, such as:

```text
\mathrm
\mathsf
\mathbf
\mathit
\textrm
\textsf
\textbf
\textit
\quad
\qquad
\,
\:
\;
\!
```

Keep both files conservative. This is not intended to be a full TeX system.

## User-supplied files

Users should be able to provide additional macro and ignore files with:

```r
nice_text(x, macros.file = "my-macros.tex")
nice_text(x, ignore.file = "my-ignore-commands.txt")
```

The default should be to append user-supplied files to the package defaults:

```r
append.macros = TRUE
append.ignore = TRUE
```

This means:
- package defaults are read first;
- user-supplied files are read second;
- user definitions may override package defaults if the same macro is defined again.

If `append.macros = FALSE`, use only `macros.file`.

If `append.ignore = FALSE`, use only `ignore.file`.

If `macros.file = NULL`, check:

```r
getOption("earnmisc.tex_macros_file")
```

If that option is set, treat it as the user-supplied macros file.

If `ignore.file = NULL`, check:

```r
getOption("earnmisc.tex_ignore_file")
```

If that option is set, treat it as the user-supplied ignore file.

The package defaults should still be used unless the corresponding append argument is `FALSE`.

## Helper functions for inspection

Please add easy ways to inspect the active and default TeX support lists.

Implement and export these functions:

```r
nice_text_default_macros_file()
nice_text_default_ignore_file()
nice_text_macros(macros.file = NULL, append.macros = TRUE)
nice_text_ignore_commands(ignore.file = NULL, append.ignore = TRUE)
```

Suggested behaviour:

### `nice_text_default_macros_file()`

Return the path to the installed package default macros file.

### `nice_text_default_ignore_file()`

Return the path to the installed package default ignore-command file.

### `nice_text_macros()`

Return the currently active no-argument macro definitions as a named character vector or data frame.

It should include:
- package defaults;
- user option file from `getOption("earnmisc.tex_macros_file")`, if set;
- explicit `macros.file`, if supplied;
- user definitions appended or replacing defaults according to `append.macros`.

Document the exact return type.

### `nice_text_ignore_commands()`

Return the currently active ignore-command list as a character vector.

It should include:
- package defaults;
- user option file from `getOption("earnmisc.tex_ignore_file")`, if set;
- explicit `ignore.file`, if supplied;
- user commands appended or replacing defaults according to `append.ignore`.

Document the exact return type.

## `use.tikz` behaviour

If `use.tikz` is `TRUE`, return `x` unchanged.

If `use.tikz` is `FALSE`, preprocess `x` using macros and ignore-command rules, then convert with `latex2exp::TeX()` when `latex2exp` is available.

If `use.tikz = NULL`, look for an object called `use.tikz` in the calling environment.

Suggested behaviour:
- If the calling environment contains a scalar logical object named `use.tikz`, use that value.
- Otherwise default to `FALSE`.
- Validate that `use.tikz` is ultimately a scalar logical value.

## Dependencies

Do not put `latex2exp` in `Imports`.

Use it conditionally via:

```r
requireNamespace("latex2exp", quietly = TRUE)
```

Add `latex2exp` to `Suggests` if needed.

If `latex2exp` is not available and `use.tikz = FALSE`, return the preprocessed character vector rather than failing.

## TeX macro expansion

Support simple no-argument definitions of the form:

```tex
\newcommand{\foo}{replacement}
\renewcommand{\foo}{replacement}
\def\foo{replacement}
```

Requirements:
- Support no-argument macros only in this first implementation.
- Recursive expansion is useful, but protect against infinite loops with a small maximum number of passes.
- Ignore unsupported macro definitions rather than failing.
- Give clear warnings only when `warn = TRUE`.
- Keep the parser simple and well tested; do not attempt to implement full TeX.

Example:

```tex
\newcommand{\R}{\mathcal R}
\newcommand{\Rn}{\R_0}
```

should allow:

```r
nice_text("$\\Rn$")
```

to expand before non-tikz conversion.

## Ignored TeX commands for non-tikz devices

When `use.tikz = FALSE`, unsupported TeX commands should not leak into plot labels as plain text.

For example:

```r
nice_text("$A_{\\mathrm i}$")
```

should not produce a label containing the literal text `mathrm`.

Requirements:
- Commands like `\mathrm{...}`, `\mathsf{...}`, `\mathbf{...}`, `\mathit{...}`, and similar one-argument style wrappers should keep their contents and remove the command.
- Commands like `\quad`, `\,`, `\:`, `\;`, `\!`, and similar spacing commands should be removed.
- Keep this conservative. Do not rewrite mathematical meaning.
- Apply this only when `use.tikz = FALSE`.

For commands listed in ignore files:
- one-argument wrapper commands such as `\foo{bar}` should become `bar`;
- bare commands such as `\foo` should be removed.

## Documentation

Add roxygen2 documentation for:
- `nice_text()`;
- `nice_text_default_macros_file()`;
- `nice_text_default_ignore_file()`;
- `nice_text_macros()`;
- `nice_text_ignore_commands()`.

The documentation should explain:
- tikz versus non-tikz behaviour;
- how `use.tikz = NULL` is resolved from the calling environment;
- the package default TeX support files;
- how user files append to or replace defaults;
- the package options `earnmisc.tex_macros_file` and `earnmisc.tex_ignore_file`;
- that this is a lightweight helper, not a full TeX parser.

Use Canadian spelling.

Examples should be lightweight and check-friendly. Use `tempfile()` for examples involving user files.

Update package-level documentation if appropriate.

## Tests

Add focused `testthat` tests for:
- `use.tikz = TRUE` returns input unchanged;
- explicit `use.tikz = FALSE`;
- `use.tikz = NULL` finds a scalar logical `use.tikz` in the calling environment;
- default `use.tikz = NULL` falls back to `FALSE`;
- package default macros file exists;
- package default ignore-command file exists;
- `nice_text_macros()` returns package defaults;
- `nice_text_ignore_commands()` returns package defaults;
- simple macro expansion from the package default file;
- simple macro expansion from a temporary user file appended to defaults;
- user macro overriding a package default when appended;
- replacing defaults with `append.macros = FALSE`;
- ignored wrapper commands such as `\mathrm{...}`;
- ignored spacing commands such as `\quad`;
- ignore commands from a temporary user ignore file appended to defaults;
- replacing default ignore commands with `append.ignore = FALSE`;
- vector input preserves length;
- behaviour when `latex2exp` is unavailable if this can be tested cleanly without brittle mocking.

Avoid brittle tests that depend too much on the exact internal structure of `latex2exp` output. It is fine to test internal preprocessing helpers if needed.

## Internal helpers

It is fine to add unexported internal helpers such as:

```r
resolve_use_tikz()
nice_text_file_paths()
read_tex_macros()
expand_tex_macros()
read_tex_ignore_commands()
clean_tex_for_latex2exp()
```

Keep them simple and do not export them unless there is a clear reason.

## Package metadata

Update `DESCRIPTION` if needed.

Likely:
- add `latex2exp` to `Suggests`, not `Imports`.

Make sure files under `inst/tex/` are included in the package build.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What API you implemented.
2. Where the package default TeX support files live.
3. How user files append to or replace package defaults.
4. How to inspect the active and default macro and ignore lists.
5. How `use.tikz = NULL` is resolved.
6. What files changed.
7. What tests were added.
8. What verification commands were run and their results.
9. Any limitations or TODOs.

### Response Summary

<!-- codex-workflow-response-start: 20260509T225207Z -->
Implemented `nice_text()` and the TeX support files.

API added:
- `nice_text()`
- `nice_text_default_macros_file()`
- `nice_text_default_ignore_file()`
- `nice_text_macros()`
- `nice_text_ignore_commands()`

Default support files live at:
- [inst/tex/default-macros.tex](/Users/earn/r/earnmisc/inst/tex/default-macros.tex)
- [inst/tex/default-ignore-commands.txt](/Users/earn/r/earnmisc/inst/tex/default-ignore-commands.txt)

User files append by default. Package defaults are read first, option files second, explicit user files third, so later definitions can override earlier ones. `append.macros = FALSE` or `append.ignore = FALSE` omits the package defaults and uses only user files.

Inspection helpers:
- `nice_text_default_macros_file()` and `nice_text_default_ignore_file()` return default file paths.
- `nice_text_macros()` returns active no-argument macros as a named character vector.
- `nice_text_ignore_commands()` returns active ignored TeX commands as a character vector.

`use.tikz = NULL` now checks for a scalar logical `use.tikz` in the calling environment; if absent, it defaults to `FALSE`.

Changed files:
- [DESCRIPTION](/Users/earn/r/earnmisc/DESCRIPTION): added `latex2exp` to `Suggests`.
- [R/nice_text.R](/Users/earn/r/earnmisc/R/nice_text.R)
- [R/earnmisc-package.R](/Users/earn/r/earnmisc/R/earnmisc-package.R)
- [NAMESPACE](/Users/earn/r/earnmisc/NAMESPACE)
- `inst/tex/*`
- generated `man/nice_text*.Rd`
- [tests/testthat/test-nice_text.R](/Users/earn/r/earnmisc/tests/testthat/test-nice_text.R)

Tests added for tikz/non-tikz handling, default files, macro parsing/overrides, option files, ignore-command cleanup, append/replacement behaviour, vector length preservation, and `use.tikz` validation.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

Limitations: this intentionally supports only simple no-argument TeX macros and conservative command cleanup. It is not a full TeX parser.
<!-- codex-workflow-response-end: 20260509T225207Z -->

### Commit

<!-- codex-workflow-commit-start: 20260509T225207Z -->
- Recorded: `2026-05-09T23:08:50+00:00`
- Hash: `852e2ea19c6a033aa835957eeaff5570335a00f3`
- Subject: Add nice_text TeX label helper
<!-- codex-workflow-commit-end: 20260509T225207Z -->

## 2026-05-10T04:46:11+00:00 — `20260510T044611Z`

<!-- codex-workflow-entry: 20260510T044611Z -->

### Prompt

Please update the default TeX macro support for `earnmisc::nice_text()`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Replace the current package default macro file with my curated default macro list.

The file is:

```text
inst/tex/default-macros.tex
```

This file should reflect my stable cross-package plot-label notation. Do not add generic mathematical macros just because they seem common. In particular, do not re-add arbitrary defaults such as `\I`, `\E`, or `\dd` unless they appear explicitly below.

## New default macro file

Replace the contents of `inst/tex/default-macros.tex` with exactly this content:

```tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Conservative no-argument macros for earnmisc::nice_text() %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% basic reproduction number
\newcommand{\R}{\mathcal R}
\newcommand{\Rn}{\R_0}
%% incidence
\newcommand{\inc}{\iota}
%% Force of Infection
\newcommand{\FoI}{F}
%% Kermack and McKendrik
\newcommand{\kmsubscript}{\text{\scalebox{0.6}{\mathrm{KM}}}}
\newcommand{\Xkm}{\tX_{\kmsubscript}}
\newcommand{\Ykm}{\tY_{\kmsubscript}}
\newcommand{\Zkm}{\tZ_{\kmsubscript}}
%% approximate quantities
\newcommand{\tX}{\tilde{X}}
\newcommand{\tY}{\tilde{Y}}
\newcommand{\tZ}{\tilde{Z}}
\newcommand{\tinc}{\tilde{\inc}}
%% asymptotic values
\newcommand{\xp}{x^{+}} %{\infty}}
\newcommand{\xm}{x^{-}} %{-\infty}}
\newcommand{\zp}{z^{+}} %{\infty}}
\newcommand{\zm}{z^{-}} %{-\infty}}
\newcommand{\xpm}{x^\pm}
\newcommand{\xmp}{x^\mp}
\newcommand{\Xpm}{X^{\pm}}
%% multi-functions
\newcommand{\Xp}{X^{+}}
\newcommand{\Xm}{X^{-}}
%% exponential rates
\newcommand{\lamp}{{\lambda^{\!{+}}}}
\newcommand{\lamm}{{\lambda^{\!{-}}}}
\newcommand{\lampm}{\lambda^{\!{\pm}}}
\newcommand{\lammp}{\lambda^{\!{\mp}}}
\newcommand{\lambdakm}{\lambda_{\kmsubscript}}
%% peak values
\newcommand{\xpeak}{\hat{x}}
\newcommand{\ypeak}{\hat{y}}
\newcommand{\zpeak}{\hat{z}}
\newcommand{\taupeak}{\hat{\tau}}
\newcommand{\taupeakkm}{\taupeak_{\kmsubscript}}
\newcommand{\ypeakkm}{\ypeak_{\kmsubscript}}
\newcommand{\xpeakkm}{\xpeak_{\kmsubscript}}
\newcommand{\tFoIpeak}{\hat{\tilde{\FoI}}}
\newcommand{\tincpeak}{\hat{\tilde{\inc}}}
%% age of infection
\newcommand{\aoi}{\alpha}
%% Lambert W function
\newcommand{\Wp}{W_{\!+}}
\newcommand{\Wm}{W_{\!-}}
\newcommand{\Wpm}{W_{\!\pm}}
%% initial conditions
\newcommand{\tauinit}{\tau_{\mathrm{i}}}
\newcommand{\xinit}{x_{\mathrm{i}}}
\newcommand{\yinit}{y_{\mathrm{i}}}
\newcommand{\zinit}{z_{\mathrm{i}}}
%% order of magnitude
\newcommand{\Oh}{{\mathcal O}}
%% sets
\newcommand{\reals}{{\mathbb R}}
\newcommand{\integers}{{\mathbb Z}}
\newcommand{\naturals}{{\mathbb N}}
%% stage durations
\newcommand{\Tinf}{T_{\mathrm{inf}}}
\newcommand{\Tlat}{T_{\mathrm{lat}}}
%% entering boundary layer
\newcommand{\xin}{x_{\mathrm{in}}}
```

## Important parser expectations

The macro parser currently supports simple no-argument TeX macros. Please ensure it continues to parse this file correctly.

The parser should ignore comment lines and inline comments appropriately.

For example, lines such as:

```tex
\newcommand{\xp}{x^{+}} %{\infty}}
```

should define `\xp` as:

```tex
x^{+}
```

not include the trailing comment.

If the current parser does not strip inline comments safely, please fix that conservatively.

## Tests

Update or add tests so that:

- `nice_text_macros()` includes all macros from the new default file.
- `nice_text_macros()` includes `\FoI`.
- `nice_text_macros()` does not include arbitrary old defaults such as `\I`, `\E`, or `\dd`.
- selected recursive expansions work, including:
  - `\Rn`, which depends on `\R`;
  - `\tinc`, which depends on `\inc`;
  - `\tFoIpeak`, which depends on `\FoI`;
  - `\Xkm`, which depends on `\tX` and `\kmsubscript`.
- inline comments do not become part of macro replacement text.
- user-supplied macro files can still append to these defaults.
- user-supplied macro files can still override these defaults.
- `append.macros = FALSE` still replaces the package defaults.

Avoid brittle tests that require `latex2exp` to fully understand every TeX command in this file. It is fine to test macro parsing and expansion through internal helpers if that is the most stable approach.

## Documentation

Update documentation only if needed.

The documentation should make clear that:

- the default macro file is a curated `earnmisc` default;
- it is intentionally not a full manuscript preamble;
- users can append or replace it with `macros.file`, `append.macros`, and `options(earnmisc.tex_macros_file = ...)`.

Use Canadian spelling.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What changed in `inst/tex/default-macros.tex`.
2. Whether the parser needed changes for comments or inline comments.
3. What tests were added or revised.
4. What verification commands were run and their results.
5. Any limitations or TODOs.

### Response Summary

<!-- codex-workflow-response-start: 20260510T044611Z -->
Updated the default macro support for `nice_text()`.

What changed:
- Replaced [inst/tex/default-macros.tex](/Users/earn/r/earnmisc/inst/tex/default-macros.tex) with your curated cross-package plot-label macro list exactly as provided.
- Removed the old arbitrary defaults `\I`, `\E`, and `\dd`.
- Updated `nice_text_macros()` documentation to describe the default macro file as curated earnmisc plot-label notation, not a full manuscript preamble.

Parser changes:
- No parser code changes were needed. The existing `remove_tex_comment()` already strips unescaped inline `%` comments before parsing.
- Verified that `\newcommand{\xp}{x^{+}} %{\infty}}` parses as `x^{+}`.

Tests revised:
- `nice_text_macros()` now checks the full curated default macro name set.
- Added checks that `\FoI` is included.
- Added checks that old defaults `\I`, `\E`, and `\dd` are absent.
- Added recursive expansion checks for `\Rn`, `\tinc`, `\tFoIpeak`, and `\Xkm`.
- Added inline-comment parsing coverage for `\xp`.
- Existing tests still cover user macro append, override, and `append.macros = FALSE`.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

Limitations remain the same: macro support is intentionally limited to simple no-argument definitions and bounded recursive expansion, not full TeX parsing.
<!-- codex-workflow-response-end: 20260510T044611Z -->

### Commit

<!-- codex-workflow-commit-start: 20260510T044611Z -->
- Recorded: `2026-05-10T04:50:14+00:00`
- Hash: `1a4711ef1b6669ee36c3880662926948921ed58d`
- Subject: Update nice_text default macros
<!-- codex-workflow-commit-end: 20260510T044611Z -->

## 2026-05-10T06:07:15+00:00 — `20260510T060715Z`

<!-- codex-workflow-entry: 20260510T060715Z -->

### Prompt

Please fix `earnmisc::nice_text()` so that package/user macros are expanded for tikz output as well as non-tikz output.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Problem

`nice_text()` now works well when `use.tikz = FALSE`, but it fails with tikz devices because macro names such as `\Rn` are returned unchanged.

For example, this fails during tikz metric calculation:

```r
nice_text("$\\Rn$", use.tikz = TRUE)
```

because tikz/LaTeX receives:

```tex
$\Rn$
```

and `\Rn` is not defined in the standalone tikz LaTeX context.

The error is like:

```text
Error in getMetricsFromLatex(TeXMetrics, verbose = verbose) :
TeX was unable to calculate metrics for:

    $\Rn$
```

## Required behaviour

`nice_text()` should expand macros for both tikz and non-tikz output.

That means:

```r
nice_text("$\\Rn$", use.tikz = TRUE)
```

should return something like:

```tex
${\mathcal R}_0$
```

or an equivalent recursively expanded LaTeX string, not `"$\\Rn$"`.

For `use.tikz = TRUE`:
- expand macros using the package default macro file plus any user macro files;
- do not run the non-tikz cleanup/ignore-command step;
- do not call `latex2exp::TeX()`;
- return a character vector of expanded LaTeX strings.

For `use.tikz = FALSE`:
- keep the existing behaviour: expand macros, clean ignored commands, and call `latex2exp::TeX()` when available.

## Preserve append/replace semantics

Macro expansion for tikz output should use the same macro-source logic as non-tikz output:

- package defaults first;
- option file from `getOption("earnmisc.tex_macros_file")`, if set;
- explicit `macros.file`, if supplied;
- later definitions override earlier ones;
- `append.macros = FALSE` uses only user-supplied macro files and omits the package defaults.

Ignore-command files should still apply only to non-tikz output.

## Important distinction

Previously, `use.tikz = TRUE` returned `x` unchanged.

That is no longer sufficient.

The revised behaviour should be:

```r
if (use.tikz) {
  return(expand_macros_only(x))
}
```

not:

```r
if (use.tikz) {
  return(x)
}
```

Please update documentation to explain this clearly.

## Tests

Add or revise tests so that:

- `nice_text("$\\Rn$", use.tikz = TRUE)` expands `\Rn`.
- recursive expansion works in tikz mode, including:
  - `\Rn`;
  - `\tinc`;
  - `\tFoIpeak`;
  - `\Xkm`.
- tikz mode does not apply the ignore-command cleanup step.
  For example, `nice_text("$A_{\\mathrm{i}}$", use.tikz = TRUE)` should preserve `\mathrm`.
- tikz mode does not call `latex2exp::TeX()`.
- non-tikz behaviour still works.
- user macro append, override, and `append.macros = FALSE` work in tikz mode as well as non-tikz mode.
- vector input preserves length in tikz mode.

Avoid brittle tests that require a tikz device or actual LaTeX compilation. Test returned strings directly.

## Documentation

Update roxygen2 documentation for `nice_text()`.

The documentation should now say:

- tikz mode returns macro-expanded LaTeX strings;
- non-tikz mode returns `latex2exp::TeX()` output when available;
- macro expansion happens in both modes;
- ignored TeX command cleanup happens only in non-tikz mode;
- `nice_text()` is not a full TeX parser.

Use Canadian spelling.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. Why tikz mode was failing.
2. How macro expansion now works in tikz mode.
3. How tikz and non-tikz processing now differ.
4. What tests were added or revised.
5. What files changed.
6. What verification commands were run and their results.

### Response Summary

<!-- codex-workflow-response-start: 20260510T060715Z -->
Fixed `nice_text()` for tikz output.

Tikz mode was failing because `nice_text()` returned `x` unchanged when `use.tikz = TRUE`, so macros like `\Rn` reached tikz/LaTeX without definitions.

Now:
- `use.tikz = TRUE`: expands macros only, returns character LaTeX strings, does not apply ignore-command cleanup, and does not call `latex2exp::TeX()`.
- `use.tikz = FALSE`: expands macros, applies ignore-command cleanup, then calls `latex2exp::TeX()` when available.

Macro expansion in tikz mode uses the same source order as non-tikz mode:
package defaults, option file, explicit `macros.file`, with later definitions overriding earlier ones; `append.macros = FALSE` omits defaults.

Changed files:
- [R/nice_text.R](/Users/earn/r/earnmisc/R/nice_text.R)
- [tests/testthat/test-nice_text.R](/Users/earn/r/earnmisc/tests/testthat/test-nice_text.R)
- [man/nice_text.Rd](/Users/earn/r/earnmisc/man/nice_text.Rd)

Tests added/revised for:
- `nice_text("$\\Rn$", use.tikz = TRUE)` expansion.
- recursive tikz expansion for `\Rn`, `\tinc`, `\tFoIpeak`, and `\Xkm`.
- tikz mode preserving `\mathrm`.
- tikz mode returning character strings, not `latex2exp` output.
- user macro append, override, and `append.macros = FALSE` in tikz mode.
- vector length preservation in tikz mode.
- existing non-tikz behaviour remains covered.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

I left the pre-existing unrelated dirty files in `PROMPT*` and `sandbox/` alone.
<!-- codex-workflow-response-end: 20260510T060715Z -->

### Commit

<!-- codex-workflow-commit-start: 20260510T060715Z -->
_Pending._
<!-- codex-workflow-commit-end: 20260510T060715Z -->

## 2026-05-10T06:14:08+00:00 — `20260510T061408Z`

<!-- codex-workflow-entry: 20260510T061408Z -->

### Prompt

Please simplify the default TeX macro for `\kmsubscript` in `earnmisc::nice_text()`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Problem

After fixing macro expansion for tikz output, `\Rn` now works, but labels involving `\kmsubscript` fail during tikz metric calculation.

For example, macro expansion currently produces something like:

```tex
$\lambda_{\text{\scalebox{0.6}{\mathrm{KM}}}}$
```

and tikz/LaTeX fails with:

```text
Error in getMetricsFromLatex(TeXMetrics, verbose = verbose) :
TeX was unable to calculate metrics for:

    $\lambda_{\text{\scalebox{0.6}{\mathrm{KM}}}}$
```

The likely issue is that the expanded macro uses `\text` and `\scalebox`, which may not be available in the small LaTeX context used by tikz metric calculation.

## Requested change

Please simplify the default `\kmsubscript` macro in:

```text
inst/tex/default-macros.tex
```

Change it from the current form:

```tex
\newcommand{\kmsubscript}{\text{\scalebox{0.6}{\mathrm{KM}}}}
```

to a simpler, safer math-mode form such as:

```tex
\newcommand{\kmsubscript}{\mathrm{KM}}
```

Use this exact replacement unless there is a clearly better simple math-mode alternative.

The goal is for expanded labels such as:

```tex
$\lambda_{\kmsubscript}$
```

to become something like:

```tex
$\lambda_{\mathrm{KM}}$
```

which should be acceptable in the tikz metric calculation context.

## Tests

Please update tests accordingly.

Tests should verify that:

- `nice_text_macros()` reports `\kmsubscript` as `\mathrm{KM}`.
- tikz macro expansion of `"$\\lambdakm$"` produces a string involving `\lambda_{\mathrm{KM}}`, not `\text` or `\scalebox`.
- tikz macro expansion of `"$\\Xkm$"`, `"$\\Ykm$"`, and `"$\\Zkm$"` does not contain `\text` or `\scalebox`.
- existing recursive macro expansion tests still pass.
- non-tikz behaviour still works as before.

Avoid tests that require actually opening a tikz device or compiling LaTeX. Testing returned strings from `nice_text(..., use.tikz = TRUE)` is enough.

## Documentation

Update documentation only if it explicitly mentions the old `\kmsubscript` definition.

Keep the documentation clear that the default macros are intentionally simple and suitable for plot labels, not a full manuscript preamble.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What `\kmsubscript` was changed to.
2. Whether any parser or `nice_text()` code needed to change.
3. What tests were added or revised.
4. What verification commands were run and their results.
5. Any remaining limitations or TODOs.

### Response Summary

<!-- codex-workflow-response-start: 20260510T061408Z -->
Changed `\kmsubscript` in [inst/tex/default-macros.tex](/Users/earn/r/earnmisc/inst/tex/default-macros.tex) to:

```tex
\newcommand{\kmsubscript}{\mathrm{KM}}
```

No parser or `nice_text()` code changes were needed.

Tests revised in [tests/testthat/test-nice_text.R](/Users/earn/r/earnmisc/tests/testthat/test-nice_text.R):
- `nice_text_macros()` reports `kmsubscript` as `\mathrm{KM}`.
- tikz expansion of `"$\\lambdakm$"` gives `"$\\lambda_{\\mathrm{KM}}$"`.
- tikz expansion of `"$\\Xkm$"`, `"$\\Ykm$"`, and `"$\\Zkm$"` does not contain `\text` or `\scalebox`.
- Existing recursive expansion expectations were updated for the simpler KM subscript.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

Remaining limitation: `nice_text()` is still a lightweight no-argument macro expander, not a full TeX parser.
<!-- codex-workflow-response-end: 20260510T061408Z -->

### Commit

<!-- codex-workflow-commit-start: 20260510T061408Z -->
- Recorded: `2026-05-10T06:19:51+00:00`
- Hash: `997a8b3f6ff482bc4b338a3fbf23c66a812a17bf`
- Subject: remove tikz output file
<!-- codex-workflow-commit-end: 20260510T061408Z -->

## 2026-05-10T16:03:24+00:00 — `20260510T160324Z`

<!-- codex-workflow-entry: 20260510T160324Z -->

### Prompt

Please add tikz helper functions to `earnmisc`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add helpers:

```r
tikz_open()
tikz_info()
tikz_compile()
```

These should make it easier to open a `tikzDevice::tikz()` graphics device, retain metadata about the output file and device arguments, and compile the resulting `.tex` file to PDF.

## Background

`tikzDevice::tikz()` returns no useful value, so after opening a tikz device there is no direct way to recover the filename, width, height, or arguments used.

I want `earnmisc::tikz_open()` to wrap `tikzDevice::tikz()` and return/store this metadata.

The current `tikzDevice::tikz()` API includes arguments such as:

```r
file = filename
filename = ifelse(onefile, "./Rplots.tex", "./Rplot%03d.tex")
width = 7
height = 7
onefile = TRUE
bg = "transparent"
fg = "black"
pointsize = 10
lwdUnit = getOption("tikzLwdUnit")
standAlone = FALSE
bareBones = FALSE
console = FALSE
sanitize = FALSE
engine = getOption("tikzDefaultEngine")
documentDeclaration = getOption("tikzDocumentDeclaration")
packages
footer = getOption("tikzFooter")
symbolicColors = getOption("tikzSymbolicColors")
colorFileName = "%s_colors.tex"
maxSymbolicColors = getOption("tikzMaxSymbolicColors")
timestamp = TRUE
verbose = interactive()
```

Please explicitly expose these arguments in `tikz_open()`, rather than just using `...`.

Change one default for my workflow:

```r
standAlone = TRUE
```

instead of the `tikzDevice::tikz()` default `FALSE`.

## Dependency

Do not put `tikzDevice` in `Imports`.

Use it conditionally via:

```r
requireNamespace("tikzDevice", quietly = TRUE)
```

Add `tikzDevice` to `Suggests`.

If `tikzDevice` is not available, `tikz_open()` should fail with a clear error.

## `tikz_open()`

Please implement and export:

```r
tikz_open <- function(
  file = filename,
  filename = ifelse(onefile, "./Rplots.tex", "./Rplot%03d.tex"),
  width = 7,
  height = 7,
  onefile = TRUE,
  bg = "transparent",
  fg = "black",
  pointsize = 10,
  lwdUnit = getOption("tikzLwdUnit"),
  standAlone = TRUE,
  bareBones = FALSE,
  console = FALSE,
  sanitize = FALSE,
  engine = getOption("tikzDefaultEngine"),
  documentDeclaration = getOption("tikzDocumentDeclaration"),
  packages = NULL,
  footer = getOption("tikzFooter"),
  symbolicColors = getOption("tikzSymbolicColors"),
  colorFileName = "%s_colors.tex",
  maxSymbolicColors = getOption("tikzMaxSymbolicColors"),
  timestamp = TRUE,
  verbose = interactive(),
  message = TRUE
)
```

If `packages = NULL`, call `tikzDevice::tikz()` without explicitly passing `packages`, so that tikzDevice can use its own default machinery. If this is awkward, choose a clean implementation and document it.

Required behaviour:
- Open a tikz graphics device by calling `tikzDevice::tikz()` with the corresponding arguments.
- Return invisibly a list containing all argument values, plus useful metadata.
- Store the same list internally so `tikz_info()` can retrieve it later.
- Include at least:
  - `file`;
  - `filename`;
  - `width`;
  - `height`;
  - all other arguments passed to `tikzDevice::tikz()`;
  - `device`;
  - `device.name`;
  - `opened_at`, preferably `Sys.time()`;
  - `working_directory`, preferably `getwd()`;
  - `normalized_file`, using `normalizePath(file, mustWork = FALSE)`;
  - `pdf_file`, the expected PDF filename after compilation.

The returned object can be a plain list, but please give it a simple class, for example:

```r
class(info) <- c("earnmisc_tikz_info", "list")
```

### Messages from `tikz_open()`

By default, `tikz_open()` should print a message of the form:

```text
tikz_open: writing to filename.tex (width = 14, height = 7) ...
```

This should happen after the device has been opened successfully.

Use `message = TRUE` by default to control this.

If opening the device fails, give a clear error.

## `tikz_info()`

Please implement and export:

```r
tikz_info <- function(device = NULL)
```

Required behaviour:
- Return the most recent tikz info object if `device = NULL`.
- If `device` is supplied, return the stored info for that device if available.
- Return `NULL` or give a clear error if no matching info is available. Choose the cleaner behaviour and document it.
- Do not require the device still to be open; the info should remain available after `dev.off()`.

If possible, store info by device number in a package-private environment, and also store the most recent tikz info object.

## `tikz_compile()`

Please implement and export:

```r
tikz_compile <- function(
  x,
  engine = "lualatex",
  batchmode = TRUE,
  clean = FALSE,
  message = TRUE
)
```

`x` should be either:
- a character string giving the `.tex` filename; or
- a full list returned by `tikz_open()`.

Required behaviour:
- Determine the `.tex` file from `x`.
- Compile with `lualatex` by default.
- Use batch mode by default.
- Produce the corresponding `.pdf` file.
- Return the PDF filename invisibly or visibly. I prefer visible return so this works naturally:

```r
tikz.pdf <- tikz_compile(tikz.info)
system(paste0("open ", tikz.pdf))
```

So please return the PDF filename as a character string.
- By default, print a message indicating success, for example:

```text
tikz_compile: produced filename.pdf
```

- If compilation fails or the PDF is not produced, stop with a helpful error such as:

```text
tikz_compile: failed to produce filename.pdf
```

Include useful details if available, such as the exit status or log file path.

Implementation details:
- Use `system2()` rather than `system()`.
- Compile in the directory containing the `.tex` file, so relative paths work naturally.
- Quote paths safely.
- The default command should be approximately:

```sh
lualatex -interaction=batchmode filename.tex
```

- If `batchmode = FALSE`, omit `-interaction=batchmode` or use a less quiet interaction mode if that is cleaner.
- `clean = TRUE` may remove common auxiliary files such as `.aux`, `.log`, and `.out` after successful compilation. Keep this conservative.
- Do not delete the `.tex` or `.pdf` file.

## Expected usage

The following should work:

```r
tikz.info <- tikz_open(my.tex.file, width = 14)
plot(1:10)
dev.off()

tikz.pdf <- tikz_compile(tikz.info)
system(paste0("open ", tikz.pdf))
```

Also:

```r
tikz_open("figure.tex", width = 14, height = 7)
plot(1:10)
tikz.info()
dev.off()
tikz_compile("figure.tex")
```

## Documentation

Add roxygen2 documentation for:
- `tikz_open()`;
- `tikz_info()`;
- `tikz_compile()`.

Explain:
- `tikz_open()` wraps `tikzDevice::tikz()`;
- `standAlone = TRUE` is the `earnmisc` default;
- `tikz_open()` stores metadata because `tikzDevice::tikz()` itself returns no value;
- `tikz_compile()` uses `lualatex` by default;
- `tikzDevice` is suggested, not imported;
- a working LaTeX installation is required for compilation.

Use Canadian spelling.

Examples should be lightweight and check-friendly. Do not run actual tikz compilation in examples. Use `\dontrun{}` or `\donttest{}` where appropriate.

## Tests

Add focused tests where possible, but avoid brittle tests that require an installed LaTeX system or working tikzDevice unless already available.

Suggested tests:
- `tikz_compile()` resolves the expected PDF filename from a character `.tex` filename.
- `tikz_compile()` resolves the expected PDF filename from a `tikz_open()` info-like list.
- If testing actual compilation is not safe, isolate filename-resolution helpers and test those.
- `tikz_info()` returns `NULL` or an error before any tikz device has been opened, according to the documented design.
- Metadata construction includes all explicit `tikz_open()` arguments.
- `standAlone = TRUE` is the `tikz_open()` default.
- Message formatting can be tested if straightforward.
- Tests that require `tikzDevice` should skip if it is not installed.
- Tests that require `lualatex` should skip if it is not found with `Sys.which("lualatex")`.

## Package metadata

Update `DESCRIPTION`:
- add `tikzDevice` to `Suggests`.

Regenerate documentation and NAMESPACE.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What API you implemented.
2. What metadata `tikz_open()` returns and stores.
3. How `tikz_info()` retrieves stored info.
4. How `tikz_compile()` determines the PDF filename and runs LaTeX.
5. What dependencies were added to `Suggests`.
6. What tests were added or revised.
7. What verification commands were run and their results.
8. Any limitations or TODOs.

### Response Summary

<!-- codex-workflow-response-start: 20260510T160324Z -->
Implemented the tikz helpers.

API added:
- `tikz_open()`
- `tikz_info()`
- `tikz_compile()`

`tikz_open()`:
- Wraps `tikzDevice::tikz()` and keeps `tikzDevice` in `Suggests`, not `Imports`.
- Uses `standAlone = TRUE` by default.
- Returns invisibly and stores an `earnmisc_tikz_info` list with the tikz arguments plus metadata:
  `file`, `filename`, `width`, `height`, all other tikz arguments, `device`, `device.name`, `opened_at`, `working_directory`, `normalized_file`, and `pdf_file`.
- Omits `packages` from the `tikzDevice::tikz()` call when `packages = NULL`, but still records `packages = NULL` in metadata.
- Prints `tikz_open: writing to ...` after successful open when `message = TRUE`.

`tikz_info()`:
- Returns the most recent stored tikz info when `device = NULL`.
- Returns stored metadata for a supplied device number when available.
- Returns `NULL` when no matching info exists.
- Stored info remains available after `dev.off()`.

`tikz_compile()`:
- Accepts either a `.tex` filename or a `tikz_open()` info list.
- Resolves the PDF filename by replacing the input extension with `.pdf`.
- Runs `system2(engine, ...)` in the `.tex` file directory.
- Defaults to `lualatex -interaction=batchmode`.
- Returns the PDF filename visibly.
- `clean = TRUE` removes only conservative auxiliary files: `.aux`, `.log`, `.out`.

Dependency added:
- `tikzDevice` in `Suggests`.

Files changed:
- [DESCRIPTION](/Users/earn/r/earnmisc/DESCRIPTION)
- [R/tikz.R](/Users/earn/r/earnmisc/R/tikz.R)
- [R/earnmisc-package.R](/Users/earn/r/earnmisc/R/earnmisc-package.R)
- [NAMESPACE](/Users/earn/r/earnmisc/NAMESPACE)
- [tests/testthat/test-tikz.R](/Users/earn/r/earnmisc/tests/testthat/test-tikz.R)
- generated `man/tikz_open.Rd`, `man/tikz_info.Rd`, `man/tikz_compile.Rd`, and package docs

Tests added:
- PDF filename resolution from `.tex` names.
- Filename extraction from character input and info-like lists.
- Metadata construction and class.
- `standAlone = TRUE` default.
- `tikz_info()` empty and stored-info behaviour.
- Clear missing-`tikzDevice` error when applicable.
- Basic `tikz_compile()` input validation without requiring LaTeX.

Verification:
- `make document`: passed.
- `make test`: passed; one missing-`tikzDevice` test skipped because `tikzDevice` is installed locally.
- `make check`: passed with `Status: OK`.

Limitations: tests avoid actual tikz device rendering and LaTeX compilation unless those tools are explicitly available; `tikz_compile()` still requires a working LaTeX engine at runtime.
<!-- codex-workflow-response-end: 20260510T160324Z -->

### Commit

<!-- codex-workflow-commit-start: 20260510T160324Z -->
_Pending._
<!-- codex-workflow-commit-end: 20260510T160324Z -->

## 2026-05-11T15:13:05+00:00 — `20260511T151305Z`

<!-- codex-workflow-entry: 20260511T151305Z -->

### Prompt

Please add graphics-device helper functions to `earnmisc`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add and export two small helpers:

```r
dev_is_tikz()
dev_is_pdf()
```

These should return scalar `TRUE` or `FALSE` depending on the currently active graphics device.

Example intended use:

```r
if (dev_is_tikz()) {
  tikz_compile(...)
}
```

## Behaviour

### `dev_is_tikz()`

Return `TRUE` when the current graphics device appears to be a tikz device opened by `tikzDevice::tikz()` or `earnmisc::tikz_open()`.

Return `FALSE` otherwise, including when there is no open user graphics device.

### `dev_is_pdf()`

Return `TRUE` when the current graphics device is a PDF device opened by `grDevices::pdf()`.

Return `FALSE` otherwise, including when there is no open user graphics device.

## Implementation notes

Keep the implementation simple.

A reasonable starting point is to inspect the current device name using:

```r
names(grDevices::dev.cur())
```

or equivalent base R graphics-device information.

Please check the actual device names produced by ordinary `pdf()` and, when available, `tikzDevice::tikz()`.

If useful, add a small non-exported helper such as:

```r
current_device_name()
```

or:

```r
dev_name()
```

to avoid duplicating logic. Document any non-exported helper with roxygen2 comments, following `AGENTS.md`.

Do not introduce new required dependencies.

`dev_is_tikz()` may use device-name detection and/or stored metadata from `tikz_open()` if that makes the result more reliable. However, it should still work for a tikz device opened directly with `tikzDevice::tikz()` if possible.

## Edge cases

Please handle these cleanly:

- no open user graphics device;
- current device is the null device;
- current device is PDF;
- current device is tikz;
- current device is another device such as the default screen device.

The helpers should not error in ordinary use.

## Documentation

Add roxygen2 documentation for:

```r
dev_is_tikz()
dev_is_pdf()
```

Mention that these are lightweight helpers based on the currently active graphics device.

Use Canadian spelling.

Examples should be lightweight and check-friendly. Avoid examples requiring `tikzDevice` unless protected with `if (requireNamespace("tikzDevice", quietly = TRUE))`.

## Tests

Add tests for:

- both functions return scalar logical values;
- both return `FALSE` on the null device or when no user graphics device is active;
- `dev_is_pdf()` returns `TRUE` inside a temporary `pdf()` device;
- `dev_is_tikz()` returns `TRUE` inside a temporary tikz device when `tikzDevice` is installed;
- `dev_is_tikz()` tests skip cleanly when `tikzDevice` is unavailable.

Tests involving device opening should use `on.exit(grDevices::dev.off(), add = TRUE)` or equivalent cleanup so devices are not left open.

Avoid requiring LaTeX compilation. Opening a tikz device should be enough if `tikzDevice` is available; skip if not safe.

## Package docs

Update package-level documentation if appropriate, probably by mentioning these under graphics-device helpers.

Regenerate documentation and NAMESPACE.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What functions were added.
2. How the current device is detected.
3. How null/no-device cases are handled.
4. What tests were added.
5. What verification commands were run and their results.
6. Any limitations or TODOs.

### Response Summary

<!-- codex-workflow-response-start: 20260511T151305Z -->
Added the graphics-device helpers.

Functions added:
- `dev_is_tikz()`
- `dev_is_pdf()`

Detection:
- Both use an internal `dev_name()` helper around `names(grDevices::dev.cur())`.
- In this environment, `grDevices::pdf()` reports `"pdf"` and `tikzDevice::tikz()` reports `"tikz output"`.
- `dev_is_tikz()` returns `TRUE` if the current device name contains `"tikz"` or if the current device number matches metadata stored by `tikz_open()`.
- `dev_is_pdf()` returns `TRUE` when the current device name is exactly `"pdf"`.

Null/no-device handling:
- The null device reports `"null device"`.
- Both helpers return scalar `FALSE` on the null device and do not error.

Changed files:
- [R/devices.R](/Users/earn/r/earnmisc/R/devices.R)
- [tests/testthat/test-devices.R](/Users/earn/r/earnmisc/tests/testthat/test-devices.R)
- [R/earnmisc-package.R](/Users/earn/r/earnmisc/R/earnmisc-package.R)
- [NAMESPACE](/Users/earn/r/earnmisc/NAMESPACE)
- generated docs: `man/dev_is_tikz.Rd`, `man/dev_is_pdf.Rd`, `man/dev_name.Rd`, package docs

Tests added:
- Scalar logical return values.
- Null-device behaviour.
- PDF detection inside a temporary `pdf()` device.
- Tikz detection inside a temporary tikz device, skipped if `tikzDevice` is unavailable.
- Metadata fallback detection for devices tracked by `tikz_open()`.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

Limitation: detection is intentionally lightweight and depends on device names plus `tikz_open()` metadata; unusual custom devices with nonstandard names may not be classified.
<!-- codex-workflow-response-end: 20260511T151305Z -->

### Commit

<!-- codex-workflow-commit-start: 20260511T151305Z -->
- Recorded: `2026-05-11T15:17:20+00:00`
- Hash: `4beba083e585c2b4587000206e8ca6eb183a4e41`
- Subject: Add graphics device detection helpers
<!-- codex-workflow-commit-end: 20260511T151305Z -->

## 2026-05-13T12:49:35+00:00 — `20260513T124935Z`

<!-- codex-workflow-entry: 20260513T124935Z -->

### Prompt

Please add two list utility functions to `earnmisc`:

```r
update_list()
input_form()
```

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add small, dependency-free utilities for:

1. Updating selected elements of a possibly nested list while preserving other elements and attributes/classes.
2. Producing pasteable R code that reconstructs an object, especially a list.

Avoid tidyverse dependencies.

## `update_list()`

Please implement and export:

```r
update_list <- function(x, ..., .create = FALSE)
```

The function should return a modified copy of `x`.

Examples:

```r
x.new <- update_list(x, type = "new")
x.new <- update_list(x, "parms$graphics$lwd" = 3)
x.new <- update_list(x,
                     type = "new",
                     "parms$graphics$lwd" = 3)
```

### Path syntax

Named arguments in `...` should identify elements to update.

Top-level names should update top-level list elements:

```r
update_list(x, type = "new")
```

Path strings using `$` should update nested list elements:

```r
update_list(x, "parms$graphics$lwd" = 3)
```

This should be equivalent to:

```r
x$parms$graphics$lwd <- 3
```

Please support simple `$`-separated names only in this first implementation. Do not try to parse arbitrary R expressions.

If names contain whitespace around `$`, trim it:

```r
"parms $ graphics $ lwd"
```

should be treated like:

```r
"parms$graphics$lwd"
```

### Creation behaviour

If `.create = FALSE`, updating a nested path should require all intermediate list elements to exist. Missing paths should give a clear error.

If `.create = TRUE`, missing intermediate elements should be created as lists.

For example:

```r
update_list(list(), "parms$graphics$lwd" = 3, .create = TRUE)
```

should return:

```r
list(parms = list(graphics = list(lwd = 3)))
```

### Attribute and class preservation

`update_list()` should preserve attributes and class of the top-level object where possible.

For example, if `x` has a class with print or summary methods, the returned object should keep that class.

Please add tests for attribute/class preservation.

### Validation

Please validate inputs clearly:

- `x` should be a list-like object.
- all updates must be named;
- names must be non-empty;
- path components must be non-empty;
- duplicate update paths should either be applied in order or rejected. Please choose the cleaner behaviour and document it.
- paths that try to descend into a non-list object should error clearly unless replacement occurs exactly at that path.

### Implementation

Use base R only.

It is fine to add non-exported helpers such as:

```r
parse_list_path()
set_list_path()
```

Document non-exported helpers with roxygen2 comments, following `AGENTS.md`.

## `input_form()`

Please implement and export:

```r
input_form <- function(
  x,
  file = "",
  control = "all",
  width.cutoff = 60
)
```

The purpose is to produce R code that can be pasted elsewhere to reconstruct `x`.

This should be a friendly wrapper around `dput()`.

### Behaviour

If called as:

```r
input_form(x)
```

it should print/cat the result to the console, like `cat()`, and invisibly return the result as a single character string.

If called as:

```r
txt <- input_form(x)
```

`txt` should receive the character string invisibly? Please consider R conventions carefully here.

My preference:
- always return the character string, visibly or invisibly according to what is most natural;
- when `file = ""`, cat the string to the console;
- when `file` is a filename, write the string to the file and return the string invisibly.

If a visible return plus console output would duplicate output annoyingly at the console, use invisible return when printing/writing.

For file output:

```r
input_form(x, file = "blah.R")
```

should write the generated R code to `blah.R`.

Use `dput()` internally, likely via a text connection or `capture.output()`.

Preserve attributes as much as `dput()` can. Use `control = "all"` by default.

### Limitations

Document that exact reconstruction is not guaranteed for every possible R object. This is mainly intended for ordinary R objects and nested lists, not environments, external pointers, or objects with nontrivial reference semantics.

## Documentation

Add roxygen2 documentation for both exported functions.

Use Canadian spelling.

Examples should be lightweight and check-friendly.

Examples for `update_list()` should include:
- top-level update;
- nested update with `$` path;
- `.create = TRUE`.

Examples for `input_form()` should include:
- generating a pasteable string;
- writing to a temporary file.

## Tests

Add `testthat` tests for `update_list()`:

- top-level update;
- nested update;
- multiple updates;
- `.create = TRUE`;
- missing path error when `.create = FALSE`;
- descending into non-list error;
- class and attributes preserved;
- original input is not modified;
- unnamed update error;
- duplicate paths behaviour.

Add `testthat` tests for `input_form()`:

- returns/captures a character string;
- output can be parsed and evaluated to reconstruct a simple list;
- attributes are preserved for simple attributed objects;
- writes to a temporary file;
- default `control = "all"` preserves attributes better than `control = NULL`, if this can be tested cleanly.

Avoid brittle tests for objects that `dput()` cannot reliably reconstruct.

## Package docs

Update package-level documentation if appropriate.

Regenerate documentation and NAMESPACE.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What API was implemented.
2. How nested update paths are specified.
3. How attributes/classes are preserved.
4. How `input_form()` uses `dput()`.
5. What limitations remain.
6. What files changed.
7. What tests were added.
8. What verification commands were run and their results.

### Response Summary

<!-- codex-workflow-response-start: 20260513T124935Z -->
Implemented the two list utilities.

API added:
- `update_list(x, ..., .create = FALSE)`
- `input_form(x, file = "", control = "all", width.cutoff = 60)`

`update_list()`:
- Updates top-level names like `type = "new"`.
- Updates nested paths with simple `$` syntax, e.g. `"parms$graphics$lwd" = 3`.
- Trims whitespace around path components, so `"parms $ graphics $ lwd"` works.
- `.create = TRUE` creates missing intermediate lists.
- `.create = FALSE` errors on missing intermediate paths.
- Rejects duplicate canonical paths rather than applying them in order.
- Preserves top-level attributes/classes through ordinary R copy-modify semantics.
- Does not modify the original input.

`input_form()`:
- Uses `dput()` via `capture.output()` to generate pasteable R code.
- Prints to console when `file = ""` and invisibly returns the character string.
- Writes to a file when `file` is a filename and invisibly returns the same string.
- Uses `control = "all"` by default to preserve attributes where `dput()` can.
- `width.cutoff` is kept in the API, but current R’s `dput()` does not expose it directly, so it is validated but not passed through.

Files changed:
- [R/list_utils.R](/Users/earn/r/earnmisc/R/list_utils.R)
- [tests/testthat/test-list_utils.R](/Users/earn/r/earnmisc/tests/testthat/test-list_utils.R)
- [R/earnmisc-package.R](/Users/earn/r/earnmisc/R/earnmisc-package.R)
- [NAMESPACE](/Users/earn/r/earnmisc/NAMESPACE)
- generated docs for exported and internal helpers

Tests added:
- top-level, nested, multiple, and `.create = TRUE` updates;
- missing path and non-list descent errors;
- class/attribute preservation;
- original input immutability;
- unnamed, empty, invalid, duplicate path validation;
- `input_form()` console/file output;
- parse/eval reconstruction of simple lists;
- attribute preservation with default `control = "all"`.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

Limitations:
- `update_list()` only supports simple `$`-separated names, not arbitrary R expressions.
- `input_form()` depends on what `dput()` can reconstruct; it is not intended for environments, external pointers, or reference-semantics objects.
<!-- codex-workflow-response-end: 20260513T124935Z -->

### Commit

<!-- codex-workflow-commit-start: 20260513T124935Z -->
- Recorded: `2026-05-13T12:56:17+00:00`
- Hash: `24963e72702362076f75d7fd2173c35d33420484`
- Subject: Add list update and input-form utilities
<!-- codex-workflow-commit-end: 20260513T124935Z -->

## 2026-05-13T13:50:47+00:00 — `20260513T135047Z`

<!-- codex-workflow-entry: 20260513T135047Z -->

### Prompt

Please revise `earnmisc::input_form()`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Current implementation

`input_form()` currently uses:

```r
output.lines <- utils::capture.output(
  dput(x, control = control)
)
output.text <- paste(output.lines, collapse = "\n")
```

It validates `width.cutoff`, but `width.cutoff` is otherwise ignored because current R’s `dput()` does not expose a `width.cutoff` argument.

## Requested changes

Please revise `input_form()` to make `width.cutoff` meaningful and to add more control over file output and generated text.

Suggested revised API:

```r
input_form <- function(
  x,
  file = "",
  append = FALSE,
  control = "all",
  width.cutoff = 60,
  prefix = "",
  suffix = "",
  final.newline = TRUE,
  overwrite = TRUE
)
```

Use this exact API unless there is a strong reason to adjust it.

## `width.cutoff`

`width.cutoff` should control the deparse width as much as base R allows.

Rather than using `capture.output(dput(...))`, use `deparse()` directly, for example:

```r
output.lines <- deparse(
  x,
  width.cutoff = width.cutoff,
  control = control
)
```

Then collapse lines manually.

Please update the documentation to explain that `width.cutoff` is passed to `deparse()` and controls the approximate line width used during deparsing; it is not a strict maximum line length.

Keep validation sensible. Base R `deparse()` requires `width.cutoff` to be an integer-ish value between 20 and 500. Please validate accordingly.

## `append`

Add an `append` argument modelled on `cat()`/`write()` conventions.

Behaviour:
- If `file = ""`, `append` should have no practical effect.
- If `file` is a filename and `append = FALSE`, write a fresh file subject to `overwrite`.
- If `file` is a filename and `append = TRUE`, append to the existing file if it exists, or create it if it does not.

Use `cat()` or `writeLines()` in a way that handles `append` cleanly.

## `overwrite`

Add an `overwrite` argument controlling what happens when `file` already exists and `append = FALSE`.

Allowed values:

```r
TRUE
"warn"
"recover"
"error"
```

Behaviour:
- `overwrite = TRUE`: overwrite silently, matching current behaviour.
- `overwrite = "warn"`: warn that the existing file is being overwritten, then overwrite.
- `overwrite = "recover"`: before overwriting, copy the existing file to a recoverable backup path, warn with the backup filename, then overwrite.
- `overwrite = "error"`: stop with an informative error and do not overwrite.

Please also accept `overwrite = FALSE` as a synonym for `"error"` if that seems natural.

For `overwrite = "recover"`, choose a simple backup filename that avoids clobbering existing backups, for example:

```text
blah.R.bak
blah.R.bak1
blah.R.bak2
```

or a timestamped backup such as:

```text
blah.R.20260513-143012.bak
```

Use a simple, documented design.

If `append = TRUE`, do not treat an existing file as an overwrite; append to it. In that case, `overwrite` should be ignored or only validated. Please document this.

## `prefix` and `suffix`

Add `prefix` and `suffix` arguments.

These should be character scalars.

The final generated text should be:

```r
paste0(prefix, deparsed.object, suffix)
```

or the multiline equivalent.

Examples:

```r
input_form(my.list, prefix = "new.list <- ")
input_form(my.list, prefix = "new.list <- ", suffix = " # revised list")
```

For multiline deparse output, `prefix` should appear before the first line and `suffix` after the final line. For example, this is acceptable:

```r
new.list <- list(
  a = 1,
  b = 2
) # revised list
```

Please add tests for prefix and suffix.

## Final newline

Currently console/file output includes a final newline. This is a good default, but it should be controllable.

Add:

```r
final.newline = TRUE
```

Behaviour:
- If `final.newline = TRUE`, console and file output should end with a newline.
- If `final.newline = FALSE`, console and file output should not add a final newline.
- The returned character scalar should match exactly what was written/printed, including the final newline if `final.newline = TRUE`.

This is a change from the current implementation if the current returned string excludes the final newline. Please document the exact return value clearly.

## Return value

Return a character scalar containing exactly the generated text.

If the text is printed to the console or written to a file, return it invisibly.

Current behaviour already returns invisibly when printing or writing; please preserve that convention.

## Documentation

Update roxygen2 documentation for `input_form()`.

Please document:
- that it is based on `deparse()` rather than a full serializer;
- how `width.cutoff` works and that it is not a strict line-length guarantee;
- `append`;
- `overwrite`;
- backup behaviour for `overwrite = "recover"`;
- `prefix` and `suffix`;
- `final.newline`;
- limitations for environments, external pointers, reference objects, and other objects that cannot be reconstructed reliably from deparsed code.

Use Canadian spelling.

Examples should be lightweight and check-friendly.

Add examples for:
- assignment prefix;
- file append;
- `overwrite = "error"` or `"warn"` if easy to show safely with `tempfile()`;
- `final.newline = FALSE`.

## Tests

Add or revise tests for:

### Width cutoff
- `width.cutoff` is passed to `deparse()` and changes output for a suitable object.
- invalid `width.cutoff` values error clearly.
- Documentation/test comments should not imply strict maximum line length.

### Append
- `append = FALSE` writes a new file.
- `append = TRUE` appends to an existing file.
- `append = TRUE` creates a file if it does not already exist.

### Overwrite
- existing file + `overwrite = TRUE` overwrites silently.
- existing file + `overwrite = "warn"` warns and overwrites.
- existing file + `overwrite = "error"` errors and does not overwrite.
- existing file + `overwrite = FALSE` behaves like `"error"` if you choose to support that.
- existing file + `overwrite = "recover"` creates a backup and overwrites.
- `append = TRUE` does not trigger overwrite protection.

### Prefix/suffix
- prefix is prepended to the generated object form.
- suffix is appended to the generated object form.
- prefixed assignment text can be parsed and evaluated when appropriate.

### Final newline
- `final.newline = TRUE` includes a trailing newline in the returned string and output.
- `final.newline = FALSE` does not include a trailing newline.

### Reconstruction
- simple lists can still be parsed/evaluated to reconstruct the original object.
- simple attributes are still preserved with `control = "all"` where base R supports this.

## Internal helpers

It is fine to add non-exported helpers, for example:

```r
normalise_overwrite()
backup_file_path()
write_input_form()
```

Document non-exported helpers with roxygen2 comments, following `AGENTS.md`.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. How `width.cutoff` is now implemented.
2. What the final `input_form()` API is.
3. How append and overwrite behaviour work.
4. How backup/recover behaviour works.
5. How prefix, suffix, and final newline are handled.
6. What files changed.
7. What tests were added or revised.
8. What verification commands were run and their results.

### Response Summary

<!-- codex-workflow-response-start: 20260513T135047Z -->
Revised `input_form()` as requested.

`width.cutoff` now uses `deparse()` directly:

```r
deparse(x, width.cutoff = width.cutoff, control = control)
```

It is validated as an integer-ish value from 20 to 500. Documentation notes this is an approximate deparse width, not a strict line-length guarantee.

Final API:

```r
input_form(
  x,
  file = "",
  append = FALSE,
  control = "all",
  width.cutoff = 60,
  prefix = "",
  suffix = "",
  final.newline = TRUE,
  overwrite = TRUE
)
```

Append and overwrite:
- `append = TRUE` appends to an existing file or creates a new one; overwrite protection is ignored.
- `overwrite = TRUE` overwrites silently.
- `overwrite = "warn"` warns and overwrites.
- `overwrite = "error"` stops without overwriting.
- `overwrite = FALSE` is treated like `"error"`.
- `overwrite = "recover"` copies the existing file to `file.bak`, `file.bak1`, etc., then overwrites.

Prefix/suffix/newline:
- `prefix` is placed before the first deparsed line.
- `suffix` is placed after the final deparsed line.
- `final.newline = TRUE` makes the returned string and written/printed output end in `\n`.
- `final.newline = FALSE` omits that final newline.
- Returned text now exactly matches what is printed/written.

Files changed:
- [R/list_utils.R](/Users/earn/r/earnmisc/R/list_utils.R)
- [tests/testthat/test-list_utils.R](/Users/earn/r/earnmisc/tests/testthat/test-list_utils.R)
- [man/input_form.Rd](/Users/earn/r/earnmisc/man/input_form.Rd)
- new internal helper docs from roxygen: `backup_file_path`, `normalise_overwrite`, `validate_character_scalar`, `validate_width_cutoff`, `write_input_form`

Tests added/revised for width cutoff, invalid widths, append modes, overwrite modes, recover backups, prefix/suffix parseability, exact final newline behaviour, reconstruction, and attribute preservation.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

Limitations remain: this is based on `deparse()`, not a full serializer; environments, external pointers, and reference-style objects may not reconstruct reliably.
<!-- codex-workflow-response-end: 20260513T135047Z -->

### Commit

<!-- codex-workflow-commit-start: 20260513T135047Z -->
- Recorded: `2026-05-13T13:55:55+00:00`
- Hash: `dd62fb13296713d881d44fa11747949bb5da5519`
- Subject: Improve input_form output control
<!-- codex-workflow-commit-end: 20260513T135047Z -->

## 2026-05-13T14:33:48+00:00 — `20260513T143348Z`

<!-- codex-workflow-entry: 20260513T143348Z -->

### Prompt

Please revise `earnmisc::input_form()` to support aligned list formatting.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add an `align` argument to `input_form()` so that list input forms can be easier to read and edit.

Current example:

```r
input_form(
  out.fig$overlay.curve.styles,
  width = 90,
  prefix = "my.overlay.curve.style <- ",
  file = "myoverlay.R"
)
```

currently produces something like:

```r
my.overlay.curve.style <- list(exact = list(col = "#DFEAEC", lwd = 8, lty = 1), KM.tauinit = list(col = "grey10", lwd = 2, 
    lty = 3), localX.tauinit = list(col = "#0072B2", lwd = 2, lty = 3), original.y = list(col = "#1C6F75", 
    lwd = 2, lty = 1))
```

I would like an `align` argument that can produce more readable multiline output.

## Revised API

Please revise the API to include:

```r
align = c(",", "=")
```

The full API should become:

```r
input_form(
  x,
  file = "",
  append = FALSE,
  control = "all",
  width.cutoff = 60,
  prefix = "",
  suffix = "",
  final.newline = TRUE,
  overwrite = TRUE,
  align = c(",", "=")
)
```

Use this exact API unless there is a strong technical reason not to.

## `align` behaviour

### `align = NULL`

When `align = NULL`, preserve the current behaviour exactly.

For example, this should continue to use ordinary `deparse()` output:

```r
input_form(x, align = NULL)
```

### `align = ","`

When `align = ","`, format suitable named lists in a multiline style with leading commas aligned.

For example:

```r
input_form(
  out.fig$overlay.curve.styles,
  width = 90,
  prefix = "my.overlay.curve.style <- ",
  align = ","
)
```

should produce output like:

```r
my.overlay.curve.style <- list(
    exact = list(col = "#DFEAEC", lwd = 8, lty = 1)
  , KM.tauinit = list(col = "grey10", lwd = 2, lty = 3)
  , localX.tauinit = list(col = "#0072B2", lwd = 2, lty = 3)
  , original.y = list(col = "#1C6F75", lwd = 2, lty = 1)
)
```

### `align = c(",", "=")`

When `align = c(",", "=")`, format suitable named lists in a multiline style with leading commas and aligned equals signs.

This should be the default.

For example:

```r
input_form(
  out.fig$overlay.curve.styles,
  width = 90,
  prefix = "my.overlay.curve.style <- ",
  align = c(",", "=")
)
```

should produce output like:

```r
my.overlay.curve.style <- list(
    exact          = list(col = "#DFEAEC", lwd = 8, lty = 1)
  , KM.tauinit     = list(col = "grey10", lwd = 2, lty = 3)
  , localX.tauinit = list(col = "#0072B2", lwd = 2, lty = 3)
  , original.y     = list(col = "#1C6F75", lwd = 2, lty = 1)
)
```

## Scope and fallback behaviour

Keep this conservative.

This is not intended to be a full R-code formatter.

The aligned formatting should target suitable named list objects, especially lists whose top-level elements can each be deparsed compactly.

If the object is not a list, or if alignment cannot be applied safely, fall back to the ordinary `deparse()` output used when `align = NULL`.

For now, it is acceptable for alignment to apply only to top-level named lists.

Do not try to fully reformat arbitrary nested R code.

Nested list values may be deparsed compactly on the same line where possible, using `width.cutoff`.

## Prefix and suffix interaction

`prefix` should still appear before the full generated input form.

For aligned list output, this means:

```r
prefix = "my.overlay.curve.style <- "
```

should produce:

```r
my.overlay.curve.style <- list(
    exact          = list(col = "#DFEAEC", lwd = 8, lty = 1)
  , KM.tauinit     = list(col = "grey10", lwd = 2, lty = 3)
)
```

not:

```r
my.overlay.curve.style <- 
list(...)
```

`suffix` should still be appended after the final generated object form, as currently documented.

For example:

```r
input_form(x, prefix = "x <- ", suffix = " # revised list")
```

should place the suffix after the closing parenthesis or final deparsed line.

## Names and quoting

Please preserve syntactically valid names without quotes, matching ordinary `deparse()` where possible.

If a list name is not syntactically valid, quote it in a way that produces parseable R code.

Examples:
- `exact` should appear as `exact`.
- `KM.tauinit` should appear as `KM.tauinit`.
- names containing spaces or other non-syntactic characters should be backticked or otherwise represented parseably.

Use base R utilities where possible, such as `make.names()` checks or `deparse()` of a named one-element list, to avoid hand-rolling too much syntax.

## Parseability

Aligned output should be valid R code.

For suitable list objects, this should hold:

```r
txt <- input_form(x, align = c(",", "="))
y <- eval(parse(text = txt))
identical(x, y)
```

For assignment prefixes:

```r
txt <- input_form(x, prefix = "x.new <- ", align = c(",", "="))
env <- new.env(parent = emptyenv())
eval(parse(text = txt), envir = env)
identical(env$x.new, x)
```

Please add tests for this.

## Validation

Validate `align`.

Allowed values should be:

```r
NULL
","
c(",", "=")
```

It is fine to also accept `align = "="` as a synonym for `align = c(",", "=")` only if you think that is useful, but do not leave this decision ambiguous. My preference is to support only the three allowed values above for now.

Invalid values should error clearly.

## Documentation

Update roxygen2 documentation for `input_form()`.

Document:
- `align = NULL` preserves ordinary deparse output;
- `align = ","` aligns leading commas for suitable named lists;
- `align = c(",", "=")` also aligns equals signs and is the default;
- alignment is intentionally conservative and applies mainly to top-level named lists;
- output falls back to ordinary deparse formatting when alignment is not applicable;
- aligned output is intended to remain parseable R input.

Use Canadian spelling.

Examples should be lightweight and check-friendly.

Please include examples of:
- default aligned output;
- `align = NULL`;
- `align = ","`;
- assignment prefix with aligned output.

## Tests

Add or revise tests for:

- `align = NULL` preserves current deparse-based behaviour.
- default `align = c(",", "=")` gives multiline aligned output for a named list.
- `align = ","` gives leading-comma multiline output without equals alignment.
- `align = c(",", "=")` aligns equals signs.
- aligned output parses and reconstructs a simple named list.
- aligned output with `prefix = "x.new <- "` parses and assigns correctly.
- suffix works with aligned output.
- final newline behaviour still works with aligned output.
- file writing still works with aligned output.
- append/overwrite behaviour still works with aligned output.
- non-list objects fall back to ordinary deparse output.
- unnamed lists either fall back to ordinary deparse output or are handled parseably; choose the simpler behaviour and document it clearly.
- non-syntactic names are handled parseably.
- invalid `align` values error clearly.

## Internal helpers

It is fine to add non-exported helpers such as:

```r
validate_align()
input_form_deparse()
input_form_align_list()
format_list_name()
deparse_one_line()
```

Document non-exported helpers with roxygen2 comments, following `AGENTS.md`.

Keep the implementation base-R only.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. The final `align` API and defaults.
2. How aligned formatting is implemented.
3. What objects fall back to ordinary deparse output.
4. How parseability is tested.
5. What files changed.
6. What tests were added or revised.
7. What verification commands were run and their results.

### Response Summary

<!-- codex-workflow-response-start: 20260513T143348Z -->
Implemented aligned list formatting for `input_form()`.

Final API:
```r
input_form(
  x,
  file = "",
  append = FALSE,
  control = "all",
  width.cutoff = 60,
  prefix = "",
  suffix = "",
  final.newline = TRUE,
  overwrite = TRUE,
  align = c(",", "=")
)
```

How alignment works:
- `align = NULL`: uses ordinary `deparse()` output.
- `align = ","`: formats suitable top-level named lists with leading commas.
- `align = c(",", "=")`: default; also pads names so `=` signs align.
- Alignment applies only to plain top-level named lists whose element values deparse to one line.
- Non-lists, unnamed lists, lists with extra attributes/classes, or lists with multi-line top-level values fall back to ordinary `deparse()`.

Parseability is tested by parsing/evaluating aligned output directly, including assignment-prefix output like `x.new <- list(...)`. Non-syntactic names are formatted with backticks via base R name deparsing.

Files changed:
- [R/list_utils.R](/Users/earn/r/earnmisc/R/list_utils.R)
- [tests/testthat/test-list_utils.R](/Users/earn/r/earnmisc/tests/testthat/test-list_utils.R)
- [man/input_form.Rd](/Users/earn/r/earnmisc/man/input_form.Rd)
- generated internal helper docs for alignment helpers

Tests added/revised for:
- `align = NULL` ordinary deparse behaviour.
- default aligned multiline output.
- leading-comma-only output.
- aligned `=` positions.
- parse/eval reconstruction.
- assignment prefix parsing.
- suffix and final newline.
- file writing, append, and overwrite with aligned output.
- fallback for non-list and unnamed list inputs.
- non-syntactic names.
- invalid `align` values.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

Unrelated existing files remain untouched: `PROMPT_latest.md`, `PROMPTS_used.md`, and untracked `blah.R*` files.
<!-- codex-workflow-response-end: 20260513T143348Z -->

### Commit

<!-- codex-workflow-commit-start: 20260513T143348Z -->
- Recorded: `2026-05-13T14:46:46+00:00`
- Hash: `67fbc3212f788084f2b4af06850b5c815912119b`
- Subject: Add aligned list formatting to input_form
<!-- codex-workflow-commit-end: 20260513T143348Z -->

## 2026-05-13T15:39:35+00:00 — `20260513T153935Z`

<!-- codex-workflow-entry: 20260513T153935Z -->

### Prompt

Please add colour-swatch display helpers to `earnmisc`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add a small base-graphics helper that displays colours as labelled swatches, so I can quickly glance at a palette and choose colours for plotting.

Existing packages have related tools, for example `RColorBrewer::display.brewer.pal()` for Brewer palettes and `unikn::seecol()` for general colour inspection, but I want a small dependency-free helper in `earnmisc` that works naturally with the Okabe--Ito colours already provided by this package.

## API

Please implement and export:

```r
show_colours()
show_oi_colours()
```

Use Canadian spelling for the function names.

Suggested API:

```r
show_colours <- function(
  colours,
  labels = names(colours),
  nrow = NULL,
  ncol = NULL,
  main = NULL,
  border = "grey30",
  text.colour = NULL,
  cex = 0.9,
  mar = c(0, 0, 2, 0),
  ...
)
```

and:

```r
show_oi_colours <- function(
  extended = TRUE,
  alpha = NULL,
  ...
)
```

`show_oi_colours()` should call `okabe_ito_colours(extended = extended, alpha = alpha)` and then call `show_colours()`.

## Behaviour

### `show_colours()`

`show_colours()` should:

- accept a character vector of R colours;
- use `labels = names(colours)` by default;
- draw one rectangular swatch per colour using base graphics;
- arrange swatches in a grid using `par(mfrow = ...)` or an equivalent base-graphics layout;
- choose a reasonable grid automatically if `nrow` and `ncol` are not supplied;
- label each swatch with the corresponding colour name or label;
- preserve and restore the user’s graphics parameters with `on.exit(par(old.par), add = TRUE)`;
- return the input colour vector invisibly.

If `labels = NULL`, draw swatches without labels.

If colours are unnamed and `labels` is missing, use the colour values themselves as labels.

If `text.colour = NULL`, choose black or white text automatically based on the background colour luminance. Keep this simple and deterministic.

The function should pass `...` to `graphics::text()` or, if more sensible, to the internal labelling call. Document what `...` is used for.

### `show_oi_colours()`

`show_oi_colours()` should:

- display the default extended Okabe--Ito palette by default;
- support `extended = FALSE`;
- support `alpha`;
- pass layout/labelling arguments through `...` to `show_colours()`;
- return the displayed colour vector invisibly.

## Layout

If both `nrow` and `ncol` are `NULL`, choose a compact grid automatically.

A simple approach is:

```r
ncol <- ceiling(sqrt(n))
nrow <- ceiling(n / ncol)
```

If one of `nrow` or `ncol` is supplied, compute the other.

Validate that the grid has enough cells for all colours.

Use base graphics only.

## Documentation

Add roxygen2 documentation for both exported functions.

Document:
- that these are simple base-graphics swatch displays;
- that `show_oi_colours()` is a convenience wrapper for the Okabe--Ito palette;
- that `show_colours()` accepts any R colour vector;
- that graphics parameters are restored after plotting.

Use Canadian spelling.

Examples should be lightweight and check-friendly. Since these functions draw plots, wrap examples in `if (interactive())` if needed, or keep them simple enough for checks.

## Tests

Add tests where feasible without brittle graphics comparison.

Suggested tests:
- `show_colours()` returns the input colours invisibly.
- unnamed colours use colour values as labels without error.
- named colours use names by default.
- `labels = NULL` works.
- automatic layout produces enough cells.
- supplied `nrow` or `ncol` is handled correctly.
- invalid colours error clearly if possible, or at least do not leave graphics parameters unrestored.
- graphics parameters are restored after the function exits.
- `show_oi_colours()` returns `okabe_ito_colours(extended = TRUE)` by default.
- `show_oi_colours(extended = FALSE)` returns the original palette.
- `show_oi_colours(alpha = 0.5)` returns the alpha-adjusted palette.

Use a temporary graphics device such as `pdf(tempfile())` for plotting tests, and ensure it is closed with `on.exit(grDevices::dev.off(), add = TRUE)`.

## Internal helpers

It is fine to add documented non-exported helpers such as:

```r
colour_text_contrast()
colour_grid_dims()
```

Keep them simple and base-R only.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What functions were added.
2. How grid layout is chosen.
3. How label text colour is chosen.
4. What files changed.
5. What tests were added.
6. What verification commands were run and their results.

### Response Summary

<!-- codex-workflow-response-start: 20260513T153935Z -->
Added the colour-swatch helpers.

Functions added:
- `show_colours()`
- `show_oi_colours()`

Grid layout:
- If neither `nrow` nor `ncol` is supplied:
  `ncol <- ceiling(sqrt(n))`, `nrow <- ceiling(n / ncol)`.
- If one dimension is supplied, the other is computed.
- If both are supplied, the grid must have enough cells.

Label text colour:
- If `text.colour = NULL`, it uses a simple luminance calculation from `grDevices::col2rgb()`.
- Light swatches get black text; dark swatches get white text.

Implementation:
- Uses base graphics only.
- Draws all swatches in one plot region with `rect()` and labels with `text()`.
- Restores graphics parameters with `on.exit(par(old.par), add = TRUE)`.
- `...` is passed to `graphics::text()`.

Files changed:
- [R/show_colours.R](/Users/earn/r/earnmisc/R/show_colours.R)
- [tests/testthat/test-show_colours.R](/Users/earn/r/earnmisc/tests/testthat/test-show_colours.R)
- [R/earnmisc-package.R](/Users/earn/r/earnmisc/R/earnmisc-package.R)
- [NAMESPACE](/Users/earn/r/earnmisc/NAMESPACE)
- generated docs for exported and internal helpers

Tests added:
- invisible return values.
- named, unnamed, and label-free colours.
- automatic and explicit grid dimensions.
- contrast text helper.
- graphics parameter restoration.
- invalid colour errors.
- `show_oi_colours()` default, original palette, and alpha behaviour.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.
<!-- codex-workflow-response-end: 20260513T153935Z -->

### Commit

<!-- codex-workflow-commit-start: 20260513T153935Z -->
- Recorded: `2026-05-13T15:43:25+00:00`
- Hash: `f610e8efdf8cfabdad58c1778c79a6c012ed58d7`
- Subject: Add colour swatch display helpers
<!-- codex-workflow-commit-end: 20260513T153935Z -->

## 2026-05-13T20:19:10+00:00 — `20260513T201910Z`

<!-- codex-workflow-entry: 20260513T201910Z -->

### Prompt

Please expand the `show_colours()` and `show_oi_colours()` roxygen documentation in `earnmisc`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Improve the documentation for the colour-swatch helpers by adding practical examples and brief guidance on choosing complementary, harmonious, and accessible colours.

Do not change the behaviour of `show_colours()` or `show_oi_colours()` in this task unless a tiny documentation-example cleanup requires it.

## Built-in R colour example

Please add an example showing how to browse R’s built-in named colours using `show_colours()`.

Base R’s `colours()` / `colors()` returns 657 built-in colour names. Please mention this in the documentation.

Add an example along these lines:

```r
for (i in 1:41) {
  show_colours(colours()[(1 + 16 * (i - 1)):(16 * i)])
}
```

However, please make the example check-friendly. Since this opens many plots, put it in `\dontrun{}` or otherwise protect it from being run during checks.

Also consider adding a smaller check-friendly example, for example:

```r
show_colours(colours()[1:16])
```

Use `colours()` in examples and prose, consistent with Canadian spelling, but it is fine to mention that `colors()` is the US-spelling alias.

## Further resources section

Please add a short roxygen section, perhaps called:

```r
@section Further resources:
```

or:

```r
@section Palette design workflow:
```

Keep this section practical and concise.

Mention that `show_colours()` is a lightweight in-R inspection helper, and that users who want help designing or browsing palettes may also find other tools useful.

## Suggested R packages

Mention these R packages as complementary resources, with clickable links in the rendered help where practical.

Use roxygen markdown links where appropriate.

### `colorspace`

Mention that `colorspace` is especially useful when the user wants to design, tune, or evaluate colour palettes.

Mention that it includes tools for palette design and colour-vision-deficiency assessment.

CRAN link:

```text
https://cran.r-project.org/package=colorspace
```

### `khroma`

Mention that `khroma` is especially useful when the user wants strong pre-vetted scientific palettes and diagnostic tools, especially for colour-blind-safe visualisation.

CRAN link:

```text
https://cran.r-project.org/package=khroma
```

### `paletteer`

Mention that `paletteer` is especially useful when the user wants to browse many palette families quickly through a unified interface.

CRAN link:

```text
https://cran.r-project.org/package=paletteer
```

Please present these as suggestions, not dependencies. Do not add any of these packages to `DESCRIPTION`.

## Suggested external tools

Mention a couple of external palette tools for rapid exploration.

### Adobe Color

Mention that Adobe Color is useful for harmony-based palette exploration and includes accessibility / colour-contrast tools.

Link:

```text
https://color.adobe.com/create/color-accessibility
```

### Coolors

Mention that Coolors is useful for quickly generating, locking, and exploring palettes.

Link:

```text
https://coolors.co/
```

## Suggested workflow

Add a short practical workflow suggestion, for example:

1. Prototype candidate colours in Adobe Color or Coolors.
2. Bring the candidate hex colours into R.
3. Inspect and tune them with `colorspace`.
4. Check accessibility and distinguishability with `khroma` or an accessibility tool.
5. Use `show_colours()` to compare the final candidates directly inside the package workflow.

Keep this brief and user-facing.

## Style requirements

- Keep the main function documentation clear and concise.
- Do not turn the help page into a long essay.
- Keep wording practical rather than academic.
- Do not overstate that any one tool is “best”.
- Present external packages and websites as optional resources that complement `show_colours()`.
- Emphasize moving from rough palette ideas to inspectable colours in R.
- Use Canadian spelling in prose.
- Preserve existing examples unless they need minor cleanup.
- Do not change function behaviour.

## Tests

No new tests are required unless the documentation examples require small changes.

If examples are changed in a way that affects checks, make sure they remain check-friendly.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What documentation sections were added or revised.
2. Whether any examples were added or protected with `\dontrun{}`.
3. Whether any function behaviour changed.
4. What files changed.
5. What verification commands were run and their results.

### Response Summary

<!-- codex-workflow-response-start: 20260513T201910Z -->
Updated the roxygen documentation for `show_colours()` and `show_oi_colours()` only. Function behaviour did not change.

Added/revised documentation:
- Added a `Palette design workflow` section to both help pages.
- Added optional resources: `colorspace`, `khroma`, `paletteer`, Adobe Color, and Coolors, with links.
- Added a practical workflow from rough palette ideas to R inspection.
- Added built-in R colour examples using `colours()`.
- Mentioned that base R has 657 built-in named colours and that `colors()` is an alias.

Examples:
- Added check-friendly `show_colours(colours()[1:16])`.
- Added the full built-in-colour browsing loop protected with `\dontrun{}`:
  `for (i in 1:41) show_colours(...)`.

Files changed:
- [R/show_colours.R](/Users/earn/r/earnmisc/R/show_colours.R)
- [man/show_colours.Rd](/Users/earn/r/earnmisc/man/show_colours.Rd)
- [man/show_oi_colours.Rd](/Users/earn/r/earnmisc/man/show_oi_colours.Rd)

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.
<!-- codex-workflow-response-end: 20260513T201910Z -->

### Commit

<!-- codex-workflow-commit-start: 20260513T201910Z -->
- Recorded: `2026-05-13T20:21:09+00:00`
- Hash: `82bb27e1f28cc1288e10e7d1155df667932a17be`
- Subject: Expand colour helper documentation
<!-- codex-workflow-commit-end: 20260513T201910Z -->

## 2026-05-15T12:36:40+00:00 — `20260515T123640Z`

<!-- codex-workflow-entry: 20260515T123640Z -->

### Prompt

Please add generic `mts` plotting overlay helpers to `earnmisc`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add generic helpers for plotting and overlaying matching columns of multivariate time series (`mts`) objects.

This is generic `mts` functionality and belongs in `earnmisc`, not in `gaemr`.

Base R has `plot.mts()` / `plot.ts()` and `lines.ts()`, but there is no convenient generic helper that creates a multi-panel `mts` layout and then overlays matching columns from one or more other `mts` objects.

## Important design decision

Do **not** try to support overlaying onto an arbitrary existing base `plot.mts()` plot after the fact.

Base `plot.mts()` does not expose a stable public panel map, panel coordinates, or a reliable way to re-enter earlier panels. A function that pretends to work after arbitrary:

```r
plot(x)
lines_mts(y)
```

would be fragile.

Instead, implement a small coherent `earnmisc` plotting workflow:

```r
plot.info <- plot_mts(x)
lines_mts(y, plot.info = plot.info)
```

and a convenience wrapper:

```r
plot_mts_overlay(x, y, z, ...)
```

Document clearly that `lines_mts()` is intended to overlay onto layouts created by `plot_mts()`, not arbitrary `plot.mts()` output.

## API to implement

Please implement and export:

```r
plot_mts()
lines_mts()
plot_mts_overlay()
```

Use these exact function names.

## `plot_mts()`

Suggested API:

```r
plot_mts <- function(
  x,
  columns = NULL,
  nrow = NULL,
  ncol = NULL,
  main = NULL,
  xlab = "Time",
  ylab = NULL,
  col = "black",
  lty = 1,
  lwd = 1,
  type = "l",
  axes = TRUE,
  frame.plot = TRUE,
  mar = NULL,
  oma = NULL,
  ...
)
```

### Behaviour

`plot_mts()` should:

- accept an `mts` object or an object coercible enough to be handled safely as a multivariate time series;
- plot each selected column in its own panel;
- use base graphics only;
- create a multi-panel layout with `par(mfrow = ...)` or equivalent;
- choose a compact layout if `nrow` and `ncol` are not supplied;
- preserve and restore appropriate graphics parameters where sensible;
- store enough panel metadata for `lines_mts()` to overlay later;
- invisibly return a useful info object.

The return object should be a list with class:

```r
class(plot.info) <- c("earnmisc_mts_plot_info", "list")
```

It should include at least:

```r
x
columns
column.names
panel.order
layout
time
usr
mfg
xlim
ylim
device
created_at
curves
```

Use clear names and include whatever additional metadata is useful.

Store the most recent `plot_mts()` result in a package-private environment so that `lines_mts(y)` can use it by default when `plot.info` is not supplied.

### Curve registry

The returned object must include a curve registry designed to support a future `legend_mts()` helper.

Use a data frame called:

```r
curves
```

The `curves` data frame should include one row for every base curve drawn by `plot_mts()`.

Include at least these columns:

```r
source
object.index
column
name
panel.index
panel.name
col
lty
lwd
type
drawn
reason
```

For the base `x` curves:
- `source` should be `"base"`;
- `object.index` should be `0L`;
- `drawn` should be `TRUE`;
- `reason` should be `NA_character_`.

This registry should be structured so that later overlay calls can append rows for additional curves.

### Plotting details

For each panel:

- plot the corresponding `x` column;
- use the column name as a default panel title or y label if `ylab = NULL`;
- allow graphical parameters such as `col`, `lty`, and `lwd` to be scalar, vectorised by column order, or named by column;
- pass `...` to the underlying plotting call where appropriate.

Keep this simple and robust. This is not intended to reproduce every detail of `plot.mts()`.

## `lines_mts()`

Suggested API:

```r
lines_mts <- function(
  y,
  plot.info = NULL,
  columns = NULL,
  match = c("name", "position"),
  unmatched = c("warn", "error", "ignore"),
  col = "red",
  lty = 1,
  lwd = 1,
  source = NULL,
  object.index = NULL,
  ...
)
```

### Behaviour

`lines_mts()` should overlay columns of `y` onto an existing layout created by `plot_mts()`.

If `plot.info = NULL`, use the most recent stored `plot_mts()` info object.

If no stored plot info exists, error clearly with a message saying that `lines_mts()` requires a `plot.info` object from `plot_mts()` or a prior call to `plot_mts()`.

### Matching behaviour

Use this decisive matching policy:

- `match = "name"` is the default.
- If both the plotted base object and overlay `y` have column names, match by column name.
- If `match = "name"` but either side lacks column names, fall back to position matching with a warning.
- `match = "position"` matches by column position.
- `columns` optionally restricts which `y` columns are considered.
- If `columns` is character, interpret it as `y` column names.
- If `columns` is numeric, interpret it as `y` column indices.

### Unmatched columns

Use this decisive unmatched policy:

- `unmatched = "warn"` is the default.
- `unmatched = "warn"` skips unmatched `y` columns and warns.
- `unmatched = "error"` errors if any selected `y` columns cannot be matched.
- `unmatched = "ignore"` silently skips unmatched `y` columns.

### Graphical parameters

Allow `col`, `lty`, and `lwd` to be:

- scalar;
- vectors matching the number of selected overlay columns;
- named vectors keyed by `y` column names.

Use ordinary recycling rules with a warning for non-multiple lengths.

Pass `...` to `graphics::lines()`.

### Time handling

Use the time index of each `y` series when drawing.

If `y` and the base object have different time ranges, draw the available `y` times as supplied by `stats::time(y)`; do not attempt to rescale. Base time-series coordinates should make this work naturally.

If a `y` series falls outside the plotted x-range, draw whatever is visible within the existing panel.

### Return value and plot-info update

`lines_mts()` should invisibly return the updated `plot.info` object, not only the overlay mapping.

The returned `plot.info$curves` should include:
- all existing base curves;
- all overlay curves selected for this call;
- rows for skipped unmatched overlay columns, with `drawn = FALSE` and an informative `reason`.

For overlay curves:
- `source` should default to a useful label such as `"overlay"` or `"overlay1"`;
- `object.index` should identify the overlay object when called through `plot_mts_overlay()`;
- `panel.index` and `panel.name` should identify where the curve was drawn, or `NA` if skipped.

Please also update the internally stored most-recent plot info with the returned object, so repeated calls such as:

```r
plot_mts(x)
lines_mts(y)
lines_mts(z)
```

accumulate a complete curve registry.

## `plot_mts_overlay()`

Suggested API:

```r
plot_mts_overlay <- function(
  x,
  ...,
  columns.x = NULL,
  columns = NULL,
  match = c("name", "position"),
  unmatched = c("warn", "error", "ignore"),
  col.x = "black",
  lty.x = 1,
  lwd.x = 1,
  col = NULL,
  lty = NULL,
  lwd = NULL,
  overlay.names = NULL,
  ...
)
```

Do not use duplicate formal `...` arguments. Choose a syntactically valid final API that supports both:
- one or more overlay `mts` objects;
- graphical/layout arguments for `plot_mts()` and `lines_mts()`.

A clean design might use separate list arguments such as:

```r
plot.args = list()
lines.args = list()
```

or explicit `col.overlay`, `lty.overlay`, and `lwd.overlay`.

Please implement this decisive API instead:

```r
plot_mts_overlay <- function(
  x,
  ...,
  columns.x = NULL,
  columns.y = NULL,
  match = c("name", "position"),
  unmatched = c("warn", "error", "ignore"),
  col.x = "black",
  lty.x = 1,
  lwd.x = 1,
  col.y = NULL,
  lty.y = NULL,
  lwd.y = NULL,
  overlay.names = NULL,
  plot.args = list(),
  lines.args = list()
)
```

Here:
- `...` contains one or more overlay `mts` objects;
- `columns.x` restricts columns plotted from the base object;
- `columns.y` restricts columns considered from each overlay object;
- `col.x`, `lty.x`, and `lwd.x` are for the base curves;
- `col.y`, `lty.y`, and `lwd.y` are for overlay curves;
- `overlay.names` optionally gives labels for the overlay objects;
- `plot.args` contains additional arguments passed to `plot_mts()`;
- `lines.args` contains additional arguments passed to `lines_mts()`.

### Behaviour

`plot_mts_overlay()` should:

1. require at least one overlay object in `...`;
2. call `plot_mts()` on `x`;
3. call `lines_mts()` once for each overlay object;
4. invisibly return the final updated `plot.info` object.

The returned `plot.info$curves` should contain rows for:
- base curves;
- all overlay curves from all overlay objects;
- skipped overlay curves, if any.

For multiple overlays, `object.index` should identify overlay order:
- base object: `0L`;
- first overlay: `1L`;
- second overlay: `2L`;
- and so on.

If `overlay.names` is supplied, use those names in the `source` column. Otherwise use `"overlay1"`, `"overlay2"`, etc.

### Overlay graphical parameters

For multiple overlay objects:
- if `col.y`, `lty.y`, or `lwd.y` is `NULL`, choose simple defaults;
- if supplied as a vector, recycle across overlay curves in a clear documented way;
- if supplied as a list, treat each list element as the graphical parameter vector for the corresponding overlay object.

Keep this simple and document the chosen behaviour.

## Validation

Please validate clearly:

- `x` and all overlay objects must be multivariate time series or coercible to matrix/time-series form in a safe way;
- selected columns must exist;
- layout must have enough panels;
- `match` and `unmatched` must be valid;
- `plot.args` and `lines.args` must be lists;
- `overlay.names`, if supplied, must have length equal to the number of overlay objects;
- graphical-parameter vectorisation should be predictable;
- `plot.info` must have the expected class/structure.

## Documentation

Add roxygen2 documentation for:

```r
plot_mts()
lines_mts()
plot_mts_overlay()
```

Documentation should explain:

- these are base-graphics helpers for multivariate time series;
- `lines_mts()` is intended for layouts created by `plot_mts()`;
- arbitrary existing `plot.mts()` output is not supported;
- matching by column name is the default;
- position matching is available;
- unmatched columns can warn, error, or be ignored;
- graphical parameters can be scalar, vectorised, or named by column;
- returned `plot.info` objects contain a curve registry useful for later legend construction;
- `plot_mts_overlay()` accepts any number of overlay `mts` objects.

Use Canadian spelling.

Examples should be lightweight and check-friendly. Include examples showing:

```r
x <- ts(cbind(a = 1:10, b = 11:20))
y <- ts(cbind(a = 2:11, b = 10:19))

plot.info <- plot_mts(x)
plot.info <- lines_mts(y, plot.info = plot.info)
```

and:

```r
plot_mts_overlay(x, y)
```

Also include examples showing:
- name matching when overlay columns are in a different order;
- multiple overlay objects;
- inspection of `plot.info$curves`.

## Tests

Add tests where possible without brittle graphics comparison.

Use temporary graphics devices such as `pdf(tempfile())` for plotting tests, and close them reliably with `on.exit(grDevices::dev.off(), add = TRUE)`.

Test:

- `plot_mts()` returns an object of class `earnmisc_mts_plot_info`;
- returned metadata includes panel order, column names, layout, device, coordinate information, and `curves`;
- base curves are recorded in `plot.info$curves`;
- `lines_mts()` uses stored last plot info when `plot.info = NULL`;
- `lines_mts()` errors clearly when no plot info is available;
- name matching works when overlay columns are reordered;
- position matching works;
- unmatched columns warn, error, or ignore according to `unmatched`;
- `columns` restricts selected overlay columns;
- scalar graphical parameters work;
- vector graphical parameters work;
- named graphical parameters work;
- non-multiple graphical parameter recycling warns;
- `lines_mts()` returns an updated `plot.info` with appended curve registry rows;
- repeated `lines_mts()` calls accumulate registry rows;
- `plot_mts_overlay()` works with one overlay;
- `plot_mts_overlay()` works with multiple overlays;
- `plot_mts_overlay()` records overlay object indices and source labels;
- invalid `plot.info` errors clearly.

Avoid image comparison.

## Internal helpers

It is fine to add documented non-exported helpers such as:

```r
as_mts_matrix()
mts_column_names()
mts_layout_dims()
resolve_mts_columns()
match_mts_columns()
resolve_line_graphics()
make_mts_curve_registry()
store_mts_plot_info()
last_mts_plot_info()
```

Document non-exported helpers with roxygen2 comments, following `AGENTS.md`.

Use base R only.

## Package docs

Update package-level documentation to mention the new `mts` plotting helpers.

Regenerate documentation and NAMESPACE.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What functions were added.
2. Why arbitrary existing `plot.mts()` output is not supported.
3. How `plot_mts()` stores panel metadata.
4. How the curve registry is structured for future legend support.
5. How `lines_mts()` matches columns and handles unmatched columns.
6. How multiple overlays work in `plot_mts_overlay()`.
7. How graphical parameters are vectorised or matched by name.
8. What useful information is returned invisibly.
9. What files changed.
10. What tests were added.
11. What verification commands were run and their results.
12. Any limitations or TODOs.

### Response Summary

<!-- codex-workflow-response-start: 20260515T123640Z -->
Implemented the generic `mts` overlay workflow.

**Added functions**
- `plot_mts()`
- `lines_mts()`
- `plot_mts_overlay()`

These are exported in `NAMESPACE`.

**Design**
- `lines_mts()` is intentionally tied to layouts created by `plot_mts()`.
- Arbitrary existing `plot.mts()` output is not supported because base R does not expose a stable panel map or reliable way to re-enter prior panels.
- `plot_mts()` stores panel metadata including `usr`, `mfg`, layout, selected columns, time index, device, and a `curves` registry.
- `lines_mts()` uses explicit `plot.info` or the most recent stored `plot_mts()` result.
- Matching defaults to column names, falls back to position with a warning when names are unavailable, and supports `unmatched = "warn"`, `"error"`, or `"ignore"`.
- Graphical parameters can be scalar, vectorised, or named by column.

**Curve Registry**
`plot.info$curves` records base and overlay curves with:
`source`, `object.index`, `column`, `name`, `panel.index`, `panel.name`, `col`, `lty`, `lwd`, `type`, `drawn`, and `reason`.

**Files changed**
- [R/mts_plot.R](/Users/earn/r/earnmisc/R/mts_plot.R)
- [R/earnmisc-package.R](/Users/earn/r/earnmisc/R/earnmisc-package.R)
- [NAMESPACE](/Users/earn/r/earnmisc/NAMESPACE)
- [man/plot_mts.Rd](/Users/earn/r/earnmisc/man/plot_mts.Rd)
- [man/lines_mts.Rd](/Users/earn/r/earnmisc/man/lines_mts.Rd)
- [man/plot_mts_overlay.Rd](/Users/earn/r/earnmisc/man/plot_mts_overlay.Rd)
- [man/earnmisc-package.Rd](/Users/earn/r/earnmisc/man/earnmisc-package.Rd)
- [tests/testthat/test-mts_plot.R](/Users/earn/r/earnmisc/tests/testthat/test-mts_plot.R)

Existing dirty `PROMPT_latest.md` and `PROMPTS_used.md` were left untouched.

**Tests added**
Added coverage for metadata, stored plot info, name and position matching, unmatched policies, column restriction, graphical parameter handling, repeated overlays, wrapper behaviour, validation, and curve registry accumulation.

**Verification**
- `make document` passed.
- `make test` passed.
- `make check` passed with `Status: OK`.

`make check` printed repository index access warnings due restricted network access, but they did not affect the final check status.
<!-- codex-workflow-response-end: 20260515T123640Z -->

### Commit

<!-- codex-workflow-commit-start: 20260515T123640Z -->
- Recorded: `2026-05-15T14:00:39+00:00`
- Hash: `0f7b56fdb7b3d6fc642bda4f75e8a3bf2127c3c2`
- Subject: Add generic mts overlay plotting helpers
<!-- codex-workflow-commit-end: 20260515T123640Z -->

## 2026-05-15T14:49:44+00:00 — `20260515T144944Z`

<!-- codex-workflow-entry: 20260515T144944Z -->

### Prompt

Please fix argument forwarding in `plot_mts_overlay()`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Problem

The following works:

```r
library(earnmisc)
library(gaemr)

sol.2 <- solve_sir(R0 = 2, x.minus = 1, start.level = 0.02)
sol.4 <- solve_sir(R0 = 4, x.minus = 1, start.level = 0.02)
sol.8 <- solve_sir(R0 = 8, x.minus = 1, start.level = 0.02)
m <- list(sol.2$series, sol.4$series, sol.8$series)

plot_mts_overlay(
  m[[3]], m[[2]], m[[1]],
  lwd.x = 3,
  plot.args = list(las = 1, bty = "L", xlim = c(-1, 2))
)
```

But either of these additions causes an error:

```r
plot.args = list(las = 1, bty = "L", xlim = c(-1, 2), col = oi.blue)
```

or:

```r
lines.args = list(lty = 1)
```

The error is:

```text
formal argument "lty" matched by multiple actual arguments
```

or the analogous error for another graphical argument.

This almost certainly means that `plot_mts_overlay()` is passing arguments such as `col`, `lty`, or `lwd` both explicitly and through `plot.args` / `lines.args`.

## Required design

`plot_mts_overlay()` should allow `plot.args` and `lines.args` to override the corresponding explicit defaults.

Specifically:

- `col.x`, `lty.x`, and `lwd.x` provide defaults for the base `plot_mts()` call.
- If `plot.args` contains `col`, `lty`, or `lwd`, those values should override `col.x`, `lty.x`, or `lwd.x`.
- `col.y`, `lty.y`, and `lwd.y` provide defaults for overlay `lines_mts()` calls.
- If `lines.args` contains `col`, `lty`, or `lwd`, those values should override `col.y`, `lty.y`, or `lwd.y`.
- More generally, `plot.args` should be allowed to override any explicitly constructed argument passed to `plot_mts()`, except for core arguments that must not be overridden such as `x`.
- `lines.args` should be allowed to override any explicitly constructed argument passed to `lines_mts()`, except for core arguments that must not be overridden such as `y`, `plot.info`, `source`, and `object.index`.

Use a small internal helper if useful, for example:

```r
merge_call_args(defaults, overrides, protected = character())
```

where:
- `defaults` are the arguments constructed by `plot_mts_overlay()`;
- `overrides` are `plot.args` or `lines.args`;
- `overrides` replace same-named defaults;
- protected names cannot be overridden and should error clearly if present in `overrides`.

Document any non-exported helper with roxygen2 comments, following `AGENTS.md`.

## Protected argument policy

Use this definitive policy.

For `plot.args`, disallow overriding:

```r
x
columns
```

because these are controlled by `x` and `columns.x`.

For `lines.args`, disallow overriding:

```r
y
plot.info
columns
source
object.index
```

because these are controlled internally for each overlay object.

If a user supplies one of those protected names, error clearly.

Other arguments in `plot.args` or `lines.args` may override defaults.

## Tests

Add or revise tests so that:

- `plot_mts_overlay(..., plot.args = list(col = oi.blue))` no longer errors.
- `plot_mts_overlay(..., lines.args = list(lty = 1))` no longer errors.
- `plot.args = list(col = ...)` overrides `col.x` in the base curve registry.
- `plot.args = list(lty = ...)` overrides `lty.x` in the base curve registry.
- `plot.args = list(lwd = ...)` overrides `lwd.x` in the base curve registry.
- `lines.args = list(col = ...)` overrides `col.y` in overlay curve registry rows.
- `lines.args = list(lty = ...)` overrides `lty.y` in overlay curve registry rows.
- `lines.args = list(lwd = ...)` overrides `lwd.y` in overlay curve registry rows.
- Supplying protected names in `plot.args`, such as `x` or `columns`, errors clearly.
- Supplying protected names in `lines.args`, such as `y`, `plot.info`, `columns`, `source`, or `object.index`, errors clearly.
- Existing tests for one and multiple overlays still pass.

Use a temporary graphics device and avoid image comparison.

## Documentation

Update `plot_mts_overlay()` documentation to explain:

- `plot.args` supplies additional arguments to `plot_mts()`;
- `lines.args` supplies additional arguments to `lines_mts()`;
- same-named values in `plot.args` override base plotting defaults such as `col.x`, `lty.x`, and `lwd.x`;
- same-named values in `lines.args` override overlay defaults such as `col.y`, `lty.y`, and `lwd.y`;
- protected core arguments cannot be supplied through `plot.args` or `lines.args`.

Use Canadian spelling.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What caused the duplicate formal-argument error.
2. How `plot.args` and `lines.args` are now merged with defaults.
3. Which arguments are protected from override.
4. What tests were added or revised.
5. What files changed.
6. What verification commands were run and their results.

### Response Summary

<!-- codex-workflow-response-start: 20260515T144944Z -->
Fixed `plot_mts_overlay()` argument forwarding.

The duplicate formal-argument error was caused by building calls with `c(defaults, plot.args)` / `c(defaults, lines.args)`, which allowed duplicate names like `col`, `lty`, or `lwd` to reach `do.call()`.

Now `plot_mts_overlay()` uses an internal `merge_call_args()` helper:
- same-named values in `plot.args` replace constructed `plot_mts()` defaults;
- same-named values in `lines.args` replace constructed `lines_mts()` defaults;
- protected core arguments error clearly.

Protected names:
- `plot.args`: `x`, `columns`
- `lines.args`: `y`, `plot.info`, `columns`, `source`, `object.index`

Tests were added for:
- `plot.args = list(col = ...)`, `lty`, and `lwd` overriding base registry values;
- `lines.args = list(col = ...)`, `lty`, and `lwd` overriding overlay registry values;
- protected-name errors for both argument lists;
- existing one/multiple overlay behaviour still passing.

Files changed:
- [R/mts_plot.R](/Users/earn/r/earnmisc/R/mts_plot.R)
- [man/plot_mts_overlay.Rd](/Users/earn/r/earnmisc/man/plot_mts_overlay.Rd)
- [tests/testthat/test-mts_plot.R](/Users/earn/r/earnmisc/tests/testthat/test-mts_plot.R)

Verification:
- `make document` passed.
- `make test` passed.
- `make check` passed, `Status: OK`.

The check still prints repository index access warnings from restricted network access, but the package check itself is clean.
<!-- codex-workflow-response-end: 20260515T144944Z -->

### Commit

<!-- codex-workflow-commit-start: 20260515T144944Z -->
- Recorded: `2026-05-15T14:52:58+00:00`
- Hash: `aada5529eedab70c666c21969e531ea37498068e`
- Subject: Fix plot_mts_overlay argument forwarding
<!-- codex-workflow-commit-end: 20260515T144944Z -->

## 2026-05-15T19:12:24+00:00 — `20260515T191224Z`

<!-- codex-workflow-entry: 20260515T191224Z -->

### Prompt

Please add reserved blank-panel support and `legend_mts()` helpers to the `earnmisc` `mts` plotting workflow.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Extend the existing generic `mts` plotting workflow:

```r
plot_mts()
lines_mts()
plot_mts_overlay()
```

so that `plot_mts()` can reserve one or more entire panels for later legends, annotations, or other custom graphics.

Also add:

```r
set_mts_panel()
legend_mts()
```

Do not add `add_to_mts_panel()` in this task, but design the metadata so that such a helper could be added later. If mentioned in comments or documentation, use the future name `add_to_mts_panel()`, not `with_mts_panel()`.

## Design summary

The intended workflow is:

```r
plot.info <- plot_mts(x, blank.panels = 1)
plot.info <- lines_mts(y, plot.info = plot.info)
plot.info <- lines_mts(z, plot.info = plot.info)
legend_mts(plot.info)
```

or interactively:

```r
plot_mts(x, blank.panels = 1)
lines_mts(y)
lines_mts(z)
legend_mts()
```

`blank.panels` reserves full layout cells. Nothing is drawn in those cells by `plot_mts()`, except whatever blank-panel initialisation is needed. Legends or custom annotations are drawn later.

## Add `blank.panels` to `plot_mts()`

Please add an argument to `plot_mts()`:

```r
blank.panels = NULL
```

Use this name, not `legend.panel`.

### Behaviour

- `blank.panels = NULL`: current behaviour, no reserved blank panels.
- `blank.panels` may be `NULL` or a positive integer vector.
- If `blank.panels` is supplied, reserve those layout cells for later legend/annotation use.
- Reserved panels should be blank after `plot_mts()` finishes.
- Data series should be plotted in all non-reserved panels.
- Blank panels are panel indices in the full layout, not data-column indices.

For example, if `x` has three selected series:

```r
plot_mts(x, blank.panels = 1)
```

should create four layout cells, reserve panel 1, and plot the three series in panels 2, 3, and 4.

```r
plot_mts(x, blank.panels = 2)
```

should reserve panel 2 and plot data in panels 1, 3, and 4.

```r
plot_mts(x, blank.panels = 4)
```

should reserve the final panel.

If `x` has three selected series and:

```r
plot_mts(x, blank.panels = c(1, 4))
```

then five layout cells should be created, panels 1 and 4 should be blank, and the three data series should be plotted in panels 2, 3, and 5.

The total number of layout cells should be:

```r
number_of_selected_series + length(blank.panels)
```

when `blank.panels` is not `NULL`.

Validate that `blank.panels` contains unique positive integers within the available full layout cell range. For example, with three selected series and two blank panels, valid blank panel indices are integers from 1 through 5.

### Metadata

Update the returned `plot.info` object to include:

```r
blank.panels
data.panels
panel.roles
panels
```

Suggested meanings:

- `blank.panels`: integer vector of reserved blank panel indices, or `NULL`;
- `data.panels`: integer vector mapping plotted data columns to layout panel indices;
- `panel.roles`: character vector of length equal to the number of layout cells, with values such as `"data"` and `"blank"`;
- `panels`: a list or data frame containing panel metadata, including `mfg`, `usr`, `xlim`, `ylim`, and any other information needed by `lines_mts()`, `set_mts_panel()`, `legend_mts()`, and a future `add_to_mts_panel()`.

Please update existing metadata consistently so `lines_mts()` overlays onto the correct data panels, skipping reserved blank panels.

The `curves` registry should record the correct `panel.index` and `panel.name` for each base and overlay curve.

## Add `set_mts_panel()`

Please implement and export:

```r
set_mts_panel <- function(
  panel,
  plot.info = NULL,
  xlim = c(0, 1),
  ylim = c(0, 1),
  axes = FALSE,
  xaxs = "i",
  yaxs = "i",
  ...
)
```

### Behaviour

`set_mts_panel()` should:

- use `plot.info` if supplied;
- otherwise use the most recent stored `plot_mts()` info object;
- validate that `panel` is a valid panel index;
- set the graphics device to the requested panel using stored panel metadata;
- call `plot.new()`;
- call `plot.window(xlim = xlim, ylim = ylim, axes = axes, xaxs = xaxs, yaxs = yaxs, ...)`;
- invisibly return metadata for the selected panel.

This helper is intended for blank/reserved panels such as legend or annotation panels. Document clearly that it clears/reinitialises the selected panel. It is not intended for adding annotations on top of an already-drawn data panel, because `plot.new()` will clear that panel.

The default coordinate system should be `xlim = c(0, 1)`, `ylim = c(0, 1)` so that legends and text can be placed easily.

All default `plot.window()` arguments listed above should be user-overridable through formal arguments or `...`.

## Add `legend_mts()`

Please implement and export:

```r
legend_mts <- function(
  plot.info = NULL,
  panel = NULL,
  by = c("source", "curve", "column"),
  legend = NULL,
  x = "center",
  inset = 0,
  bty = "n",
  ...
)
```

### Behaviour

`legend_mts()` should:

- use `plot.info` if supplied;
- otherwise use the most recent stored `plot_mts()` info object;
- use `panel` if supplied;
- otherwise use the first blank panel in `plot.info$blank.panels`;
- error clearly if no panel is supplied and `plot.info$blank.panels` is `NULL` or empty;
- use `set_mts_panel()` to initialise the legend panel;
- construct a sensible default legend from `plot.info$curves`;
- call `graphics::legend()`;
- pass `...` to `graphics::legend()`;
- invisibly return a useful legend info object.

### Default legend construction

Use drawn curves only:

```r
plot.info$curves[plot.info$curves$drawn, ]
```

Default grouping:

```r
by = "source"
```

Use this policy:

- `by = "source"`: one legend entry per curve source, using the first drawn curve for each source;
- `by = "column"`: one legend entry per column/panel name, using the first drawn curve for each column/panel;
- `by = "curve"`: one legend entry per drawn curve.

Default legend labels:
- If `legend` is supplied, use it directly.
- If `legend = NULL`, construct labels from the selected grouping.
- For `by = "source"`, use the `source` column.
- For `by = "column"`, use `panel.name` or `name`, whichever is clearer and available.
- For `by = "curve"`, use a readable combination of source and curve/panel name, for example `"overlay1: I"`.

Default graphical parameters:
- Use `col`, `lty`, and `lwd` from the selected rows of `plot.info$curves`.
- Allow the user to override them through `...` if they explicitly pass `col`, `lty`, or `lwd` to `legend_mts()`.

### Return value

`legend_mts()` should invisibly return a list with useful information, including:

```r
panel
by
legend
col
lty
lwd
curves
legend.result
```

where `legend.result` is the invisible return from `graphics::legend()` if available.

## Update `lines_mts()` and `plot_mts_overlay()` as needed

Please update these functions so they remain compatible with reserved blank panels.

In particular:

- `lines_mts()` must overlay onto the correct data panel even when blank panels are present.
- Repeated `lines_mts()` calls should continue to update and store the accumulated `plot.info`.
- `plot_mts_overlay()` should allow `blank.panels` to be passed through to `plot_mts()` via `plot.args`.
- `plot_mts_overlay()` should return final `plot.info` with blank-panel metadata and complete curve registry.

Do not draw the legend automatically in `plot_mts_overlay()` in this task.

## Documentation

Add or update roxygen2 documentation for:

```r
plot_mts()
lines_mts()
plot_mts_overlay()
set_mts_panel()
legend_mts()
```

Documentation should explain:

- `blank.panels` reserves one or more full layout cells at plot time;
- `legend_mts()` draws a legend later using the accumulated curve registry;
- by default, `legend_mts()` uses the first blank panel;
- `set_mts_panel()` reinitialises a panel with a simple coordinate system and is intended mainly for reserved panels;
- `set_mts_panel()` clears the selected panel;
- `lines_mts()` does not support arbitrary base `plot.mts()` output;
- the `curves` registry is designed to support legends and later inspection.

Use Canadian spelling.

Examples should be lightweight and check-friendly. Include an example like:

```r
x <- ts(cbind(a = 1:10, b = 11:20, c = 21:30))
y <- ts(cbind(a = 2:11, b = 10:19, c = 20:29))

plot.info <- plot_mts(x, blank.panels = 1)
plot.info <- lines_mts(y, plot.info = plot.info, source = "overlay")
legend_mts(plot.info)
```

Also include an example showing multiple blank panels, such as:

```r
plot.info <- plot_mts(x, blank.panels = c(1, 4))
set_mts_panel(4, plot.info)
text(0.5, 0.5, "Notes")
```

## Tests

Add tests without brittle image comparison. Use temporary graphics devices such as `pdf(tempfile())` and close them reliably.

Test:

### `plot_mts()` with `blank.panels`

- `blank.panels = NULL` preserves existing behaviour.
- with three selected series and `blank.panels = 1`, the layout has four panels and panel 1 is blank.
- with `blank.panels = 2`, panel 2 is blank and data panels are 1, 3, 4.
- with `blank.panels = 4`, panel 4 is blank.
- with `blank.panels = c(1, 4)`, there are five panels, panels 1 and 4 are blank, and data panels are 2, 3, 5.
- invalid `blank.panels` values error clearly, including duplicates, zero, negative values, non-integers, and out-of-range values.
- base curves record correct data panel indices when blank panels are reserved.

### `lines_mts()`

- overlays use the correct data panels when blank panels are present.
- curve registry entries for overlays record correct panel indices.
- repeated overlays still accumulate correctly.

### `set_mts_panel()`

- works with explicit `plot.info`.
- works with stored most-recent plot info.
- errors clearly for invalid panel.
- returns panel metadata invisibly.
- accepts overridden `xlim`, `ylim`, `axes`, `xaxs`, `yaxs`.

### `legend_mts()`

- uses the first `plot.info$blank.panels` panel by default.
- accepts explicit `panel`.
- errors clearly when no blank panel is available and no panel is supplied.
- constructs default legend entries by source.
- supports `by = "column"` and `by = "curve"`.
- allows explicit `legend` labels.
- returns a useful legend info object.
- passes graphical parameters to `graphics::legend()` without duplicate-argument errors.

Avoid testing exact rendered output.

## Internal helpers

It is fine to add documented non-exported helpers such as:

```r
resolve_blank_panels()
mts_panel_roles()
select_mts_legend_curves()
make_mts_legend_args()
```

Document non-exported helpers with roxygen2 comments, following `AGENTS.md`.

Use base R only.

## Package docs

Update package-level documentation to mention reserved blank panels and `legend_mts()`.

Regenerate documentation and NAMESPACE.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. How `blank.panels` works in `plot_mts()`.
2. How data panels are assigned when blank panels are reserved.
3. How `set_mts_panel()` works and what its intended limitations are.
4. How `legend_mts()` constructs default legends.
5. How legend grouping by source, column, and curve works.
6. How the curve registry supports legend construction.
7. What files changed.
8. What tests were added or revised.
9. What verification commands were run and their results.
10. Any limitations or TODOs.

### Response Summary

<!-- codex-workflow-response-start: 20260515T191224Z -->
Implemented reserved blank-panel support and the new helpers.

**Added**
- `set_mts_panel()`
- `legend_mts()`

Both are exported.

**How `blank.panels` works**
`plot_mts(..., blank.panels = ...)` now treats blank panels as full layout-cell indices. If three series are plotted and `blank.panels = c(1, 4)`, the full layout has five cells, panels `1` and `4` are reserved, and data are drawn in panels `2`, `3`, and `5`.

`plot.info` now includes:
- `blank.panels`
- `data.panels`
- `panel.roles`
- `panels`

`lines_mts()` now uses `data.panels`, so overlays land on the correct data panels even when blank panels are present.

**`set_mts_panel()`**
Selects a stored panel, calls `plot.new()`, initialises a simple `0..1` coordinate system by default, and invisibly returns panel metadata. It clears/reinitialises the selected panel, so it is intended mainly for reserved panels, legends, and notes.

**`legend_mts()`**
Builds legends from `plot.info$curves`, using drawn curves only. By default it uses the first reserved blank panel. Grouping supports:
- `by = "source"`: one entry per source
- `by = "column"`: one entry per plotted column/panel
- `by = "curve"`: one entry per drawn curve

User-supplied `legend`, `col`, `lty`, and `lwd` can override defaults through `...`.

**Files changed**
- [R/mts_plot.R](/Users/earn/r/earnmisc/R/mts_plot.R)
- [R/earnmisc-package.R](/Users/earn/r/earnmisc/R/earnmisc-package.R)
- [NAMESPACE](/Users/earn/r/earnmisc/NAMESPACE)
- [man/plot_mts.Rd](/Users/earn/r/earnmisc/man/plot_mts.Rd)
- [man/lines_mts.Rd](/Users/earn/r/earnmisc/man/lines_mts.Rd)
- [man/legend_mts.Rd](/Users/earn/r/earnmisc/man/legend_mts.Rd)
- [man/set_mts_panel.Rd](/Users/earn/r/earnmisc/man/set_mts_panel.Rd)
- [man/earnmisc-package.Rd](/Users/earn/r/earnmisc/man/earnmisc-package.Rd)
- [tests/testthat/test-mts_plot.R](/Users/earn/r/earnmisc/tests/testthat/test-mts_plot.R)

Unrelated dirty files `PROMPT_latest.md` and `PROMPTS_used.md` were left untouched.

**Tests**
Added tests for blank panel layouts, invalid blank panels, overlay mapping with blanks, `plot_mts_overlay()` pass-through, `set_mts_panel()`, `legend_mts()` default and explicit panels, legend grouping, explicit labels, and graphical overrides.

**Verification**
- `make document` passed.
- `make test` passed.
- `make check` passed with `Status: OK`.

`R CMD check` printed repository index access warnings due restricted network access, but the package check completed cleanly.
<!-- codex-workflow-response-end: 20260515T191224Z -->

### Commit

<!-- codex-workflow-commit-start: 20260515T191224Z -->
- Recorded: `2026-05-15T19:19:58+00:00`
- Hash: `e2dea886c615e86e699e83c5b7066a9f9c677312`
- Subject: Add mts blank panels and legend helpers
<!-- codex-workflow-commit-end: 20260515T191224Z -->

## 2026-05-15T20:05:31+00:00 — `20260515T200531Z`

<!-- codex-workflow-entry: 20260515T200531Z -->

### Prompt

Please fix source tracking for the `earnmisc` `mts` plotting helpers so that `legend_mts(by = "source")` distinguishes repeated `lines_mts()` calls.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Problem

The new `legend_mts()` function works in many respects, but `by = "source"` currently collapses repeated overlay calls into a single `"overlay"` source.

Example:

```r
library(earnmisc)
library(gaemr)

sol.2 <- solve_sir(R0 = 2, x.minus = 1, start.level = 0.02)
sol.4 <- solve_sir(R0 = 4, x.minus = 1, start.level = 0.02)
sol.8 <- solve_sir(R0 = 8, x.minus = 1, start.level = 0.02)
m <- list(sol.2$series, sol.4$series, sol.8$series)

plot_mts(
  m[[3]],
  las = 1,
  bty = "L",
  xlim = c(-1, 2),
  lwd = 3,
  col = oi.black,
  blank.panels = c(2)
)
lines_mts(m[[2]], lty = 1, lwd = 2, col = oi.reddish_purple)
lines_mts(m[[1]], lty = 1, lwd = 2, col = oi.sky_blue)
legend_mts(by = "source")
```

The legend currently has two entries:

```text
base
overlay
```

This is wrong. There should be three entries corresponding to the three `mts` objects:

```text
m[[3]]
m[[2]]
m[[1]]
```

or user-supplied source labels if provided.

The underlying issue is that all `lines_mts()` calls are apparently being recorded with the same source label, such as `"overlay"`, so the curve registry cannot distinguish overlay objects.

## Required design

Each call to `plot_mts()` and `lines_mts()` should record a distinct source label in `plot.info$curves`.

### `plot_mts()`

Add or revise an argument:

```r
source = NULL
```

Behaviour:

- If `source` is supplied, use it as the source label for all base curves from `x`.
- If `source = NULL`, use the unevaluated expression supplied for `x`, converted to a readable character label.

For example:

```r
plot_mts(m[[3]])
```

should record source:

```text
m[[3]]
```

and:

```r
plot_mts(m[[3]], source = "R0 = 8")
```

should record source:

```text
R0 = 8
```

### `lines_mts()`

Keep or revise the existing argument:

```r
source = NULL
```

Behaviour:

- If `source` is supplied, use it as the source label for all curves from that `lines_mts()` call.
- If `source = NULL`, use the unevaluated expression supplied for `y`, converted to a readable character label.

For example:

```r
lines_mts(m[[2]])
```

should record source:

```text
m[[2]]
```

and:

```r
lines_mts(m[[2]], source = "R0 = 4")
```

should record source:

```text
R0 = 4
```

Each `lines_mts()` call must preserve its own source label in the curve registry.

Do not default repeated direct `lines_mts()` calls to the same label `"overlay"`.

### Source-label helper

Use a small internal helper if useful, for example:

```r
source_label <- function(expr, source = NULL)
```

or similar.

A base R approach is sufficient. For example, use `deparse1(substitute(x))` or a compatibility equivalent if needed.

Document any internal helper with roxygen2 comments, following `AGENTS.md`.

### Source labels and legend labels

`plot.info$curves$source` should be a character vector.

If users want mathematical legend labels, they can still pass explicit labels to `legend_mts(legend = ...)`, or later we can consider allowing expression-valued source labels. For this fix, keep `source` as a character label unless the existing code already supports expression labels safely.

## `legend_mts(by = "source")`

Revise `legend_mts(by = "source")` so that it creates one legend entry per distinct source in first-seen order, using drawn curves only.

For the example above, after:

```r
plot_mts(m[[3]], ...)
lines_mts(m[[2]], ...)
lines_mts(m[[1]], ...)
legend_mts(by = "source")
```

the default legend labels should be:

```text
m[[3]]
m[[2]]
m[[1]]
```

and the graphical parameters should correspond to the first drawn curve for each source.

If users supply explicit legend labels:

```r
legend_mts(by = "source", legend = c("R0 = 8", "R0 = 4", "R0 = 2"))
```

those labels should override the source labels.

## `object.index`

Please also make sure `object.index` remains useful.

Suggested policy:

- base curves from `plot_mts()`: `object.index = 0L`;
- each direct `lines_mts()` call increments the object index if `object.index = NULL`;
- `plot_mts_overlay()` continues to set object indices explicitly:
  - base object: `0L`;
  - first overlay: `1L`;
  - second overlay: `2L`;
  - etc.

This is important so future tools can distinguish both source labels and object order.

If implementing automatic incrementing for direct `lines_mts()` calls is awkward, at minimum ensure repeated calls have distinct `source` labels. But the preferred design is to keep `object.index` distinct as well.

## `plot_mts_overlay()`

Update `plot_mts_overlay()` as needed so source labels remain good there too.

Desired behaviour:

- If `overlay.names` is supplied, use those as overlay source labels.
- If `overlay.names` is not supplied, use readable labels derived from the overlay expressions in `...`, where possible.
- The base object source should come from `source.x` if you add such an argument, or from the expression for `x` if not supplied.

Please use a definitive API. If a new explicit base-source argument is needed, use:

```r
source.x = NULL
```

and document it.

For overlay source labels, continue to support:

```r
overlay.names = NULL
```

where `NULL` means derive labels from the overlay expressions.

## Tests

Add or revise tests for:

- `plot_mts(m[[3]])` records source `"m[[3]]"` or the exact readable expression produced by the implemented helper.
- `lines_mts(m[[2]])` records source `"m[[2]]"` or the exact readable expression produced by the helper.
- repeated direct `lines_mts()` calls produce distinct source values in `plot.info$curves`.
- `legend_mts(by = "source")` selects one entry per distinct source, in first-seen order.
- the motivating example pattern gives three source legend entries, not two.
- explicit `source` in `plot_mts()` overrides the default source label.
- explicit `source` in `lines_mts()` overrides the default source label.
- explicit `legend` in `legend_mts()` overrides source-derived legend labels.
- `plot_mts_overlay()` preserves explicit `overlay.names`.
- `plot_mts_overlay()` derives overlay source labels from expressions when `overlay.names = NULL`.
- `object.index` values are still sensible for base and overlay curves.

Use temporary graphics devices and avoid image comparison.

## Documentation

Update roxygen2 documentation for:

```r
plot_mts()
lines_mts()
plot_mts_overlay()
legend_mts()
```

Documentation should explain:

- `source = NULL` means the source label is inferred from the input expression;
- `source = "label"` lets the user override the inferred label;
- `legend_mts(by = "source")` groups by these source labels;
- repeated `lines_mts()` calls are tracked separately;
- users can override legend labels directly with the `legend` argument to `legend_mts()`.

Use Canadian spelling.

Examples should include:

```r
plot.info <- plot_mts(x, source = "baseline")
plot.info <- lines_mts(y, plot.info = plot.info, source = "comparison")
legend_mts(plot.info, by = "source")
```

and, if practical, an example showing inferred source labels.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What caused repeated overlays to collapse into one legend entry.
2. How source labels are now inferred.
3. How explicit source labels override inferred labels.
4. How `legend_mts(by = "source")` now chooses entries.
5. How `object.index` is handled for repeated direct overlays.
6. What files changed.
7. What tests were added or revised.
8. What verification commands were run and their results.
9. Any limitations or TODOs.

### Response Summary

<!-- codex-workflow-response-start: 20260515T200531Z -->
Fixed source tracking for the `mts` plotting workflow.

The collapse happened because `plot_mts()` always recorded base curves as `"base"` and direct `lines_mts()` calls defaulted to `"overlay"`, so `legend_mts(by = "source")` correctly grouped identical labels, but the labels were too coarse.

Now:
- `plot_mts(x)` infers the source label from the expression for `x`, e.g. `m[[3]]`.
- `lines_mts(y)` infers the source label from the expression for `y`, e.g. `m[[2]]`.
- Explicit `source = "label"` overrides the inferred label in both functions.
- `plot_mts_overlay()` now has `source.x = NULL`; overlay labels come from `overlay.names` if supplied, otherwise from overlay expressions in `...`.
- Direct repeated `lines_mts()` calls still increment `object.index` automatically: base is `0L`, first overlay is `1L`, second is `2L`, etc.
- `legend_mts(by = "source")` continues to select the first drawn curve per distinct source in first-seen order, now with useful distinct source labels.

Tests were added/revised for:
- inferred labels like `m[[3]]`, `m[[2]]`, `m[[1]]`;
- explicit `source` overrides;
- three source legend entries for the motivating pattern;
- explicit `legend` labels overriding source labels;
- `plot_mts_overlay()` inferred and explicit overlay labels;
- sensible `object.index` values.

Files changed:
- [R/mts_plot.R](/Users/earn/r/earnmisc/R/mts_plot.R)
- [man/plot_mts.Rd](/Users/earn/r/earnmisc/man/plot_mts.Rd)
- [man/lines_mts.Rd](/Users/earn/r/earnmisc/man/lines_mts.Rd)
- [man/plot_mts_overlay.Rd](/Users/earn/r/earnmisc/man/plot_mts_overlay.Rd)
- [man/legend_mts.Rd](/Users/earn/r/earnmisc/man/legend_mts.Rd)
- [tests/testthat/test-mts_plot.R](/Users/earn/r/earnmisc/tests/testthat/test-mts_plot.R)

Verification:
- `make document` passed.
- `make test` passed.
- `make check` passed with `Status: OK`.

The check printed repository index access warnings due restricted network access, but the package check itself completed cleanly.
<!-- codex-workflow-response-end: 20260515T200531Z -->

### Commit

<!-- codex-workflow-commit-start: 20260515T200531Z -->
- Recorded: `2026-05-15T20:09:14+00:00`
- Hash: `9dd46c2207783605037722b01bd8eb4e405b707a`
- Subject: Fix mts source tracking for legends
<!-- codex-workflow-commit-end: 20260515T200531Z -->
