test_that("xys_line draws the requested line and returns parameters invisibly", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(1:10, 1:10)

  result <- withVisible(xys_line(3, 4, slope = 2))

  expect_false(result$visible)
  expect_identical(result$value, c(intercept = -2, slope = 2))
})

test_that("xys_line validates scalar numeric inputs", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(1:10, 1:10)

  expect_error(xys_line(c(1, 2), 1, 1), "`x`")
  expect_error(xys_line(1, c(1, 2), 1), "`y`")
  expect_error(xys_line(1, 1, c(1, 2)), "`slope`")
  expect_error(xys_line(NA_real_, 1, 1), "`x`")
})
