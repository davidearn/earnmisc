test_that("named plot parameter helpers return named numeric vectors", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(1:3, 1:3)

  expect_named(named_par_usr(), c("left", "right", "bottom", "top"))
  expect_type(named_par_usr(), "double")
  expect_length(named_par_usr(), 4)

  expect_named(named_par_mar(), c("bottom", "left", "top", "right"))
  expect_type(named_par_mar(), "double")
  expect_length(named_par_mar(), 4)
})

test_that("plot_metadata returns current plot metadata", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(1:3, 1:3)

  metadata <- plot_metadata(xlim = c(1, 3), ylim = c(1, 3))

  expect_named(metadata, c("xlim", "ylim", "par.usr", "par.mar", "par.list"))
  expect_identical(metadata$xlim, c(1, 3))
  expect_identical(metadata$ylim, c(1, 3))
  expect_named(metadata$par.usr, c("left", "right", "bottom", "top"))
  expect_named(metadata$par.mar, c("bottom", "left", "top", "right"))
  expect_type(metadata$par.list, "list")
})
