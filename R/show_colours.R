#' Display colours as labelled swatches
#'
#' Draw a simple base-graphics display of colours as rectangular swatches.
#' This is a lightweight helper for quickly inspecting any R colour vector.
#' Graphics parameters are restored after plotting.
#'
#' @param colours Character vector of R colours.
#' @param labels Character vector of labels, or `NULL` for no labels. By
#'   default, names are used when available; otherwise colour values are used.
#' @param nrow,ncol Optional grid dimensions. If both are `NULL`, a compact
#'   grid is chosen automatically. If one is supplied, the other is computed.
#' @param main Optional plot title.
#' @param border Border colour for swatches.
#' @param text.colour Label text colour. If `NULL`, black or white is chosen
#'   from the swatch colour luminance.
#' @param cex Character expansion for labels.
#' @param mar Plot margins used while drawing. Restored on exit.
#' @param ... Additional arguments passed to [graphics::text()].
#'
#' @return Invisibly returns `colours`.
#'
#' @section Palette design workflow:
#' `show_colours()` is a lightweight in-R inspection helper. For broader
#' palette design, browsing, and accessibility checks, optional complementary
#' tools can be useful:
#'
#' * [colorspace](https://cran.r-project.org/package=colorspace) helps design,
#'   tune, and evaluate palettes, including colour-vision-deficiency checks.
#' * [khroma](https://cran.r-project.org/package=khroma) provides pre-vetted
#'   scientific palettes and diagnostic tools for colour-blind-safe
#'   visualisation.
#' * [paletteer](https://cran.r-project.org/package=paletteer) gives a unified
#'   way to browse many R palette families.
#' * [Adobe Color](https://color.adobe.com/create/color-accessibility) is useful
#'   for harmony-based palette exploration and colour-contrast checks.
#' * [Coolors](https://coolors.co/) is useful for quickly generating, locking,
#'   and exploring palettes.
#'
#' A practical workflow is to prototype candidate colours in Adobe Color or
#' Coolors, bring the hex colours into R, inspect and tune them with
#' `colorspace`, check accessibility with `khroma` or another accessibility
#' tool, and then compare final candidates directly with `show_colours()`.
#'
#' @examples
#' show_colours(c(red = "red", blue = "blue"))
#' show_colours(c("#000000", "#FFFFFF"), labels = NULL)
#'
#' ## Base R includes 657 built-in named colours. `colors()` is an alias.
#' show_colours(colours()[1:16])
#'
#' \dontrun{
#' ## Browse all built-in named colours in groups of 16.
#' for (i in 1:41) {
#'   show_colours(colours()[(1 + 16 * (i - 1)):(16 * i)])
#' }
#' }
#'
#' @export
show_colours <- function(colours,
                         labels = names(colours),
                         nrow = NULL,
                         ncol = NULL,
                         main = NULL,
                         border = "grey30",
                         text.colour = NULL,
                         cex = 0.9,
                         mar = c(0, 0, 2, 0),
                         ...) {
  if (!is.character(colours) || length(colours) < 1L || anyNA(colours)) {
    stop("`colours` must be a non-empty character vector of R colours.", call. = FALSE)
  }
  validate_r_colours(colours)

  if (missing(labels) && is.null(names(colours))) {
    labels <- colours
  }

  if (!is.null(labels)) {
    if (!is.character(labels) || length(labels) != length(colours) || anyNA(labels)) {
      stop("`labels` must be `NULL` or a character vector the same length as `colours`.", call. = FALSE)
    }
  }

  if (!is.null(text.colour)) {
    if (!is.character(text.colour) || length(text.colour) < 1L || anyNA(text.colour)) {
      stop("`text.colour` must be `NULL` or a character vector of R colours.", call. = FALSE)
    }
    validate_r_colours(text.colour)
    text.colour <- rep(text.colour, length.out = length(colours))
  } else {
    text.colour <- colour_text_contrast(colours)
  }

  grid.dimensions <- colour_grid_dims(length(colours), nrow = nrow, ncol = ncol)
  old.par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old.par), add = TRUE)

  graphics::par(mar = mar)
  graphics::plot.new()
  graphics::plot.window(
    xlim = c(0, grid.dimensions$ncol),
    ylim = c(0, grid.dimensions$nrow),
    xaxs = "i",
    yaxs = "i"
  )

  if (!is.null(main)) {
    graphics::title(main = main)
  }

  for (colour.number in seq_along(colours)) {
    row.number <- (colour.number - 1L) %/% grid.dimensions$ncol
    column.number <- (colour.number - 1L) %% grid.dimensions$ncol
    x.left <- column.number
    x.right <- column.number + 1
    y.top <- grid.dimensions$nrow - row.number
    y.bottom <- y.top - 1

    graphics::rect(
      xleft = x.left,
      ybottom = y.bottom,
      xright = x.right,
      ytop = y.top,
      col = colours[[colour.number]],
      border = border
    )

    if (!is.null(labels)) {
      graphics::text(
        x = (x.left + x.right) / 2,
        y = (y.bottom + y.top) / 2,
        labels = labels[[colour.number]],
        col = text.colour[[colour.number]],
        cex = cex,
        ...
      )
    }
  }

  invisible(colours)
}

