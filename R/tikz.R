tikz_info_store <- new.env(parent = emptyenv())
tikz_info_store$latest <- NULL
tikz_info_store$by_device <- new.env(parent = emptyenv())

#' Open a tikz graphics device and store metadata
#'
#' Open a tikz graphics device with [tikzDevice::tikz()] and store useful
#' metadata about the file, dimensions, device, and arguments used. This is
#' useful because `tikzDevice::tikz()` itself returns no useful value.
#'
#' `tikzDevice` is a suggested package, not imported. `tikz_open()` fails with
#' a clear error if `tikzDevice` is not available. The `earnmisc` default for
#' `standAlone` is `TRUE`, so generated `.tex` files are ready for direct
#' compilation in the usual case. Metadata are stored internally for
#' [tikz_info()]; `tikz_open()` does not assign `use.tikz` or other variables
#' in the caller environment.
#'
#' @param file Output `.tex` file passed to [tikzDevice::tikz()].
#' @param filename Default filename pattern passed through to
#'   [tikzDevice::tikz()].
#' @param width,height Width and height of the graphics device in inches.
#' @param onefile,bg,fg,pointsize,lwdUnit,standAlone,bareBones,console,sanitize
#'   Arguments passed to [tikzDevice::tikz()].
#' @param engine,documentDeclaration,packages,footer,symbolicColors,colorFileName
#'   Arguments passed to [tikzDevice::tikz()]. If `packages = NULL`, the
#'   argument is omitted so `tikzDevice` can use its own default.
#' @param maxSymbolicColors,timestamp,verbose Arguments passed to
#'   [tikzDevice::tikz()].
#' @param message Logical scalar. If `TRUE`, print a short message after the
#'   device opens successfully.
#'
#' @return Invisibly returns an object of class `earnmisc_tikz_info`, a list
#'   containing the tikz arguments plus metadata including `device`,
#'   `device.name`, `opened_at`, `working_directory`, `normalized_file`, and
#'   `pdf_file`.
#'
#' @examples
#' \dontrun{
#' tikz.info <- tikz_open("figure.tex", width = 14, height = 7)
#' plot(1:10)
#' grDevices::dev.off()
#' tikz_compile(tikz.info)
#' }
#'
#' @export
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
) {
  message <- validate_tikz_logical_scalar(message, "message")

  if (!requireNamespace("tikzDevice", quietly = TRUE)) {
    stop(
      "`tikzDevice` is required for `tikz_open()`. Install it with install.packages(\"tikzDevice\").",
      call. = FALSE
    )
  }

  tikz.arguments <- list(
    file = file,
    filename = filename,
    width = width,
    height = height,
    onefile = onefile,
    bg = bg,
    fg = fg,
    pointsize = pointsize,
    lwdUnit = lwdUnit,
    standAlone = standAlone,
    bareBones = bareBones,
    console = console,
    sanitize = sanitize,
    engine = engine,
    documentDeclaration = documentDeclaration,
    footer = footer,
    symbolicColors = symbolicColors,
    colorFileName = colorFileName,
    maxSymbolicColors = maxSymbolicColors,
    timestamp = timestamp,
    verbose = verbose
  )

  if (!is.null(packages)) {
    tikz.arguments$packages <- packages
  }

  tryCatch(
    do.call(tikzDevice::tikz, tikz.arguments),
    error = function(error) {
      stop("tikz_open: failed to open tikz device: ", conditionMessage(error), call. = FALSE)
    }
  )

  device <- grDevices::dev.cur()
  device.name <- names(device)
  device.number <- unname(device)
  info <- build_tikz_info(
    arguments = c(tikz.arguments, list(packages = packages)),
    device = device.number,
    device.name = device.name,
    opened_at = Sys.time(),
    working_directory = getwd()
  )

  store_tikz_info(info)

  if (message) {
    base::message(
      "tikz_open: writing to ",
      info$file,
      " (width = ",
      info$width,
      ", height = ",
      info$height,
      ") ..."
    )
  }

  invisible(info)
}

#' Retrieve stored tikz device metadata
#'
#' Return metadata stored by the most recent call to [tikz_open()], or metadata
#' for a specific device number.
#'
#' The device does not need to still be open. Metadata remains available after
#' [grDevices::dev.off()].
#'
#' @param device Optional device number. If `NULL`, return the most recent tikz
#'   info object.
#'
#' @return An object of class `earnmisc_tikz_info`, or `NULL` if no matching
#'   metadata is available.
#'
#' @examples
#' tikz_info()
#'
#' @export
tikz_info <- function(device = NULL) {
  if (is.null(device)) {
    return(tikz_info_store$latest)
  }

  device <- as.character(device)

  if (!exists(device, envir = tikz_info_store$by_device, inherits = FALSE)) {
    return(NULL)
  }

  get(device, envir = tikz_info_store$by_device, inherits = FALSE)
}

