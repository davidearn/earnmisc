# Latest Codex Prompt

- Entry ID: `20260509T225207Z`
- Recorded: `2026-05-09T22:52:07+00:00`

Please revise the proposed `nice_text()` design so that `earnmisc` ships with default TeX macro and ignore-command files.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add `nice_text()` to `earnmisc`, with package-supplied default TeX support files.

The package should include default files that can be maintained over time:

```text
inst/tex/default-macros.tex
inst/tex/default-ignore-commands.txt
```

These files should provide the basic TeX macro expansion and ignore-command behaviour that most users of `nice_text()` will want, without requiring them to configure anything.

Users should also be able to supply their own files, either replacing the package defaults or appending to them.

## Main API

Please implement and export:

```r
nice_text(
  x,
  use.tikz = NULL,
  macros.file = NULL,
  ignore.file = NULL,
  append.macros = TRUE,
  append.ignore = TRUE,
  warn = TRUE
)
```

Use this exact API unless there is a strong reason to adjust it.

## Default package files

Add package default files:

```text
inst/tex/default-macros.tex
inst/tex/default-ignore-commands.txt
```

After installation, these should be accessed with:

```r
system.file("tex", "default-macros.tex", package = "earnmisc")
system.file("tex", "default-ignore-commands.txt", package = "earnmisc")
```

The default macro file should include a small, conservative set of generally useful macros, for example definitions related to common plot-label notation. Include `\Rn` support if the underlying macros are defined, for example:

```tex
\newcommand{\R}{\mathcal R}
\newcommand{\Rn}{\R_0}
```

The default ignore-command file should include common TeX commands that should be removed or simplified for non-tikz graphics devices, such as:

```text
\mathrm
\mathsf
\mathbf
\mathit
\textrm
\textsf
\textbf
\textit
\quad
\qquad
\,
\:
\;
\!
```

Keep both files conservative. This is not intended to be a full TeX system.

## User-supplied files

Users should be able to provide additional macro and ignore files with:

```r
nice_text(x, macros.file = "my-macros.tex")
nice_text(x, ignore.file = "my-ignore-commands.txt")
```

The default should be to append user-supplied files to the package defaults:

```r
append.macros = TRUE
append.ignore = TRUE
```

This means:
- package defaults are read first;
- user-supplied files are read second;
- user definitions may override package defaults if the same macro is defined again.

If `append.macros = FALSE`, use only `macros.file`.

If `append.ignore = FALSE`, use only `ignore.file`.

If `macros.file = NULL`, check:

```r
getOption("earnmisc.tex_macros_file")
```

If that option is set, treat it as the user-supplied macros file.

If `ignore.file = NULL`, check:

```r
getOption("earnmisc.tex_ignore_file")
```

If that option is set, treat it as the user-supplied ignore file.

The package defaults should still be used unless the corresponding append argument is `FALSE`.

## Helper functions for inspection

Please add easy ways to inspect the active and default TeX support lists.

Implement and export these functions:

```r
nice_text_default_macros_file()
nice_text_default_ignore_file()
nice_text_macros(macros.file = NULL, append.macros = TRUE)
nice_text_ignore_commands(ignore.file = NULL, append.ignore = TRUE)
```

Suggested behaviour:

### `nice_text_default_macros_file()`

Return the path to the installed package default macros file.

### `nice_text_default_ignore_file()`

Return the path to the installed package default ignore-command file.

### `nice_text_macros()`

Return the currently active no-argument macro definitions as a named character vector or data frame.

It should include:
- package defaults;
- user option file from `getOption("earnmisc.tex_macros_file")`, if set;
- explicit `macros.file`, if supplied;
- user definitions appended or replacing defaults according to `append.macros`.

Document the exact return type.

### `nice_text_ignore_commands()`

Return the currently active ignore-command list as a character vector.

It should include:
- package defaults;
- user option file from `getOption("earnmisc.tex_ignore_file")`, if set;
- explicit `ignore.file`, if supplied;
- user commands appended or replacing defaults according to `append.ignore`.

Document the exact return type.

## `use.tikz` behaviour

If `use.tikz` is `TRUE`, return `x` unchanged.

If `use.tikz` is `FALSE`, preprocess `x` using macros and ignore-command rules, then convert with `latex2exp::TeX()` when `latex2exp` is available.

If `use.tikz = NULL`, look for an object called `use.tikz` in the calling environment.

Suggested behaviour:
- If the calling environment contains a scalar logical object named `use.tikz`, use that value.
- Otherwise default to `FALSE`.
- Validate that `use.tikz` is ultimately a scalar logical value.

