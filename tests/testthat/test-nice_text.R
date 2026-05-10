test_that("nice_text expands macros for tikz output", {
  expect_identical(nice_text("$\\Rn$", use.tikz = TRUE), "$\\mathcal R_0$")
})

test_that("recursive macro expansion works in tikz mode", {
  expect_identical(nice_text("$\\Rn$", use.tikz = TRUE), "$\\mathcal R_0$")
  expect_identical(nice_text("$\\tinc$", use.tikz = TRUE), "$\\tilde{\\iota}$")
  expect_identical(nice_text("$\\tFoIpeak$", use.tikz = TRUE), "$\\hat{\\tilde{F}}$")
  expect_identical(
    nice_text("$\\Xkm$", use.tikz = TRUE),
    "$\\tilde{X}_{\\text{\\scalebox{0.6}{\\mathrm{KM}}}}$"
  )
})

test_that("tikz mode preserves ignored commands and returns character strings", {
  input <- "$A_{\\mathrm{i}}$"
  result <- nice_text(input, use.tikz = TRUE)

  expect_identical(result, input)
  expect_type(result, "character")
})

test_that("nice_text accepts explicit non-tikz output", {
  result <- nice_text("$\\Rn$", use.tikz = FALSE, warn = FALSE)

  expect_length(result, 1)
})

test_that("use.tikz NULL resolves from the calling environment", {
  use.tikz <- TRUE
  input <- "$\\Rn$"

  expect_identical(nice_text(input), "$\\mathcal R_0$")
})

test_that("use.tikz NULL falls back to FALSE", {
  expect_false(resolve_use_tikz(NULL, new.env(parent = emptyenv())))
})

test_that("default TeX support files exist", {
  expect_true(file.exists(nice_text_default_macros_file()))
  expect_true(file.exists(nice_text_default_ignore_file()))
})

test_that("nice_text_macros returns package defaults", {
  macros <- nice_text_macros()
  expected.names <- c(
    "R",
    "Rn",
    "inc",
    "FoI",
    "kmsubscript",
    "Xkm",
    "Ykm",
    "Zkm",
    "tX",
    "tY",
    "tZ",
    "tinc",
    "xp",
    "xm",
    "zp",
    "zm",
    "xpm",
    "xmp",
    "Xpm",
    "Xp",
    "Xm",
    "lamp",
    "lamm",
    "lampm",
    "lammp",
    "lambdakm",
    "xpeak",
    "ypeak",
    "zpeak",
    "taupeak",
    "taupeakkm",
    "ypeakkm",
    "xpeakkm",
    "tFoIpeak",
    "tincpeak",
    "aoi",
    "Wp",
    "Wm",
    "Wpm",
    "tauinit",
    "xinit",
    "yinit",
    "zinit",
    "Oh",
    "reals",
    "integers",
    "naturals",
    "Tinf",
    "Tlat",
    "xin"
  )

  expect_named(macros, expected.names)
  expect_identical(unname(macros["R"]), "\\mathcal R")
  expect_identical(unname(macros["Rn"]), "\\R_0")
  expect_identical(unname(macros["FoI"]), "F")
  expect_false("I" %in% names(macros))
  expect_false("E" %in% names(macros))
  expect_false("dd" %in% names(macros))
})

test_that("nice_text_ignore_commands returns package defaults", {
  commands <- nice_text_ignore_commands()

  expect_true("\\mathrm" %in% commands)
  expect_true("\\mathsf" %in% commands)
  expect_true("\\quad" %in% commands)
  expect_true("\\," %in% commands)
})

test_that("default macro expansion is recursive and bounded", {
  macros <- nice_text_macros()

  expect_identical(expand_tex_macros("$\\Rn$", macros), "$\\mathcal R_0$")
  expect_identical(expand_tex_macros("$\\tinc$", macros), "$\\tilde{\\iota}$")
  expect_identical(expand_tex_macros("$\\tFoIpeak$", macros), "$\\hat{\\tilde{F}}$")
  expect_identical(
    expand_tex_macros("$\\Xkm$", macros),
    "$\\tilde{X}_{\\text{\\scalebox{0.6}{\\mathrm{KM}}}}$"
  )
})

test_that("inline comments do not enter macro replacements", {
  macros <- nice_text_macros()

  expect_identical(unname(macros["xp"]), "x^{+}")
  expect_identical(expand_tex_macros("$\\xp$", macros), "$x^{+}$")
})

test_that("temporary user macros append to defaults", {
  macros.file <- tempfile(fileext = ".tex")
  writeLines("\\newcommand{\\foo}{bar}", macros.file)

  macros <- nice_text_macros(macros.file = macros.file)

  expect_identical(unname(macros["R"]), "\\mathcal R")
  expect_identical(unname(macros["foo"]), "bar")
})

test_that("temporary user macros append to defaults in tikz mode", {
  macros.file <- tempfile(fileext = ".tex")
  writeLines("\\newcommand{\\foo}{bar}", macros.file)

  result <- nice_text(
    "$\\foo \\Rn$",
    use.tikz = TRUE,
    macros.file = macros.file
  )

  expect_identical(result, "$bar \\mathcal R_0$")
})

