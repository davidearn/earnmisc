# Latest Codex Prompt

- Entry ID: `20260511T151305Z`
- Recorded: `2026-05-11T15:13:05+00:00`

Please add graphics-device helper functions to `earnmisc`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add and export two small helpers:

```r
dev_is_tikz()
dev_is_pdf()
```

These should return scalar `TRUE` or `FALSE` depending on the currently active graphics device.

Example intended use:

```r
if (dev_is_tikz()) {
  tikz_compile(...)
}
```

## Behaviour

### `dev_is_tikz()`

Return `TRUE` when the current graphics device appears to be a tikz device opened by `tikzDevice::tikz()` or `earnmisc::tikz_open()`.

Return `FALSE` otherwise, including when there is no open user graphics device.

### `dev_is_pdf()`

Return `TRUE` when the current graphics device is a PDF device opened by `grDevices::pdf()`.

Return `FALSE` otherwise, including when there is no open user graphics device.

## Implementation notes

Keep the implementation simple.

A reasonable starting point is to inspect the current device name using:

```r
names(grDevices::dev.cur())
```

or equivalent base R graphics-device information.

Please check the actual device names produced by ordinary `pdf()` and, when available, `tikzDevice::tikz()`.

If useful, add a small non-exported helper such as:

```r
current_device_name()
```

or:

```r
dev_name()
```

to avoid duplicating logic. Document any non-exported helper with roxygen2 comments, following `AGENTS.md`.

Do not introduce new required dependencies.

`dev_is_tikz()` may use device-name detection and/or stored metadata from `tikz_open()` if that makes the result more reliable. However, it should still work for a tikz device opened directly with `tikzDevice::tikz()` if possible.

## Edge cases

Please handle these cleanly:

- no open user graphics device;
- current device is the null device;
- current device is PDF;
- current device is tikz;
- current device is another device such as the default screen device.

The helpers should not error in ordinary use.

## Documentation

Add roxygen2 documentation for:

```r
dev_is_tikz()
dev_is_pdf()
```

Mention that these are lightweight helpers based on the currently active graphics device.

Use Canadian spelling.

Examples should be lightweight and check-friendly. Avoid examples requiring `tikzDevice` unless protected with `if (requireNamespace("tikzDevice", quietly = TRUE))`.

## Tests

Add tests for:

- both functions return scalar logical values;
- both return `FALSE` on the null device or when no user graphics device is active;
- `dev_is_pdf()` returns `TRUE` inside a temporary `pdf()` device;
- `dev_is_tikz()` returns `TRUE` inside a temporary tikz device when `tikzDevice` is installed;
- `dev_is_tikz()` tests skip cleanly when `tikzDevice` is unavailable.

Tests involving device opening should use `on.exit(grDevices::dev.off(), add = TRUE)` or equivalent cleanup so devices are not left open.

Avoid requiring LaTeX compilation. Opening a tikz device should be enough if `tikzDevice` is available; skip if not safe.

## Package docs

Update package-level documentation if appropriate, probably by mentioning these under graphics-device helpers.

Regenerate documentation and NAMESPACE.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What functions were added.
2. How the current device is detected.
3. How null/no-device cases are handled.
4. What tests were added.
5. What verification commands were run and their results.
6. Any limitations or TODOs.
