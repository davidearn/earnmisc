test_that("update_list updates top-level elements", {
  x <- list(type = "old", value = 1)

  expect_identical(update_list(x, type = "new"), list(type = "new", value = 1))
})

test_that("update_list updates nested elements", {
  x <- list(parms = list(graphics = list(lwd = 1, col = "black")))
  updated.x <- update_list(x, "parms$graphics$lwd" = 3)

  expect_identical(updated.x$parms$graphics$lwd, 3)
  expect_identical(updated.x$parms$graphics$col, "black")
})

test_that("update_list handles multiple updates and trims whitespace in paths", {
  x <- list(type = "old", parms = list(graphics = list(lwd = 1)))
  updated.x <- update_list(x, type = "new", "parms $ graphics $ lwd" = 3)

  expect_identical(updated.x$type, "new")
  expect_identical(updated.x$parms$graphics$lwd, 3)
})

test_that("update_list can create missing intermediate lists", {
  updated.x <- update_list(list(), "parms$graphics$lwd" = 3, .create = TRUE)

  expect_identical(updated.x, list(parms = list(graphics = list(lwd = 3))))
})

test_that("update_list errors on missing paths when creation is disabled", {
  expect_error(update_list(list(), "parms$graphics$lwd" = 3), "Missing list path component")
})

test_that("update_list errors when descending into non-list elements", {
  x <- list(parms = 1)

  expect_error(update_list(x, "parms$graphics$lwd" = 3), "Cannot descend into non-list")
  expect_identical(update_list(x, parms = 2), list(parms = 2))
})

test_that("update_list preserves top-level class and attributes", {
  x <- list(a = 1, b = 2)
  class(x) <- "my_list"
  attr(x, "label") <- "important"

  updated.x <- update_list(x, a = 3)

  expect_s3_class(updated.x, "my_list")
  expect_identical(attr(updated.x, "label"), "important")
  expect_identical(updated.x$a, 3)
})

test_that("update_list does not modify original input", {
  x <- list(parms = list(graphics = list(lwd = 1)))
  updated.x <- update_list(x, "parms$graphics$lwd" = 3)

  expect_identical(x$parms$graphics$lwd, 1)
  expect_identical(updated.x$parms$graphics$lwd, 3)
})

test_that("update_list validates update names and paths", {
  expect_error(update_list(list(a = 1), 2), "must be named")
  expect_error(
    do.call(update_list, c(list(x = list(a = 1)), stats::setNames(list(2), ""))),
    "must be named"
  )
  expect_error(update_list(list(a = 1), "a$$b" = 2), "components must be non-empty")
})

test_that("update_list rejects duplicate update paths", {
  expect_error(
    update_list(list(a = 1), a = 2, " a " = 3),
    "Duplicate update path"
  )
})

test_that("update_list validates list input and .create", {
  expect_error(update_list(1, a = 2), "`x`")
  expect_error(update_list(list(), a = 2, .create = NA), "`.create`")
})

test_that("input_form prints and returns a character string invisibly", {
  printed.output <- capture.output(
    result <- withVisible(input_form(list(a = 1, b = "two")))
  )

  expect_false(result$visible)
  expect_type(result$value, "character")
  expect_length(result$value, 1)
  expect_match(result$value, "list")
  expect_true(endsWith(result$value, "\n"))
  expect_true(length(printed.output) > 0)
})

test_that("input_form width.cutoff is passed to deparse", {
  x <- as.list(stats::setNames(1:20, paste0("long_name_", 1:20)))
  narrow <- capture.output(narrow.result <- input_form(x, width.cutoff = 20))
  wide <- capture.output(wide.result <- input_form(x, width.cutoff = 500))

  expect_true(length(narrow) > 0)
  expect_true(length(wide) > 0)
  expect_false(identical(narrow.result, wide.result))
  expect_true(length(strsplit(narrow.result, "\n", fixed = TRUE)[[1]]) >
                length(strsplit(wide.result, "\n", fixed = TRUE)[[1]]))
})

test_that("input_form validates width.cutoff", {
  expect_error(input_form(list(a = 1), width.cutoff = 19), "`width.cutoff`")
  expect_error(input_form(list(a = 1), width.cutoff = 501), "`width.cutoff`")
  expect_error(input_form(list(a = 1), width.cutoff = 20.5), "`width.cutoff`")
})

test_that("input_form output can reconstruct a simple list", {
  x <- list(a = 1, b = "two", c = list(TRUE))
  txt <- capture.output(returned <- input_form(x))
  reconstructed.x <- eval(parse(text = returned))

  expect_true(length(txt) > 0)
  expect_identical(reconstructed.x, x)
})

test_that("input_form preserves simple attributes with default control", {
  x <- structure(list(a = 1), label = "important", class = "my_list")
  returned <- capture.output(result <- input_form(x))
  reconstructed.x <- eval(parse(text = result))

  expect_true(length(returned) > 0)
  expect_identical(attributes(reconstructed.x), attributes(x))
})

test_that("input_form writes a new temporary file", {
  x <- list(a = 1)
  out.file <- tempfile(fileext = ".R")
  result <- withVisible(input_form(x, file = out.file))

  expect_false(result$visible)
  expect_true(file.exists(out.file))
  expect_identical(
    readChar(out.file, nchars = file.info(out.file)$size, useBytes = TRUE),
    result$value
  )
  expect_identical(eval(parse(file = out.file)), x)
})

