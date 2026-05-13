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
#' This is a friendly wrapper around [dput()], intended mainly for ordinary R
#' objects and nested lists.
#'
#' Exact reconstruction is not guaranteed for every possible object, especially
#' environments, external pointers, or objects with nontrivial reference
#' semantics.
#'
#' @param x Object to represent as R code.
#' @param file Filename to write to, or `""` to print to the console.
#' @param control Control argument passed to [dput()]. The default `"all"`
#'   preserves attributes where possible.
#' @param width.cutoff Width cutoff retained for API compatibility. Current R
#'   versions do not expose this argument in [dput()].
#'
#' @return A character scalar containing the generated R code. The value is
#'   returned invisibly when it is also printed to the console or written to a
#'   file.
#'
#' @examples
#' txt <- input_form(list(a = 1, b = "two"))
#'
#' out.file <- tempfile(fileext = ".R")
#' input_form(list(a = 1), file = out.file)
#' readLines(out.file)
#'
#' @export
input_form <- function(x,
                       file = "",
                       control = "all",
                       width.cutoff = 60) {
  if (!is.numeric(width.cutoff) || length(width.cutoff) != 1L ||
      is.na(width.cutoff) || width.cutoff < 20) {
    stop("`width.cutoff` must be a numeric scalar of at least 20.", call. = FALSE)
  }

  output.lines <- utils::capture.output(
    dput(x, control = control)
  )
  output.text <- paste(output.lines, collapse = "\n")

  if (identical(file, "")) {
    cat(output.text, "\n", sep = "")
    return(invisible(output.text))
  }

  writeLines(output.text, con = file, useBytes = TRUE)
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
