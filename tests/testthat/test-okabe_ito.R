test_that("okabe_ito_colours returns the original named palette by default", {
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
  expect_length(colours, 8)
})

test_that("okabe_ito_colours can return the extended named palette", {
  colours <- okabe_ito_colours(extended = TRUE)

  expect_named(colours, c(
    "black",
    "orange",
    "sky_blue",
    "bluish_green",
    "yellow",
    "blue",
    "vermillion",
    "reddish_purple",
    "grey",
    "amber"
  ))
  expect_identical(unname(colours["grey"]), "#999999")
  expect_identical(unname(colours["amber"]), "#EECC66")
  expect_identical(colours[1:8], okabe_ito_colours())
})

test_that("okabe_ito_colours can apply alpha", {
  colours <- okabe_ito_colours(alpha = 0.5)
  extended.colours <- okabe_ito_colours(extended = TRUE, alpha = 0.25)

  expect_named(colours, names(okabe_ito_colours()))
  expect_identical(
    unname(colours["black"]),
    unname(grDevices::adjustcolor("#000000", alpha.f = 0.5))
  )
  expect_named(extended.colours, names(okabe_ito_colours(extended = TRUE)))
  expect_identical(
    unname(extended.colours["amber"]),
    unname(grDevices::adjustcolor("#EECC66", alpha.f = 0.25))
  )
})

test_that("okabe_ito_palette returns the first n colours", {
  expect_identical(okabe_ito_palette(0), okabe_ito_colours()[0])
  expect_identical(okabe_ito_palette(3), okabe_ito_colours()[1:3])
  expect_identical(
    okabe_ito_palette(9, extended = TRUE),
    okabe_ito_colours(extended = TRUE)[1:9]
  )
  expect_length(okabe_ito_palette(extended = TRUE), 10)
})

test_that("okabe_ito helpers validate inputs", {
  expect_error(okabe_ito_colours(alpha = -0.1), "`alpha`")
  expect_error(okabe_ito_colours(alpha = 2), "`alpha`")
  expect_error(okabe_ito_colours(extended = NA), "`extended`")
  expect_error(okabe_ito_colours(extended = c(TRUE, FALSE)), "`extended`")
  expect_error(okabe_ito_palette(-1), "`n`")
  expect_error(okabe_ito_palette(1.5), "`n`")
  expect_error(okabe_ito_palette(9), "`n`")
  expect_error(okabe_ito_palette(11, extended = TRUE), "`n`")
  expect_error(okabe_ito_palette(extended = "yes"), "`extended`")
})
