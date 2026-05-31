test_that("tikz_info returns NULL before any tikz device is opened", {
  expect_null(tikz_info())
  expect_null(tikz_info(device = 9999))
})

test_that("tikz_pdf_file resolves the expected PDF filename", {
  tex.file <- file.path(tempdir(), "figure.tex")

  expect_identical(tikz_pdf_file(tex.file), file.path(tempdir(), "figure.pdf"))
  expect_identical(tikz_pdf_file("figure"), "./figure.pdf")
})

test_that("tikz_tex_file_from_input accepts filenames and info-like lists", {
  tex.file <- file.path(tempdir(), "figure.tex")
  info <- list(file = tex.file)

  expect_identical(tikz_tex_file_from_input(tex.file), normalizePath(tex.file, mustWork = FALSE))
  expect_identical(tikz_tex_file_from_input(info), normalizePath(tex.file, mustWork = FALSE))
  expect_error(tikz_tex_file_from_input(list()), "`x`")
})

test_that("build_tikz_info includes tikz arguments and metadata", {
  arguments <- list(
    file = "figure.tex",
    filename = "figure.tex",
    width = 14,
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
    verbose = FALSE
  )

  info <- build_tikz_info(
    arguments = arguments,
    device = 2,
    device.name = "tikz output",
    opened_at = as.POSIXct("2026-05-10 12:00:00", tz = "UTC"),
    working_directory = getwd()
  )

  expect_s3_class(info, "earnmisc_tikz_info")
  expect_identical(info$file, "figure.tex")
  expect_identical(info$width, 14)
  expect_identical(info$height, 7)
  expect_true(info$standAlone)
  expect_identical(info$device, 2)
  expect_identical(info$device.name, "tikz output")
  expect_identical(info$working_directory, getwd())
  expect_identical(info$normalized_file, normalizePath("figure.tex", mustWork = FALSE))
  expect_identical(info$pdf_file, "./figure.pdf")
})

test_that("tikz_open defaults to standAlone TRUE", {
  expect_true(formals(tikz_open)$standAlone)
})

test_that("tikz_open does not assign use.tikz in the caller", {
  skip_if_not_installed("tikzDevice")

  tex.file <- tempfile(fileext = ".tex")

  expect_false(exists("use.tikz", inherits = FALSE))
  tikz_open(tex.file, message = FALSE)
  on.exit(grDevices::dev.off(), add = TRUE)

  expect_false(exists("use.tikz", inherits = FALSE))
})

test_that("tikz_open does not overwrite caller use.tikz", {
  skip_if_not_installed("tikzDevice")

  use.tikz <- FALSE
  tex.file <- tempfile(fileext = ".tex")

  tikz_open(tex.file, message = FALSE)
  on.exit(grDevices::dev.off(), add = TRUE)

  expect_false(use.tikz)
})

test_that("tikz_info retrieves stored info by latest and device", {
  info <- build_tikz_info(
    arguments = list(file = "stored.tex", filename = "stored.tex", width = 1, height = 1),
    device = 1234,
    device.name = "tikz output",
    opened_at = Sys.time(),
    working_directory = getwd()
  )

  old.latest <- tikz_info_store$latest
  old.device <- if (exists("1234", envir = tikz_info_store$by_device, inherits = FALSE)) {
    get("1234", envir = tikz_info_store$by_device, inherits = FALSE)
  } else {
    NULL
  }
  on.exit({
    tikz_info_store$latest <- old.latest
    if (is.null(old.device)) {
      rm(list = "1234", envir = tikz_info_store$by_device)
    } else {
      assign("1234", old.device, envir = tikz_info_store$by_device)
    }
  })

  store_tikz_info(info)

  expect_identical(tikz_info(), info)
  expect_identical(tikz_info(1234), info)
})

test_that("tikz_open fails clearly if tikzDevice is unavailable", {
  if (requireNamespace("tikzDevice", quietly = TRUE)) {
    skip("tikzDevice is installed")
  }

  expect_error(tikz_open(tempfile(fileext = ".tex"), message = FALSE), "`tikzDevice` is required")
})

test_that("tikz_compile validates inputs without requiring LaTeX", {
  expect_error(tikz_compile(list(), message = FALSE), "`x`")
})
