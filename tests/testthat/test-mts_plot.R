test_that("plot_mts returns plot metadata and base curve registry", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  result <- withVisible(plot_mts(x))

  expect_false(result$visible)
  plot.info <- result$value
  expect_s3_class(plot.info, "earnmisc_mts_plot_info")
  expect_true(all(c("panel.order", "column.names", "layout", "device", "usr", "mfg", "xlim", "ylim", "blank.panels", "data.panels", "panel.roles", "panels", "curves") %in% names(plot.info)))
  expect_identical(plot.info$column.names, c("a", "b"))
  expect_identical(plot.info$panel.order, 1:2)
  expect_null(plot.info$blank.panels)
  expect_identical(plot.info$data.panels, 1:2)
  expect_identical(plot.info$panel.roles, c("data", "data"))
  expect_equal(nrow(plot.info$curves), 2)
  expect_identical(plot.info$curves$source, c("x", "x"))
  expect_true("source.label" %in% names(plot.info$curves))
  expect_identical(plot.info$curves$source.label[[1L]], "x")
  expect_identical(plot.info$curves$object.index, c(0L, 0L))
  expect_true(all(plot.info$curves$drawn))
  expect_true(all(is.na(plot.info$curves$reason)))
})

test_that("plot_mts reserves blank panels and records data panels", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))

  first.blank <- plot_mts(x, blank.panels = 1)
  expect_identical(first.blank$blank.panels, 1L)
  expect_identical(first.blank$data.panels, c(2L, 3L, 4L))
  expect_identical(first.blank$panel.roles, c("blank", "data", "data", "data"))
  expect_identical(first.blank$curves$panel.index, c(2L, 3L, 4L))

  middle.blank <- plot_mts(x, blank.panels = 2)
  expect_identical(middle.blank$blank.panels, 2L)
  expect_identical(middle.blank$data.panels, c(1L, 3L, 4L))
  expect_identical(middle.blank$panel.roles, c("data", "blank", "data", "data"))
  expect_identical(middle.blank$curves$panel.index, c(1L, 3L, 4L))

  final.blank <- plot_mts(x, blank.panels = 4)
  expect_identical(final.blank$blank.panels, 4L)
  expect_identical(final.blank$data.panels, c(1L, 2L, 3L))
  expect_identical(final.blank$panel.roles, c("data", "data", "data", "blank"))
  expect_identical(final.blank$curves$panel.index, c(1L, 2L, 3L))

  multiple.blank <- plot_mts(x, blank.panels = c(1, 4))
  expect_identical(multiple.blank$blank.panels, c(1L, 4L))
  expect_identical(multiple.blank$data.panels, c(2L, 3L, 5L))
  expect_identical(multiple.blank$panel.roles, c("blank", "data", "data", "blank", "data"))
  expect_identical(multiple.blank$curves$panel.index, c(2L, 3L, 5L))
})

