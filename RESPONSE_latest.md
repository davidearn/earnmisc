# Latest Codex Response Summary

- Entry ID: `20260515T144944Z`
- Recorded: `2026-05-15T14:52:10+00:00`

Fixed `plot_mts_overlay()` argument forwarding.

The duplicate formal-argument error was caused by building calls with `c(defaults, plot.args)` / `c(defaults, lines.args)`, which allowed duplicate names like `col`, `lty`, or `lwd` to reach `do.call()`.

Now `plot_mts_overlay()` uses an internal `merge_call_args()` helper:
- same-named values in `plot.args` replace constructed `plot_mts()` defaults;
- same-named values in `lines.args` replace constructed `lines_mts()` defaults;
- protected core arguments error clearly.

Protected names:
- `plot.args`: `x`, `columns`
- `lines.args`: `y`, `plot.info`, `columns`, `source`, `object.index`

Tests were added for:
- `plot.args = list(col = ...)`, `lty`, and `lwd` overriding base registry values;
- `lines.args = list(col = ...)`, `lty`, and `lwd` overriding overlay registry values;
- protected-name errors for both argument lists;
- existing one/multiple overlay behaviour still passing.

Files changed:
- [R/mts_plot.R](/Users/earn/r/earnmisc/R/mts_plot.R)
- [man/plot_mts_overlay.Rd](/Users/earn/r/earnmisc/man/plot_mts_overlay.Rd)
- [tests/testthat/test-mts_plot.R](/Users/earn/r/earnmisc/tests/testthat/test-mts_plot.R)

Verification:
- `make document` passed.
- `make test` passed.
- `make check` passed, `Status: OK`.

The check still prints repository index access warnings from restricted network access, but the package check itself is clean.
