# Latest Codex Prompt

- Entry ID: `20260513T153935Z`
- Recorded: `2026-05-13T15:39:35+00:00`

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