test_that("plot_mts validates blank panels", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))

  expect_error(plot_mts(x, blank.panels = c(1, 1)), "unique")
  expect_error(plot_mts(x, blank.panels = 0), "positive")
  expect_error(plot_mts(x, blank.panels = -1), "positive")
  expect_error(plot_mts(x, blank.panels = 1.5), "positive integer")
  expect_error(plot_mts(x, blank.panels = 5), "outside")
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
  overlay.rows <- by.name$curves[by.name$curves$object.index == 1L, ]
  expect_identical(overlay.rows$name, c("b", "a"))
  expect_identical(overlay.rows$panel.index, c(2L, 1L))

  plot.info <- plot_mts(x)
  by.position <- lines_mts(y, plot.info = plot.info, match = "position")
  overlay.rows <- by.position$curves[by.position$curves$object.index == 1L, ]
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
  overlay.rows <- warned$curves[warned$curves$object.index == 1L, ]
  expect_identical(overlay.rows$drawn, c(TRUE, FALSE))
  expect_identical(overlay.rows$reason, c(NA_character_, "unmatched"))

  plot.info <- plot_mts(x)
  expect_error(lines_mts(y, plot.info = plot.info, unmatched = "error"), "Unmatched mts column")

  plot.info <- plot_mts(x)
  expect_silent(ignored <- lines_mts(y, plot.info = plot.info, unmatched = "ignore"))
  overlay.rows <- ignored$curves[ignored$curves$object.index == 1L, ]
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
  overlay.rows <- restricted$curves[restricted$curves$object.index == 1L, ]
  expect_equal(nrow(overlay.rows), 1)
  expect_identical(overlay.rows$name, "b")
  expect_identical(overlay.rows$col, "red")
  expect_identical(overlay.rows$lty, "2")
  expect_identical(overlay.rows$lwd, 3)

  plot.info <- plot_mts(x)
  vectorised <- lines_mts(y, plot.info = plot.info, col = c("red", "blue", "green"), lty = c(1, 2, 3))
  overlay.rows <- vectorised$curves[vectorised$curves$object.index == 1L, ]
  expect_identical(overlay.rows$col, c("red", "blue", "green"))
  expect_identical(overlay.rows$lty, c("1", "2", "3"))

  plot.info <- plot_mts(x)
  named <- lines_mts(y, plot.info = plot.info, col = c(a = "red", b = "blue", c = "green"))
  overlay.rows <- named$curves[named$curves$object.index == 1L, ]
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
  expect_identical(plot.info$curves$source, c("x", "x", "y", "y", "z", "z"))
})

test_that("plot_mts and lines_mts infer and override source labels", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  m <- list(
    stats::ts(cbind(a = 1:10, b = 11:20)),
    stats::ts(cbind(a = 2:11, b = 10:19)),
    stats::ts(cbind(a = 3:12, b = 9:18))
  )

  plot.info <- plot_mts(m[[3]], blank.panels = 1)
  expect_identical(unique(plot.info$curves$source), "m[[3]]")

  plot.info <- lines_mts(m[[2]], plot.info = plot.info)
  plot.info <- lines_mts(m[[1]], plot.info = plot.info)
  expect_identical(unique(plot.info$curves$source), c("m[[3]]", "m[[2]]", "m[[1]]"))
  expect_identical(unique(plot.info$curves$object.index), c(0L, 1L, 2L))

  by.source <- legend_mts(plot.info, by = "source")
  expect_identical(by.source$legend, c("m[[3]]", "m[[2]]", "m[[1]]"))
  expect_equal(nrow(by.source$curves), 3)

  explicit <- legend_mts(
    plot.info,
    by = "source",
    legend = c("R0 = 8", "R0 = 4", "R0 = 2")
  )
  expect_identical(explicit$legend, c("R0 = 8", "R0 = 4", "R0 = 2"))

  labelled <- plot_mts(m[[3]], source = "R0 = 8")
  expect_identical(unique(labelled$curves$source), "R0 = 8")
  labelled <- lines_mts(m[[2]], plot.info = labelled, source = "R0 = 4")
  expect_identical(unique(labelled$curves$source), c("R0 = 8", "R0 = 4"))
})

test_that("source labels preserve expression-like legend labels", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  m <- list(
    stats::ts(cbind(a = 1:10, b = 11:20)),
    stats::ts(cbind(a = 2:11, b = 10:19)),
    stats::ts(cbind(a = 3:12, b = 9:18))
  )

  plot.info <- plot_mts(m[[3]], source = expression(R[0] == 8), blank.panels = 1)
  plot.info <- lines_mts(m[[2]], plot.info = plot.info, source = expression(R[0] == 4))
  plot.info <- lines_mts(m[[1]], plot.info = plot.info, source = expression(R[0] == 2))

  expect_type(plot.info$curves$source, "character")
  expect_true(inherits(plot.info$curves$source.label[[1L]], "expression"))
  expect_identical(length(plot.info$curves$source.label[[1L]]), 1L)
  expect_equal(length(unique(plot.info$curves$source)), 3)

  by.source <- legend_mts(plot.info, by = "source")
  expect_true(inherits(by.source$legend, "expression"))
  expect_equal(length(by.source$legend), 3)

  explicit <- legend_mts(plot.info, by = "source", legend = c("R0 = 8", "R0 = 4", "R0 = 2"))
  expect_identical(explicit$legend, c("R0 = 8", "R0 = 4", "R0 = 2"))
})

