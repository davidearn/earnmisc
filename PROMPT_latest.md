# Latest Codex Prompt

- Entry ID: `20260509T185311Z`
- Recorded: `2026-05-09T18:53:11+00:00`

Please fix two issues in `xys_line()`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Problem 1: graphical parameters are not vectorised correctly

Currently, `xys_line()` ignores all but the first component of vector graphical parameters such as `col`, `lty`, and possibly `lwd`.

For example:

```r
plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))
xys_line(0, c(0.1, -0.1), 1,
         col = c("blue", "red"),
         lty = c("solid", "dotted"))
```

should draw one solid blue line and one dotted red line, but currently both lines are solid blue.

Please revise `xys_line()` so that graphical parameters supplied through `...` are handled sensibly when multiple lines are drawn.

Requirements:
- If a graphical parameter in `...` has length 1, recycle it for all lines.
- If a graphical parameter in `...` has length equal to the number of lines, use the corresponding element for each line.
- Use R’s ordinary recycling rules where appropriate.
- Pass the correct scalar graphical parameters to each individual `graphics::abline()` call.
- Preserve existing scalar behaviour.

This should work for common `abline()` graphical parameters such as:

```r
col
lty
lwd
```

but the implementation should not be unnecessarily restricted to only these names.

## Problem 2: infinite slopes should work

Currently, `xys_line()` crashes when `slope = Inf`.

A call such as:

```r
xys_line(0.5, 0, Inf)
```

should draw a vertical line through `x = 0.5`, equivalent to:

```r
graphics::abline(v = 0.5)
```

Requirements:
- `slope = Inf` should draw a vertical line at `x`.
- `slope = -Inf` should also draw a vertical line at `x`.
- For infinite slopes, `y` is irrelevant for plotting but should still be accepted for API consistency.
- The invisible return value should remain useful.
- For a scalar infinite-slope call, return something sensible and documented, for example:

```r
c(intercept = NA_real_, slope = Inf)
```

or include `x` if that is cleaner. Choose and document the design.
- For vectorised calls, include enough information in the returned data frame to identify vertical lines, including `x`, `y`, `slope`, and `intercept`, with `intercept = NA_real_` for vertical lines.
- Mixed finite and infinite slopes should work.

Examples that should work:

```r
plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))
xys_line(0, c(0.1, -0.1), 1,
         col = c("blue", "red"),
         lty = c("solid", "dotted"))

plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))
xys_line(c(-0.5, 0.5), 0, Inf,
         col = c("blue", "red"),
         lty = c("solid", "dotted"))

plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))
xys_line(0, 0, c(1, Inf),
         col = c("blue", "red"),
         lty = c("solid", "dotted"))
```

## Tests

Please add or revise tests for:
- vectorised `col`;
- vectorised `lty`;
- vectorised `lwd` if straightforward;
- scalar finite slope;
- scalar infinite slope;
- vectorised infinite slopes;
- mixed finite and infinite slopes;
- the invisible return values.

Avoid brittle graphics-device or image-comparison tests. Prefer testing the computed return values. If testing propagation of graphical parameters requires mocking or refactoring, keep the implementation simple and do not introduce heavy dependencies.

## Documentation

Please update roxygen2 documentation and examples for `xys_line()` to show:
- vectorised `x`, `y`, and `slope`;
- vectorised graphical parameters such as `col` and `lty`;
- infinite slopes for vertical lines.

Keep examples lightweight and check-friendly.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What bug caused graphical parameters to use only the first value.
2. How vector graphical parameters are now handled.
3. How infinite slopes are now handled.
4. What files changed.
5. What tests were added or revised.
6. What verification commands were run and their results.
