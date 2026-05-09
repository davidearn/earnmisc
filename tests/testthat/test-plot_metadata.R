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

test_that("named_par_list preserves par entries and names common vectors", {
  grDevices::pdf(file = NULL)
  on.exit(grDevices::dev.off())
  graphics::plot(1:3, 1:3)

  raw.par.list <- graphics::par(no.readonly = TRUE)
  par.list <- named_par_list()

  expect_setequal(names(par.list), names(raw.par.list))
  expect_named(par.list$usr, c("left", "right", "bottom", "top"))
  expect_named(par.list$mar, c("bottom", "left", "top", "right"))
  expect_named(par.list$oma, c("bottom", "left", "top", "right"))
  expect_named(par.list$mai, c("bottom", "left", "top", "right"))
  expect_named(par.list$omi, c("bottom", "left", "top", "right"))
  expect_named(par.list$pin, c("width", "height"))
  expect_named(par.list$plt, c("left", "right", "bottom", "top"))
  expect_named(par.list$fig, c("left", "right", "bottom", "top"))
  expect_named(par.list$xaxp, c("minimum", "maximum", "intervals"))
  expect_named(par.list$yaxp, c("minimum", "maximum", "intervals"))
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
  expect_setequal(names(metadata$par.list), names(graphics::par(no.readonly = TRUE)))
  expect_identical(metadata$par.usr, metadata$par.list$usr)
  expect_identical(metadata$par.mar, metadata$par.list$mar)
})
