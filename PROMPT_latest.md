# Latest Codex Prompt

- Entry ID: `20260513T143348Z`
- Recorded: `2026-05-13T14:33:48+00:00`

Please revise `earnmisc::input_form()` to support aligned list formatting.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add an `align` argument to `input_form()` so that list input forms can be easier to read and edit.

Current example:

```r
input_form(
  out.fig$overlay.curve.styles,
  width = 90,
  prefix = "my.overlay.curve.style <- ",
  file = "myoverlay.R"
)
```

currently produces something like:

```r
my.overlay.curve.style <- list(exact = list(col = "#DFEAEC", lwd = 8, lty = 1), KM.tauinit = list(col = "grey10", lwd = 2, 
    lty = 3), localX.tauinit = list(col = "#0072B2", lwd = 2, lty = 3), original.y = list(col = "#1C6F75", 
    lwd = 2, lty = 1))
```

I would like an `align` argument that can produce more readable multiline output.

## Revised API

Please revise the API to include:

```r
align = c(",", "=")
```

The full API should become:

```r
input_form(
  x,
  file = "",
  append = FALSE,
  control = "all",
  width.cutoff = 60,
  prefix = "",
  suffix = "",
  final.newline = TRUE,
  overwrite = TRUE,
  align = c(",", "=")
)
```

Use this exact API unless there is a strong technical reason not to.

## `align` behaviour

### `align = NULL`

When `align = NULL`, preserve the current behaviour exactly.

For example, this should continue to use ordinary `deparse()` output:

```r
input_form(x, align = NULL)
```

### `align = ","`

When `align = ","`, format suitable named lists in a multiline style with leading commas aligned.

For example:

```r
input_form(
  out.fig$overlay.curve.styles,
  width = 90,
  prefix = "my.overlay.curve.style <- ",
  align = ","
)
```

should produce output like:

```r
my.overlay.curve.style <- list(
    exact = list(col = "#DFEAEC", lwd = 8, lty = 1)
  , KM.tauinit = list(col = "grey10", lwd = 2, lty = 3)
  , localX.tauinit = list(col = "#0072B2", lwd = 2, lty = 3)
  , original.y = list(col = "#1C6F75", lwd = 2, lty = 1)
)
```

### `align = c(",", "=")`

When `align = c(",", "=")`, format suitable named lists in a multiline style with leading commas and aligned equals signs.

This should be the default.

For example:

```r
input_form(
  out.fig$overlay.curve.styles,
  width = 90,
  prefix = "my.overlay.curve.style <- ",
  align = c(",", "=")
)
```

should produce output like:

```r
my.overlay.curve.style <- list(
    exact          = list(col = "#DFEAEC", lwd = 8, lty = 1)
  , KM.tauinit     = list(col = "grey10", lwd = 2, lty = 3)
  , localX.tauinit = list(col = "#0072B2", lwd = 2, lty = 3)
  , original.y     = list(col = "#1C6F75", lwd = 2, lty = 1)
)
```

## Scope and fallback behaviour

Keep this conservative.

This is not intended to be a full R-code formatter.

The aligned formatting should target suitable named list objects, especially lists whose top-level elements can each be deparsed compactly.

If the object is not a list, or if alignment cannot be applied safely, fall back to the ordinary `deparse()` output used when `align = NULL`.

For now, it is acceptable for alignment to apply only to top-level named lists.

Do not try to fully reformat arbitrary nested R code.

Nested list values may be deparsed compactly on the same line where possible, using `width.cutoff`.

## Prefix and suffix interaction

`prefix` should still appear before the full generated input form.

For aligned list output, this means:

```r
prefix = "my.overlay.curve.style <- "
```

should produce:

```r
my.overlay.curve.style <- list(
    exact          = list(col = "#DFEAEC", lwd = 8, lty = 1)
  , KM.tauinit     = list(col = "grey10", lwd = 2, lty = 3)
)
```

not:

```r
my.overlay.curve.style <- 
list(...)
```

`suffix` should still be appended after the final generated object form, as currently documented.

For example:

```r
input_form(x, prefix = "x <- ", suffix = " # revised list")
```

should place the suffix after the closing parenthesis or final deparsed line.

## Names and quoting

Please preserve syntactically valid names without quotes, matching ordinary `deparse()` where possible.

If a list name is not syntactically valid, quote it in a way that produces parseable R code.

Examples:
- `exact` should appear as `exact`.
- `KM.tauinit` should appear as `KM.tauinit`.
- names containing spaces or other non-syntactic characters should be backticked or otherwise represented parseably.

Use base R utilities where possible, such as `make.names()` checks or `deparse()` of a named one-element list, to avoid hand-rolling too much syntax.

## Parseability

Aligned output should be valid R code.

For suitable list objects, this should hold:

```r
txt <- input_form(x, align = c(",", "="))
y <- eval(parse(text = txt))
identical(x, y)
```

For assignment prefixes:

```r
txt <- input_form(x, prefix = "x.new <- ", align = c(",", "="))
env <- new.env(parent = emptyenv())
eval(parse(text = txt), envir = env)
identical(env$x.new, x)
```

Please add tests for this.

## Validation

Validate `align`.

Allowed values should be:

```r
NULL
","
c(",", "=")
```

It is fine to also accept `align = "="` as a synonym for `align = c(",", "=")` only if you think that is useful, but do not leave this decision ambiguous. My preference is to support only the three allowed values above for now.

Invalid values should error clearly.

## Documentation

Update roxygen2 documentation for `input_form()`.

Document:
- `align = NULL` preserves ordinary deparse output;
- `align = ","` aligns leading commas for suitable named lists;
- `align = c(",", "=")` also aligns equals signs and is the default;
- alignment is intentionally conservative and applies mainly to top-level named lists;
- output falls back to ordinary deparse formatting when alignment is not applicable;
- aligned output is intended to remain parseable R input.

Use Canadian spelling.

Examples should be lightweight and check-friendly.

Please include examples of:
- default aligned output;
- `align = NULL`;
- `align = ","`;
- assignment prefix with aligned output.

## Tests

Add or revise tests for:

- `align = NULL` preserves current deparse-based behaviour.
- default `align = c(",", "=")` gives multiline aligned output for a named list.
- `align = ","` gives leading-comma multiline output without equals alignment.
- `align = c(",", "=")` aligns equals signs.
- aligned output parses and reconstructs a simple named list.
- aligned output with `prefix = "x.new <- "` parses and assigns correctly.
- suffix works with aligned output.
- final newline behaviour still works with aligned output.
- file writing still works with aligned output.
- append/overwrite behaviour still works with aligned output.
- non-list objects fall back to ordinary deparse output.
- unnamed lists either fall back to ordinary deparse output or are handled parseably; choose the simpler behaviour and document it clearly.
- non-syntactic names are handled parseably.
- invalid `align` values error clearly.

## Internal helpers

It is fine to add non-exported helpers such as:

```r
validate_align()
input_form_deparse()
input_form_align_list()
format_list_name()
deparse_one_line()
```

Document non-exported helpers with roxygen2 comments, following `AGENTS.md`.

Keep the implementation base-R only.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. The final `align` API and defaults.
2. How aligned formatting is implemented.
3. What objects fall back to ordinary deparse output.
4. How parseability is tested.
5. What files changed.
6. What tests were added or revised.
7. What verification commands were run and their results.
