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
