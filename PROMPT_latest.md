# Latest Codex Prompt

- Entry ID: `20260510T061408Z`
- Recorded: `2026-05-10T06:14:08+00:00`

Please simplify the default TeX macro for `\kmsubscript` in `earnmisc::nice_text()`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Problem

After fixing macro expansion for tikz output, `\Rn` now works, but labels involving `\kmsubscript` fail during tikz metric calculation.

For example, macro expansion currently produces something like:

```tex
$\lambda_{\text{\scalebox{0.6}{\mathrm{KM}}}}$
```

and tikz/LaTeX fails with:

```text
Error in getMetricsFromLatex(TeXMetrics, verbose = verbose) :
TeX was unable to calculate metrics for:

    $\lambda_{\text{\scalebox{0.6}{\mathrm{KM}}}}$
```

The likely issue is that the expanded macro uses `\text` and `\scalebox`, which may not be available in the small LaTeX context used by tikz metric calculation.

## Requested change

Please simplify the default `\kmsubscript` macro in:

```text
inst/tex/default-macros.tex
```

Change it from the current form:

```tex
\newcommand{\kmsubscript}{\text{\scalebox{0.6}{\mathrm{KM}}}}
```

to a simpler, safer math-mode form such as:

```tex
\newcommand{\kmsubscript}{\mathrm{KM}}
```

Use this exact replacement unless there is a clearly better simple math-mode alternative.

The goal is for expanded labels such as:

```tex
$\lambda_{\kmsubscript}$
```

to become something like:

```tex
$\lambda_{\mathrm{KM}}$
```

which should be acceptable in the tikz metric calculation context.

## Tests

Please update tests accordingly.

Tests should verify that:

- `nice_text_macros()` reports `\kmsubscript` as `\mathrm{KM}`.
- tikz macro expansion of `"$\\lambdakm$"` produces a string involving `\lambda_{\mathrm{KM}}`, not `\text` or `\scalebox`.
- tikz macro expansion of `"$\\Xkm$"`, `"$\\Ykm$"`, and `"$\\Zkm$"` does not contain `\text` or `\scalebox`.
- existing recursive macro expansion tests still pass.
- non-tikz behaviour still works as before.

Avoid tests that require actually opening a tikz device or compiling LaTeX. Testing returned strings from `nice_text(..., use.tikz = TRUE)` is enough.

## Documentation

Update documentation only if it explicitly mentions the old `\kmsubscript` definition.

Keep the documentation clear that the default macros are intentionally simple and suitable for plot labels, not a full manuscript preamble.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What `\kmsubscript` was changed to.
2. Whether any parser or `nice_text()` code needed to change.
3. What tests were added or revised.
4. What verification commands were run and their results.
5. Any remaining limitations or TODOs.