#' Compile a tikz `.tex` file to PDF
#'
#' Compile a tikz `.tex` file using LaTeX. By default this uses `lualatex` in
#' batch mode and returns the produced PDF filename.
#'
#' A working LaTeX installation is required. Compilation is run in the directory
#' containing the `.tex` file so relative paths in the document work naturally.
#'
#' @param x Character scalar giving a `.tex` filename, or an info list returned
#'   by [tikz_open()].
#' @param engine Character scalar giving the LaTeX engine command.
#' @param batchmode Logical scalar. If `TRUE`, pass `-interaction=batchmode`.
#' @param clean Logical scalar. If `TRUE`, remove common auxiliary files after
#'   successful compilation. The `.tex` and `.pdf` files are never removed.
#' @param message Logical scalar. If `TRUE`, print a success message.
#'
#' @return A character scalar giving the PDF filename.
#'
#' @examples
#' \dontrun{
#' tikz.info <- tikz_open("figure.tex")
#' plot(1:10)
#' grDevices::dev.off()
#' tikz_compile(tikz.info)
#' }
#'
#' @export
tikz_compile <- function(
  x,
  engine = "lualatex",
  batchmode = TRUE,
  clean = FALSE,
  message = TRUE
) {
  engine <- validate_tikz_character_scalar(engine, "engine")
  batchmode <- validate_tikz_logical_scalar(batchmode, "batchmode")
  clean <- validate_tikz_logical_scalar(clean, "clean")
  message <- validate_tikz_logical_scalar(message, "message")

  tex.file <- tikz_tex_file_from_input(x)
  pdf.file <- tikz_pdf_file(tex.file)

  if (!file.exists(tex.file)) {
    stop("tikz_compile: TeX file does not exist: ", tex.file, call. = FALSE)
  }

  if (!nzchar(Sys.which(engine))) {
    stop("tikz_compile: LaTeX engine not found: ", engine, call. = FALSE)
  }

  tex.directory <- dirname(tex.file)
  tex.basename <- basename(tex.file)
  old.working.directory <- getwd()
  on.exit(setwd(old.working.directory), add = TRUE)
  setwd(tex.directory)

  arguments <- tex.basename

  if (batchmode) {
    arguments <- c("-interaction=batchmode", arguments)
  }

  status <- system2(engine, args = arguments)

  if (!identical(status, 0L) || !file.exists(basename(pdf.file))) {
    log.file <- tikz_auxiliary_file(tex.basename, "log")
    stop(
      "tikz_compile: failed to produce ",
      pdf.file,
      " (exit status ",
      status,
      "; log file: ",
      file.path(tex.directory, log.file),
      ")",
      call. = FALSE
    )
  }

  if (clean) {
    clean_tikz_auxiliary_files(tex.basename)
  }

  if (message) {
    base::message("tikz_compile: produced ", pdf.file)
  }

  pdf.file
}

build_tikz_info <- function(arguments,
                            device,
                            device.name,
                            opened_at,
                            working_directory) {
  file <- arguments$file
  info <- c(
    arguments,
    list(
      device = device,
      device.name = device.name,
      opened_at = opened_at,
      working_directory = working_directory,
      normalized_file = normalizePath(file, mustWork = FALSE),
      pdf_file = tikz_pdf_file(file)
    )
  )
  class(info) <- c("earnmisc_tikz_info", "list")
  info
}

store_tikz_info <- function(info) {
  tikz_info_store$latest <- info
  assign(as.character(info$device), info, envir = tikz_info_store$by_device)
  invisible(info)
}

tikz_tex_file_from_input <- function(x) {
  if (is.character(x) && length(x) == 1L && !is.na(x)) {
    return(normalizePath(x, mustWork = FALSE))
  }

  if (is.list(x) && !is.null(x$file)) {
    return(normalizePath(x$file, mustWork = FALSE))
  }

  stop("`x` must be a character `.tex` filename or a tikz info list.", call. = FALSE)
}

tikz_pdf_file <- function(tex.file) {
  tex.file <- validate_tikz_character_scalar(tex.file, "tex.file")
  file.path(
    dirname(tex.file),
    paste0(tools::file_path_sans_ext(basename(tex.file)), ".pdf")
  )
}

tikz_auxiliary_file <- function(tex.basename, extension) {
  paste0(tools::file_path_sans_ext(tex.basename), ".", extension)
}

clean_tikz_auxiliary_files <- function(tex.basename) {
  auxiliary.files <- tikz_auxiliary_file(tex.basename, c("aux", "log", "out"))
  unlink(auxiliary.files[file.exists(auxiliary.files)])
  invisible(auxiliary.files)
}

validate_tikz_character_scalar <- function(x, name) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    stop("`", name, "` must be a non-empty character scalar.", call. = FALSE)
  }

  x
}

validate_tikz_logical_scalar <- function(x, name) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop("`", name, "` must be a scalar logical value.", call. = FALSE)
  }

  x
}
