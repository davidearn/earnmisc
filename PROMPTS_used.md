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
