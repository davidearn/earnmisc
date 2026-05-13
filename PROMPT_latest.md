# Latest Codex Prompt

- Entry ID: `20260513T135047Z`
- Recorded: `2026-05-13T13:50:47+00:00`

Please revise `earnmisc::input_form()`.

Read `AGENTS.md` first and follow it closely.

Do not modify `tools/`.
Do not run `make prompt`, `make response`, or `make record.commit`.
Do not create Git commits.

## Current implementation

`input_form()` currently uses:

```r
output.lines <- utils::capture.output(
  dput(x, control = control)
)
output.text <- paste(output.lines, collapse = "\n")
```

It validates `width.cutoff`, but `width.cutoff` is otherwise ignored because current R’s `dput()` does not expose a `width.cutoff` argument.

## Requested changes

Please revise `input_form()` to make `width.cutoff` meaningful and to add more control over file output and generated text.

Suggested revised API:

```r
input_form <- function(
  x,
  file = "",
  append = FALSE,
  control = "all",
  width.cutoff = 60,
  prefix = "",
  suffix = "",
  final.newline = TRUE,
  overwrite = TRUE
)
```

Use this exact API unless there is a strong reason to adjust it.

## `width.cutoff`

`width.cutoff` should control the deparse width as much as base R allows.

Rather than using `capture.output(dput(...))`, use `deparse()` directly, for example:

```r
output.lines <- deparse(
  x,
  width.cutoff = width.cutoff,
  control = control
)
```

Then collapse lines manually.

Please update the documentation to explain that `width.cutoff` is passed to `deparse()` and controls the approximate line width used during deparsing; it is not a strict maximum line length.

Keep validation sensible. Base R `deparse()` requires `width.cutoff` to be an integer-ish value between 20 and 500. Please validate accordingly.

## `append`

Add an `append` argument modelled on `cat()`/`write()` conventions.

Behaviour:
- If `file = ""`, `append` should have no practical effect.
- If `file` is a filename and `append = FALSE`, write a fresh file subject to `overwrite`.
- If `file` is a filename and `append = TRUE`, append to the existing file if it exists, or create it if it does not.

Use `cat()` or `writeLines()` in a way that handles `append` cleanly.

## `overwrite`

Add an `overwrite` argument controlling what happens when `file` already exists and `append = FALSE`.

Allowed values:

```r
TRUE
"warn"
"recover"
"error"
```

Behaviour:
- `overwrite = TRUE`: overwrite silently, matching current behaviour.
- `overwrite = "warn"`: warn that the existing file is being overwritten, then overwrite.
- `overwrite = "recover"`: before overwriting, copy the existing file to a recoverable backup path, warn with the backup filename, then overwrite.
- `overwrite = "error"`: stop with an informative error and do not overwrite.

Please also accept `overwrite = FALSE` as a synonym for `"error"` if that seems natural.

For `overwrite = "recover"`, choose a simple backup filename that avoids clobbering existing backups, for example:

```text
blah.R.bak
blah.R.bak1
blah.R.bak2
```

or a timestamped backup such as:

```text
blah.R.20260513-143012.bak
```

Use a simple, documented design.

If `append = TRUE`, do not treat an existing file as an overwrite; append to it. In that case, `overwrite` should be ignored or only validated. Please document this.

## `prefix` and `suffix`

Add `prefix` and `suffix` arguments.

These should be character scalars.

The final generated text should be:

```r
paste0(prefix, deparsed.object, suffix)
```

or the multiline equivalent.

Examples:

```r
input_form(my.list, prefix = "new.list <- ")
input_form(my.list, prefix = "new.list <- ", suffix = " # revised list")
```

For multiline deparse output, `prefix` should appear before the first line and `suffix` after the final line. For example, this is acceptable:

```r
new.list <- list(
  a = 1,
  b = 2
) # revised list
```

Please add tests for prefix and suffix.

## Final newline

Currently console/file output includes a final newline. This is a good default, but it should be controllable.

Add:

```r
final.newline = TRUE
```

Behaviour:
- If `final.newline = TRUE`, console and file output should end with a newline.
- If `final.newline = FALSE`, console and file output should not add a final newline.
- The returned character scalar should match exactly what was written/printed, including the final newline if `final.newline = TRUE`.

This is a change from the current implementation if the current returned string excludes the final newline. Please document the exact return value clearly.

## Return value

Return a character scalar containing exactly the generated text.

If the text is printed to the console or written to a file, return it invisibly.

Current behaviour already returns invisibly when printing or writing; please preserve that convention.

## Documentation

Update roxygen2 documentation for `input_form()`.

Please document:
- that it is based on `deparse()` rather than a full serializer;
- how `width.cutoff` works and that it is not a strict line-length guarantee;
- `append`;
- `overwrite`;
- backup behaviour for `overwrite = "recover"`;
- `prefix` and `suffix`;
- `final.newline`;
- limitations for environments, external pointers, reference objects, and other objects that cannot be reconstructed reliably from deparsed code.

Use Canadian spelling.

Examples should be lightweight and check-friendly.

Add examples for:
- assignment prefix;
- file append;
- `overwrite = "error"` or `"warn"` if easy to show safely with `tempfile()`;
- `final.newline = FALSE`.

## Tests

Add or revise tests for:

### Width cutoff
- `width.cutoff` is passed to `deparse()` and changes output for a suitable object.
- invalid `width.cutoff` values error clearly.
- Documentation/test comments should not imply strict maximum line length.

### Append
- `append = FALSE` writes a new file.
- `append = TRUE` appends to an existing file.
- `append = TRUE` creates a file if it does not already exist.

### Overwrite
- existing file + `overwrite = TRUE` overwrites silently.
- existing file + `overwrite = "warn"` warns and overwrites.
- existing file + `overwrite = "error"` errors and does not overwrite.
- existing file + `overwrite = FALSE` behaves like `"error"` if you choose to support that.
- existing file + `overwrite = "recover"` creates a backup and overwrites.
- `append = TRUE` does not trigger overwrite protection.

### Prefix/suffix
- prefix is prepended to the generated object form.
- suffix is appended to the generated object form.
- prefixed assignment text can be parsed and evaluated when appropriate.

### Final newline
- `final.newline = TRUE` includes a trailing newline in the returned string and output.
- `final.newline = FALSE` does not include a trailing newline.

### Reconstruction
- simple lists can still be parsed/evaluated to reconstruct the original object.
- simple attributes are still preserved with `control = "all"` where base R supports this.

## Internal helpers

It is fine to add non-exported helpers, for example:

```r
normalise_overwrite()
backup_file_path()
write_input_form()
```

Document non-exported helpers with roxygen2 comments, following `AGENTS.md`.

## Verification

After making changes, run:

```sh
make document
make test
make check
```

Please report:
1. How `width.cutoff` is now implemented.
2. What the final `input_form()` API is.
3. How append and overwrite behaviour work.
4. How backup/recover behaviour works.
5. How prefix, suffix, and final newline are handled.
6. What files changed.
7. What tests were added or revised.
8. What verification commands were run and their results.
