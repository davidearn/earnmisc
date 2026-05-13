# Latest Codex Prompt

- Entry ID: `20260513T124935Z`
- Recorded: `2026-05-13T12:49:35+00:00`

Please add two list utility functions to `earnmisc`:

```r
update_list()
input_form()
```

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Goal

Add small, dependency-free utilities for:

1. Updating selected elements of a possibly nested list while preserving other elements and attributes/classes.
2. Producing pasteable R code that reconstructs an object, especially a list.

Avoid tidyverse dependencies.

## `update_list()`

Please implement and export:

```r
update_list <- function(x, ..., .create = FALSE)
```

The function should return a modified copy of `x`.

Examples:

```r
x.new <- update_list(x, type = "new")
x.new <- update_list(x, "parms$graphics$lwd" = 3)
x.new <- update_list(x,
                     type = "new",
                     "parms$graphics$lwd" = 3)
```

### Path syntax

Named arguments in `...` should identify elements to update.

Top-level names should update top-level list elements:

```r
update_list(x, type = "new")
```

Path strings using `$` should update nested list elements:

```r
update_list(x, "parms$graphics$lwd" = 3)
```

This should be equivalent to:

```r
x$parms$graphics$lwd <- 3
```

Please support simple `$`-separated names only in this first implementation. Do not try to parse arbitrary R expressions.

If names contain whitespace around `$`, trim it:

```r
"parms $ graphics $ lwd"
```

should be treated like:

```r
"parms$graphics$lwd"
```

### Creation behaviour

If `.create = FALSE`, updating a nested path should require all intermediate list elements to exist. Missing paths should give a clear error.

If `.create = TRUE`, missing intermediate elements should be created as lists.

For example:

```r
update_list(list(), "parms$graphics$lwd" = 3, .create = TRUE)
```

should return:

```r
list(parms = list(graphics = list(lwd = 3)))
```

### Attribute and class preservation

`update_list()` should preserve attributes and class of the top-level object where possible.

For example, if `x` has a class with print or summary methods, the returned object should keep that class.

Please add tests for attribute/class preservation.

### Validation

Please validate inputs clearly:

- `x` should be a list-like object.
- all updates must be named;
- names must be non-empty;
- path components must be non-empty;
- duplicate update paths should either be applied in order or rejected. Please choose the cleaner behaviour and document it.
- paths that try to descend into a non-list object should error clearly unless replacement occurs exactly at that path.

### Implementation

Use base R only.

It is fine to add non-exported helpers such as:

```r
parse_list_path()
set_list_path()
```

Document non-exported helpers with roxygen2 comments, following `AGENTS.md`.

## `input_form()`

Please implement and export:

```r
input_form <- function(
  x,
  file = "",
  control = "all",
  width.cutoff = 60
)
```

The purpose is to produce R code that can be pasted elsewhere to reconstruct `x`.

This should be a friendly wrapper around `dput()`.

### Behaviour

If called as:

```r
input_form(x)
```

it should print/cat the result to the console, like `cat()`, and invisibly return the result as a single character string.

If called as:

```r
txt <- input_form(x)
```

`txt` should receive the character string invisibly? Please consider R conventions carefully here.

My preference:
- always return the character string, visibly or invisibly according to what is most natural;
- when `file = ""`, cat the string to the console;
- when `file` is a filename, write the string to the file and return the string invisibly.

If a visible return plus console output would duplicate output annoyingly at the console, use invisible return when printing/writing.

For file output:

```r
input_form(x, file = "blah.R")
```

should write the generated R code to `blah.R`.

Use `dput()` internally, likely via a text connection or `capture.output()`.

Preserve attributes as much as `dput()` can. Use `control = "all"` by default.

### Limitations

Document that exact reconstruction is not guaranteed for every possible R object. This is mainly intended for ordinary R objects and nested lists, not environments, external pointers, or objects with nontrivial reference semantics.

## Documentation

Add roxygen2 documentation for both exported functions.

Use Canadian spelling.

Examples should be lightweight and check-friendly.

Examples for `update_list()` should include:
- top-level update;
- nested update with `$` path;
- `.create = TRUE`.

Examples for `input_form()` should include:
- generating a pasteable string;
- writing to a temporary file.

## Tests

Add `testthat` tests for `update_list()`:

- top-level update;
- nested update;
- multiple updates;
- `.create = TRUE`;
- missing path error when `.create = FALSE`;
- descending into non-list error;
- class and attributes preserved;
- original input is not modified;
- unnamed update error;
- duplicate paths behaviour.

Add `testthat` tests for `input_form()`:

- returns/captures a character string;
- output can be parsed and evaluated to reconstruct a simple list;
- attributes are preserved for simple attributed objects;
- writes to a temporary file;
- default `control = "all"` preserves attributes better than `control = NULL`, if this can be tested cleanly.

Avoid brittle tests for objects that `dput()` cannot reliably reconstruct.

## Package docs

Update package-level documentation if appropriate.

Regenerate documentation and NAMESPACE.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. What API was implemented.
2. How nested update paths are specified.
3. How attributes/classes are preserved.
4. How `input_form()` uses `dput()`.
5. What limitations remain.
6. What files changed.
7. What tests were added.
8. What verification commands were run and their results.
