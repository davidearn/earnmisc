# Latest Codex Prompt

- Entry ID: `20260515T144944Z`
- Recorded: `2026-05-15T14:49:44+00:00`

Please fix argument forwarding in `plot_mts_overlay()`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Problem

The following works:

```r
library(earnmisc)
library(gaemr)

sol.2 <- solve_sir(R0 = 2, x.minus = 1, start.level = 0.02)
sol.4 <- solve_sir(R0 = 4, x.minus = 1, start.level = 0.02)
sol.8 <- solve_sir(R0 = 8, x.minus = 1, start.level = 0.02)
m <- list(sol.2$series, sol.4$series, sol.8$series)

plot_mts_overlay(
  m[[3]], m[[2]], m[[1]],
  lwd.x = 3,
  plot.args = list(las = 1, bty = "L", xlim = c(-1, 2))
)
```

But either of these additions causes an error:

```r
plot.args = list(las = 1, bty = "L", xlim = c(-1, 2), col = oi.blue)
```

or:

```r
lines.args = list(lty = 1)
```

The error is:

```text
formal argument "lty" matched by multiple actual arguments
```

or the analogous error for another graphical argument.

This almost certainly means that `plot_mts_overlay()` is passing arguments such as `col`, `lty`, or `lwd` both explicitly and through `plot.args` / `lines.args`.

## Required design

`plot_mts_overlay()` should allow `plot.args` and `lines.args` to override the corresponding explicit defaults.

Specifically:

- `col.x`, `lty.x`, and `lwd.x` provide defaults for the base `plot_mts()` call.
- If `plot.args` contains `col`, `lty`, or `lwd`, those values should override `col.x`, `lty.x`, or `lwd.x`.
- `col.y`, `lty.y`, and `lwd.y` provide defaults for overlay `lines_mts()` calls.
- If `lines.args` contains `col`, `lty`, or `lwd`, those values should override `col.y`, `lty.y`, or `lwd.y`.
- More generally, `plot.args` should be allowed to override any explicitly constructed argument passed to `plot_mts()`, except for core arguments that must not be overridden such as `x`.
- `lines.args` should be allowed to override any explicitly constructed argument passed to `lines_mts()`, except for core arguments that must not be overridden such as `y`, `plot.info`, `source`, and `object.index`.

Use a small internal helper if useful, for example:

```r
merge_call_args(defaults, overrides, protected = character())
```

where:
- `defaults` are the arguments constructed by `plot_mts_overlay()`;
- `overrides` are `plot.args` or `lines.args`;
- `overrides` replace same-named defaults;
- protected names cannot be overridden and should error clearly if present in `overrides`.

Document any non-exported helper with roxygen2 comments, following `AGENTS.md`.

## Protected argument policy

Use this definitive policy.

For `plot.args`, disallow overriding:

```r
x
columns
```

because these are controlled by `x` and `columns.x`.

For `lines.args`, disallow overriding:

```r
y
plot.info
columns
source
object.index
```

because these are controlled internally for each overlay object.

If a user supplies one of those protected names, error clearly.

Other arguments in `plot.args` or `lines.args` may override defaults.

## Tests

Add or revise tests so that:

- `plot_mts_overlay(..., plot.args = list(col = oi.blue))` no longer errors.
- `plot_mts_overlay(..., lines.args = list(lty = 1))` no longer errors.
- `plot.args = list(col = ...)` overrides `col.x` in the base curve registry.
- `plot.args = list(lty = ...)` overrides `lty.x` in the base curve registry.
- `plot.args = list(lwd = ...)` overrides `lwd.x` in the base curve registry.
- `lines.args = list(col = ...)` overrides `col.y` in overlay curve registry rows.
- `lines.args = list(lty = ...)` overrides `lty.y` in overlay curve registry rows.
- `lines.args = list(lwd = ...)` overrides `lwd.y` in overlay curve registry rows.
- Supplying protected names in `plot.args`, such as `x` or `columns`, errors clearly.
- Supplying protected names in `lines.args`, such as `y`, `plot.info`, `columns`, `source`, or `object.index`, errors clearly.
- Existing tests for one and multiple overlays still pass.

Use a temporary graphics device and avoid image comparison.

## Documentation

Update `plot_mts_overlay()` documentation to explain:

- `plot.args` supplies additional arguments to `plot_mts()`;
- `lines.args` supplies additional arguments to `lines_mts()`;
- same-named values in `plot.args` override base plotting defaults such as `col.x`, `lty.x`, and `lwd.x`;
- same-named values in `lines.args` override overlay defaults such as `col.y`, `lty.y`, and `lwd.y`;
- protected core arguments cannot be supplied through `plot.args` or `lines.args`.

Use Canadian spelling.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What caused the duplicate formal-argument error.
2. How `plot.args` and `lines.args` are now merged with defaults.
3. Which arguments are protected from override.
4. What tests were added or revised.
5. What files changed.
6. What verification commands were run and their results.
