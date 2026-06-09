with_aligned_text_pdf <- function(expr) {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)
  eval.parent(substitute(expr))
}

test_that("aligned_text accepts numeric top-left placement", {
  out <- with_aligned_text_pdf({
    graphics::plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1), las = 1)
    withVisible(aligned_text(
      0.1, 0.9,
      lhs = c("a", "b"),
      mid = c(":", ":"),
      rhs = c("one", "two"),
      use.tikz = TRUE
    ))
  })

  expect_false(out$visible)
  expect_s3_class(out$value, "earnmisc_aligned_text_info")
  expect_equal(out$value$placement.type, "numeric")
  expect_equal(out$value$anchor, c(x = 0.1, y = 0.9))
  expect_true(all(is.finite(out$value$column.x)))
  expect_true(all(is.finite(out$value$row.y)))
})

test_that("aligned_text accepts legend-style keyword placement", {
  out <- with_aligned_text_pdf({
    graphics::plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1), las = 1)
    bottomright <- aligned_text(
      "bottomright",
      lhs = "a",
      mid = "=",
      rhs = "one",
      use.tikz = TRUE
    )
    topleft <- aligned_text(
      "topleft",
      lhs = "b",
      mid = "=",
      rhs = "two",
      use.tikz = TRUE
    )
    list(bottomright = bottomright, topleft = topleft)
  })

  expect_equal(out$bottomright$position, "bottomright")
  expect_equal(out$bottomright$horizontal, "right")
  expect_equal(out$bottomright$vertical, "bottom")
  expect_equal(out$topleft$position, "topleft")
  expect_equal(out$topleft$horizontal, "left")
  expect_equal(out$topleft$vertical, "top")
  expect_true(all(is.finite(out$bottomright$anchor)))
  expect_true(all(is.finite(out$topleft$anchor)))
})

test_that("aligned_text requires equal column lengths", {
  expect_error(
    aligned_text(
      0, 1,
      lhs = c("a", "b"),
      mid = "=",
      rhs = "one",
      use.tikz = TRUE
    ),
    "`lhs`, `mid`, and `rhs` must have the same length",
    fixed = TRUE
  )
})

test_that("aligned_text records default column adjustments", {
  info <- with_aligned_text_pdf({
    graphics::plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1), las = 1)
    aligned_text(
      0.1, 0.9,
      lhs = "a",
      mid = "=",
      rhs = "one",
      use.tikz = TRUE
    )
  })

  expect_equal(info$adj, c(lhs = 1, mid = 0.5, rhs = 0))
  expect_equal(info$columns$adj, c(1, 0.5, 0))
})

test_that("aligned_text accepts user-supplied column adjustments", {
  info <- with_aligned_text_pdf({
    graphics::plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1), las = 1)
    aligned_text(
      0.1, 0.9,
      lhs = "a",
      mid = "=",
      rhs = "one",
      lhs.adj = 0,
      mid.adj = 1,
      rhs.adj = 0.5,
      use.tikz = TRUE
    )
  })

  expect_equal(info$adj, c(lhs = 0, mid = 1, rhs = 0.5))
  expect_equal(info$columns$adj, c(0, 1, 0.5))
})

test_that("aligned_text resolves default gap from m width", {
  out <- with_aligned_text_pdf({
    graphics::plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1), las = 1)
    expected.gap <- 0.3 * graphics::strwidth("m", cex = 1.2)
    info <- aligned_text(
      0.1, 0.9,
      lhs = "a",
      mid = "=",
      rhs = "one",
      cex = 1.2,
      use.tikz = TRUE
    )
    list(info = info, expected.gap = expected.gap)
  })

  expect_equal(out$info$gap, out$expected.gap)
})

test_that("aligned_text accepts user-supplied gap", {
  info <- with_aligned_text_pdf({
    graphics::plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1), las = 1)
    aligned_text(
      0.1, 0.9,
      lhs = "a",
      mid = "=",
      rhs = "one",
      gap = 0.04,
      use.tikz = TRUE
    )
  })

  expect_equal(info$gap, 0.04)
})

test_that("aligned_text returns useful placement information", {
  info <- with_aligned_text_pdf({
    graphics::plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1), las = 1)
    aligned_text(
      "center",
      lhs = c("$x$", "$y$"),
      mid = c("$=$", "$=$"),
      rhs = c("$1$", "$2$"),
      use.tikz = TRUE
    )
  })

  expect_s3_class(info, "earnmisc_aligned_text_info")
  expect_named(info$columns, c("column", "x", "left", "right", "width", "adj"))
  expect_named(info$rows, c("row", "y"))
  expect_equal(info$columns$column, c("lhs", "mid", "rhs"))
  expect_equal(info$rows$row, 1:2)
  expect_true(is.finite(info$block.width))
  expect_true(is.finite(info$block.height))
  expect_true(info$gap >= 0)
})