test_that("input_form appends to an existing file", {
  out.file <- tempfile(fileext = ".R")
  first <- input_form(list(a = 1), file = out.file)
  second <- input_form(list(b = 2), file = out.file, append = TRUE)

  expect_identical(
    readChar(out.file, nchars = file.info(out.file)$size, useBytes = TRUE),
    paste0(first, second)
  )
})

test_that("input_form append TRUE creates a file and ignores overwrite protection", {
  out.file <- tempfile(fileext = ".R")
  result <- input_form(list(a = 1), file = out.file, append = TRUE, overwrite = "error")

  expect_true(file.exists(out.file))
  expect_identical(
    readChar(out.file, nchars = file.info(out.file)$size, useBytes = TRUE),
    result
  )
})

test_that("input_form overwrite TRUE overwrites silently", {
  out.file <- tempfile(fileext = ".R")
  writeLines("old <- TRUE", out.file)

  expect_silent(result <- input_form(list(a = 1), file = out.file, overwrite = TRUE))
  expect_identical(
    readChar(out.file, nchars = file.info(out.file)$size, useBytes = TRUE),
    result
  )
})

test_that("input_form overwrite warn warns and overwrites", {
  out.file <- tempfile(fileext = ".R")
  writeLines("old <- TRUE", out.file)

  expect_warning(
    result <- input_form(list(a = 1), file = out.file, overwrite = "warn"),
    "Overwriting existing file"
  )
  expect_identical(
    readChar(out.file, nchars = file.info(out.file)$size, useBytes = TRUE),
    result
  )
})

test_that("input_form overwrite error does not overwrite", {
  out.file <- tempfile(fileext = ".R")
  writeLines("old <- TRUE", out.file)

  expect_error(input_form(list(a = 1), file = out.file, overwrite = "error"), "File already exists")
  expect_identical(readLines(out.file), "old <- TRUE")
})

test_that("input_form overwrite FALSE behaves like error", {
  out.file <- tempfile(fileext = ".R")
  writeLines("old <- TRUE", out.file)

  expect_error(input_form(list(a = 1), file = out.file, overwrite = FALSE), "File already exists")
  expect_identical(readLines(out.file), "old <- TRUE")
})

test_that("input_form overwrite recover creates backup and overwrites", {
  out.file <- tempfile(fileext = ".R")
  writeLines("old <- TRUE", out.file)

  expect_warning(
    result <- input_form(list(a = 1), file = out.file, overwrite = "recover"),
    "backup"
  )

  expect_identical(
    readChar(out.file, nchars = file.info(out.file)$size, useBytes = TRUE),
    result
  )
  expect_true(file.exists(paste0(out.file, ".bak")))
  expect_identical(readLines(paste0(out.file, ".bak")), "old <- TRUE")
})

test_that("input_form append TRUE does not trigger overwrite protection", {
  out.file <- tempfile(fileext = ".R")
  writeLines("old <- TRUE", out.file)

  expect_silent(input_form(list(a = 1), file = out.file, append = TRUE, overwrite = "error"))
  expect_true(length(readLines(out.file)) > 1)
})

test_that("input_form applies prefix and suffix", {
  result <- capture.output(
    text <- input_form(
      list(a = 1, b = 2),
      prefix = "new.list <- ",
      suffix = " # revised list",
      final.newline = FALSE
    )
  )
  env <- new.env(parent = baseenv())

  expect_true(length(result) > 0)
  expect_true(startsWith(text, "new.list <- "))
  expect_true(endsWith(text, " # revised list"))
  eval(parse(text = text), envir = env)
  expect_identical(env$new.list, list(a = 1, b = 2))
})

test_that("input_form validates prefix, suffix, append, final.newline, and overwrite", {
  expect_error(input_form(list(a = 1), prefix = c("a", "b")), "`prefix`")
  expect_error(input_form(list(a = 1), suffix = NA_character_), "`suffix`")
  expect_error(input_form(list(a = 1), append = NA), "`append`")
  expect_error(input_form(list(a = 1), final.newline = NA), "`final.newline`")
  expect_error(input_form(list(a = 1), overwrite = "replace"), "`overwrite`")
})

test_that("input_form final.newline controls returned and written text", {
  with.newline <- capture.output(
    with.newline.result <- input_form(list(a = 1), final.newline = TRUE)
  )
  without.newline <- capture.output(
    without.newline.result <- input_form(list(a = 1), final.newline = FALSE)
  )
  out.file <- tempfile(fileext = ".R")
  file.result <- input_form(list(a = 1), file = out.file, final.newline = FALSE)

  expect_true(length(with.newline) > 0)
  expect_true(length(without.newline) > 0)
  expect_true(endsWith(with.newline.result, "\n"))
  expect_false(endsWith(without.newline.result, "\n"))
  expect_false(endsWith(file.result, "\n"))
  expect_identical(
    readChar(out.file, nchars = file.info(out.file)$size, useBytes = TRUE),
    file.result
  )
})

test_that("input_form default control preserves attributes better than NULL", {
  x <- structure(1:3, label = "important")
  default.text <- capture.output(default.result <- input_form(x))
  null.text <- capture.output(null.result <- input_form(x, control = NULL))

  expect_true(length(default.text) > 0)
  expect_true(length(null.text) > 0)
  expect_identical(attr(eval(parse(text = default.result)), "label"), "important")
  expect_null(attr(eval(parse(text = null.result)), "label"))
})
