test_that("xys_line scalar input returns parameters invisibly", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(1:10, 1:10)

  result <- withVisible(xys_line(3, 4, slope = 2))

  expect_false(result$visible)
  expect_identical(result$value, c(intercept = -2, slope = 2))
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
  expect_identical(result$value, expected)
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
