# AGENTS.md

## Project purpose

`earnmisc` is a small personal R utility package for general-purpose helper functions used across other packages, including `agemortr`, `gaemr`, and `mcmarksr2`.

The package should remain small, clean, well-documented, minimally dependent, and focused on reusable utilities rather than project-specific scientific code.

Current intended scope includes:

- Okabe--Ito colour palette helpers.
- `xys_line()`, a wrapper around `graphics::abline()` that draws lines through specified points with specified slopes.
- General base-graphics plot metadata helpers.
- Plot-label helpers such as `nice_text()`.
- TeX/tikz graphics helpers such as `tikz_open()`, `tikz_info()`, and `tikz_compile()`.
- Development-oriented helpers that are broadly useful across the user's packages.

## Design principles

- Prefer simple, explicit base R implementations.
- Keep dependencies minimal.
- Avoid tidyverse dependencies unless there is a clear and explicit reason.
- Prefer functions from base R and recommended packages such as `graphics`, `grDevices`, and `utils`.
- Use suggested packages conditionally with `requireNamespace()` when possible.
- Keep optional package dependencies in `Suggests` rather than `Imports` unless they are genuinely required for ordinary package use.
- Export only generally useful utilities.
- Do not add project-specific scientific functions to this package.
- Keep examples lightweight and suitable for `R CMD check`.
- Plotting examples should draw to the current graphics device rather than writing files unless file output is the explicit subject of the example.
- Avoid broad rewrites when a small, well-tested change is sufficient.
- Preserve existing documented behaviour unless explicitly asked to change it.

## Coding style

Follow these style preferences throughout the package:

- Function names use underscores, for example `okabe_ito_palette()`.
- Function arguments and local non-function object names use dots, for example `alpha.value`.
- Comments at the start of lines begin with `##`.
- End-of-line comments begin with `#`.
- Use Canadian spelling in documentation, comments, messages, and warnings.
- Prefer clear, direct code over clever abstractions.
- Avoid unnecessary metaprogramming.
- Prefer small documented helper functions over large opaque functions.

## Documentation

Use `roxygen2` documentation for exported functions, non-exported functions, and package-level documentation.

Package-level help must work:

```r
?earnmisc
```

The package-level documentation should briefly describe the purpose of the package and list the main utility families.

### Internal function documentation

Use roxygen2-style documentation for all functions, including non-exported internal helpers.

For exported functions, include complete user-facing documentation and `@export`.

For non-exported functions, include concise roxygen2 documentation explaining purpose, parameters, return value, and important assumptions. Do not add `@export`. Internal documentation should help future maintainers understand the code without making internal helpers part of the public API.

Do not avoid helper functions merely because they require documentation; prefer clear, documented helpers over large opaque functions.

All exported functions should have roxygen2 documentation including:

- title;
- description;
- parameters;
- return value;
- lightweight examples;
- `@export` where appropriate.

For non-exported functions, examples are usually unnecessary. Keep internal documentation concise but useful.

## Testing

Use `testthat` for tests.

Tests should cover core behaviour and edge cases without being brittle. For plotting helpers, tests should check returned values and avoid relying on image comparison unless explicitly requested.

For example, `xys_line(x, y, slope, ...)` should be tested for intercept calculation, vectorised behaviour, graphical-parameter handling, vertical-line handling, and invisible return value.

Tests that require optional packages or external tools should skip cleanly when those tools are unavailable.

Avoid tests that depend unnecessarily on exact internals of optional packages such as `latex2exp`, `tikzDevice`, or a local LaTeX installation.

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

## Current package structure

The package structure is expected to remain lean. A typical structure is:

```text
earnmisc/
├── AGENTS.md
├── DESCRIPTION
├── NAMESPACE
├── R/
│   ├── earnmisc-package.R
│   ├── okabe_ito.R
│   ├── xys_line.R
│   ├── plot_metadata.R
│   ├── nice_text.R
│   └── tikz.R
├── inst/
│   └── tex/
│       ├── default-macros.tex
│       └── default-ignore-commands.txt
├── man/
├── tests/
│   ├── testthat.R
│   └── testthat/
│       ├── test-okabe_ito.R
│       ├── test-xys_line.R
│       ├── test-plot_metadata.R
│       ├── test-nice_text.R
│       └── test-tikz.R
├── reference-code/       # ignored; reference only
├── tools/                # development workflow only
├── Makefile              # development workflow only
├── .Rbuildignore
├── .gitignore
└── README.md
```

