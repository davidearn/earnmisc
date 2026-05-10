#' Prepare TeX-like text for plot labels
#'
#' Prepare a character vector for plot labels on tikz and non-tikz graphics
#' devices. For tikz devices, the input is returned unchanged. For non-tikz
#' devices, simple no-argument TeX macros are expanded, configured TeX commands
#' are removed or simplified, and [latex2exp::TeX()] is used when the
#' `latex2exp` package is available.
#'
#' This is a lightweight helper, not a full TeX parser. It supports
#' conservative no-argument definitions of the form
#' `\\newcommand{\\foo}{replacement}`, `\\renewcommand{\\foo}{replacement}`,
#' and `\\def\\foo{replacement}`.
#'
#' @param x Character vector of labels.
#' @param use.tikz Optional logical scalar. If `TRUE`, return `x` unchanged.
#'   If `FALSE`, preprocess for non-tikz graphics devices. If `NULL`, look for
#'   a scalar logical object named `use.tikz` in the calling environment and
#'   otherwise use `FALSE`.
#' @param macros.file Optional path to a user TeX macro file. If `NULL`, the
#'   option `earnmisc.tex_macros_file` is checked.
#' @param ignore.file Optional path to a user ignore-command file. If `NULL`,
#'   the option `earnmisc.tex_ignore_file` is checked.
#' @param append.macros Logical scalar. If `TRUE`, read package default macros
#'   first and user macros second. If `FALSE`, use only user macro files.
#' @param append.ignore Logical scalar. If `TRUE`, read package default ignore
#'   commands first and user commands second. If `FALSE`, use only user ignore
#'   files.
#' @param warn Logical scalar. If `TRUE`, warn about unsupported macro
#'   definitions and missing optional TeX conversion support.
#'
#' @return If `use.tikz` resolves to `TRUE`, returns `x` unchanged. Otherwise
#'   returns the result of [latex2exp::TeX()] when `latex2exp` is available, or
#'   the preprocessed character vector when it is not.
#'
#' @examples
#' nice_text("$\\Rn$", use.tikz = TRUE)
#' nice_text("$\\Rn$", use.tikz = FALSE, warn = FALSE)
#'
#' macros.file <- tempfile(fileext = ".tex")
#' writeLines("\\newcommand{\\foo}{bar}", macros.file)
#' nice_text("$\\foo$", macros.file = macros.file, use.tikz = TRUE)
#' nice_text_macros(macros.file = macros.file)
#'
#' @export
nice_text <- function(x,
                      use.tikz = NULL,
                      macros.file = NULL,
                      ignore.file = NULL,
                      append.macros = TRUE,
                      append.ignore = TRUE,
                      warn = TRUE) {
  if (!is.character(x)) {
    stop("`x` must be a character vector.", call. = FALSE)
  }
  warn <- validate_logical_scalar(warn, "warn")
  use.tikz <- resolve_use_tikz(use.tikz, parent.frame())

  if (use.tikz) {
    return(x)
  }

  preprocessed.text <- nice_text_preprocess(
    x,
    macros.file = macros.file,
    ignore.file = ignore.file,
    append.macros = append.macros,
    append.ignore = append.ignore,
    warn = warn
  )

  if (requireNamespace("latex2exp", quietly = TRUE)) {
    return(latex2exp::TeX(preprocessed.text))
  }

  if (warn) {
    warning(
      "`latex2exp` is not available; returning preprocessed character text.",
      call. = FALSE
    )
  }
  preprocessed.text
}

#' Default TeX macro file for `nice_text()`
#'
#' Return the path to the package-supplied default TeX macro file.
#'
#' @return A character scalar giving the installed file path.
#'
#' @examples
#' nice_text_default_macros_file()
#'
#' @export
nice_text_default_macros_file <- function() {
  default.file <- system.file("tex", "default-macros.tex", package = "earnmisc")

  if (!nzchar(default.file)) {
    default.file <- file.path("inst", "tex", "default-macros.tex")
  }

  default.file
}

#' Default TeX ignore-command file for `nice_text()`
#'
#' Return the path to the package-supplied default TeX ignore-command file.
#'
#' @return A character scalar giving the installed file path.
#'
#' @examples
#' nice_text_default_ignore_file()
#'
#' @export
nice_text_default_ignore_file <- function() {
  default.file <- system.file(
    "tex",
    "default-ignore-commands.txt",
    package = "earnmisc"
  )

  if (!nzchar(default.file)) {
    default.file <- file.path("inst", "tex", "default-ignore-commands.txt")
  }

  default.file
}

