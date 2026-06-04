with_axis_labels_pdf <- function(expr) {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)
  eval.parent(substitute(expr))
}

capture_axis_label_calls <- function(expr) {
  mtext.name <- ".earnmisc_axis_labels_mtext_capture"
  text.name <- ".earnmisc_axis_labels_text_capture"
  assign(mtext.name, list(), envir = .GlobalEnv)
  assign(text.name, list(), envir = .GlobalEnv)
  on.exit({
    if (exists(mtext.name, envir = .GlobalEnv, inherits = FALSE)) {
      rm(list = mtext.name, envir = .GlobalEnv)
    }
    if (exists(text.name, envir = .GlobalEnv, inherits = FALSE)) {
      rm(list = text.name, envir = .GlobalEnv)
    }
  }, add = TRUE)

  suppressMessages(trace(
    graphics::mtext,
    tracer = quote({
      mtext.dots <- list(...)
      calls <- get(".earnmisc_axis_labels_mtext_capture", envir = .GlobalEnv)
      calls[[length(calls) + 1L]] <- list(
        text = text,
        text.character = as.character(text),
        side = side,
        line = line,
        at = at,
        las = mtext.dots[["las", exact = TRUE]],
        cex = cex,
        col = col,
        dots.names = names(mtext.dots)
      )
      assign(".earnmisc_axis_labels_mtext_capture", calls, envir = .GlobalEnv)
    }),
    print = FALSE
  ))
  on.exit(suppressMessages(untrace(graphics::mtext)), add = TRUE)

  suppressMessages(trace(
    graphics::text,
    tracer = quote({
      text.dots <- list(...)
      calls <- get(".earnmisc_axis_labels_text_capture", envir = .GlobalEnv)
      calls[[length(calls) + 1L]] <- list(
        x = x,
        y = text.dots[["y", exact = TRUE]],
        labels = text.dots[["labels", exact = TRUE]],
        labels.character = as.character(text.dots[["labels", exact = TRUE]]),
        cex = text.dots[["cex", exact = TRUE]],
        col = text.dots[["col", exact = TRUE]],
        dots.names = names(text.dots)
      )
      assign(".earnmisc_axis_labels_text_capture", calls, envir = .GlobalEnv)
    }),
    print = FALSE
  ))
  on.exit(suppressMessages(untrace(graphics::text)), add = TRUE)

  value <- eval.parent(substitute(expr))
  list(
    value = value,
    mtext = get(mtext.name, envir = .GlobalEnv),
    text = get(text.name, envir = .GlobalEnv)
  )
}

axis_label_test_ticks <- function(side) {
  usr <- graphics::par("usr")
  ticks <- graphics::axTicks(side)
  if (side == 1L) {
    ticks <- ticks[is.finite(ticks) & ticks >= usr[[1L]] & ticks <= usr[[2L]]]
  } else {
    ticks <- ticks[is.finite(ticks) & ticks >= usr[[3L]] & ticks <= usr[[4L]]]
  }
  sort(unique(ticks))
}

test_that("axis_labels is available", {
  expect_true(is.function(axis_labels))
})

test_that("axis_labels works on a temporary PDF device", {
  out <- with_axis_labels_pdf({
    graphics::plot(0:1, 0:1, xlab = "", ylab = "", las = 1)
    withVisible(axis_labels("$x$", "$y$", use.tikz = TRUE))
  })

  expect_false(out$visible)
  expect_s3_class(out$value, "earnmisc_axis_labels_info")
  expect_equal(out$value$xlab, "$x$")
  expect_equal(out$value$ylab, "$y$")
  expect_true(all(is.finite(out$value$usr)))
})

test_that("axis_labels places x and y labels through mtext by default", {
  out <- with_axis_labels_pdf({
    graphics::plot(0:1, 0:1, xlab = "", ylab = "", las = 1)
    expected.line <- graphics::par("mgp")[2]
    expected.x.ticks <- tail(axis_label_test_ticks(1L), 2L)
    expected.y.ticks <- tail(axis_label_test_ticks(2L), 2L)
    captured <- capture_axis_label_calls(axis_labels("$x$", "$y$", use.tikz = TRUE))
    captured$expected.line <- expected.line
    captured$expected.x.ticks <- expected.x.ticks
    captured$expected.y.ticks <- expected.y.ticks
    captured
  })

  info <- out$value
  expect_equal(info$line, out$expected.line)
  expect_equal(info$cex, 1.5)
  expect_equal(info$las, 1)
  expect_equal(info$x.pos, "right")
  expect_equal(info$y.pos, "top")
  expect_equal(info$labels$method, c("mtext", "mtext"))
  expect_equal(info$labels$placement.source, c("ticks", "ticks"))
  expect_equal(info$x.placement.source, "ticks")
  expect_equal(info$y.placement.source, "ticks")
  expect_equal(info$x.tick.values, out$expected.x.ticks)
  expect_equal(info$y.tick.values, out$expected.y.ticks)
  expect_equal(info$x.at, mean(out$expected.x.ticks))
  expect_equal(info$y.at, mean(out$expected.y.ticks))
  expect_true(all(is.finite(info$labels$at)))
  expect_length(out$mtext, 2L)
  expect_length(out$text, 0L)
  expect_equal(out$mtext[[1L]]$text.character, "$x$")
  expect_equal(out$mtext[[2L]]$text.character, "$y$")
  expect_equal(out$mtext[[1L]]$side, 1L)
  expect_equal(out$mtext[[2L]]$side, 2L)
  expect_equal(out$mtext[[1L]]$line, out$expected.line)
  expect_equal(out$mtext[[2L]]$line, out$expected.line)
  expect_equal(out$mtext[[1L]]$at, mean(out$expected.x.ticks))
  expect_equal(out$mtext[[2L]]$at, mean(out$expected.y.ticks))
  expect_equal(out$mtext[[1L]]$las, 1)
  expect_equal(out$mtext[[2L]]$las, 1)
})