This structure may evolve, but keep the package small and understandable.

## Current public API direction

Current exported functions include or may include:

```r
okabe_ito_colours()
okabe_ito_palette()
oi_alpha()
oi_colour()
xys_line()
named_par_usr()
named_par_mar()
named_par_list()
plot_metadata()
nice_text()
nice_text_default_macros_file()
nice_text_default_ignore_file()
nice_text_macros()
nice_text_ignore_commands()
tikz_open()
tikz_info()
tikz_compile()
```

Before exporting additional helpers, consider whether they are general-purpose enough to belong in `earnmisc`.

## Expected behaviour notes

### `xys_line()`

The intended user-facing form is:

```r
xys_line(x, y, slope, ...)
```

For finite slopes, it should call something equivalent to:

```r
graphics::abline(a = y - slope * x, b = slope, ...)
```

For infinite slopes, it should draw a vertical line at `x`, equivalent to:

```r
graphics::abline(v = x, ...)
```

It should support vector inputs. If more than one of `x`, `y`, and `slope` is a vector, all combinations should be plotted.

Graphical parameters supplied through `...`, such as `col`, `lty`, and `lwd`, should be recycled line-by-line when multiple lines are drawn.

For a scalar finite-slope call, it should invisibly return something useful, preferably:

```r
c(intercept = y - slope * x, slope = slope)
```

For vectorised calls, it should invisibly return a data frame with enough information to identify all plotted lines.

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

The extended palette is the default for this package, but documentation should clearly distinguish the original 8-colour Okabe--Ito palette from extended convenience colours.

Provide a convenient way to get:

- the full named palette;
- the first `n` colours;
- exported colour constants such as `oi.orange`;
- alpha-adjusted colours using `grDevices::adjustcolor()`.

The intended plotting idiom for exported colour constants is:

```r
col = oi.orange
```

Do not add support for quoted pseudo-colour names such as:

```r
col = "oi.orange"
```

### Base-graphics metadata helpers

Base-graphics metadata helpers should remain general-purpose.

`named_par_list()` should return the output of `graphics::par(no.readonly = TRUE)` or equivalent, with common vector-valued entries named sensibly where possible.

`plot_metadata()` should include the named full par list produced by `named_par_list()`.

### `nice_text()`

`nice_text()` is a lightweight helper for plot labels.

It should support both tikz and non-tikz workflows:

- In tikz mode, expand package and user TeX macros and return character LaTeX strings.
- In non-tikz mode, expand macros, clean ignored TeX commands, and use `latex2exp::TeX()` when available.
- It is not a full TeX parser.

Package default TeX support files should live under:

```text
inst/tex/default-macros.tex
inst/tex/default-ignore-commands.txt
```

Users should be able to append to or replace these defaults using function arguments and package options.

Default macro files should reflect stable cross-package plot-label notation for this package. Do not add generic mathematical macros merely because they are common.

### `tikz_open()`, `tikz_info()`, and `tikz_compile()`

`tikz_open()` should wrap `tikzDevice::tikz()`, keep `tikzDevice` in `Suggests`, default to `standAlone = TRUE`, and store metadata that can be retrieved later with `tikz_info()`.

`tikz_open()` should print a helpful message by default, for example:

```text
tikz_open: writing to filename.tex (width = 14, height = 7) ...
```

Do not print `done` from `tikz_open()`, because the function cannot reliably know when the graphics device will later be closed.

`tikz_compile()` should compile a tikz `.tex` file, or the info object returned by `tikz_open()`, using `lualatex` in batch mode by default.

Do not require LaTeX or `tikzDevice` for ordinary package checks; tests requiring those tools should skip cleanly.

## Verification expectations

Once the package skeleton and Makefile exist, typical verification commands include:

```sh
make document
make test
make check
```

Use the Makefile targets when available and appropriate. If a target fails because the package skeleton is not yet complete, report that clearly and proceed with the most direct equivalent R command when sensible.

Do not run prompt/response logging targets unless explicitly instructed.

## Reporting expectations

When reporting work, include:

1. What files changed.
2. What functions were added or revised.
3. What tests were added or revised.
4. What verification commands were run and their results.
5. Any assumptions, limitations, or TODOs.

Do not create Git commits unless explicitly asked. If asked to suggest a commit message, provide one clean copyable block.
