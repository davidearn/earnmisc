# Latest Codex Prompt

- Entry ID: `20260515T191224Z`
- Recorded: `2026-05-15T19:12:24+00:00`

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
