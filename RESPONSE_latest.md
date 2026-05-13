# Latest Codex Response Summary

- Entry ID: `20260513T153935Z`
- Recorded: `2026-05-13T15:42:39+00:00`

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
