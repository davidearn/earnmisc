# Latest Codex Prompt

- Entry ID: `20260510T160324Z`
- Recorded: `2026-05-10T16:03:24+00:00`

Please add tikz helper functions to `earnmisc`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add helpers:

```r
tikz_open()
tikz_info()
tikz_compile()
```

These should make it easier to open a `tikzDevice::tikz()` graphics device, retain metadata about the output file and device arguments, and compile the resulting `.tex` file to PDF.

## Background

`tikzDevice::tikz()` returns no useful value, so after opening a tikz device there is no direct way to recover the filename, width, height, or arguments used.

I want `earnmisc::tikz_open()` to wrap `tikzDevice::tikz()` and return/store this metadata.

The current `tikzDevice::tikz()` API includes arguments such as:

```r
file = filename
filename = ifelse(onefile, "./Rplots.tex", "./Rplot%03d.tex")
width = 7
height = 7
onefile = TRUE
bg = "transparent"
fg = "black"
pointsize = 10
lwdUnit = getOption("tikzLwdUnit")
standAlone = FALSE
bareBones = FALSE
console = FALSE
sanitize = FALSE
engine = getOption("tikzDefaultEngine")
documentDeclaration = getOption("tikzDocumentDeclaration")
packages
footer = getOption("tikzFooter")
symbolicColors = getOption("tikzSymbolicColors")
colorFileName = "%s_colors.tex"
maxSymbolicColors = getOption("tikzMaxSymbolicColors")
timestamp = TRUE
verbose = interactive()
```

Please explicitly expose these arguments in `tikz_open()`, rather than just using `...`.

Change one default for my workflow:

```r
standAlone = TRUE
```

instead of the `tikzDevice::tikz()` default `FALSE`.

## Dependency

Do not put `tikzDevice` in `Imports`.

Use it conditionally via:

```r
requireNamespace("tikzDevice", quietly = TRUE)
```

Add `tikzDevice` to `Suggests`.

If `tikzDevice` is not available, `tikz_open()` should fail with a clear error.

## `tikz_open()`

Please implement and export:

```r
tikz_open <- function(
  file = filename,
  filename = ifelse(onefile, "./Rplots.tex", "./Rplot%03d.tex"),
  width = 7,
  height = 7,
  onefile = TRUE,
  bg = "transparent",
  fg = "black",
  pointsize = 10,
  lwdUnit = getOption("tikzLwdUnit"),
  standAlone = TRUE,
  bareBones = FALSE,
  console = FALSE,
  sanitize = FALSE,
  engine = getOption("tikzDefaultEngine"),
  documentDeclaration = getOption("tikzDocumentDeclaration"),
  packages = NULL,
  footer = getOption("tikzFooter"),
  symbolicColors = getOption("tikzSymbolicColors"),
  colorFileName = "%s_colors.tex",
  maxSymbolicColors = getOption("tikzMaxSymbolicColors"),
  timestamp = TRUE,
  verbose = interactive(),
  message = TRUE
)
```

If `packages = NULL`, call `tikzDevice::tikz()` without explicitly passing `packages`, so that tikzDevice can use its own default machinery. If this is awkward, choose a clean implementation and document it.

Required behaviour:
- Open a tikz graphics device by calling `tikzDevice::tikz()` with the corresponding arguments.
- Return invisibly a list containing all argument values, plus useful metadata.
- Store the same list internally so `tikz_info()` can retrieve it later.
- Include at least:
  - `file`;
  - `filename`;
  - `width`;
  - `height`;
  - all other arguments passed to `tikzDevice::tikz()`;
  - `device`;
  - `device.name`;
  - `opened_at`, preferably `Sys.time()`;
  - `working_directory`, preferably `getwd()`;
  - `normalized_file`, using `normalizePath(file, mustWork = FALSE)`;
  - `pdf_file`, the expected PDF filename after compilation.

The returned object can be a plain list, but please give it a simple class, for example:

```r
class(info) <- c("earnmisc_tikz_info", "list")
```

### Messages from `tikz_open()`

By default, `tikz_open()` should print a message of the form:

```text
tikz_open: writing to filename.tex (width = 14, height = 7) ...
```

This should happen after the device has been opened successfully.

Use `message = TRUE` by default to control this.

If opening the device fails, give a clear error.

## `tikz_info()`

Please implement and export:

```r
tikz_info <- function(device = NULL)
```

