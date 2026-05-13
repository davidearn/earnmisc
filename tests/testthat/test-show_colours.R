test_that("show_colours returns colours invisibly", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  colours <- c(red = "red", blue = "blue")
  result <- withVisible(show_colours(colours))

  expect_false(result$visible)
  expect_identical(result$value, colours)
})

test_that("show_colours handles unnamed colours and missing labels", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  colours <- c("#000000", "#FFFFFF")

  expect_silent(show_colours(colours))
  expect_silent(show_colours(colours, labels = NULL))
})

test_that("show_colours handles named colours and explicit layout", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  colours <- c(first = "red", second = "blue", third = "green")

  expect_silent(show_colours(colours, nrow = 1))
  expect_silent(show_colours(colours, ncol = 1))
  expect_silent(show_colours(colours, nrow = 2, ncol = 2))
})

test_that("colour_grid_dims chooses enough cells", {
  expect_identical(colour_grid_dims(10), list(nrow = 3L, ncol = 4L))
  expect_identical(colour_grid_dims(5, nrow = 2), list(nrow = 2L, ncol = 3L))
  expect_identical(colour_grid_dims(5, ncol = 2), list(nrow = 3L, ncol = 2L))
  expect_error(colour_grid_dims(5, nrow = 2, ncol = 2), "enough cells")
})

test_that("colour_text_contrast chooses black or white text", {
  expect_identical(colour_text_contrast(c("#000000", "#FFFFFF")), c("white", "black"))
})

test_that("show_colours restores graphics parameters after success", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)
  old.mar <- graphics::par("mar")

  show_colours(c(red = "red", blue = "blue"), mar = c(1, 1, 1, 1))

  expect_identical(graphics::par("mar"), old.mar)
})

test_that("show_colours restores graphics parameters after invalid plotting input", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)
  old.mar <- graphics::par("mar")

  expect_error(show_colours(c(red = "red"), labels = c("a", "b")), "`labels`")
  expect_identical(graphics::par("mar"), old.mar)
})

test_that("show_colours errors clearly for invalid colours", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)
  old.mar <- graphics::par("mar")

  expect_error(show_colours("not-a-colour"), "Invalid R colour")
  expect_identical(graphics::par("mar"), old.mar)
})

test_that("show_oi_colours returns default extended palette invisibly", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  result <- withVisible(show_oi_colours())

  expect_false(result$visible)
  expect_identical(result$value, okabe_ito_colours(extended = TRUE))
})

test_that("show_oi_colours supports original palette and alpha", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  original.result <- withVisible(show_oi_colours(extended = FALSE))
  alpha.result <- withVisible(show_oi_colours(alpha = 0.5))

  expect_identical(original.result$value, okabe_ito_colours(extended = FALSE))
  expect_identical(alpha.result$value, okabe_ito_colours(alpha = 0.5))
})