## Dependencies

Do not put `latex2exp` in `Imports`.

Use it conditionally via:

```r
requireNamespace("latex2exp", quietly = TRUE)
```

Add `latex2exp` to `Suggests` if needed.

If `latex2exp` is not available and `use.tikz = FALSE`, return the preprocessed character vector rather than failing.

## TeX macro expansion

Support simple no-argument definitions of the form:

```tex
\newcommand{\foo}{replacement}
\renewcommand{\foo}{replacement}
\def\foo{replacement}
```

Requirements:
- Support no-argument macros only in this first implementation.
- Recursive expansion is useful, but protect against infinite loops with a small maximum number of passes.
- Ignore unsupported macro definitions rather than failing.
- Give clear warnings only when `warn = TRUE`.
- Keep the parser simple and well tested; do not attempt to implement full TeX.

Example:

```tex
\newcommand{\R}{\mathcal R}
\newcommand{\Rn}{\R_0}
```

should allow:

```r
nice_text("$\\Rn$")
```

to expand before non-tikz conversion.

## Ignored TeX commands for non-tikz devices

When `use.tikz = FALSE`, unsupported TeX commands should not leak into plot labels as plain text.

For example:

```r
nice_text("$A_{\\mathrm i}$")
```

should not produce a label containing the literal text `mathrm`.

Requirements:
- Commands like `\mathrm{...}`, `\mathsf{...}`, `\mathbf{...}`, `\mathit{...}`, and similar one-argument style wrappers should keep their contents and remove the command.
- Commands like `\quad`, `\,`, `\:`, `\;`, `\!`, and similar spacing commands should be removed.
- Keep this conservative. Do not rewrite mathematical meaning.
- Apply this only when `use.tikz = FALSE`.

For commands listed in ignore files:
- one-argument wrapper commands such as `\foo{bar}` should become `bar`;
- bare commands such as `\foo` should be removed.

## Documentation

Add roxygen2 documentation for:
- `nice_text()`;
- `nice_text_default_macros_file()`;
- `nice_text_default_ignore_file()`;
- `nice_text_macros()`;
- `nice_text_ignore_commands()`.

The documentation should explain:
- tikz versus non-tikz behaviour;
- how `use.tikz = NULL` is resolved from the calling environment;
- the package default TeX support files;
- how user files append to or replace defaults;
- the package options `earnmisc.tex_macros_file` and `earnmisc.tex_ignore_file`;
- that this is a lightweight helper, not a full TeX parser.

Use Canadian spelling.

Examples should be lightweight and check-friendly. Use `tempfile()` for examples involving user files.

Update package-level documentation if appropriate.

## Tests

Add focused `testthat` tests for:
- `use.tikz = TRUE` returns input unchanged;
- explicit `use.tikz = FALSE`;
- `use.tikz = NULL` finds a scalar logical `use.tikz` in the calling environment;
- default `use.tikz = NULL` falls back to `FALSE`;
- package default macros file exists;
- package default ignore-command file exists;
- `nice_text_macros()` returns package defaults;
- `nice_text_ignore_commands()` returns package defaults;
- simple macro expansion from the package default file;
- simple macro expansion from a temporary user file appended to defaults;
- user macro overriding a package default when appended;
- replacing defaults with `append.macros = FALSE`;
- ignored wrapper commands such as `\mathrm{...}`;
- ignored spacing commands such as `\quad`;
- ignore commands from a temporary user ignore file appended to defaults;
- replacing default ignore commands with `append.ignore = FALSE`;
- vector input preserves length;
- behaviour when `latex2exp` is unavailable if this can be tested cleanly without brittle mocking.

Avoid brittle tests that depend too much on the exact internal structure of `latex2exp` output. It is fine to test internal preprocessing helpers if needed.

## Internal helpers

It is fine to add unexported internal helpers such as:

```r
resolve_use_tikz()
nice_text_file_paths()
read_tex_macros()
expand_tex_macros()
read_tex_ignore_commands()
clean_tex_for_latex2exp()
```

Keep them simple and do not export them unless there is a clear reason.

## Package metadata

Update `DESCRIPTION` if needed.

Likely:
- add `latex2exp` to `Suggests`, not `Imports`.

Make sure files under `inst/tex/` are included in the package build.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What API you implemented.
2. Where the package default TeX support files live.
3. How user files append to or replace package defaults.
4. How to inspect the active and default macro and ignore lists.
5. How `use.tikz = NULL` is resolved.
6. What files changed.
7. What tests were added.
8. What verification commands were run and their results.
9. Any limitations or TODOs.
