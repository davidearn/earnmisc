# Latest Codex Response Summary

- Entry ID: `20260515T200531Z`
- Recorded: `2026-05-15T20:08:31+00:00`

Fixed source tracking for the `mts` plotting workflow.

The collapse happened because `plot_mts()` always recorded base curves as `"base"` and direct `lines_mts()` calls defaulted to `"overlay"`, so `legend_mts(by = "source")` correctly grouped identical labels, but the labels were too coarse.

Now:
- `plot_mts(x)` infers the source label from the expression for `x`, e.g. `m[[3]]`.
- `lines_mts(y)` infers the source label from the expression for `y`, e.g. `m[[2]]`.
- Explicit `source = "label"` overrides the inferred label in both functions.
- `plot_mts_overlay()` now has `source.x = NULL`; overlay labels come from `overlay.names` if supplied, otherwise from overlay expressions in `...`.
- Direct repeated `lines_mts()` calls still increment `object.index` automatically: base is `0L`, first overlay is `1L`, second is `2L`, etc.
- `legend_mts(by = "source")` continues to select the first drawn curve per distinct source in first-seen order, now with useful distinct source labels.

Tests were added/revised for:
- inferred labels like `m[[3]]`, `m[[2]]`, `m[[1]]`;
- explicit `source` overrides;
- three source legend entries for the motivating pattern;
- explicit `legend` labels overriding source labels;
- `plot_mts_overlay()` inferred and explicit overlay labels;
- sensible `object.index` values.

Files changed:
- [R/mts_plot.R](/Users/earn/r/earnmisc/R/mts_plot.R)
- [man/plot_mts.Rd](/Users/earn/r/earnmisc/man/plot_mts.Rd)
- [man/lines_mts.Rd](/Users/earn/r/earnmisc/man/lines_mts.Rd)
- [man/plot_mts_overlay.Rd](/Users/earn/r/earnmisc/man/plot_mts_overlay.Rd)
- [man/legend_mts.Rd](/Users/earn/r/earnmisc/man/legend_mts.Rd)
- [tests/testthat/test-mts_plot.R](/Users/earn/r/earnmisc/tests/testthat/test-mts_plot.R)

Verification:
- `make document` passed.
- `make test` passed.
- `make check` passed with `Status: OK`.

The check printed repository index access warnings due restricted network access, but the package check itself completed cleanly.