test_that("source labels accept nice_text expression-like labels", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(a = 2:11, b = 10:19))
  x.label <- nice_text("$R_0 = 8$")
  y.label <- nice_text("$R_0 = 4$")

  plot.info <- plot_mts(x, source = x.label, blank.panels = 1)
  plot.info <- lines_mts(y, plot.info = plot.info, source = y.label)

  expect_type(plot.info$curves$source, "character")
  expect_identical(plot.info$curves$source.label[[1L]], x.label)
  by.source <- legend_mts(plot.info, by = "source")
  if (inherits(x.label, "expression") || inherits(y.label, "expression")) {
    expect_true(inherits(by.source$legend, "expression"))
  } else {
    expect_type(by.source$legend, "character")
  }
})

test_that("invalid source labels error clearly", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(a = 2:11, b = 10:19))

  expect_error(plot_mts(x, source = ""), "`source`")
  expect_error(plot_mts(x, source = c("a", "b")), "`source`")
  expect_error(plot_mts(x, source = expression(a, b)), "`source`")
  expect_error(plot_mts(x, source = list("a")), "`source`")

  plot.info <- plot_mts(x)
  expect_error(lines_mts(y, plot.info = plot.info, source = ""), "`source`")
  expect_error(lines_mts(y, plot.info = plot.info, source = expression(a, b)), "`source`")
})

test_that("lines_mts overlays on data panels when blank panels are present", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))
  y <- stats::ts(cbind(c = 20:29, b = 10:19, a = 2:11))
  z <- stats::ts(cbind(a = 3:12, b = 9:18, c = 19:28))

  plot.info <- plot_mts(x, blank.panels = c(1, 4))
  plot.info <- lines_mts(y, plot.info = plot.info)
  overlay.rows <- plot.info$curves[plot.info$curves$object.index == 1L, ]
  expect_identical(overlay.rows$name, c("c", "b", "a"))
  expect_identical(overlay.rows$panel.index, c(5L, 3L, 2L))

  plot.info <- lines_mts(z, plot.info = plot.info, source = "z")
  expect_equal(nrow(plot.info$curves), 9)
  z.rows <- plot.info$curves[plot.info$curves$source == "z", ]
  expect_identical(z.rows$panel.index, c(2L, 3L, 5L))
})

test_that("abline_mts requires plot info and uses stored plot info", {
  old.last <- mts_plot_store$last
  on.exit(mts_plot_store$last <- old.last, add = TRUE)

  mts_plot_store$last <- NULL
  expect_error(abline_mts(h = 0), "requires a `plot.info` object")

  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  plot_mts(x)
  updated <- abline_mts(h = 0)

  expect_s3_class(updated, "earnmisc_mts_plot_info")
  expect_equal(nrow(updated$curves), 4)
  expect_identical(updated$curves$type, c("l", "l", "abline", "abline"))
  expect_identical(updated$curves$panel.index, c(1L, 2L, 1L, 2L))
})

test_that("abline_mts selects data panels, blank panels, and columns", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))
  plot.info <- plot_mts(x, blank.panels = 2)

  default <- abline_mts(plot.info = plot.info, h = 0)
  abline.rows <- default$curves[default$curves$type == "abline", ]
  expect_identical(abline.rows$panel.index, c(1L, 3L, 4L))

  explicit.blank <- abline_mts(plot.info = plot.info, panels = 2, h = 0)
  abline.rows <- explicit.blank$curves[explicit.blank$curves$type == "abline", ]
  expect_identical(tail(abline.rows$panel.index, 1), 2L)
  expect_true(is.na(tail(abline.rows$column, 1)))

  by.name <- abline_mts(plot.info = plot.info, columns = "b", h = 0)
  abline.rows <- by.name$curves[by.name$curves$type == "abline", ]
  expect_identical(tail(abline.rows$panel.index, 1), 3L)
  expect_identical(tail(abline.rows$name, 1), "b")

  by.index <- abline_mts(plot.info = plot.info, columns = 3, h = 0)
  abline.rows <- by.index$curves[by.index$curves$type == "abline", ]
  expect_identical(tail(abline.rows$panel.index, 1), 4L)
  expect_identical(tail(abline.rows$name, 1), "c")

  expect_error(abline_mts(plot.info = plot.info, panels = 1, columns = "a", h = 0), "Only one")
  expect_error(abline_mts(plot.info = plot.info, panels = 99, h = 0), "`panels`")
})

