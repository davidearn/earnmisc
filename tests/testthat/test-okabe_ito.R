test_that("okabe_ito_colours returns the standard named palette", {
  colours <- okabe_ito_colours()

  expect_named(colours, c(
    "black",
    "orange",
    "sky_blue",
    "bluish_green",
    "yellow",
    "blue",
    "vermillion",
    "reddish_purple"
  ))
  expect_identical(unname(colours["orange"]), "#E69F00")
  expect_identical(unname(colours["sky_blue"]), "#56B4E9")
})

test_that("okabe_ito_colours can apply alpha", {
  colours <- okabe_ito_colours(alpha = 0.5)

  expect_named(colours, names(okabe_ito_colours()))
  expect_identical(
    unname(colours["black"]),
    unname(grDevices::adjustcolor("#000000", alpha.f = 0.5))
  )
})

test_that("okabe_ito_palette returns the first n colours", {
  expect_identical(okabe_ito_palette(0), okabe_ito_colours()[0])
  expect_identical(okabe_ito_palette(3), okabe_ito_colours()[1:3])
})

test_that("okabe_ito helpers validate inputs", {
  expect_error(okabe_ito_colours(alpha = -0.1), "`alpha`")
  expect_error(okabe_ito_colours(alpha = 2), "`alpha`")
  expect_error(okabe_ito_palette(-1), "`n`")
  expect_error(okabe_ito_palette(1.5), "`n`")
  expect_error(okabe_ito_palette(9), "`n`")
})
