# AGENTS.md

## Project purpose

`earnmisc` is a small personal R utility package for general-purpose helper functions used across other packages, including `agemortr`, `gaemr`, and `mcmarksr2`.

The package should remain small, clean, well-documented, minimally dependent, and focused on reusable utilities rather than project-specific scientific code.

Initial intended scope includes:

- Okabe--Ito colour palette helpers.
- `xys_line()`, a small wrapper around `graphics::abline()` that draws a line through a point `(x, y)` with a specified slope.
- General base-graphics plot metadata helpers, possibly adapted from existing `agemortr` reference code.

## Design principles

- Prefer simple, explicit base R implementations.
- Keep dependencies minimal.
- Avoid tidyverse dependencies unless there is a clear and explicit reason.
- Prefer functions from base R and recommended packages such as `graphics`, `grDevices`, and `utils`.
- Export only generally useful utilities.
- Do not add project-specific scientific functions to this package.
- Keep examples lightweight and suitable for `R CMD check`.
- Plotting examples should draw to the current graphics device rather than writing files.

## Coding style

Follow these style preferences throughout the package:

- Function names use underscores, for example `okabe_ito_palette()`.
- Function arguments and local non-function object names use dots, for example `alpha.value`.
- Comments at the start of lines begin with `##`.
- End-of-line comments begin with `#`.
- Use Canadian spelling in documentation, comments, messages, and warnings.
- Prefer clear, direct code over clever abstractions.
- Avoid unnecessary metaprogramming.

## Documentation

Use `roxygen2` documentation for exported functions and package-level documentation.

Package-level help must work:

```r
?earnmisc
```

The package-level documentation should briefly describe the purpose of the package and list the main utility families.

All exported functions should have roxygen2 documentation including:

- title;
- description;
- parameters;
- return value;
- lightweight examples;
- `@export` where appropriate.

## Testing

Use `testthat` for tests.

Tests should cover core behaviour and edge cases without being brittle. For plotting helpers, tests should check returned values and avoid relying on image comparison unless explicitly requested.

For example, `xys_line(x, y, slope, ...)` should be tested for the intercept calculation and invisible return value.

## Reference code

The repository may contain an ignored folder:

```text
reference-code/
```

This folder is reference material only. It may contain code copied from other packages, such as:

```text
reference-code/okabe_ito_from_gaemr.R
reference-code/xys_line_reference.R
reference-code/plot_metadata_from_agemortr.R
reference-code/AGENTS-agemortr.md
reference-code/AGENTS-gaemr.md
reference-code/AGENTS-mcmarksr2.md
reference-code/README.md
```

Important rules:

- Inspect `reference-code/` when useful.
- Do not copy code blindly from `reference-code/`.
- Reimplement clean, general-purpose versions suitable for `earnmisc`.
- Keep `reference-code/` out of Git.
- Keep `reference-code/` out of R package builds.

The repository may also contain `tools/` and a `Makefile` copied from `agemortr` for development workflow. These are not package functionality.

- Do not modify `tools/` unless explicitly asked.
- Do not run `make prompt`, `make response`, or `make record.commit` unless explicitly asked.
- Do not create Git commits unless explicitly asked.
- Ensure `tools/` and `Makefile` are excluded from the built R package via `.Rbuildignore`.

## Initial package structure

A simple initial structure is expected:

```text
earnmisc/
├── AGENTS.md
├── DESCRIPTION
├── NAMESPACE
├── R/
│   ├── earnmisc-package.R
│   ├── okabe_ito.R
│   ├── xys_line.R
│   └── plot_metadata.R
├── man/
├── tests/
│   ├── testthat.R
│   └── testthat/
│       ├── test-okabe_ito.R
│       ├── test-xys_line.R
│       └── test-plot_metadata.R
├── reference-code/       # ignored; reference only
├── tools/                # development workflow only
├── Makefile              # development workflow only
├── .Rbuildignore
├── .gitignore
└── README.md
```

This structure may evolve, but keep the package lean.

## Initial API direction

Likely initial exported functions include:

```r
okabe_ito_colours()
okabe_ito_palette()
xys_line()
```

Possible additional exported functions include:

```r
named_par_usr()
named_par_mar()
plot_metadata()
```

Before exporting additional helpers, consider whether they are general-purpose enough to belong in `earnmisc`.

## Expected behaviour notes

### `xys_line()`

The intended user-facing form is:

```r
xys_line(x, y, slope, ...)
```

It should call something equivalent to:

```r
graphics::abline(a = y - slope * x, b = slope, ...)
```

It should invisibly return something useful, probably:

```r
c(intercept = y - slope * x, slope = slope)
```

### Okabe--Ito colours

Okabe--Ito helpers should provide the standard colourblind-friendly palette with clear names such as:

```r
black
orange
sky_blue
bluish_green
yellow
blue
vermillion
reddish_purple
```

Provide a convenient way to get:

- the full named palette;
- the first `n` colours;
- optionally alpha-adjusted colours using `grDevices::adjustcolor()` if this can be done cleanly.

## Verification expectations

Once the package skeleton and Makefile exist, typical verification commands include:

```sh
make document
make test
make check
```

Use the Makefile targets when available and appropriate. If a target fails because the package skeleton is not yet complete, report that clearly and proceed with the most direct equivalent R command when sensible.

Do not run prompt/response logging targets unless explicitly instructed.
