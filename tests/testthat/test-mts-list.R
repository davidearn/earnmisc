test_that("mts_list constructs native-grid objects", {
  expect_true("mts_list" %in% getNamespaceExports("earnmisc"))

  x <- mts_list(
    list(first = c(1, 2, 3), second = c(4, 5, 6, 7)),
    time = list(first = c(0, 1, 2), second = c(0, 2, 4, 6))
  )

  expect_s3_class(x, "mts_list")
  expect_s3_class(x, "list")
  expect_equal(length(x), 2L)
  expect_equal(names(x), c("first", "second"))
  expect_equal(x$first$time, c(0, 1, 2))
  expect_equal(x$second$value, c(4, 5, 6, 7))
})

test_that("mts_list validates time and value lengths", {
  expect_error(
    mts_list(list(a = 1:3), time = list(a = 1:2)),
    "mismatched time and value lengths"
  )
  expect_error(
    mts_list(list(a = c(1, Inf))),
    "non-finite series values"
  )
  expect_error(
    mts_list(list(a = 1:2), time = list(a = c(0, NA))),
    "non-finite time values"
  )
})

test_that("mts_plot works on native-grid mts_list objects", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- mts_list(
    list(first = c(1, 2, 3), second = c(4, 5, 6, 7)),
    time = list(first = c(0, 1, 2), second = c(0, 2, 4, 6))
  )

  result <- withVisible(mts_plot(
    x,
    nrow = 1,
    ncol = 2,
    col = c(first = "red", second = "blue"),
    lty = c(first = 1, second = 2),
    lwd = 2
  ))

  expect_false(result$visible)
  plot.info <- result$value
  expect_s3_class(plot.info, "earnmisc_mts_plot_info")
  expect_equal(plot.info$layout$nrow, 1L)
  expect_equal(plot.info$layout$ncol, 2L)
  expect_equal(plot.info$column.names, c("first", "second"))
  expect_equal(plot.info$panels[["1"]]$xlim, c(0, 2))
  expect_equal(plot.info$panels[["2"]]$xlim, c(0, 6))
  expect_equal(plot.info$curves$col, c("red", "blue"))
  expect_equal(plot.info$curves$lty, c("1", "2"))
})

test_that("mts_plot supports selected native-grid panels and blank panels", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- mts_list(
    list(a = 1:3, b = 2:5, c = 3:8),
    time = list(a = 1:3, b = 2:5, c = 3:8)
  )

  plot.info <- mts_plot(x, columns = c("c", "a"), blank.panels = 1, nrow = 1, ncol = 3)

  expect_equal(plot.info$layout$nrow, 1L)
  expect_equal(plot.info$layout$ncol, 3L)
  expect_equal(plot.info$blank.panels, 1L)
  expect_equal(plot.info$data.panels, c(2L, 3L))
  expect_equal(plot.info$column.names, c("c", "a"))
  expect_equal(plot.info$curves$panel.index, c(2L, 3L))
})

test_that("mts_lines has a native-grid mts_list method", {
  expect_true("mts_lines.mts_list" %in% methods("mts_lines"))
})

test_that("mts_lines overlays native-grid mts_list objects", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- mts_list(
    list(first = c(1, 2, 3), second = c(4, 5, 6, 7)),
    time = list(first = c(0, 1, 2), second = c(0, 2, 4, 6))
  )
  y <- mts_list(
    list(first = c(1.5, 2.5, 3.5, 4.5), second = c(4.5, 5.5, 6.5)),
    time = list(first = c(0, 0.5, 1, 2), second = c(0, 3, 6))
  )

  plot.info <- mts_plot(x, nrow = 1, ncol = 2)
  updated <- mts_lines(y, plot.info = plot.info, col = 2, lty = 2, lwd = 3)
  overlay.rows <- updated$curves[updated$curves$object.index == 1L, ]

  expect_s3_class(updated, "earnmisc_mts_plot_info")
  expect_equal(nrow(updated$curves), 4L)
  expect_equal(nrow(overlay.rows), 2L)
  expect_equal(overlay.rows$panel.index, c(1L, 2L))
  expect_equal(overlay.rows$name, c("first", "second"))
  expect_equal(overlay.rows$col, c("2", "2"))
  expect_equal(overlay.rows$lty, c("2", "2"))
  expect_equal(overlay.rows$lwd, c(3, 3))
  expect_equal(overlay.rows$type, c("l", "l"))
})

test_that("mts_lines overlays native-grid objects using stored plot info", {
  old.last <- mts_plot_store$last
  on.exit(mts_plot_store$last <- old.last, add = TRUE)

  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- mts_list(
    list(first = c(1, 2, 3), second = c(4, 5, 6, 7)),
    time = list(first = c(0, 1, 2), second = c(0, 2, 4, 6))
  )
  y <- mts_list(
    list(first = c(1.5, 2.5, 3.5), second = c(4.5, 5.5, 6.5, 7.5)),
    time = list(first = c(0, 1, 2), second = c(0, 2, 4, 6))
  )

  mts_plot(x, nrow = 1, ncol = 2)
  updated <- mts_lines(y, col = "red")

  expect_s3_class(updated, "earnmisc_mts_plot_info")
  expect_equal(nrow(updated$curves), 4L)
})

test_that("mts_lines validates native-grid overlay panel counts", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- mts_list(
    list(first = c(1, 2, 3), second = c(4, 5, 6, 7)),
    time = list(first = c(0, 1, 2), second = c(0, 2, 4, 6))
  )
  y <- mts_list(
    list(first = c(1.5, 2.5, 3.5)),
    time = list(first = c(0, 1, 2))
  )

  plot.info <- mts_plot(x, nrow = 1, ncol = 2)

  expect_error(
    mts_lines(y, plot.info = plot.info),
    "overlay series count must match plotted data panel count",
    fixed = TRUE
  )
})

test_that("mts_lines can match native-grid overlays by name", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  x <- mts_list(
    list(first = c(1, 2, 3), second = c(4, 5, 6, 7)),
    time = list(first = c(0, 1, 2), second = c(0, 2, 4, 6))
  )
  y <- mts_list(
    list(second = c(4.5, 5.5, 6.5), first = c(1.5, 2.5, 3.5, 4.5)),
    time = list(second = c(0, 3, 6), first = c(0, 0.5, 1, 2))
  )

  plot.info <- mts_plot(x, nrow = 1, ncol = 2)
  updated <- mts_lines(y, plot.info = plot.info, match = "name")
  overlay.rows <- updated$curves[updated$curves$object.index == 1L, ]

  expect_equal(overlay.rows$name, c("second", "first"))
  expect_equal(overlay.rows$panel.index, c(2L, 1L))
})