test_that("abline_mts handles graphical parameters by panel", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))

  plot.info <- plot_mts(x)
  scalar <- abline_mts(plot.info = plot.info, h = 0, col = "grey70", lty = 2, lwd = 3)
  abline.rows <- scalar$curves[scalar$curves$type == "abline", ]
  expect_identical(abline.rows$col, rep("grey70", 3))
  expect_identical(abline.rows$lty, rep("2", 3))
  expect_identical(abline.rows$lwd, rep(3, 3))

  plot.info <- plot_mts(x)
  vectorised <- abline_mts(plot.info = plot.info, h = 0, col = c("red", "blue", "green"), lty = c(1, 2, 3))
  abline.rows <- vectorised$curves[vectorised$curves$type == "abline", ]
  expect_identical(abline.rows$col, c("red", "blue", "green"))
  expect_identical(abline.rows$lty, c("1", "2", "3"))

  plot.info <- plot_mts(x)
  named <- abline_mts(plot.info = plot.info, h = 0, col = c(a = "red", b = "blue", c = "green"))
  abline.rows <- named$curves[named$curves$type == "abline", ]
  expect_identical(abline.rows$col, c("red", "blue", "green"))

  plot.info <- plot_mts(x)
  expect_warning(
    abline_mts(plot.info = plot.info, h = 0, col = c("red", "blue")),
    "recycling values"
  )
})

test_that("abline_mts accepts standard abline modes", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  plot.info <- plot_mts(x)

  expect_silent(abline_mts(plot.info = plot.info, a = 0, b = 1, record = FALSE))
  expect_silent(abline_mts(plot.info = plot.info, h = 0, record = FALSE))
  expect_silent(abline_mts(plot.info = plot.info, v = 1, record = FALSE))
  expect_silent(abline_mts(plot.info = plot.info, coef = c(0, 1), record = FALSE))
  expect_silent(abline_mts(plot.info = plot.info, reg = stats::lm(1:10 ~ seq_len(10)), record = FALSE))
})

test_that("abline_mts records and skips registry rows according to record", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  plot.info <- plot_mts(x)

  unrecorded <- abline_mts(plot.info = plot.info, h = 0, record = FALSE)
  expect_equal(nrow(unrecorded$curves), 2)

  recorded <- abline_mts(plot.info = plot.info, h = 0, record = TRUE)
  expect_equal(nrow(recorded$curves), 4)
  expect_identical(recorded$curves$type, c("l", "l", "abline", "abline"))
  expect_identical(recorded$curves$source[3:4], c("abline", "abline"))
  expect_identical(recorded$curves$object.index, c(0L, 0L, 1L, 1L))

  repeated <- abline_mts(plot.info = recorded, v = 1)
  expect_equal(nrow(repeated$curves), 6)
  expect_identical(repeated$curves$object.index, c(0L, 0L, 1L, 1L, 2L, 2L))
})

test_that("abline_mts supports flexible source labels", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))

  plot.info <- plot_mts(x)
  character.source <- abline_mts(plot.info = plot.info, h = 0, source = "zero")
  abline.rows <- character.source$curves[character.source$curves$type == "abline", ]
  expect_identical(unique(abline.rows$source), "zero")
  expect_identical(abline.rows$source.label[[1L]], "zero")

  plot.info <- plot_mts(x)
  expression.source <- abline_mts(plot.info = plot.info, h = 0, source = expression(y == 0))
  abline.rows <- expression.source$curves[expression.source$curves$type == "abline", ]
  expect_true(inherits(abline.rows$source.label[[1L]], "expression"))

  plot.info <- plot_mts(x)
  nice.source <- nice_text("$y = 0$")
  nice <- abline_mts(plot.info = plot.info, h = 0, source = nice.source)
  abline.rows <- nice$curves[nice$curves$type == "abline", ]
  expect_identical(abline.rows$source.label[[1L]], nice.source)
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
  expect_identical(one$curves$source, c("x", "x", "y", "y"))

  many <- plot_mts_overlay(x, y, z, overlay.names = c("first", "second"))
  expect_equal(nrow(many$curves), 6)
  expect_identical(many$curves$object.index, c(0L, 0L, 1L, 1L, 2L, 2L))
  expect_identical(many$curves$source, c("x", "x", "first", "first", "second", "second"))
})

