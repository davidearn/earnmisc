# Latest Codex Prompt

- Entry ID: `20260515T200531Z`
- Recorded: `2026-05-15T20:05:31+00:00`

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
