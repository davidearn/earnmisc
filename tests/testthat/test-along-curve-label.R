with_along_curve_pdf <- function(expr) {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)
  eval.parent(substitute(expr))
}

test_that("along_curve_label places labels by displayed arclength fraction", {
  info <- with_along_curve_pdf({
    x <- seq(0, 2 * pi, length.out = 200)
    y <- sin(x) + 2
    graphics::plot(x, y, type = "l")
    along_curve_label(x, y, "fraction", fraction = 0.3)
  })

  expect_s3_class(info, "earnmisc_along_curve_label_info")
  expect_equal(info$at, "fraction")
  expect_named(info$point, c("x", "y"))
  expect_named(info$point.user, c("x", "y"))
  expect_true(all(is.finite(info$point)))
  expect_true(all(is.finite(info$point.user)))
  expect_true(is.finite(info$angle))
  expect_true(is.finite(info$srt))
  expect_true(info$text.drawn)
})

test_that("along_curve_label interpolates x and y crossings", {
  out <- with_along_curve_pdf({
    x <- seq(0, 2, length.out = 41)
    y <- 2 * x + 1
    graphics::plot(x, y, type = "l")
    x.info <- along_curve_label(
      x, y, "x crossing",
      at = "x",
      x.at = 0.375,
      crossing = "first"
    )
    y.info <- along_curve_label(
      x, y, "y crossing",
      at = "y",
      y.at = 1.75,
      crossing = "first"
    )
    list(x = x.info, y = y.info)
  })

  expect_equal(out$x$point[["x"]], 0.375, tolerance = 1e-8)
  expect_equal(out$x$point[["y"]], 1.75, tolerance = 1e-8)
  expect_equal(out$y$point[["x"]], 0.375, tolerance = 1e-8)
  expect_equal(out$y$point[["y"]], 1.75, tolerance = 1e-8)
  expect_equal(out$x$at, "x")
  expect_equal(out$y$at, "y")
})

test_that("along_curve_label supports index, point, and line placements", {
  out <- with_along_curve_pdf({
    x <- seq(0, 2, length.out = 101)
    y <- x^2
    graphics::plot(x, y, type = "l")
    index.info <- along_curve_label(x, y, "index", at = "index", index = 25)
    point.info <- along_curve_label(
      x, y, "point",
      at = "point",
      point = c(1.1, 1.1)
    )
    line.info <- along_curve_label(
      x, y, "line",
      at = "line",
      line = c(x = 0, y = 1, slope = 0),
      crossing = "first"
    )
    list(index = index.info, point = point.info, line = line.info)
  })

  x <- seq(0, 2, length.out = 101)
  y <- x^2
  expect_equal(out$index$point, c(x = x[[25]], y = y[[25]]))
  expect_equal(out$point$at, "point")
  expect_true(all(is.finite(out$point$point)))
  expect_equal(out$line$at, "line")
  expect_equal(out$line$point[["y"]], 1, tolerance = 1e-8)
  expect_equal(out$line$point[["x"]], 1, tolerance = 1e-8)
})

test_that("along_curve_label handles rotation, upright angles, and srt overrides", {
  out <- with_along_curve_pdf({
    x <- seq(0, 1, length.out = 50)
    y <- 10 - 100 * x
    graphics::plot(x, y, type = "l")
    auto <- along_curve_label(x, y, "auto", fraction = 0.5)
    flat <- along_curve_label(x, y, "flat", fraction = 0.6, rotate = FALSE)
    override <- along_curve_label(x, y, "override", fraction = 0.7, srt = 25)
    list(auto = auto, flat = flat, override = override)
  })

  expect_true(is.finite(out$auto$angle))
  expect_true(out$auto$srt >= -90 && out$auto$srt <= 90)
  expect_equal(out$flat$srt, 0)
  expect_equal(out$flat$srt.source, "unrotated")
  expect_equal(out$override$srt, 25)
  expect_equal(out$override$srt.source, "explicit")
})

