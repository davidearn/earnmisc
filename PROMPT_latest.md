# Latest Codex Prompt

- Entry ID: `20260520T034033Z`
- Recorded: `2026-05-20T03:40:33+00:00`

Please add `mts_xys_line()` to `earnmisc` and convert `xys_line()` into an S3 generic.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add an `mts`-aware helper:

```r
mts_xys_line()
```

and make the existing `xys_line()` function an S3 generic so other packages, especially `gaemr`, can define methods such as:

```r
xys_line.sir_solution()
```

that exploit `earnmisc::mts_xys_line()`.

## Convert `xys_line()` to an S3 generic

The existing exported `xys_line()` currently handles numeric arguments:

```r
xys_line(x, y, slope, ...)
```

It should become an S3 generic:

```r
xys_line <- function(x, ...) {
  UseMethod("xys_line")
}
```

Move the current implementation to:

```r
xys_line.default <- function(x, y, slope, ...)
```

The default method should preserve all current behaviour, including:

- scalar and vectorised `x`, `y`, and `slope`;
- all-combinations expansion for vectorised `x`, `y`, and `slope`;
- vectorised graphical parameters such as `col`, `lty`, and `lwd`;
- infinite slopes using `graphics::abline(v = x, ...)`;
- scalar return shape when exactly one line is drawn;
- data-frame return shape when multiple lines are drawn.

Export the S3 method appropriately using roxygen2.

The public user-facing help for `xys_line()` should still document the default numeric behaviour clearly.

## Add `mts_xys_line()`

Please implement and export:

```r
mts_xys_line <- function(
  x,
  y,
  slope,
  plot.info = NULL,
  panels = NULL,
  columns = NULL,
  source = "xys_line",
  record = TRUE,
  ...
)
```

Use this API unless there is a strong technical reason to adjust it.

## Behaviour

`mts_xys_line()` should add point/slope reference lines to panels created by `mts_plot()`.

It should be analogous to `mts_abline()`, but use `xys_line.default()` or the underlying numeric implementation to draw lines specified by a point `(x, y)` and a `slope`.

The intended use is:

```r
plot.info <- mts_plot(z)
plot.info <- mts_xys_line(0, 0, 1, plot.info = plot.info)
plot.info <- mts_xys_line(0, c(0.1, -0.1), 1, plot.info = plot.info)
```

With blank panels:

```r
plot.info <- mts_plot(z, blank.panels = 2)
plot.info <- mts_xys_line(0, 0, 1, plot.info = plot.info)
```

By default, draw on all data panels and skip reserved blank panels.

## Plot info

`mts_xys_line()` should:

- use `plot.info` if supplied;
- otherwise use the most recent stored `mts_plot()` info object;
- error clearly if no stored `mts_plot()` info is available;
- return the updated `plot.info` object invisibly;
- update the stored most-recent plot info when `record = TRUE`.

## Panel and column selection

Follow the same selection conventions as `mts_abline()`.

By default, draw on all data panels in:

```r
plot.info$data.panels
```

If `panels` is supplied:

- interpret it as full layout panel indices;
- allow data panels and blank panels if explicitly requested;
- validate that all requested panels exist.

If `columns` is supplied:

- interpret character values as plotted column names;
- interpret numeric values as plotted-column indices;
- map these to the corresponding data panels.

If both `panels` and `columns` are supplied, error clearly.

## Re-entering panels

Use the same internal panel re-entry mechanism as `mts_abline()`.

`mts_xys_line()` must not call `plot.new()` or clear the panel. It should re-enter each existing panel and add lines.

If the current internal helper is named something like `enter_mts_panel()`, reuse it.

## Graphical arguments

Graphical arguments in `...`, such as `col`, `lty`, and `lwd`, should work naturally.

Use the same graphical-parameter handling style as `mts_abline()` and `xys_line.default()`.

Requirements:

- scalar graphical arguments are reused for all selected panels and generated lines;
- vector graphical arguments are recycled predictably;
- named graphical argument vectors are matched by plotted column name where possible;
- non-multiple recycling warns.

Please avoid duplicate-argument errors.

## Vectorisation

`mts_xys_line()` should preserve the vectorisation semantics of `xys_line.default()`.

That is:

```r
mts_xys_line(0, c(0.1, -0.1), 1)
```

should draw two parallel lines in each selected panel.

If more than one of `x`, `y`, and `slope` is a vector, all combinations should be drawn in each selected panel.

Infinite slopes should work as vertical lines, as in `xys_line.default()`.

## Registry recording

If `record = TRUE`, append entries to:

```r
plot.info$curves
```

so these lines can be included in future legends if desired.

For recorded rows, include at least the existing curve-registry columns:

