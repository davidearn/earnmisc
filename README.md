# earnmisc

`earnmisc` is a small personal R package for general-purpose helper functions
used across related packages.

Initial utilities include:

* Okabe-Ito colour palette helpers: `okabe_ito_colours()` and
  `okabe_ito_palette()`.
* `xys_line()`, an S3 generic whose default method draws a line through a point
  with a specified slope.
* `mts_*` plotting helpers for multivariate time-series overlays and reference
  lines, including `mts_xys_line()`.
* Small base graphics plot metadata helpers.

The package is intentionally lean and avoids non-essential dependencies.
