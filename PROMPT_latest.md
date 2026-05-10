# Latest Codex Prompt

- Entry ID: `20260510T060715Z`
- Recorded: `2026-05-10T06:07:15+00:00`

Please fix `earnmisc::nice_text()` so that package/user macros are expanded for tikz output as well as non-tikz output.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Problem

`nice_text()` now works well when `use.tikz = FALSE`, but it fails with tikz devices because macro names such as `\Rn` are returned unchanged.

For example, this fails during tikz metric calculation:

```r
nice_text("$\\Rn$", use.tikz = TRUE)
```

because tikz/LaTeX receives:

```tex
$\Rn$
```

and `\Rn` is not defined in the standalone tikz LaTeX context.

The error is like:

```text
Error in getMetricsFromLatex(TeXMetrics, verbose = verbose) :
TeX was unable to calculate metrics for:

    $\Rn$
```

## Required behaviour

`nice_text()` should expand macros for both tikz and non-tikz output.

That means:

```r
nice_text("$\\Rn$", use.tikz = TRUE)
```

should return something like:

```tex
${\mathcal R}_0$
```

or an equivalent recursively expanded LaTeX string, not `"$\\Rn$"`.

For `use.tikz = TRUE`:
- expand macros using the package default macro file plus any user macro files;
- do not run the non-tikz cleanup/ignore-command step;
- do not call `latex2exp::TeX()`;
- return a character vector of expanded LaTeX strings.

For `use.tikz = FALSE`:
- keep the existing behaviour: expand macros, clean ignored commands, and call `latex2exp::TeX()` when available.

## Preserve append/replace semantics

Macro expansion for tikz output should use the same macro-source logic as non-tikz output:

- package defaults first;
- option file from `getOption("earnmisc.tex_macros_file")`, if set;
- explicit `macros.file`, if supplied;
- later definitions override earlier ones;
- `append.macros = FALSE` uses only user-supplied macro files and omits the package defaults.

Ignore-command files should still apply only to non-tikz output.

## Important distinction

Previously, `use.tikz = TRUE` returned `x` unchanged.

That is no longer sufficient.

The revised behaviour should be:

```r
if (use.tikz) {
  return(expand_macros_only(x))
}
```

not:

```r
if (use.tikz) {
  return(x)
}
```

Please update documentation to explain this clearly.

## Tests

Add or revise tests so that:

- `nice_text("$\\Rn$", use.tikz = TRUE)` expands `\Rn`.
- recursive expansion works in tikz mode, including:
  - `\Rn`;
  - `\tinc`;
  - `\tFoIpeak`;
  - `\Xkm`.
- tikz mode does not apply the ignore-command cleanup step.
  For example, `nice_text("$A_{\\mathrm{i}}$", use.tikz = TRUE)` should preserve `\mathrm`.
- tikz mode does not call `latex2exp::TeX()`.
- non-tikz behaviour still works.
- user macro append, override, and `append.macros = FALSE` work in tikz mode as well as non-tikz mode.
- vector input preserves length in tikz mode.

Avoid brittle tests that require a tikz device or actual LaTeX compilation. Test returned strings directly.

## Documentation

Update roxygen2 documentation for `nice_text()`.

The documentation should now say:

- tikz mode returns macro-expanded LaTeX strings;
- non-tikz mode returns `latex2exp::TeX()` output when available;
- macro expansion happens in both modes;
- ignored TeX command cleanup happens only in non-tikz mode;
- `nice_text()` is not a full TeX parser.

Use Canadian spelling.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. Why tikz mode was failing.
2. How macro expansion now works in tikz mode.
3. How tikz and non-tikz processing now differ.
4. What tests were added or revised.
5. What files changed.
6. What verification commands were run and their results.
