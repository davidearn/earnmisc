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

  old.mfrow <- graphics::par("mfrow")
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
  expect_equal(graphics::par("mfrow"), old.mfrow)
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
