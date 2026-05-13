#' Update elements of a list
#'
#' Return a modified copy of a list-like object after replacing selected
#' elements. Update names can refer to top-level elements or to nested elements
#' using simple `$`-separated paths.
#'
#' Duplicate update paths are rejected, because repeated replacements for the
#' same element are usually accidental.
#'
#' @param x A list-like object.
#' @param ... Named updates. Names identify elements to replace, such as
#'   `type` or `"parms$graphics$lwd"`.
#' @param .create Logical scalar. If `TRUE`, create missing intermediate lists.
#'   If `FALSE`, missing intermediate path components are errors.
#'
#' @return A modified copy of `x`, preserving top-level attributes and class
#'   where possible.
#'
#' @examples
#' x <- list(type = "old", parms = list(graphics = list(lwd = 1)))
#' update_list(x, type = "new")
#' update_list(x, "parms$graphics$lwd" = 3)
#' update_list(list(), "parms$graphics$lwd" = 3, .create = TRUE)
#'
#' @export
update_list <- function(x, ..., .create = FALSE) {
  if (!is.list(x)) {
    stop("`x` must be a list-like object.", call. = FALSE)
  }
  .create <- validate_list_logical_scalar(.create, ".create")

  updates <- list(...)
  update.names <- names(updates)

  if (length(updates) == 0L) {
    return(x)
  }
  if (is.null(update.names) || anyNA(update.names) || any(!nzchar(update.names))) {
    stop("All updates in `...` must be named.", call. = FALSE)
  }

  paths <- lapply(update.names, parse_list_path)
  canonical.paths <- vapply(paths, paste, character(1), collapse = "$")
  duplicate.paths <- unique(canonical.paths[duplicated(canonical.paths)])

  if (length(duplicate.paths) > 0L) {
    stop(
      "Duplicate update path",
      if (length(duplicate.paths) == 1L) "" else "s",
      ": ",
      paste(duplicate.paths, collapse = ", "),
      call. = FALSE
    )
  }

  updated.x <- x

  for (update.number in seq_along(updates)) {
    updated.x <- set_list_path(
      updated.x,
      path = paths[[update.number]],
      value = updates[[update.number]],
      create = .create
    )
  }

  updated.x
}

#' Print an object as pasteable R input
#'
#' Produce R code that can usually be pasted elsewhere to reconstruct an object.
#' This is a friendly wrapper around [deparse()], intended mainly for ordinary
#' R objects and nested lists.
#'
#' Exact reconstruction is not guaranteed for every possible object, especially
#' environments, external pointers, or objects with nontrivial reference
#' semantics.
#'
#' @param x Object to represent as R code.
#' @param file Filename to write to, or `""` to print to the console.
#' @param append Logical scalar. If `TRUE` and `file` is a filename, append to
#'   the file or create it if it does not exist. Ignored when `file = ""`.
#' @param control Control argument passed to [deparse()]. The default `"all"`
#'   preserves attributes where possible.
#' @param width.cutoff Integer-ish scalar between 20 and 500 passed to
#'   [deparse()]. It controls the approximate line width used while deparsing,
#'   but is not a strict maximum line length.
#' @param prefix,suffix Character scalars added before the first deparsed line
#'   and after the final deparsed line.
#' @param final.newline Logical scalar. If `TRUE`, add a final newline to the
#'   generated text.
#' @param overwrite Controls behaviour when `file` exists and `append = FALSE`.
#'   `TRUE` overwrites silently, `"warn"` warns then overwrites, `"recover"`
#'   copies the existing file to a `.bak`, `.bak1`, ... backup before
#'   overwriting, and `"error"` stops. `FALSE` is accepted as a synonym for
#'   `"error"`. When `append = TRUE`, existing files are appended to and
#'   overwrite protection is not applied.
#'
#' @return A character scalar containing exactly the generated text, including
#'   the final newline when `final.newline = TRUE`. The value is returned
#'   invisibly when it is printed to the console or written to a file.
#'
#' @examples
#' txt <- input_form(list(a = 1, b = "two"), final.newline = FALSE)
#' input_form(list(a = 1, b = "two"), prefix = "new.list <- ")
#'
#' out.file <- tempfile(fileext = ".R")
#' input_form(list(a = 1), file = out.file)
#' input_form(list(b = 2), file = out.file, append = TRUE)
#' readLines(out.file)
#'
#' existing.file <- tempfile(fileext = ".R")
#' writeLines("old <- TRUE", existing.file)
#' try(input_form(list(a = 1), file = existing.file, overwrite = "error"))
#'
#' input_form(list(a = 1), final.newline = FALSE)
#'
#' @export
input_form <- function(x,
                       file = "",
                       append = FALSE,
                       control = "all",
                       width.cutoff = 60,
                       prefix = "",
                       suffix = "",
                       final.newline = TRUE,
                       overwrite = TRUE) {
  append <- validate_list_logical_scalar(append, "append")
  final.newline <- validate_list_logical_scalar(final.newline, "final.newline")
  width.cutoff <- validate_width_cutoff(width.cutoff)
  prefix <- validate_character_scalar(prefix, "prefix")
  suffix <- validate_character_scalar(suffix, "suffix")
  overwrite <- normalise_overwrite(overwrite)

  output.lines <- deparse(
    x,
    width.cutoff = width.cutoff,
    control = control
  )
  output.text <- paste0(prefix, paste(output.lines, collapse = "\n"), suffix)

  if (final.newline) {
    output.text <- paste0(output.text, "\n")
  }

  if (identical(file, "")) {
    cat(output.text, sep = "")
    return(invisible(output.text))
  }

  write_input_form(
    output.text,
    file = file,
    append = append,
    overwrite = overwrite
  )
  invisible(output.text)
}