Required behaviour:
- Return the most recent tikz info object if `device = NULL`.
- If `device` is supplied, return the stored info for that device if available.
- Return `NULL` or give a clear error if no matching info is available. Choose the cleaner behaviour and document it.
- Do not require the device still to be open; the info should remain available after `dev.off()`.

If possible, store info by device number in a package-private environment, and also store the most recent tikz info object.

## `tikz_compile()`

Please implement and export:

```r
tikz_compile <- function(
  x,
  engine = "lualatex",
  batchmode = TRUE,
  clean = FALSE,
  message = TRUE
)
```

`x` should be either:
- a character string giving the `.tex` filename; or
- a full list returned by `tikz_open()`.

Required behaviour:
- Determine the `.tex` file from `x`.
- Compile with `lualatex` by default.
- Use batch mode by default.
- Produce the corresponding `.pdf` file.
- Return the PDF filename invisibly or visibly. I prefer visible return so this works naturally:

```r
tikz.pdf <- tikz_compile(tikz.info)
system(paste0("open ", tikz.pdf))
```

So please return the PDF filename as a character string.
- By default, print a message indicating success, for example:

```text
tikz_compile: produced filename.pdf
```

- If compilation fails or the PDF is not produced, stop with a helpful error such as:

```text
tikz_compile: failed to produce filename.pdf
```

Include useful details if available, such as the exit status or log file path.

Implementation details:
- Use `system2()` rather than `system()`.
- Compile in the directory containing the `.tex` file, so relative paths work naturally.
- Quote paths safely.
- The default command should be approximately:

```sh
lualatex -interaction=batchmode filename.tex
```

- If `batchmode = FALSE`, omit `-interaction=batchmode` or use a less quiet interaction mode if that is cleaner.
- `clean = TRUE` may remove common auxiliary files such as `.aux`, `.log`, and `.out` after successful compilation. Keep this conservative.
- Do not delete the `.tex` or `.pdf` file.

## Expected usage

The following should work:

```r
tikz.info <- tikz_open(my.tex.file, width = 14)
plot(1:10)
dev.off()

tikz.pdf <- tikz_compile(tikz.info)
system(paste0("open ", tikz.pdf))
```

Also:

```r
tikz_open("figure.tex", width = 14, height = 7)
plot(1:10)
tikz.info()
dev.off()
tikz_compile("figure.tex")
```

## Documentation

Add roxygen2 documentation for:
- `tikz_open()`;
- `tikz_info()`;
- `tikz_compile()`.

Explain:
- `tikz_open()` wraps `tikzDevice::tikz()`;
- `standAlone = TRUE` is the `earnmisc` default;
- `tikz_open()` stores metadata because `tikzDevice::tikz()` itself returns no value;
- `tikz_compile()` uses `lualatex` by default;
- `tikzDevice` is suggested, not imported;
- a working LaTeX installation is required for compilation.

Use Canadian spelling.

Examples should be lightweight and check-friendly. Do not run actual tikz compilation in examples. Use `\dontrun{}` or `\donttest{}` where appropriate.

## Tests

Add focused tests where possible, but avoid brittle tests that require an installed LaTeX system or working tikzDevice unless already available.

Suggested tests:
- `tikz_compile()` resolves the expected PDF filename from a character `.tex` filename.
- `tikz_compile()` resolves the expected PDF filename from a `tikz_open()` info-like list.
- If testing actual compilation is not safe, isolate filename-resolution helpers and test those.
- `tikz_info()` returns `NULL` or an error before any tikz device has been opened, according to the documented design.
- Metadata construction includes all explicit `tikz_open()` arguments.
- `standAlone = TRUE` is the `tikz_open()` default.
- Message formatting can be tested if straightforward.
- Tests that require `tikzDevice` should skip if it is not installed.
- Tests that require `lualatex` should skip if it is not found with `Sys.which("lualatex")`.

## Package metadata

Update `DESCRIPTION`:
- add `tikzDevice` to `Suggests`.

Regenerate documentation and NAMESPACE.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What API you implemented.
2. What metadata `tikz_open()` returns and stores.
3. How `tikz_info()` retrieves stored info.
4. How `tikz_compile()` determines the PDF filename and runs LaTeX.
5. What dependencies were added to `Suggests`.
6. What tests were added or revised.
7. What verification commands were run and their results.
8. Any limitations or TODOs.