```r
source
source.label
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

Suggested values:

- `type = "xys_line"`;
- `source` defaults to `"xys_line"`;
- `source.label` uses the existing flexible source-label mechanism;
- `object.index` uses the next available object index;
- `drawn = TRUE`;
- `reason = NA_character_`.

If multiple point/slope lines are drawn in the same panel, record enough rows to represent each drawn line.

If useful, include additional registry columns such as:

```r
x
y
slope
intercept
```

These would be helpful for later inspection and legends. Add them if they fit cleanly with the existing registry design.

If `record = FALSE`, draw the lines but do not append registry rows.

## Source labels

Use the same flexible source-label mechanism already used by `mts_plot()`, `mts_lines()`, and `mts_abline()`.

`source` should accept:

- character scalar;
- scalar expression;
- `nice_text()` output;
- other scalar expression-like labels already supported by the `mts` plotting helpers.

Examples:

```r
mts_xys_line(0, 0, 1, source = "slope 1")
mts_xys_line(0, 0, 1, source = expression(slope == 1))
mts_xys_line(0, 0, 1, source = nice_text(r"($slope = 1$)"))
```

## S3 extensibility for `gaemr`

The purpose of making `xys_line()` generic is to allow downstream packages such as `gaemr` to define methods.

For example, `gaemr` may later define:

```r
xys_line.sir_solution <- function(x, ...) {
  ## Extract appropriate mts plot information or solution series from x.
  ## Then call earnmisc::mts_xys_line(...)
}
```

Please document the S3 extensibility briefly in the `xys_line()` documentation.

Do not implement any `gaemr`-specific method in `earnmisc`.

Do not add any `gaemr` dependency.

## Documentation

Add or update roxygen2 documentation for:

```r
xys_line()
xys_line.default()
mts_xys_line()
```

Documentation should explain:

- `xys_line()` is now an S3 generic;
- the default method preserves the existing numeric point/slope behaviour;
- other packages can provide methods for their own classes;
- `mts_xys_line()` adds point/slope lines to panels created by `mts_plot()`;
- `mts_xys_line()` is analogous to `mts_abline()`;
- by default it draws on all data panels and skips blank panels;
- `panels` selects full layout panel indices;
- `columns` selects plotted data columns;
- vectorisation of `x`, `y`, and `slope`;
- infinite slopes draw vertical lines;
- `record = TRUE` adds entries to the curve registry.

Use Canadian spelling.

Examples should be lightweight and check-friendly.

Include examples such as:

```r
xys_line(0, 0, 1)
xys_line(0, c(0.1, -0.1), 1)
```

and:

```r
z <- ts(cbind(a = 1:10, b = 11:20))
plot.info <- mts_plot(z)
plot.info <- mts_xys_line(0, 5, 1, plot.info = plot.info, col = "grey50")
```

Use temporary graphics devices in examples if necessary, or keep examples simple enough for checks.

## Tests

Add or revise tests for:

### S3 generic

- `xys_line()` is an S3 generic.
- `xys_line.default()` preserves existing scalar behaviour.
- `xys_line.default()` preserves existing vectorised behaviour.
- existing `xys_line()` tests still pass through the generic.
- a temporary test class can dispatch through `xys_line.test_class()` if useful.

### `mts_xys_line()`

Use temporary graphics devices and avoid image comparison.

Test:

- errors clearly when no `mts_plot()` info is available;
- uses the most recent stored `mts_plot()` info when `plot.info = NULL`;
- draws on all data panels by default;
- skips blank panels by default;
- explicit `panels` can target a blank panel if requested;
- `columns` restricts data panels by name;
- `columns` restricts data panels by index;
- supplying both `panels` and `columns` errors clearly;
- scalar graphical parameters work;
- vector graphical parameters work;
- named graphical parameters match by column where possible;
- non-multiple graphical-parameter recycling warns;
- vectorised `x`, `y`, and `slope` semantics are preserved;
- infinite slopes work;
- `record = TRUE` appends rows to `plot.info$curves`;
- `record = FALSE` does not append rows;
- source labels can be character, expression, and `nice_text()` output;
- returned object has class `earnmisc_mts_plot_info`;
- repeated `mts_xys_line()` calls accumulate registry rows when `record = TRUE`.

## Internal helpers

It is fine to add documented non-exported helpers such as:

```r
make_mts_xys_registry()
resolve_mts_xys_graphics()
```

Reuse existing internal helpers from `mts_abline()` and `xys_line.default()` wherever possible.

Document non-exported helpers with roxygen2 comments, following `AGENTS.md`.

Use base R only.

## Package docs

Update package-level documentation to mention `xys_line()` as an S3 generic and `mts_xys_line()` with the other `mts` plotting helpers.

Regenerate documentation and NAMESPACE.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:

1. How `xys_line()` was converted to an S3 generic.
2. How the default numeric behaviour was preserved.
3. What `mts_xys_line()` does.
4. How `mts_xys_line()` selects panels and columns.
5. How it re-enters existing panels without clearing them.
6. How vectorised point/slope arguments are handled.
7. How registry recording works.
8. What files changed.
9. What tests were added or revised.
10. What verification commands were run and their results.
11. Any limitations or TODOs.