test_that("along_curve_label supports knockout, nice_text, and draw-free metadata", {
  out <- with_along_curve_pdf({
    x <- seq(-2, 2, length.out = 100)
    y <- exp(-x^2)
    graphics::plot(x, y, type = "l")
    knockout <- along_curve_label(
      x, y, "knockout",
      fraction = 0.4,
      knockout = TRUE,
      knockout.border = "black",
      knockout.lwd = 1
    )
    tex <- along_curve_label(
      x, y, "$\\mathcal{R}_0 = 4$",
      fraction = 0.5,
      nice.text = TRUE,
      nice.text.args = list(use.tikz = TRUE)
    )
    metadata <- along_curve_label(
      x, y, "metadata",
      fraction = 0.6,
      draw = FALSE,
      knockout = TRUE
    )
    list(knockout = knockout, tex = tex, metadata = metadata)
  })

  expect_true(out$knockout$knockout)
  expect_true(out$knockout$knockout.drawn)
  expect_s3_class(out$knockout$knockout.polygon, "data.frame")
  expect_equal(nrow(out$knockout$knockout.polygon), 4)
  expect_true(is.character(out$tex$plotting.label))
  expect_false(out$metadata$drawn)
  expect_false(out$metadata$text.drawn)
  expect_false(out$metadata$knockout.drawn)
  expect_s3_class(out$metadata$knockout.polygon, "data.frame")
})

test_that("along_curve_label handles log-scale axes", {
  out <- with_along_curve_pdf({
    x <- seq(0.1, 10, length.out = 200)
    y <- exp(-0.3 * x) + 0.02
    graphics::plot(x, y, log = "y", type = "l")
    log.y <- along_curve_label(x, y, "log y", fraction = 0.5)

    graphics::plot(x, y, log = "xy", type = "l")
    log.xy <- along_curve_label(
      x, y, "log xy",
      at = "point",
      point = c(2, 0.4),
      offset = c(0.02, 0.03)
    )
    list(log.y = log.y, log.xy = log.xy)
  })

  expect_true(all(is.finite(out$log.y$point)))
  expect_gt(out$log.y$point[["y"]], 0)
  expect_true(all(is.finite(out$log.xy$point)))
  expect_gt(out$log.xy$point[["x"]], 0)
  expect_gt(out$log.xy$point[["y"]], 0)
})

test_that("along_curve_label validates inputs and restores xpd", {
  with_along_curve_pdf({
    x <- seq(0, 2, length.out = 50)
    y <- x^2 + 1
    graphics::plot(x, y, type = "l")

    graphics::par(xpd = FALSE)
    expect_false(graphics::par("xpd"))
    along_curve_label(x, y, "restored", xpd = NA)
    expect_false(graphics::par("xpd"))

    expect_error(along_curve_label(x, y), "`label`")
    expect_error(along_curve_label("x", y, "bad"), "`x` must be numeric")
    expect_error(along_curve_label(x[-1], y, "bad"), "same length")
    expect_error(along_curve_label(x, y, ""), "`label`")
    expect_error(along_curve_label(x, y, "bad", fraction = -0.1), "`fraction`")
    expect_error(
      along_curve_label(x, y, "bad", at = "x"),
      "`x.at` must be supplied",
      fixed = TRUE
    )
    expect_error(
      along_curve_label(x, y, "bad", at = "y"),
      "`y.at` must be supplied",
      fixed = TRUE
    )
    expect_error(
      along_curve_label(x, y, "bad", at = "index", index = 1.2),
      "whole-number"
    )
    expect_error(
      along_curve_label(x, y, "bad", at = "point", point = c(1, 2, 3)),
      "`point`"
    )
    expect_error(
      along_curve_label(x, y, "bad", at = "line"),
      "`line` must be supplied",
      fixed = TRUE
    )
    expect_error(
      along_curve_label(x, y, "bad", at = "x", x.at = 3),
      "No curve crossing"
    )
    expect_error(along_curve_label(x, y, "bad", offset = 1), "`offset`")
    expect_error(along_curve_label(x, y, "bad", adj = 1), "`adj`")
    expect_error(
      along_curve_label(x, y, "bad", knockout.pad = 0),
      "`knockout.pad`"
    )
    expect_error(
      along_curve_label(x, y, "bad", nice.text.args = "bad"),
      "`nice.text.args`"
    )
  })
})

test_that("along_curve_label rejects non-positive coordinates on log axes", {
  with_along_curve_pdf({
    graphics::plot(1:3, 1:3, log = "xy", type = "l")
    expect_error(
      along_curve_label(c(0, 1, 2), c(1, 2, 3), "bad"),
      "positive finite values on a log-scale x axis"
    )
    expect_error(
      along_curve_label(c(1, 2, 3), c(0, 2, 3), "bad"),
      "positive finite values on a log-scale y axis"
    )
  })
})