test_that("plot_mts_overlay derives and overrides source labels", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  m <- list(
    stats::ts(cbind(a = 1:10, b = 11:20)),
    stats::ts(cbind(a = 2:11, b = 10:19)),
    stats::ts(cbind(a = 3:12, b = 9:18))
  )

  inferred <- plot_mts_overlay(m[[3]], m[[2]], m[[1]])
  expect_identical(unique(inferred$curves$source), c("m[[3]]", "m[[2]]", "m[[1]]"))
  expect_identical(unique(inferred$curves$object.index), c(0L, 1L, 2L))

  labelled <- plot_mts_overlay(
    m[[3]],
    m[[2]],
    m[[1]],
    source.x = "R0 = 8",
    overlay.names = c("R0 = 4", "R0 = 2")
  )
  expect_identical(unique(labelled$curves$source), c("R0 = 8", "R0 = 4", "R0 = 2"))
  expect_identical(unique(labelled$curves$object.index), c(0L, 1L, 2L))

  expression.labels <- plot_mts_overlay(
    m[[3]],
    m[[2]],
    m[[1]],
    source.x = expression(R[0] == 8),
    overlay.names = expression(R[0] == 4, R[0] == 2),
    plot.args = list(blank.panels = 1)
  )
  expect_type(expression.labels$curves$source, "character")
  expect_equal(length(unique(expression.labels$curves$source)), 3)
  expect_true(inherits(expression.labels$curves$source.label[[1L]], "expression"))
  by.source <- legend_mts(expression.labels, by = "source")
  expect_true(inherits(by.source$legend, "expression"))
  expect_equal(length(by.source$legend), 3)
})

test_that("plot_mts_overlay passes blank panels through plot.args", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))
  y <- stats::ts(cbind(a = 2:11, b = 10:19, c = 20:29))

  plot.info <- plot_mts_overlay(x, y, plot.args = list(blank.panels = 1))

  expect_identical(plot.info$blank.panels, 1L)
  expect_identical(plot.info$data.panels, c(2L, 3L, 4L))
  expect_identical(plot.info$curves$panel.index, c(2L, 3L, 4L, 2L, 3L, 4L))
})

test_that("set_mts_panel works with explicit and stored plot info", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))
  plot.info <- plot_mts(x, blank.panels = 1)

  explicit <- withVisible(set_mts_panel(1, plot.info, xlim = c(-1, 1), ylim = c(2, 3), axes = TRUE, xaxs = "r", yaxs = "r"))
  expect_false(explicit$visible)
  expect_identical(explicit$value$panel.index, 1L)
  expect_identical(explicit$value$xlim, c(-1, 1))
  expect_identical(explicit$value$ylim, c(2, 3))

  stored <- set_mts_panel(1)
  expect_identical(stored$panel.index, 1L)
  expect_error(set_mts_panel(99, plot.info), "valid full-layout panel")
})