test_that("temporary user macros override defaults when appended", {
  macros.file <- tempfile(fileext = ".tex")
  writeLines("\\renewcommand{\\R}{R}", macros.file)

  macros <- nice_text_macros(macros.file = macros.file)

  expect_identical(unname(macros["R"]), "R")
  expect_identical(expand_tex_macros("$\\Rn$", macros), "$R_0$")
})

test_that("temporary user macros override defaults in tikz mode", {
  macros.file <- tempfile(fileext = ".tex")
  writeLines("\\renewcommand{\\R}{R}", macros.file)

  result <- nice_text("$\\Rn$", use.tikz = TRUE, macros.file = macros.file)

  expect_identical(result, "$R_0$")
})

test_that("append.macros FALSE replaces package defaults", {
  macros.file <- tempfile(fileext = ".tex")
  writeLines("\\newcommand{\\foo}{bar}", macros.file)

  macros <- nice_text_macros(macros.file = macros.file, append.macros = FALSE)

  expect_named(macros, "foo")
  expect_identical(unname(macros["foo"]), "bar")
})

test_that("append.macros FALSE replaces package defaults in tikz mode", {
  macros.file <- tempfile(fileext = ".tex")
  writeLines("\\newcommand{\\foo}{bar}", macros.file)

  result <- nice_text(
    "$\\foo \\Rn$",
    use.tikz = TRUE,
    macros.file = macros.file,
    append.macros = FALSE
  )

  expect_identical(result, "$bar \\Rn$")
})

test_that("macro option file is included before explicit user file", {
  option.file <- tempfile(fileext = ".tex")
  explicit.file <- tempfile(fileext = ".tex")
  writeLines("\\newcommand{\\foo}{option}", option.file)
  writeLines("\\renewcommand{\\foo}{explicit}", explicit.file)
  old.options <- options(earnmisc.tex_macros_file = option.file)
  on.exit(options(old.options))

  macros <- nice_text_macros(macros.file = explicit.file)

  expect_identical(unname(macros["foo"]), "explicit")
})

test_that("ignored wrapper and spacing commands are cleaned", {
  commands <- nice_text_ignore_commands()

  expect_identical(
    clean_tex_for_latex2exp("$A_{\\mathrm{i}}$", commands),
    "$A_{i}$"
  )
  expect_identical(
    clean_tex_for_latex2exp("$A\\quad B\\,C$", commands),
    "$A BC$"
  )
})

test_that("temporary user ignore commands append to defaults", {
  ignore.file <- tempfile()
  writeLines("\\foo", ignore.file)

  commands <- nice_text_ignore_commands(ignore.file = ignore.file)

  expect_true("\\mathrm" %in% commands)
  expect_true("\\foo" %in% commands)
  expect_identical(clean_tex_for_latex2exp("$\\foo{bar}$", commands), "$bar$")
})

test_that("append.ignore FALSE replaces package defaults", {
  ignore.file <- tempfile()
  writeLines("\\foo", ignore.file)

  commands <- nice_text_ignore_commands(ignore.file = ignore.file, append.ignore = FALSE)

  expect_identical(commands, "\\foo")
  expect_identical(clean_tex_for_latex2exp("$\\mathrm{i}$", commands), "$\\mathrm{i}$")
  expect_identical(clean_tex_for_latex2exp("$\\foo{i}$", commands), "$i$")
})

test_that("ignore option file is included before explicit user file", {
  option.file <- tempfile()
  explicit.file <- tempfile()
  writeLines("\\foo", option.file)
  writeLines("\\bar", explicit.file)
  old.options <- options(earnmisc.tex_ignore_file = option.file)
  on.exit(options(old.options))

  commands <- nice_text_ignore_commands(ignore.file = explicit.file)

  expect_true("\\foo" %in% commands)
  expect_true("\\bar" %in% commands)
})

test_that("nice_text preprocessing preserves vector length", {
  input <- c("$\\Rn$", "$A_{\\mathrm{i}}$")
  output <- nice_text_preprocess(input, warn = FALSE)

  expect_identical(length(output), length(input))
  expect_false(any(grepl("mathrm", output, fixed = TRUE)))
})

test_that("nice_text tikz mode preserves vector length", {
  input <- c("$\\Rn$", "$\\tinc$", "$A_{\\mathrm{i}}$")
  output <- nice_text(input, use.tikz = TRUE)

  expect_identical(length(output), length(input))
  expect_identical(output[1], "$\\mathcal R_0$")
  expect_identical(output[2], "$\\tilde{\\iota}$")
  expect_identical(output[3], "$A_{\\mathrm{i}}$")
})

test_that("nice_text validates use.tikz", {
  expect_error(nice_text("x", use.tikz = c(TRUE, FALSE)), "`use.tikz`")
  expect_error(nice_text("x", use.tikz = NA), "`use.tikz`")
})