#' Display Okabe-Ito colours as labelled swatches
#'
#' Convenience wrapper around [okabe_ito_colours()] and [show_colours()] for
#' displaying the package Okabe-Ito palette.
#'
#' @param extended Logical scalar passed to [okabe_ito_colours()]. If `TRUE`,
#'   display the extended palette. If `FALSE`, display only the original
#'   Okabe-Ito palette.
#' @param alpha Optional alpha value passed to [okabe_ito_colours()].
#' @param ... Additional arguments passed to [show_colours()].
#'
#' @return Invisibly returns the displayed colour vector.
#'
#' @section Palette design workflow:
#' `show_oi_colours()` is a quick way to inspect the package Okabe-Ito palette
#' in the current graphics device. For designing or comparing custom palettes,
#' [colorspace](https://cran.r-project.org/package=colorspace) is useful for
#' tuning palettes and checking colour-vision-deficiency behaviour,
#' [khroma](https://cran.r-project.org/package=khroma) provides pre-vetted
#' scientific palettes and diagnostics, and
#' [paletteer](https://cran.r-project.org/package=paletteer) helps browse many
#' palette families through one interface. External tools such as
#' [Adobe Color](https://color.adobe.com/create/color-accessibility) and
#' [Coolors](https://coolors.co/) can also help move quickly from rough palette
#' ideas to hex colours that can be inspected in R.
#'
#' @examples
#' show_oi_colours()
#' show_oi_colours(extended = FALSE)
#' show_colours(okabe_ito_colours()[1:4])
#'
#' @export
show_oi_colours <- function(extended = TRUE,
                            alpha = NULL,
                            ...) {
  colours <- okabe_ito_colours(extended = extended, alpha = alpha)
  show_colours(colours, ...)
}

#' Choose text colour for contrast
#'
#' Choose black or white text for each background colour using a simple
#' luminance calculation.
#'
#' @param colours Character vector of R colours.
#'
#' @return Character vector containing `"black"` or `"white"`.
colour_text_contrast <- function(colours) {
  rgb.matrix <- grDevices::col2rgb(colours) / 255
  luminance <- 0.299 * rgb.matrix["red", ] +
    0.587 * rgb.matrix["green", ] +
    0.114 * rgb.matrix["blue", ]

  ifelse(luminance > 0.5, "black", "white")
}

#' Compute colour swatch grid dimensions
#'
#' Compute a grid that has enough cells for a given number of colours.
#'
#' @param n Number of colours.
#' @param nrow,ncol Optional grid dimensions.
#'
#' @return A list with integer elements `nrow` and `ncol`.
colour_grid_dims <- function(n, nrow = NULL, ncol = NULL) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 1 || n != floor(n)) {
    stop("`n` must be a positive integer scalar.", call. = FALSE)
  }

  if (!is.null(nrow)) {
    nrow <- validate_grid_dimension(nrow, "nrow")
  }
  if (!is.null(ncol)) {
    ncol <- validate_grid_dimension(ncol, "ncol")
  }

  if (is.null(nrow) && is.null(ncol)) {
    ncol <- ceiling(sqrt(n))
    nrow <- ceiling(n / ncol)
  } else if (is.null(nrow)) {
    nrow <- ceiling(n / ncol)
  } else if (is.null(ncol)) {
    ncol <- ceiling(n / nrow)
  }

  if (nrow * ncol < n) {
    stop("`nrow` and `ncol` do not provide enough cells for all colours.", call. = FALSE)
  }

  list(nrow = as.integer(nrow), ncol = as.integer(ncol))
}

#' Validate a grid dimension
#'
#' Validate a positive integer scalar grid dimension.
#'
#' @param x Value to validate.
#' @param name Argument name for error messages.
#'
#' @return An integer scalar.
validate_grid_dimension <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || x < 1 || x != floor(x)) {
    stop("`", name, "` must be a positive integer scalar.", call. = FALSE)
  }

  as.integer(x)
}

#' Validate R colours
#'
#' Validate a character vector by asking base R to convert it to RGB.
#'
#' @param colours Character vector of colour specifications.
#'
#' @return Invisibly returns `colours`.
validate_r_colours <- function(colours) {
  tryCatch(
    grDevices::col2rgb(colours),
    error = function(error) {
      stop("Invalid R colour value: ", conditionMessage(error), call. = FALSE)
    }
  )

  invisible(colours)
}
