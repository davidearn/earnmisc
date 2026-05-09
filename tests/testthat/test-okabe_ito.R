test_that("okabe_ito_colours returns the extended named palette by default", {
  colours <- okabe_ito_colours()

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
  expect_identical(unname(colours["orange"]), "#E69F00")
  expect_identical(unname(colours["sky_blue"]), "#56B4E9")
  expect_identical(unname(colours["grey"]), "#999999")
  expect_identical(unname(colours["amber"]), "#EECC66")
  expect_length(colours, 10)
})

test_that("okabe_ito_colours can return the original named palette", {
  colours <- okabe_ito_colours(extended = FALSE)

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
  expect_identical(colours, okabe_ito_colours()[1:8])
  expect_length(colours, 8)
})

test_that("exported oi colour constants match the extended palette", {
  constants <- c(
    black = oi.black,
    orange = oi.orange,
    sky_blue = oi.sky_blue,
    bluish_green = oi.bluish_green,
    yellow = oi.yellow,
    blue = oi.blue,
    vermillion = oi.vermillion,
    reddish_purple = oi.reddish_purple,
    grey = oi.grey,
    amber = oi.amber
  )

  expect_identical(constants, okabe_ito_colours(extended = TRUE))
})

test_that("okabe_ito_colours can apply alpha", {
  colours <- okabe_ito_colours(alpha = 0.5)
  original.colours <- okabe_ito_colours(extended = FALSE, alpha = 0.25)

  expect_named(colours, names(okabe_ito_colours()))
  expect_identical(
    unname(colours["black"]),
    unname(grDevices::adjustcolor("#000000", alpha.f = 0.5))
  )
  expect_named(original.colours, names(okabe_ito_colours(extended = FALSE)))
  expect_identical(
    unname(original.colours["orange"]),
    unname(grDevices::adjustcolor("#E69F00", alpha.f = 0.25))
  )
})

test_that("okabe_ito_palette returns the first n colours", {
  expect_identical(okabe_ito_palette(0), okabe_ito_colours()[0])
  expect_identical(okabe_ito_palette(3), okabe_ito_colours()[1:3])
  expect_identical(
    okabe_ito_palette(8, extended = FALSE),
    okabe_ito_colours(extended = FALSE)
  )
  expect_length(okabe_ito_palette(), 10)
})

test_that("okabe_ito helpers validate inputs", {
  expect_error(okabe_ito_colours(alpha = -0.1), "`alpha`")
  expect_error(okabe_ito_colours(alpha = 2), "`alpha`")
  expect_error(okabe_ito_colours(extended = NA), "`extended`")
  expect_error(okabe_ito_colours(extended = c(TRUE, FALSE)), "`extended`")
  expect_error(okabe_ito_palette(-1), "`n`")
  expect_error(okabe_ito_palette(1.5), "`n`")
  expect_error(okabe_ito_palette(9, extended = FALSE), "`n`")
  expect_error(okabe_ito_palette(11, extended = TRUE), "`n`")
  expect_error(okabe_ito_palette(extended = "yes"), "`extended`")
})

test_that("oi_alpha adjusts actual R colour values", {
  expect_identical(
    unname(oi_alpha(oi.orange, 0.023)),
    unname(grDevices::adjustcolor("#E69F00", alpha.f = 0.023))
  )
  expect_identical(
    oi_alpha(c(orange = oi.orange, sky_blue = oi.sky_blue), 0.4),
    stats::setNames(
      grDevices::adjustcolor(c(oi.orange, oi.sky_blue), alpha.f = 0.4),
      c("orange", "sky_blue")
    )
  )
})

test_that("oi_colour selects named Okabe-Ito colours", {
  expect_identical(oi_colour("orange"), okabe_ito_colours()["orange"])
  expect_identical(
    oi_colour(c("orange", "sky_blue")),
    okabe_ito_colours()[c("orange", "sky_blue")]
  )
  expect_identical(
    oi_colour("orange", alpha = 0.023),
    oi_alpha(okabe_ito_colours()["orange"], 0.023)
  )
  expect_identical(oi_colour("yellow", extended = FALSE), okabe_ito_colours(FALSE)["yellow"])
})

test_that("oi_colour validates names and does not treat oi.* strings specially", {
  expect_error(oi_colour("not_a_colour"), "Unknown Okabe-Ito colour name")
  expect_error(oi_colour("oi.orange"), "Unknown Okabe-Ito colour name")
  expect_error(oi_colour("grey", extended = FALSE), "Unknown Okabe-Ito colour name")
  expect_error(oi_colour(NA_character_), "`name`")
})

test_that("oi_alpha validates alpha", {
  expect_error(oi_alpha(oi.orange, -0.1), "`alpha`")
  expect_error(oi_alpha(oi.orange, 1.1), "`alpha`")
  expect_error(oi_alpha(oi.orange, NA_real_), "`alpha`")
  expect_error(oi_colour("orange", alpha = c(0.1, 0.2)), "`alpha`")
})