#' Active TeX macros for `nice_text()`
#'
#' Return the active no-argument TeX macro definitions used by `nice_text()`.
#'
#' Package defaults are read from the curated earnmisc file
#' `inst/tex/default-macros.tex`. This file is intended for stable
#' cross-package plot-label notation, not as a full manuscript preamble. If the
#' option `earnmisc.tex_macros_file` is set, that file is read after the
#' defaults. If `macros.file` is supplied, it is read after the option file.
#' Later definitions override earlier definitions with the same macro name. Set
#' `append.macros = FALSE` to omit the package defaults.
#'
#' @param macros.file Optional path to a user TeX macro file. If `NULL`, only
#'   the option `earnmisc.tex_macros_file` is checked.
#' @param append.macros Logical scalar. If `TRUE`, include package defaults. If
#'   `FALSE`, use only user files.
#'
#' @return A named character vector. Names are macro names without the leading
#'   backslash and values are replacement strings.
#'
#' @examples
#' nice_text_macros()
#'
#' macros.file <- tempfile(fileext = ".tex")
#' writeLines("\\newcommand{\\foo}{bar}", macros.file)
#' nice_text_macros(macros.file = macros.file)
#'
#' @export
nice_text_macros <- function(macros.file = NULL, append.macros = TRUE) {
  append.macros <- validate_logical_scalar(append.macros, "append.macros")
  macros.files <- nice_text_file_paths(
    default.file = nice_text_default_macros_file(),
    option.name = "earnmisc.tex_macros_file",
    explicit.file = macros.file,
    append.default = append.macros
  )

  read_tex_macros(macros.files, warn = TRUE)
}

#' Active TeX ignore commands for `nice_text()`
#'
#' Return the active TeX commands removed or simplified by `nice_text()` for
#' non-tikz graphics devices.
#'
#' Package defaults are read from `inst/tex/default-ignore-commands.txt`. If the
#' option `earnmisc.tex_ignore_file` is set, that file is read after the
#' defaults. If `ignore.file` is supplied, it is read after the option file. Set
#' `append.ignore = FALSE` to omit the package defaults.
#'
#' @param ignore.file Optional path to a user ignore-command file. If `NULL`,
#'   only the option `earnmisc.tex_ignore_file` is checked.
#' @param append.ignore Logical scalar. If `TRUE`, include package defaults. If
#'   `FALSE`, use only user files.
#'
#' @return A character vector of TeX command names, including the leading
#'   backslash.
#'
#' @examples
#' nice_text_ignore_commands()
#'
#' ignore.file <- tempfile()
#' writeLines("\\foo", ignore.file)
#' nice_text_ignore_commands(ignore.file = ignore.file)
#'
#' @export
nice_text_ignore_commands <- function(ignore.file = NULL, append.ignore = TRUE) {
  append.ignore <- validate_logical_scalar(append.ignore, "append.ignore")
  ignore.files <- nice_text_file_paths(
    default.file = nice_text_default_ignore_file(),
    option.name = "earnmisc.tex_ignore_file",
    explicit.file = ignore.file,
    append.default = append.ignore
  )

  read_tex_ignore_commands(ignore.files)
}

nice_text_preprocess <- function(x,
                                 macros.file = NULL,
                                 ignore.file = NULL,
                                 append.macros = TRUE,
                                 append.ignore = TRUE,
                                 warn = TRUE) {
  append.macros <- validate_logical_scalar(append.macros, "append.macros")
  append.ignore <- validate_logical_scalar(append.ignore, "append.ignore")

  macros.files <- nice_text_file_paths(
    default.file = nice_text_default_macros_file(),
    option.name = "earnmisc.tex_macros_file",
    explicit.file = macros.file,
    append.default = append.macros
  )
  ignore.files <- nice_text_file_paths(
    default.file = nice_text_default_ignore_file(),
    option.name = "earnmisc.tex_ignore_file",
    explicit.file = ignore.file,
    append.default = append.ignore
  )

  macros <- read_tex_macros(macros.files, warn = warn)
  ignore.commands <- read_tex_ignore_commands(ignore.files)

  clean_tex_for_latex2exp(
    expand_tex_macros(x, macros = macros),
    ignore.commands = ignore.commands
  )
}

resolve_use_tikz <- function(use.tikz, envir = parent.frame()) {
  if (is.null(use.tikz) && exists("use.tikz", envir = envir, inherits = FALSE)) {
    use.tikz <- get("use.tikz", envir = envir, inherits = FALSE)
  }
  if (is.null(use.tikz)) {
    use.tikz <- FALSE
  }

  validate_logical_scalar(use.tikz, "use.tikz")
}

validate_logical_scalar <- function(x, name) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop("`", name, "` must be a scalar logical value.", call. = FALSE)
  }

  x
}

nice_text_file_paths <- function(default.file,
                                 option.name,
                                 explicit.file,
                                 append.default) {
  option.file <- getOption(option.name)
  user.files <- character()

  if (!is.null(option.file)) {
    user.files <- c(user.files, option.file)
  }
  if (!is.null(explicit.file)) {
    user.files <- c(user.files, explicit.file)
  }

  if (append.default) {
    files <- c(default.file, user.files)
  } else {
    files <- user.files
  }

  if (length(files) > 0L) {
    files <- path.expand(as.character(files))
    missing.files <- files[!file.exists(files)]

    if (length(missing.files) > 0L) {
      stop(
        "TeX support file does not exist: ",
        paste(missing.files, collapse = ", "),
        call. = FALSE
      )
    }
  }

  files
}

