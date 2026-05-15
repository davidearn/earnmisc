test_that("plot_mts returns plot metadata and base curve registry", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  result <- withVisible(plot_mts(x))

  expect_false(result$visible)
  plot.info <- result$value
  expect_s3_class(plot.info, "earnmisc_mts_plot_info")
  expect_true(all(c("panel.order", "column.names", "layout", "device", "usr", "mfg", "xlim", "ylim", "curves") %in% names(plot.info)))
  expect_identical(plot.info$column.names, c("a", "b"))
  expect_identical(plot.info$panel.order, 1:2)
  expect_equal(nrow(plot.info$curves), 2)
  expect_identical(plot.info$curves$source, c("base", "base"))
  expect_identical(plot.info$curves$object.index, c(0L, 0L))
  expect_true(all(plot.info$curves$drawn))
  expect_true(all(is.na(plot.info$curves$reason)))
})

test_that("lines_mts uses stored plot info and errors when none is available", {
  old.last <- mts_plot_store$last
  on.exit(mts_plot_store$last <- old.last, add = TRUE)

  mts_plot_store$last <- NULL
  y <- stats::ts(cbind(a = 2:11, b = 10:19))
  expect_error(lines_mts(y), "requires a `plot.info` object")

  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  plot_mts(x)
  updated <- lines_mts(y)

  expect_s3_class(updated, "earnmisc_mts_plot_info")
  expect_equal(nrow(updated$curves), 4)
})

test_that("lines_mts matches columns by name and position", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(b = 10:19, a = 2:11))

  plot.info <- plot_mts(x)
  by.name <- lines_mts(y, plot.info = plot.info)
  overlay.rows <- by.name$curves[by.name$curves$source == "overlay", ]
  expect_identical(overlay.rows$name, c("b", "a"))
  expect_identical(overlay.rows$panel.index, c(2L, 1L))

  plot.info <- plot_mts(x)
  by.position <- lines_mts(y, plot.info = plot.info, match = "position")
  overlay.rows <- by.position$curves[by.position$curves$source == "overlay", ]
  expect_identical(overlay.rows$panel.index, c(1L, 2L))
})

test_that("lines_mts handles unmatched columns according to policy", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(a = 2:11, c = 3:12))

  plot.info <- plot_mts(x)
  expect_warning(warned <- lines_mts(y, plot.info = plot.info), "Unmatched mts column")
  overlay.rows <- warned$curves[warned$curves$source == "overlay", ]
  expect_identical(overlay.rows$drawn, c(TRUE, FALSE))
  expect_identical(overlay.rows$reason, c(NA_character_, "unmatched"))

  plot.info <- plot_mts(x)
  expect_error(lines_mts(y, plot.info = plot.info, unmatched = "error"), "Unmatched mts column")

  plot.info <- plot_mts(x)
  expect_silent(ignored <- lines_mts(y, plot.info = plot.info, unmatched = "ignore"))
  overlay.rows <- ignored$curves[ignored$curves$source == "overlay", ]
  expect_identical(overlay.rows$drawn, c(TRUE, FALSE))
})

test_that("lines_mts supports column restriction and graphical parameters", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))
  y <- stats::ts(cbind(c = 20:29, b = 10:19, a = 2:11))

  plot.info <- plot_mts(x)
  restricted <- lines_mts(y, plot.info = plot.info, columns = "b", col = "red", lty = 2, lwd = 3)
  overlay.rows <- restricted$curves[restricted$curves$source == "overlay", ]
  expect_equal(nrow(overlay.rows), 1)
  expect_identical(overlay.rows$name, "b")
  expect_identical(overlay.rows$col, "red")
  expect_identical(overlay.rows$lty, "2")
  expect_identical(overlay.rows$lwd, 3)

  plot.info <- plot_mts(x)
  vectorised <- lines_mts(y, plot.info = plot.info, col = c("red", "blue", "green"), lty = c(1, 2, 3))
  overlay.rows <- vectorised$curves[vectorised$curves$source == "overlay", ]
  expect_identical(overlay.rows$col, c("red", "blue", "green"))
  expect_identical(overlay.rows$lty, c("1", "2", "3"))

  plot.info <- plot_mts(x)
  named <- lines_mts(y, plot.info = plot.info, col = c(a = "red", b = "blue", c = "green"))
  overlay.rows <- named$curves[named$curves$source == "overlay", ]
  expect_identical(overlay.rows$col, c("green", "blue", "red"))

  plot.info <- plot_mts(x)
  expect_warning(
    lines_mts(y, plot.info = plot.info, col = c("red", "blue")),
    "recycling values"
  )
})

test_that("repeated lines_mts calls accumulate curve registry rows", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(a = 2:11, b = 10:19))
  z <- stats::ts(cbind(a = 3:12, b = 9:18))

  plot.info <- plot_mts(x)
  plot.info <- lines_mts(y, plot.info = plot.info, source = "y")
  plot.info <- lines_mts(z, plot.info = plot.info, source = "z")

  expect_equal(nrow(plot.info$curves), 6)
  expect_identical(plot.info$curves$source, c("base", "base", "y", "y", "z", "z"))
})

test_that("plot_mts_overlay handles one or more overlays", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(a = 2:11, b = 10:19))
  z <- stats::ts(cbind(a = 3:12, b = 9:18))

  one <- plot_mts_overlay(x, y)
  expect_equal(nrow(one$curves), 4)
  expect_identical(one$curves$object.index, c(0L, 0L, 1L, 1L))
  expect_identical(one$curves$source, c("base", "base", "overlay1", "overlay1"))

  many <- plot_mts_overlay(x, y, z, overlay.names = c("first", "second"))
  expect_equal(nrow(many$curves), 6)
  expect_identical(many$curves$object.index, c(0L, 0L, 1L, 1L, 2L, 2L))
  expect_identical(many$curves$source, c("base", "base", "first", "first", "second", "second"))
})

test_that("plot_mts_overlay validates arguments", {
  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(a = 2:11, b = 10:19))

  expect_error(plot_mts_overlay(x), "At least one overlay")
  expect_error(plot_mts_overlay(x, y, y, overlay.names = "one-too-short"), "`overlay.names`")
  expect_error(plot_mts_overlay(x, y, plot.args = 1), "`plot.args`")
  expect_error(plot_mts_overlay(x, y, lines.args = 1), "`lines.args`")
})

test_that("plot_mts and lines_mts validate inputs", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(a = 2:11, b = 10:19))

  expect_error(plot_mts(x, columns = "missing"), "Unknown column name")
  expect_error(plot_mts(x, nrow = 1, ncol = 1), "enough cells")
  expect_error(plot_mts(cbind(a = letters[1:3])), "numeric")

  plot.info <- plot_mts(x)
  expect_error(lines_mts(y, plot.info = list()), "`plot.info`")
})