#' Parse a list update path
#'
#' Split a simple `$`-separated list path into its components. Whitespace around
#' `$` separators and path components is ignored.
#'
#' @param path Character scalar path such as `"parms$graphics$lwd"`.
#'
#' @return A character vector of path components.
parse_list_path <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop("Update paths must be non-empty character strings.", call. = FALSE)
  }

  path.parts <- trimws(strsplit(path, "$", fixed = TRUE)[[1]])

  if (length(path.parts) == 0L || any(!nzchar(path.parts))) {
    stop("Update path components must be non-empty.", call. = FALSE)
  }

  path.parts
}

#' Set a nested list element by path
#'
#' Replace one element of a list-like object, optionally creating missing
#' intermediate lists.
#'
#' @param x List-like object to update.
#' @param path Character vector of path components.
#' @param value Replacement value.
#' @param create Logical scalar. If `TRUE`, missing intermediate components are
#'   created as lists.
#'
#' @return A modified copy of `x`.
set_list_path <- function(x, path, value, create) {
  if (length(path) == 1L) {
    x[[path]] <- value
    return(x)
  }

  current.name <- path[[1]]

  if (is.null(x[[current.name]])) {
    if (!create) {
      stop("Missing list path component: ", current.name, call. = FALSE)
    }

    x[[current.name]] <- list()
  }

  if (!is.list(x[[current.name]])) {
    stop("Cannot descend into non-list element: ", current.name, call. = FALSE)
  }

  x[[current.name]] <- set_list_path(
    x[[current.name]],
    path = path[-1],
    value = value,
    create = create
  )
  x
}

#' Validate a logical scalar for list utilities
#'
#' Check that an argument is a non-missing logical scalar.
#'
#' @param x Value to validate.
#' @param name Argument name for error messages.
#'
#' @return The validated logical scalar.
validate_list_logical_scalar <- function(x, name) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop("`", name, "` must be a scalar logical value.", call. = FALSE)
  }

  x
}

#' Validate an input-form width cutoff
#'
#' Validate a value for [deparse()]'s `width.cutoff` argument.
#'
#' @param width.cutoff Value to validate.
#'
#' @return An integer scalar between 20 and 500.
validate_width_cutoff <- function(width.cutoff) {
  if (!is.numeric(width.cutoff) || length(width.cutoff) != 1L ||
      is.na(width.cutoff) || width.cutoff != floor(width.cutoff) ||
      width.cutoff < 20 || width.cutoff > 500) {
    stop("`width.cutoff` must be an integer between 20 and 500.", call. = FALSE)
  }

  as.integer(width.cutoff)
}

#' Validate a character scalar
#'
#' Validate a scalar character argument used by `input_form()`.
#'
#' @param x Value to validate.
#' @param name Argument name for error messages.
#'
#' @return The validated character scalar.
validate_character_scalar <- function(x, name) {
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    stop("`", name, "` must be a character scalar.", call. = FALSE)
  }

  x
}

#' Normalise overwrite mode
#'
#' Convert accepted `overwrite` values into one of the internal character modes.
#'
#' @param overwrite User-supplied overwrite mode.
#'
#' @return One of `"true"`, `"warn"`, `"recover"`, or `"error"`.
normalise_overwrite <- function(overwrite) {
  if (is.logical(overwrite) && length(overwrite) == 1L && !is.na(overwrite)) {
    if (overwrite) {
      return("true")
    }

    return("error")
  }

  if (is.character(overwrite) && length(overwrite) == 1L &&
      overwrite %in% c("warn", "recover", "error")) {
    return(overwrite)
  }

  stop(
    "`overwrite` must be TRUE, FALSE, \"warn\", \"recover\", or \"error\".",
    call. = FALSE
  )
}

#' Find a backup path
#'
#' Return the first available `.bak`, `.bak1`, `.bak2`, ... path for a file.
#'
#' @param file Existing file path.
#'
#' @return A character scalar backup path.
backup_file_path <- function(file) {
  candidates <- c(
    paste0(file, ".bak"),
    paste0(file, ".bak", seq_len(999L))
  )
  available <- candidates[!file.exists(candidates)]

  if (length(available) == 0L) {
    stop("Could not find an available backup path for `file`.", call. = FALSE)
  }

  available[[1]]
}

#' Write input-form text
#'
#' Write generated input-form text to a file, applying append and overwrite
#' rules.
#'
#' @param text Character scalar to write.
#' @param file Destination file.
#' @param append Logical scalar. Append instead of overwrite.
#' @param overwrite Normalised overwrite mode from [normalise_overwrite()].
#'
#' @return Invisibly returns `file`.
write_input_form <- function(text, file, append, overwrite) {
  file <- validate_character_scalar(file, "file")

  if (!append && file.exists(file)) {
    if (identical(overwrite, "error")) {
      stop("File already exists and `overwrite = \"error\"`: ", file, call. = FALSE)
    }

    if (identical(overwrite, "warn")) {
      warning("Overwriting existing file: ", file, call. = FALSE)
    }

    if (identical(overwrite, "recover")) {
      backup.file <- backup_file_path(file)

      if (!file.copy(file, backup.file, overwrite = FALSE)) {
        stop("Could not create backup file: ", backup.file, call. = FALSE)
      }

      warning(
        "Existing file copied to backup before overwrite: ",
        backup.file,
        call. = FALSE
      )
    }
  }

  cat(text, file = file, append = append, sep = "")
  invisible(file)
}
