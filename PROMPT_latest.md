# Latest Codex Prompt

- Entry ID: `20260509T180941Z`
- Recorded: `2026-05-09T18:09:41+00:00`

I want to create the initial skeleton and first implementation of a new R package called `earnmisc`.

Please read `AGENTS.md` first and follow it closely.

Goal for this first pass:
- Create a lean R package skeleton.
- Implement the initial general-purpose utilities.
- Add roxygen2 documentation.
- Add testthat tests.
- Ensure package-level help `?earnmisc` works.
- Keep dependencies minimal.

Initial exported functions to implement:

```r
okabe_ito_colours()
okabe_ito_palette()
xys_line()
```

Also consider implementing these if the design is simple and general-purpose:

```r
named_par_usr()
named_par_mar()
plot_metadata()
```

Do not over-engineer. It is fine to leave plot metadata helpers minimal if the reference code suggests too much package-specific complexity.

Important style requirements:
- Function names use underscores.
- Function arguments and local non-function object names use dots.
- Comments at the start of lines begin with `##`.
- End-of-line comments begin with `#`.
- Use Canadian spelling in documentation, comments, messages, and warnings.
- Prefer base R, `graphics`, `grDevices`, and `utils`.
- Avoid tidyverse dependencies.
- Use roxygen2.
- Use testthat.
- Export only generally useful utilities.

For `xys_line()`:

```r
xys_line(x, y, slope, ...)
```

should call something equivalent to:

```r
graphics::abline(a = y - slope * x, b = slope, ...)
```

and should invisibly return something useful, preferably:

```r
c(intercept = y - slope * x, slope = slope)
```

For Okabe--Ito colours:
- Provide the standard Okabe--Ito colourblind-friendly palette.
- Use these names:

```text
black
orange
sky_blue
bluish_green
yellow
blue
vermillion
reddish_purple
```

- Provide a function returning the full named palette.
- Provide a function returning the first `n` colours.
- Support `alpha` cleanly if possible, using `grDevices::adjustcolor()`.

Repository notes:
- `reference-code/` may contain useful reference material, but it is for inspection only.
- Do not copy code blindly from `reference-code/`.
- Reimplement clean, general-purpose versions suitable for `earnmisc`.
- Ensure `reference-code/` is ignored by Git and excluded from R package builds.
- The repository may contain `tools/` and `Makefile` copied from `agemortr`; these are development workflow files, not package functionality.
- Do not modify `tools/` unless necessary.
- Do not run `make prompt`, `make response`, or `make record.commit`.
- Do not create Git commits.

Please create or update these files as appropriate:

```text
DESCRIPTION
NAMESPACE
R/earnmisc-package.R
R/okabe_ito.R
R/xys_line.R
R/plot_metadata.R
tests/testthat.R
tests/testthat/test-okabe_ito.R
tests/testthat/test-xys_line.R
tests/testthat/test-plot_metadata.R
.Rbuildignore
.gitignore
README.md
```

Verification:
- If the Makefile exists and the relevant targets are usable, run:

```sh
make document
make test
make check
```

- If Makefile targets are not yet usable, run the closest direct R equivalents, such as:

```sh
Rscript -e 'roxygen2::roxygenise()'
Rscript -e 'testthat::test_local()'
R CMD check .
```

Please report:
1. What files you created or changed.
2. What functions were implemented and exported.
3. What tests were added.
4. What verification commands were run and their results.
5. Any assumptions or TODOs.
