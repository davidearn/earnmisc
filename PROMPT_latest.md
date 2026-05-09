# Latest Codex Prompt

- Entry ID: `20260509T193506Z`
- Recorded: `2026-05-09T19:35:06+00:00`

Please revise the Okabe--Ito colour helpers in `earnmisc`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Required changes

### Default to the extended palette

Change the default behaviour so that the extended Okabe--Ito palette is used by default.

Specifically:

```r
okabe_ito_colours()
okabe_ito_palette()
```

should use `extended = TRUE` by default.

Documentation should clearly explain:
- the first 8 colours are the original Okabe--Ito colourblind-friendly palette;
- additional colours are extensions used for convenience;
- users can request only the original palette with `extended = FALSE`.

Please update tests accordingly.

### Export convenient colour constants

Export convenient named colour constants following the existing `gaemr` style.

Please create and export objects such as:

```r
oi.black
oi.orange
oi.sky_blue
oi.bluish_green
oi.yellow
oi.blue
oi.vermillion
oi.reddish_purple
oi.grey
oi.amber
```

These should be character strings containing the corresponding hex colours.

Requirements:
- Export these objects.
- Document them together in a single roxygen2 help topic, probably something like `?oi_colours`.
- Keep the names stable.
- Ensure these objects agree exactly with `okabe_ito_colours(extended = TRUE)`.
- Add tests.

Do not add support for quoted pseudo-colour names such as:

```r
col = "oi.orange"
```

The intended plotting idiom is:

```r
col = oi.orange
```

where `oi.orange` evaluates to a valid R colour string.

### Add alpha helper functions

Please add clean helpers for alpha-adjusted colours without creating many exported alpha-specific objects.

Preferred API:

```r
oi_alpha(colour, alpha)
oi_colour(name, alpha = NULL, extended = TRUE)
```

Suggested behaviour:

```r
oi_alpha(oi.orange, 0.023)
oi_colour("orange", alpha = 0.023)
oi_colour("sky_blue", alpha = 0.4)
```

Requirements for `oi_alpha()`:
- Accept one or more actual R colour values, such as `oi.orange`, `"#E69F00"`, or `"orange"`.
- Accept `alpha`.
- Use `grDevices::adjustcolor()`.
- Return alpha-adjusted colours.
- Validate `alpha` sensibly.

Requirements for `oi_colour()`:
- Accept one or more Okabe--Ito palette colour names, such as `"orange"` or `"sky_blue"`.
- Do not treat strings like `"oi.orange"` as special.
- Use names from `okabe_ito_colours(extended = extended)`.
- Support `alpha = NULL` for unmodified colours.
- Support numeric `alpha` using `oi_alpha()`.
- Return named colours where sensible.
- Give clear errors for unknown names.
- Add lightweight examples.

Do not create exported objects such as `oi.orange.023`. Instead, document that:

```r
oi_alpha(oi.orange, 0.023)
```

or

```r
oi_colour("orange", alpha = 0.023)
```

is the supported way to obtain an alpha-adjusted version.

## Documentation

Update roxygen2 documentation for:
- `okabe_ito_colours()`;
- `okabe_ito_palette()`;
- the exported `oi.*` colour constants;
- `oi_alpha()`;
- `oi_colour()`.

Documentation should use Canadian spelling.

Examples should be lightweight and check-friendly.

## Tests

Please add or revise tests for:
- default extended palette behaviour;
- `extended = FALSE`;
- exported `oi.*` constants;
- consistency between constants and `okabe_ito_colours(extended = TRUE)`;
- `oi_alpha()`;
- `oi_colour()`;
- alpha validation;
- unknown colour-name errors;
- ensuring `"oi.orange"` is not treated as a valid palette colour name.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What API changes you made.
2. What colour constants were exported.
3. How alpha-adjusted colours are now obtained.
4. What files changed.
5. What tests were added or revised.
6. What verification commands were run and their results.
