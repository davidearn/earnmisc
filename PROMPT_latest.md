# Latest Codex Prompt

- Entry ID: `20260509T183521Z`
- Recorded: `2026-05-09T18:35:21+00:00`

Please revise the initial `earnmisc` implementation based on the following API and documentation requests.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/` unless explicitly necessary.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Okabe--Ito colours

The package should support both the original Okabe--Ito palette and an extended Okabe--Ito-style palette, as in the reference code.

Please inspect the relevant reference code in:

```text
reference-code/okabe_ito_from_gaemr.R
```

Use it for guidance only. Do not copy blindly.

Requirements:
- Make the original Okabe--Ito colours available.
- Make the extended Okabe--Ito colours available.
- Documentation should clearly distinguish the original palette from the extended palette.
- The default behaviour should remain simple and unsurprising.
- Preserve clear, stable names for colours.
- Continue to support alpha cleanly using `grDevices::adjustcolor()` if already implemented.
- Add or revise tests for original palette, extended palette, names, values, alpha handling, and input validation.

Please decide the cleanest API, but prefer keeping the existing names if possible:

```r
okabe_ito_colours()
okabe_ito_palette()
```

For example, it might be reasonable for one or both functions to have an argument such as `extended = FALSE`, but choose the cleanest design and document it clearly.

## Named graphics parameters

Please add a general helper:

```r
named_par_list()
```

This should return the full output of `graphics::par(no.readonly = TRUE)` or equivalent, but with vector-valued entries named sensibly where possible.

Requirements:
- Preserve all standard `par()` entries.
- Add names to common vector entries such as `usr`, `mar`, `oma`, `mai`, `omi`, `pin`, `plt`, `fig`, and similar where sensible.
- Avoid over-engineering.
- Keep the helper general-purpose.
- Export it if it is useful as a standalone utility.
- Add roxygen2 documentation and tests.

The existing helpers:

```r
named_par_usr()
named_par_mar()
```

should either use `named_par_list()` internally where appropriate, or remain as simple focused helpers if that is cleaner.

## `plot_metadata()`

Revise `plot_metadata()` so that it includes the named full par list produced by `named_par_list()`.

For example, the returned metadata should include something like:

```r
par.list
```

where `par.list` is the named list returned by `named_par_list()`.

Please keep `plot_metadata()` general-purpose and not tied to `agemortr`.

Update documentation and tests accordingly.

## `xys_line()` vectorisation

Please check whether `xys_line()` currently supports vector input.

It should support vector arguments.

Required behaviour:

```r
xys_line(0, c(0.1, -0.1), 1)
```

should draw two parallel lines with intercepts `0.1` and `-0.1`.

If more than one of `x`, `y`, and `slope` is a vector, then all combinations should be plotted.

For example, conceptually:

```r
xys_line(x = c(0, 1), y = c(0.1, -0.1), slope = c(1, 2))
```

should plot every combination of `x`, `y`, and `slope`.

Requirements:
- Use a clear and predictable implementation, probably based on `expand.grid()` or equivalent base R code.
- Call `graphics::abline()` once per line.
- Return the intercept and slope values invisibly in a useful structure.
- For a scalar call, preserve the existing simple return if possible, or document any intentional change.
- For vectorised calls, return enough information to identify all plotted lines.
- Add examples showing scalar and vector use.
- Add tests for scalar input, one vector argument, and multiple vector arguments.
- Avoid brittle graphics-device tests; test the computed return values.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

If any Makefile targets are unavailable, use the closest direct R equivalents.

Please report:
1. What design choices you made.
2. What files you changed.
3. What functions were added or revised.
4. What tests were added or revised.
5. What verification commands you ran and their results.
6. Any remaining TODOs or questions.
