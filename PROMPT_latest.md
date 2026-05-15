# Latest Codex Prompt

- Entry ID: `20260515T205031Z`
- Recorded: `2026-05-15T20:50:31+00:00`

Please make `source` labels in the `earnmisc` `mts` plotting helpers flexible enough for `graphics::legend()`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Problem

The current `source` validation in `plot_mts()` and `lines_mts()` is too restrictive.

These currently fail:

```r
lines_mts(m[[1]], source = expression(R[0] == 2))
```

with:

```text
Error: `source` must be `NULL` or a non-empty character scalar.
```

and:

```r
lines_mts(m[[1]], source = nice_text(r"($R_0 = 2$)"))
```

also fails, because:

```r
class(nice_text(r"($R_0 = 2$)"))
```

returns something like:

```r
c("latexexpression", "expression")
```

But this works:

```r
lines_mts(m[[1]], source = r"($R_0 = 2$)")
```

because it is just a character scalar.

I would like `source` to be as flexible as the `legend` argument passed to `graphics::legend()`, at least for scalar labels.

## Required behaviour

`source` in `plot_mts()` and `lines_mts()` should accept:

```r
NULL
"plain character label"
expression(R[0] == 2)
nice_text(r"($R_0 = 2$)")
```

The following should work:

```r
plot_mts(m[[3]], source = expression(R[0] == 8))
lines_mts(m[[2]], source = expression(R[0] == 4))
lines_mts(m[[1]], source = expression(R[0] == 2))
legend_mts(by = "source")
```

and:

```r
plot_mts(m[[3]], source = nice_text(r"($R_0 = 8$)"))
lines_mts(m[[2]], source = nice_text(r"($R_0 = 4$)"))
lines_mts(m[[1]], source = nice_text(r"($R_0 = 2$)"))
legend_mts(by = "source")
```

In both cases, `legend_mts(by = "source")` should pass the expression-like labels through to `graphics::legend()` so the legend renders properly.

## Important internal design

Do not force expression-like labels into an ordinary character column and lose their class.

The existing `plot.info$curves` data frame probably has a character `source` column. That is useful for grouping and inspection, but it is not enough for expression-valued legend labels.

Please use this design:

- Keep `plot.info$curves$source` as a character column for grouping and readable bookkeeping.
- Add a separate column for display labels, preferably:

```r
source.label
```

- Because `source.label` may contain character strings, expressions, or `latexexpression` objects, store it as a list-column using base R `I(list(...))` or an equivalent simple base-R approach.

For each curve:
- `source` should be a stable character key.
- `source.label` should preserve the original user-facing label object.

If `source = NULL`, infer the source label from the input expression as before:
- `source` is the inferred character label, such as `"m[[3]]"`;
- `source.label` is the same character label.

If `source` is a character scalar:
- `source` is that character string;
- `source.label` is that character string.

If `source` is an expression-like scalar:
- `source.label` preserves the expression-like object;
- `source` is a stable character key derived from deparsing the expression-like object.

Use a small helper if useful, for example:

```r
normalise_mts_source()
```

It should return something like:

```r
list(
  key = character_scalar,
  label = original_label_object
)
```

Document any non-exported helper with roxygen2 comments, following `AGENTS.md`.

## Validation

Validation should be permissive but clear.

Accept:
- `NULL`;
- non-empty character scalar;
- expression of length 1;
- `"latexexpression"` / `"expression"` objects of length 1, such as those returned by `nice_text()`.

Reject:
- empty character strings;
- character vectors of length other than 1;
- expression vectors of length other than 1;
- lists or arbitrary objects that cannot reasonably be used as a legend label.

Give clear error messages.

## `legend_mts(by = "source")`

Update `legend_mts(by = "source")` so that:

- grouping is based on the character source key;
- legend labels come from the preserved `source.label` values for the selected rows;
- character labels remain character;
- expression-like labels remain expression-like and are passed through to `graphics::legend()`.

Be careful constructing the `legend` argument for `graphics::legend()`.

If all selected labels are character, pass a character vector.

If any selected labels are expression-like, combine them into an expression object if possible, preserving plotmath behaviour.

A simple robust rule is acceptable:
- character labels can be converted to plotmath strings only if necessary, or left as character when all labels are character;
- expression-like labels should remain expression-like.

Do not break explicit `legend = ...` supplied directly to `legend_mts()`. If `legend` is supplied, it should override labels derived from `source.label`, as before.

## Other grouping modes

Please check whether `by = "curve"` and `by = "column"` need similar label-preservation logic.

At minimum:
- `by = "source"` must preserve expression-like source labels.
- Existing behaviour for `by = "column"` and `by = "curve"` should not regress.

## `plot_mts_overlay()`

Update `plot_mts_overlay()` as needed.

It should accept expression-like labels through:
- `source.x`, if supplied;
- `overlay.names`, if supplied.

If `overlay.names` is character, preserve existing behaviour.

If `overlay.names` is expression-like, make sure it works for one or more overlays if feasible. If expression-vector support for multiple overlay labels is complicated, support the common case carefully and document any limitation.

## Tests

Add or revise tests for:

- `plot_mts(..., source = expression(R[0] == 8))` succeeds.
- `lines_mts(..., source = expression(R[0] == 4))` succeeds.
- `lines_mts(..., source = nice_text(r"($R_0 = 4$)"))` succeeds.
- `plot.info$curves` keeps a character `source` key.
- `plot.info$curves` preserves expression-like labels in `source.label`.
- `legend_mts(by = "source")` uses expression-like labels when source labels are expressions.
- explicit `legend = ...` in `legend_mts()` still overrides source-derived labels.
- ordinary character source labels still work.
- inferred source labels from object expressions still work.
- invalid source values error clearly.
- repeated overlays with expression-like sources produce distinct source groups.
- `plot_mts_overlay()` works with `source.x` and/or `overlay.names` where applicable.

Use temporary graphics devices and avoid image comparison.

## Documentation

Update roxygen2 documentation for:

```r
plot_mts()
lines_mts()
plot_mts_overlay()
legend_mts()
```

Documentation should explain:

- `source` may be a character scalar or a scalar expression/plotmath label;
- `nice_text()` output can be used as a source label;
- `legend_mts(by = "source")` uses source labels in the legend;
- a character source key is still recorded internally for grouping and inspection;
- explicit `legend = ...` supplied to `legend_mts()` overrides source-derived labels.

Use Canadian spelling.

Include examples such as:

```r
plot.info <- plot_mts(x, source = expression(R[0] == 8))
plot.info <- lines_mts(y, plot.info = plot.info, source = expression(R[0] == 4))
legend_mts(plot.info, by = "source")
```

and perhaps:

```r
plot.info <- plot_mts(x, source = nice_text(r"($R_0 = 8$)"))
plot.info <- lines_mts(y, plot.info = plot.info, source = nice_text(r"($R_0 = 4$)"))
legend_mts(plot.info, by = "source")
```

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. Why expression-like source labels previously failed.
2. How source keys and source display labels are now stored.
3. How `legend_mts(by = "source")` preserves expression-like labels.
4. How `plot_mts_overlay()` handles source labels and overlay names.
5. What files changed.
6. What tests were added or revised.
7. What verification commands were run and their results.
