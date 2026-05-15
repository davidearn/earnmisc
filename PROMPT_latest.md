# Latest Codex Prompt

- Entry ID: `20260515T123640Z`
- Recorded: `2026-05-15T12:36:40+00:00`

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