test_that("legend_mts builds legends from curve registry", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))
  y <- stats::ts(cbind(a = 2:11, b = 10:19, c = 20:29))
  plot.info <- plot_mts(x, blank.panels = 1)
  plot.info <- lines_mts(y, plot.info = plot.info, source = "overlay")

  by.source <- withVisible(legend_mts(plot.info))
  expect_false(by.source$visible)
  expect_identical(by.source$value$panel, 1L)
  expect_identical(by.source$value$by, "source")
  expect_identical(by.source$value$legend, c("x", "overlay"))
  expect_equal(nrow(by.source$value$curves), 2)

  by.column <- legend_mts(plot.info, by = "column", panel = 1)
  expect_identical(by.column$legend, c("a", "b", "c"))

  by.curve <- legend_mts(plot.info, by = "curve", panel = 1)
  expect_identical(by.curve$legend, c("x: a", "x: b", "x: c", "overlay: a", "overlay: b", "overlay: c"))

  explicit <- legend_mts(plot.info, panel = 1, legend = c("x", "y"), col = c("red", "blue"), lty = c(1, 2), lwd = c(2, 3))
  expect_identical(explicit$legend, c("x", "y"))
  expect_identical(explicit$col, c("red", "blue"))
  expect_identical(explicit$lty, c(1, 2))
  expect_identical(explicit$lwd, c(2, 3))
})

test_that("legend_mts requires a panel when no blank panel exists", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  plot.info <- plot_mts(x)

  expect_error(legend_mts(plot.info), "reserved `blank.panels`")
  expect_silent(legend_mts(plot.info, panel = 1))
})

test_that("plot_mts_overlay lets plot.args override base defaults", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(a = 2:11, b = 10:19))

  colour.override <- oi.blue
  lty.override <- 3
  lwd.override <- 4
  plot.info <- plot_mts_overlay(
    x,
    y,
    col.x = "black",
    lty.x = 1,
    lwd.x = 1,
    plot.args = list(col = colour.override, lty = lty.override, lwd = lwd.override)
  )
  base.rows <- plot.info$curves[plot.info$curves$object.index == 0L, ]

  expect_identical(base.rows$col, rep(colour.override, 2))
  expect_identical(base.rows$lty, rep(as.character(lty.override), 2))
  expect_identical(base.rows$lwd, rep(lwd.override, 2))
})

test_that("plot_mts_overlay lets lines.args override overlay defaults", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(a = 2:11, b = 10:19))

  colour.override <- oi.orange
  lty.override <- 1
  lwd.override <- 5
  plot.info <- plot_mts_overlay(
    x,
    y,
    col.y = "red",
    lty.y = 4,
    lwd.y = 1,
    lines.args = list(col = colour.override, lty = lty.override, lwd = lwd.override)
  )
  overlay.rows <- plot.info$curves[plot.info$curves$object.index == 1L, ]

  expect_identical(overlay.rows$col, rep(colour.override, 2))
  expect_identical(overlay.rows$lty, rep(as.character(lty.override), 2))
  expect_identical(overlay.rows$lwd, rep(lwd.override, 2))
})

test_that("plot_mts_overlay validates arguments", {
  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(a = 2:11, b = 10:19))

  expect_error(plot_mts_overlay(x), "At least one overlay")
  expect_error(plot_mts_overlay(x, y, y, overlay.names = "one-too-short"), "`overlay.names`")
  expect_error(plot_mts_overlay(x, y, plot.args = 1), "`plot.args`")
  expect_error(plot_mts_overlay(x, y, lines.args = 1), "`lines.args`")
  expect_error(plot_mts_overlay(x, y, plot.args = list(x = x)), "protected argument")
  expect_error(plot_mts_overlay(x, y, plot.args = list(columns = "a")), "protected argument")
  expect_error(plot_mts_overlay(x, y, plot.args = list(source = "manual")), "protected argument")
})

test_that("plot_mts_overlay validates protected lines.args", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- stats::ts(cbind(a = 1:10, b = 11:20))
  y <- stats::ts(cbind(a = 2:11, b = 10:19))

  expect_error(plot_mts_overlay(x, y, lines.args = list(y = y)), "protected argument")
  expect_error(plot_mts_overlay(x, y, lines.args = list(plot.info = list())), "protected argument")
  expect_error(plot_mts_overlay(x, y, lines.args = list(columns = "a")), "protected argument")
  expect_error(plot_mts_overlay(x, y, lines.args = list(source = "manual")), "protected argument")
  expect_error(plot_mts_overlay(x, y, lines.args = list(object.index = 99L)), "protected argument")
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
