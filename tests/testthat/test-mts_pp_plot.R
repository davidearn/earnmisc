test_that("phase-plane helpers are exported", {
  exports <- getNamespaceExports("earnmisc")
  expect_true(all(c("pp_plot", "pp_lines", "mts_pp_plot", "mts_pp_lines") %in% exports))
})

test_that("phase-plane pair selection uses unordered pairs by default", {
  pairs <- resolve_pp_pairs(
    column.names = c("x", "y", "z"),
    ncol = 3L
  )

  expect_identical(pairs$h.var, c("x", "x", "y"))
  expect_identical(pairs$v.var, c("y", "z", "z"))
  expect_identical(pairs$h.column, c(1L, 1L, 2L))
  expect_identical(pairs$v.column, c(2L, 3L, 3L))
})

test_that("phase-plane pair selection supports h.var and v.var vectors", {
  pairs <- resolve_pp_pairs(
    h.var = c("x", "y"),
    v.var = c("y", "z"),
    column.names = c("x", "y", "z"),
    ncol = 3L
  )

  expect_identical(pairs$h.var, c("x", "x", "y"))
  expect_identical(pairs$v.var, c("y", "z", "z"))
  expect_error(
    resolve_pp_pairs(h.var = "x", column.names = c("x", "y"), ncol = 2L),
    "both `h.var` and `v.var`"
  )
  expect_error(
    resolve_pp_pairs(h.var = "x", v.var = "x", column.names = c("x", "y"), ncol = 2L),
    "No non-identical"
  )
})

test_that("phase-plane pair selection supports explicit pairs", {
  matrix.pairs <- resolve_pp_pairs(
    pairs = matrix(c("z", "x", "x", "y"), ncol = 2L),
    column.names = c("x", "y", "z"),
    ncol = 3L
  )
  expect_identical(matrix.pairs$h.var, c("z", "x"))
  expect_identical(matrix.pairs$v.var, c("x", "y"))

  frame.pairs <- resolve_pp_pairs(
    pairs = data.frame(h.var = c("y", "x"), v.var = c("y", "z")),
    column.names = c("x", "y", "z"),
    ncol = 3L
  )
  expect_identical(frame.pairs$h.var, c("y", "x"))
  expect_identical(frame.pairs$v.var, c("y", "z"))

  list.pairs <- resolve_pp_pairs(
    pairs = list(c("z", "x"), list(h.var = 2L, v.var = 3L)),
    column.names = c("x", "y", "z"),
    ncol = 3L
  )
  expect_identical(list.pairs$h.var, c("z", "y"))
  expect_identical(list.pairs$v.var, c("x", "z"))
})

test_that("mts_pp_plot limits excessive panel counts informatively", {
  x <- stats::ts(matrix(seq_len(100), nrow = 10, ncol = 10))

  expect_error(
    mts_pp_plot(x),
    "Phase-plane plot would require 45 panels, which exceeds max.panels = 16.*max.panels = 45"
  )
})

test_that("mts_pp_plot returns metadata and mts_pp_lines overlays with plot info", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  time <- seq(0, 2 * pi, length.out = 100)
  x <- stats::ts(cbind(
    sin = sin(time),
    cos = cos(time),
    decay = exp(-time / 4)
  ))

  result <- withVisible(mts_pp_plot(x, h.var = "sin", v.var = "cos"))
  expect_false(result$visible)
  plot.info <- result$value
  expect_s3_class(plot.info, "earnmisc_pp_plot_info")
  expect_true(all(c("pairs", "layout", "xlim", "ylim", "labels", "panels", "curves") %in% names(plot.info)))
  expect_identical(plot.info$pairs$h.var, "sin")
  expect_identical(plot.info$pairs$v.var, "cos")
  expect_equal(nrow(plot.info$curves), 1L)
  expect_identical(plot.info$curves$object.index, 0L)

  updated <- mts_pp_lines(x, plot.info = plot.info, lty = 2)
  expect_s3_class(updated, "earnmisc_pp_plot_info")
  expect_equal(nrow(updated$curves), 2L)
  expect_identical(updated$curves$object.index, c(0L, 1L))
  expect_identical(updated$curves$pair.name, c("sin-cos", "sin-cos"))
  expect_identical(updated$curves$lty, c("1", "2"))
})

test_that("mts_pp_lines can infer pairs without plot info for simple overlays", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  time <- seq(0, 2 * pi, length.out = 100)
  x <- stats::ts(cbind(sin = sin(time), cos = cos(time)))
  graphics::plot.default(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))

  plot.info <- mts_pp_lines(x, h.var = "sin", v.var = "cos")

  expect_s3_class(plot.info, "earnmisc_pp_plot_info")
  expect_identical(plot.info$pairs$h.var, "sin")
  expect_identical(plot.info$pairs$v.var, "cos")
  expect_equal(nrow(plot.info$curves), 1L)
  expect_identical(plot.info$curves$object.index, 0L)
})

test_that("phase-plane label map is applied through nice_text", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  time <- seq(0, 2 * pi, length.out = 100)
  x <- stats::ts(cbind(sin = sin(time), cos = cos(time)))
  labels <- c(sin = "$s$", cos = "$c$")
  plot.info <- mts_pp_plot(
    x,
    h.var = "sin",
    v.var = "cos",
    label.map = labels,
    use.tikz = TRUE
  )

  expect_identical(plot.info$labels$h.raw, "$s$")
  expect_identical(plot.info$labels$v.raw, "$c$")
  expect_identical(plot.info$labels$h.label[[1L]], "$s$")
  expect_identical(plot.info$labels$v.label[[1L]], "$c$")
})

test_that("pp_plot and pp_lines dispatch for mts objects", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  time <- seq(0, 2 * pi, length.out = 100)
  x <- stats::ts(cbind(sin = sin(time), cos = cos(time)))

  plot.info <- pp_plot(x, h.var = "sin", v.var = "cos")
  expect_s3_class(plot.info, "earnmisc_pp_plot_info")

  updated <- pp_lines(x, plot.info = plot.info, lty = 2)
  expect_s3_class(updated, "earnmisc_pp_plot_info")
  expect_equal(nrow(updated$curves), 2L)
})
