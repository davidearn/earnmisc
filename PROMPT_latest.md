# Latest Codex Prompt

- Entry ID: `20260519T195614Z`
- Recorded: `2026-05-19T19:56:14+00:00`

Please rename the `mts` plotting helper functions in `earnmisc` to use the `mts_*` naming pattern consistently.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Rename the `mts` plotting helpers cleanly, with no backwards compatibility aliases and no remaining references to the old names.

This package is not yet used by anyone else, so we can make a clean breaking change now.

## Required renames

Rename these exported functions:

```r
plot_mts()         -> mts_plot()
lines_mts()        -> mts_lines()
abline_mts()       -> mts_abline()
legend_mts()       -> mts_legend()
set_mts_panel()    -> mts_set_panel()
plot_mts_overlay() -> mts_plot_overlay()
```

Do not retain the old function names as aliases, wrappers, deprecated functions, or documentation references.

## Naming convention

Use the `mts_*` prefix consistently for this family.

If future documentation mentions a possible helper for adding to an existing panel without clearing it, refer to it as:

```r
mts_add_to_panel()
```

Do not refer to `add_to_mts_panel()` or `with_mts_panel()`.

## Required package-wide updates

Please update all relevant files, including:

- R source files;
- roxygen2 documentation;
- examples;
- tests;
- package-level documentation;
- NAMESPACE;
- internal references;
- error messages;
- comments;
- test descriptions;
- generated `.Rd` files after roxygen.

Search thoroughly for the old names:

```text
plot_mts
lines_mts
abline_mts
legend_mts
set_mts_panel
plot_mts_overlay
add_to_mts_panel
with_mts_panel
```

After the rename, these strings should not appear anywhere in package source, documentation, tests, or generated help files, except in deliberately ignored historical prompt logs if those are outside the package source.

Within package code and docs, use only:

```text
mts_plot
mts_lines
mts_abline
mts_legend
mts_set_panel
mts_plot_overlay
mts_add_to_panel
```

where `mts_add_to_panel()` should be mentioned only as a possible future helper, not implemented in this task.

## Documentation expectations

Update the roxygen2 documentation so that the new names are the only documented names.

The help pages should be generated as:

```r
?mts_plot
?mts_lines
?mts_abline
?mts_legend
?mts_set_panel
?mts_plot_overlay
```

Documentation should continue to explain:

- `mts_plot()` creates the multi-panel layout and stores plot metadata;
- `mts_lines()` overlays matching columns of another `mts`;
- `mts_abline()` adds `abline()`-style reference lines to data panels;
- `mts_legend()` constructs legends from the accumulated curve registry;
- `mts_set_panel()` reinitialises a selected panel, mainly for reserved blank panels;
- `mts_plot_overlay()` is the convenience wrapper for plotting one base `mts` and one or more overlays;
- arbitrary base `plot.mts()` output is not supported;
- reserved blank panels remain available.

Use Canadian spelling.

## Examples

Update all examples to use the new names.

For example, replace patterns like:

```r
plot.info <- plot_mts(x, blank.panels = 1)
plot.info <- lines_mts(y, plot.info = plot.info, source = "overlay")
plot.info <- abline_mts(h = 0, plot.info = plot.info)
set_mts_panel(1, plot.info)
legend_mts(plot.info)
```

with:

```r
plot.info <- mts_plot(x, blank.panels = 1)
plot.info <- mts_lines(y, plot.info = plot.info, source = "overlay")
plot.info <- mts_abline(h = 0, plot.info = plot.info)
mts_set_panel(1, plot.info)
mts_legend(plot.info)
```

And replace:

```r
plot_mts_overlay(x, y, z)
```

with:

```r
mts_plot_overlay(x, y, z)
```

## Tests

Update all tests to use the new names.

Add or revise tests to confirm:

- the new functions are exported;
- the old functions are not exported;
- the main workflow works with the new names:

```r
plot.info <- mts_plot(x, blank.panels = 1)
plot.info <- mts_lines(y, plot.info = plot.info)
plot.info <- mts_abline(h = 0, plot.info = plot.info)
panel.info <- mts_set_panel(1, plot.info)
legend.info <- mts_legend(plot.info)
```

- `mts_plot_overlay()` works with one or more overlays;
- curve registry, source labels, blank panels, legends, panel setting, and abline recording still behave as before.

Avoid brittle graphics-image comparisons.

## Internal helpers and stored metadata

Update internal helper names only if they directly include the old public function names and would now be confusing.

Do not rename internal helpers unnecessarily.

The class name can remain:

```r
earnmisc_mts_plot_info
```

because it describes the object, not the old function name.

Stored metadata names such as `plot.info` are fine to keep where they mean “plot information”; they do not need to become `mts.info`.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:

1. Which exported functions were renamed.
2. Whether all old public names were removed from exports, documentation, examples, and tests.
3. Whether documentation references to future helpers now use `mts_add_to_panel()`.
4. What files changed.
5. What tests were added or revised.
6. What verification commands were run and their results.
7. Any remaining TODOs or concerns.
