test_that("xys_line is an S3 generic", {
  expect_true(utils::isS3stdGeneric("xys_line"))
  expect_identical(names(formals(xys_line)), c("object", "..."))
  expect_true(is.function(xys_line.default))
})

test_that("xys_line scalar input returns parameters invisibly", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(1:10, 1:10)

  result <- withVisible(xys_line(3, 4, slope = 2))

  expect_false(result$visible)
  expect_identical(result$value, c(intercept = -2, slope = 2))
})

test_that("xys_line preserves named x-coordinate calls", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(1:10, 1:10)

  result <- withVisible(xys_line(x = 3, y = 4, slope = 2))

  expect_false(result$visible)
  expect_identical(result$value, c(intercept = -2, slope = 2))
})

test_that("xys_line.default preserves scalar input behaviour", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(1:10, 1:10)

  result <- withVisible(xys_line.default(3, 4, slope = 2))

  expect_false(result$visible)
  expect_identical(result$value, c(intercept = -2, slope = 2))

  named.result <- withVisible(xys_line.default(x = 3, y = 4, slope = 2))
  expect_false(named.result$visible)
  expect_identical(named.result$value, c(intercept = -2, slope = 2))
})

test_that("xys_line dispatches to class methods", {
  method <- function(object, ...) "dispatched"
  registerS3method(
    "xys_line",
    "test_xys_line",
    method,
    envir = asNamespace("earnmisc")
  )

  x <- structure(1, class = "test_xys_line")

  expect_identical(xys_line(x), "dispatched")
})

test_that("xys_line scalar infinite slope returns vertical line parameters invisibly", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))

  result <- withVisible(xys_line(0.5, 0, slope = Inf))

  expect_false(result$visible)
  expect_identical(result$value, c(intercept = NA_real_, slope = Inf))
})

test_that("xys_line handles one vector argument", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(0:1, 0:1, type = "n")

  result <- withVisible(xys_line(0, c(0.1, -0.1), slope = 1))

  expect_false(result$visible)
  expect_s3_class(result$value, "data.frame")
  expect_identical(result$value$x, c(0, 0))
  expect_identical(result$value$y, c(0.1, -0.1))
  expect_identical(result$value$slope, c(1, 1))
  expect_identical(result$value$intercept, c(0.1, -0.1))
})

test_that("xys_line expands vector graphical parameters", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))

  result <- withVisible(
    xys_line(
      0,
      c(0.1, -0.1),
      slope = 1,
      col = c("blue", "red"),
      lty = c("solid", "dotted"),
      lwd = c(1, 2)
    )
  )
  graphics.parameters <- attr(result$value, "graphics.parameters")

  expect_false(result$visible)
  expect_identical(graphics.parameters$col, c("blue", "red"))
  expect_identical(graphics.parameters$lty, c("solid", "dotted"))
  expect_identical(graphics.parameters$lwd, c(1, 2))
})

test_that("xys_line recycles scalar graphical parameters", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))

  result <- withVisible(
    xys_line(
      0,
      c(0.1, -0.1),
      slope = 1,
      col = "blue",
      lty = "solid",
      lwd = 2
    )
  )
  graphics.parameters <- attr(result$value, "graphics.parameters")

  expect_false(result$visible)
  expect_identical(graphics.parameters$col, c("blue", "blue"))
  expect_identical(graphics.parameters$lty, c("solid", "solid"))
  expect_identical(graphics.parameters$lwd, c(2, 2))
})

test_that("xys_line handles all combinations of vector arguments", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(0:1, 0:1, type = "n")

  result <- withVisible(xys_line(x = c(0, 1), y = c(0.1, -0.1), slope = c(1, 2)))

  expected <- expand.grid(
    x = c(0, 1),
    y = c(0.1, -0.1),
    slope = c(1, 2),
    KEEP.OUT.ATTRS = FALSE
  )
  expected$intercept <- expected$y - expected$slope * expected$x

  expect_false(result$visible)
  attr(expected, "graphics.parameters") <- list()
  expect_identical(result$value, expected)
})

test_that("xys_line handles vectorised infinite slopes", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))

  result <- withVisible(
    xys_line(
      c(-0.5, 0.5),
      0,
      slope = Inf,
      col = c("blue", "red"),
      lty = c("solid", "dotted")
    )
  )

  expect_false(result$visible)
  expect_identical(result$value$x, c(-0.5, 0.5))
  expect_identical(result$value$y, c(0, 0))
  expect_identical(result$value$slope, c(Inf, Inf))
  expect_identical(result$value$intercept, c(NA_real_, NA_real_))
  expect_identical(attr(result$value, "graphics.parameters")$col, c("blue", "red"))
  expect_identical(attr(result$value, "graphics.parameters")$lty, c("solid", "dotted"))
})

test_that("xys_line handles mixed finite and infinite slopes", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))

  result <- withVisible(
    xys_line(
      0,
      0,
      slope = c(1, Inf, -Inf),
      col = c("blue", "red", "black"),
      lty = c("solid", "dotted", "dashed")
    )
  )

  expect_false(result$visible)
  expect_identical(result$value$x, c(0, 0, 0))
  expect_identical(result$value$y, c(0, 0, 0))
  expect_identical(result$value$slope, c(1, Inf, -Inf))
  expect_identical(result$value$intercept, c(0, NA_real_, NA_real_))
  expect_identical(
    attr(result$value, "graphics.parameters")$col,
    c("blue", "red", "black")
  )
  expect_identical(
    attr(result$value, "graphics.parameters")$lty,
    c("solid", "dotted", "dashed")
  )
})

test_that("xys_line validates numeric vector inputs", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(1:10, 1:10)

  expect_error(xys_line(character(), 1, 1), "`x`")
  expect_error(xys_line(NA_real_, 1, 1), "`x`")
  expect_error(xys_line(1, NA_real_, 1), "`y`")
  expect_error(xys_line(1, 1, NA_real_), "`slope`")
})