read_tex_macros <- function(files, warn = TRUE) {
  macros <- character()

  for (file.name in files) {
    lines <- readLines(file.name, warn = FALSE)

    for (line in lines) {
      clean.line <- trimws(remove_tex_comment(line))

      if (!nzchar(clean.line)) {
        next
      }

      parsed.macro <- parse_tex_macro_definition(clean.line)

      if (is.null(parsed.macro)) {
        if (warn && starts_with_macro_definition(clean.line)) {
          warning("Ignoring unsupported TeX macro definition: ", clean.line, call. = FALSE)
        }
        next
      }

      macros[parsed.macro$name] <- parsed.macro$replacement
    }
  }

  macros
}

read_tex_ignore_commands <- function(files) {
  commands <- character()

  for (file.name in files) {
    lines <- readLines(file.name, warn = FALSE)
    lines <- trimws(vapply(lines, remove_tex_comment, character(1)))
    lines <- lines[nzchar(lines)]
    commands <- c(commands, lines)
  }

  unique(commands)
}

expand_tex_macros <- function(x, macros, max.passes = 20L) {
  if (length(macros) == 0L) {
    return(x)
  }

  macro.names <- names(macros)
  macro.names <- macro.names[order(nchar(macro.names), decreasing = TRUE)]
  expanded.text <- x

  for (pass.number in seq_len(max.passes)) {
    previous.text <- expanded.text

    for (macro.name in macro.names) {
      expanded.text <- gsub(
        paste0("\\", macro.name),
        macros[[macro.name]],
        expanded.text,
        fixed = TRUE
      )
    }

    if (identical(previous.text, expanded.text)) {
      break
    }
  }

  expanded.text
}

clean_tex_for_latex2exp <- function(x, ignore.commands) {
  cleaned.text <- x

  for (command in ignore.commands) {
    command <- trimws(command)

    if (!nzchar(command)) {
      next
    }

    command.pattern <- escape_regex(command)
    wrapper.pattern <- paste0(command.pattern, "\\{([^{}]*)\\}")
    previous.text <- character(length(cleaned.text))

    while (!identical(previous.text, cleaned.text)) {
      previous.text <- cleaned.text
      cleaned.text <- gsub(wrapper.pattern, "\\1", cleaned.text, perl = TRUE)
    }

    cleaned.text <- gsub(command.pattern, "", cleaned.text, perl = TRUE)
  }

  cleaned.text
}

parse_tex_macro_definition <- function(line) {
  if (startsWith(line, "\\newcommand") || startsWith(line, "\\renewcommand")) {
    rest <- sub("^\\\\(?:re)?newcommand", "", line, perl = TRUE)
    command.group <- read_braced_group(rest)

    if (is.null(command.group)) {
      return(NULL)
    }

    rest <- command.group$rest
    if (grepl("^\\s*\\[", rest, perl = TRUE)) {
      return(NULL)
    }

    replacement.group <- read_braced_group(rest)

    if (is.null(replacement.group)) {
      return(NULL)
    }

    macro.name <- macro_name_from_command(command.group$value)

    if (is.null(macro.name)) {
      return(NULL)
    }

    return(list(name = macro.name, replacement = replacement.group$value))
  }

  if (startsWith(line, "\\def")) {
    rest <- sub("^\\\\def\\s*", "", line, perl = TRUE)
    command.match <- regexpr("^\\\\[[:alpha:]]+", rest, perl = TRUE)

    if (command.match[1] != 1L) {
      return(NULL)
    }

    command <- regmatches(rest, command.match)
    rest <- substring(rest, attr(command.match, "match.length") + 1L)

    if (grepl("^\\s*#", rest, perl = TRUE)) {
      return(NULL)
    }

    replacement.group <- read_braced_group(rest)

    if (is.null(replacement.group)) {
      return(NULL)
    }

    macro.name <- macro_name_from_command(command)

    if (is.null(macro.name)) {
      return(NULL)
    }

    return(list(name = macro.name, replacement = replacement.group$value))
  }

  NULL
}

read_braced_group <- function(x) {
  x <- sub("^\\s+", "", x, perl = TRUE)

  if (!startsWith(x, "{")) {
    return(NULL)
  }

  depth <- 0L
  start.position <- NA_integer_

  for (position in seq_len(nchar(x))) {
    character <- substr(x, position, position)

    if (identical(character, "{")) {
      depth <- depth + 1L

      if (is.na(start.position)) {
        start.position <- position + 1L
      }
    } else if (identical(character, "}")) {
      depth <- depth - 1L

      if (depth == 0L) {
        return(list(
          value = substr(x, start.position, position - 1L),
          rest = substring(x, position + 1L)
        ))
      }
    }
  }

  NULL
}

macro_name_from_command <- function(command) {
  if (!grepl("^\\\\[[:alpha:]]+$", command, perl = TRUE)) {
    return(NULL)
  }

  substring(command, 2L)
}

starts_with_macro_definition <- function(x) {
  startsWith(x, "\\newcommand") ||
    startsWith(x, "\\renewcommand") ||
    startsWith(x, "\\def")
}

remove_tex_comment <- function(x) {
  sub("(?<!\\\\)%.*$", "", x, perl = TRUE)
}

escape_regex <- function(x) {
  gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x, perl = TRUE)
}
