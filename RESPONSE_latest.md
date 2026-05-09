# Latest Codex Response Summary

- Entry ID: `20260509T185311Z`
- Recorded: `2026-05-09T18:55:25+00:00`

Fixed `xys_line()`.

The graphical-parameter bug came from passing the full `...` unchanged to each scalar `graphics::abline()` call. Since each call draws one line, graphics parameters like `col = c("blue", "red")` were effectively treated as scalar and only the first value was used.

Now `xys_line()` expands graphical parameters once per line:
- length-1 values are recycled for every line;
- length-`n` values are matched line-by-line;
- non-multiple lengths use ordinary recycling with a warning;
- each `abline()` call receives scalar line-specific parameters.

Infinite slopes now work:
- `slope = Inf` and `slope = -Inf` call `graphics::abline(v = x, ...)`;
- scalar infinite-slope calls invisibly return `c(intercept = NA_real_, slope = Inf)`;
- vectorised returns include `x`, `y`, `slope`, and `intercept`, with `intercept = NA_real_` for vertical lines;
- mixed finite and infinite slopes are handled in the same call.

Changed files:
- [R/xys_line.R](/Users/earn/r/earnmisc/R/xys_line.R)
- [tests/testthat/test-xys_line.R](/Users/earn/r/earnmisc/tests/testthat/test-xys_line.R)
- [man/xys_line.Rd](/Users/earn/r/earnmisc/man/xys_line.Rd)

Tests added/revised for scalar finite slope, scalar infinite slope, vectorised `col`, `lty`, `lwd`, scalar graphical-parameter recycling, vectorised infinite slopes, mixed finite/infinite slopes, and invisible return values.

Verification:
- `make document`: passed.
- `make test`: passed.
- `make check`: passed with `Status: OK`.

I left the pre-existing unrelated dirty files alone: `PROMPT_latest.md`, `PROMPTS_used.md`, and `sandbox/explore.R`.
