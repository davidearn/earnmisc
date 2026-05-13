# Latest Codex Prompt

- Entry ID: `20260513T201910Z`
- Recorded: `2026-05-13T20:19:10+00:00`

Please expand the `show_colours()` and `show_oi_colours()` roxygen documentation in `earnmisc`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Improve the documentation for the colour-swatch helpers by adding practical examples and brief guidance on choosing complementary, harmonious, and accessible colours.

Do not change the behaviour of `show_colours()` or `show_oi_colours()` in this task unless a tiny documentation-example cleanup requires it.

## Built-in R colour example

Please add an example showing how to browse R’s built-in named colours using `show_colours()`.

Base R’s `colours()` / `colors()` returns 657 built-in colour names. Please mention this in the documentation.

Add an example along these lines:

```r
for (i in 1:41) {
  show_colours(colours()[(1 + 16 * (i - 1)):(16 * i)])
}
```

However, please make the example check-friendly. Since this opens many plots, put it in `\dontrun{}` or otherwise protect it from being run during checks.

Also consider adding a smaller check-friendly example, for example:

```r
show_colours(colours()[1:16])
```

Use `colours()` in examples and prose, consistent with Canadian spelling, but it is fine to mention that `colors()` is the US-spelling alias.

## Further resources section

Please add a short roxygen section, perhaps called:

```r
@section Further resources:
```

or:

```r
@section Palette design workflow:
```

Keep this section practical and concise.

Mention that `show_colours()` is a lightweight in-R inspection helper, and that users who want help designing or browsing palettes may also find other tools useful.

## Suggested R packages

Mention these R packages as complementary resources, with clickable links in the rendered help where practical.

Use roxygen markdown links where appropriate.

### `colorspace`

Mention that `colorspace` is especially useful when the user wants to design, tune, or evaluate colour palettes.

Mention that it includes tools for palette design and colour-vision-deficiency assessment.

CRAN link:

```text
https://cran.r-project.org/package=colorspace
```

### `khroma`

Mention that `khroma` is especially useful when the user wants strong pre-vetted scientific palettes and diagnostic tools, especially for colour-blind-safe visualisation.

CRAN link:

```text
https://cran.r-project.org/package=khroma
```

### `paletteer`

Mention that `paletteer` is especially useful when the user wants to browse many palette families quickly through a unified interface.

CRAN link:

```text
https://cran.r-project.org/package=paletteer
```

Please present these as suggestions, not dependencies. Do not add any of these packages to `DESCRIPTION`.

## Suggested external tools

Mention a couple of external palette tools for rapid exploration.

### Adobe Color

Mention that Adobe Color is useful for harmony-based palette exploration and includes accessibility / colour-contrast tools.

Link:

```text
https://color.adobe.com/create/color-accessibility
```

### Coolors

Mention that Coolors is useful for quickly generating, locking, and exploring palettes.

Link:

```text
https://coolors.co/
```

## Suggested workflow

Add a short practical workflow suggestion, for example:

1. Prototype candidate colours in Adobe Color or Coolors.
2. Bring the candidate hex colours into R.
3. Inspect and tune them with `colorspace`.
4. Check accessibility and distinguishability with `khroma` or an accessibility tool.
5. Use `show_colours()` to compare the final candidates directly inside the package workflow.

Keep this brief and user-facing.

## Style requirements

- Keep the main function documentation clear and concise.
- Do not turn the help page into a long essay.
- Keep wording practical rather than academic.
- Do not overstate that any one tool is “best”.
- Present external packages and websites as optional resources that complement `show_colours()`.
- Emphasize moving from rough palette ideas to inspectable colours in R.
- Use Canadian spelling in prose.
- Preserve existing examples unless they need minor cleanup.
- Do not change function behaviour.

## Tests

No new tests are required unless the documentation examples require small changes.

If examples are changed in a way that affects checks, make sure they remain check-friendly.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What documentation sections were added or revised.
2. Whether any examples were added or protected with `\dontrun{}`.
3. Whether any function behaviour changed.
4. What files changed.
5. What verification commands were run and their results.