test_that("axis_labels uses first tick midpoint for left and bottom positions", {
  out <- with_axis_labels_pdf({
    graphics::plot(0:10, 0:10, xlab = "", ylab = "", las = 1)
    expected.x.ticks <- head(axis_label_test_ticks(1L), 2L)
    expected.y.ticks <- head(axis_label_test_ticks(2L), 2L)
    captured <- capture_axis_label_calls(axis_labels(
      "$x$",
      "$y$",
      x.pos = "left",
      y.pos = "bottom",
      use.tikz = TRUE
    ))
    captured$expected.x.ticks <- expected.x.ticks
    captured$expected.y.ticks <- expected.y.ticks
    captured
  })

  info <- out$value
  expect_equal(info$x.pos, "left")
  expect_equal(info$y.pos, "bottom")
  expect_equal(info$labels$placement.source, c("ticks", "ticks"))
  expect_equal(info$x.tick.values, out$expected.x.ticks)
  expect_equal(info$y.tick.values, out$expected.y.ticks)
  expect_equal(info$x.at, mean(out$expected.x.ticks))
  expect_equal(info$y.at, mean(out$expected.y.ticks))
  expect_equal(out$mtext[[1L]]$at, mean(out$expected.x.ticks))
  expect_equal(out$mtext[[2L]]$at, mean(out$expected.y.ticks))
})

test_that("axis_labels supports axis-end labels through text", {
  out <- with_axis_labels_pdf({
    x <- seq(0, 1, length.out = 100)
    graphics::plot(x, sin(2 * pi * x), xlab = "", ylab = "", las = 1)
    capture_axis_label_calls(axis_labels(
      "$\\tau$",
      "$\\iota$",
      x.pos = "end",
      y.pos = "end",
      use.tikz = TRUE
    ))
  })

  info <- out$value
  expect_equal(info$labels$method, c("text", "text"))
  expect_equal(info$labels$position, c("end", "end"))
  expect_equal(info$labels$placement.source, c("end", "end"))
  expect_true(all(is.finite(info$labels$x)))
  expect_true(all(is.finite(info$labels$y)))
  expect_length(out$mtext, 0L)
  expect_length(out$text, 2L)
  expect_equal(out$text[[1L]]$labels.character, "$\\tau$")
  expect_equal(out$text[[2L]]$labels.character, "$\\iota$")
  expect_equal(out$text[[1L]]$cex, 1.5)
  expect_equal(out$text[[2L]]$cex, 1.5)
})

test_that("axis_labels explicit at values override along-axis fractions", {
  out <- with_axis_labels_pdf({
    graphics::plot(0:1, 0:1, xlab = "", ylab = "", las = 1)
    capture_axis_label_calls(axis_labels(
      "$x$",
      "$y$",
      x.at = 0.25,
      y.at = 0.75,
      use.tikz = TRUE
    ))
  })

  info <- out$value
  expect_equal(info$x.at, 0.25)
  expect_equal(info$y.at, 0.75)
  expect_equal(info$labels$at, c(0.25, 0.75))
  expect_equal(info$labels$placement.source, c("explicit", "explicit"))
  expect_equal(info$x.placement.source, "explicit")
  expect_equal(info$y.placement.source, "explicit")
  expect_length(info$x.tick.values, 0L)
  expect_length(info$y.tick.values, 0L)
  expect_equal(out$mtext[[1L]]$at, 0.25)
  expect_equal(out$mtext[[2L]]$at, 0.75)
})

test_that("axis_labels treats center and centre as synonyms", {
  values <- with_axis_labels_pdf({
    graphics::plot(0:1, 0:1, xlab = "", ylab = "", las = 1)
    centre <- axis_labels("$x$", NULL, x.pos = "centre", use.tikz = TRUE)
    center <- axis_labels("$x$", NULL, x.pos = "center", use.tikz = TRUE)
    list(centre = centre, center = center)
  })

  expect_equal(values$centre$x.pos, "centre")
  expect_equal(values$center$x.pos, "centre")
  expect_equal(values$centre$x.at, values$center$x.at)
  expect_equal(values$centre$labels$method, c("mtext", "none"))
  expect_equal(values$center$labels$method, c("mtext", "none"))
  expect_equal(values$centre$x.placement.source, "fraction")
  expect_equal(values$center$x.placement.source, "fraction")
})

test_that("axis_labels expands nice_text macros for tikz labels", {
  out <- with_axis_labels_pdf({
    graphics::plot(0:1, 0:1, xlab = "", ylab = "", las = 1)
    axis_labels("$\\Rn$", "$\\tinc$", use.tikz = TRUE)
  })

  expect_equal(out$rendered.xlab, "$\\mathcal R_0$")
  expect_equal(out$rendered.ylab, "$\\tilde{\\iota}$")
})

test_that("axis_labels validates user inputs", {
  with_axis_labels_pdf({
    graphics::plot(0:1, 0:1, xlab = "", ylab = "", las = 1)
    expect_error(axis_labels(1), "xlab")
    expect_error(axis_labels("$x$", x.pos = "middle"), "x.pos")
    expect_error(axis_labels("$x$", x.frac = 2), "x.frac")
    expect_error(axis_labels("$x$", x.at = Inf), "x.at")
    expect_error(axis_labels("$x$", cex = 0), "cex")
    expect_error(axis_labels("$x$", las = 4), "las")
  })
})
