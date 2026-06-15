#' Label a plotted curve directly
#'
#' `direct_curve_label()` places a text label on or near one already-plotted
#' curve. It uses a simple peak-based rule to choose a point on the descending
#' side of the curve, then draws [graphics::text()] at that point with optional
#' offsets. The helper is generic base-graphics code; it does not depend on
#' `mts_plot()` metadata.
#'
#' @param x,y Finite numeric vectors giving the curve coordinates.
#' @param label Single label to draw. Plain character strings, plotmath
#'   expressions, and labels already converted by [nice_text()] are accepted.
#' @param placement Placement rule. `"x_offset"` chooses a point after the
#'   peak nearest `peak.x + x.offset * panel_width`. `"peak_fraction"` chooses
#'   the first descending-side point where the curve has fallen to
#'   `peak.fraction * peak.y`, using linear interpolation when possible.
#' @param x.offset Non-negative horizontal offset, as a fraction of the current
#'   panel width, used by `placement = "x_offset"`. On a log x-axis this is
#'   interpreted on the displayed log scale.
#' @param peak.fraction Peak-height fraction used by
#'   `placement = "peak_fraction"`. Values must satisfy
#'   `0 < peak.fraction <= 1`. When `peak.fraction = 1`, the peak point itself
#'   is used.
#' @param x.text.offset,y.text.offset Text offsets applied after the curve
#'   point is selected, as fractions of the current panel width and height.
#'   Offsets are interpreted on the displayed scale for log axes.
#' @param adj,col,cex,font,xpd Graphical parameters passed to
#'   [graphics::text()]. The previous `xpd` value is restored on exit.
#' @param ... Additional arguments passed to [graphics::text()].
#'
#' @return Invisibly returns the selected text location as a numeric vector
#'   `c(x = ..., y = ...)`.
#'
#' @examples
#' x <- seq(-3, 3, length.out = 200)
#' y <- exp(-x^2)
#' plot(x, y, type = "l")
#' direct_curve_label(x, y, label = "curve")
#'
#' @export
direct_curve_label <- function(x, y,
                               label,
                               placement = c("x_offset", "peak_fraction"),
                               x.offset = 0.05,
                               peak.fraction = 0.7,
                               x.text.offset = 0,
                               y.text.offset = 0,
                               adj = c(0, 0.5),
                               col = "black",
                               cex = 0.8,
                               font = 1,
                               xpd = NA,
                               ...) {
  x <- validate_direct_curve_xy(x, "x")
  y <- validate_direct_curve_xy(y, "y")
  if (length(x) != length(y)) {
    stop("`x` and `y` must have the same length.", call. = FALSE)
  }
  if (length(x) < 1L) {
    stop("`x` and `y` must contain at least one point.", call. = FALSE)
  }
  validate_direct_curve_log_axis(x, "x")
  validate_direct_curve_log_axis(y, "y")

  label <- validate_direct_curve_label(label)
  placement <- match.arg(placement)
  x.offset <- validate_direct_curve_scalar(
    x.offset, "x.offset", lower = 0, lower.inclusive = TRUE
  )
  peak.fraction <- validate_direct_curve_scalar(
    peak.fraction, "peak.fraction", lower = 0, upper = 1,
    lower.inclusive = FALSE, upper.inclusive = TRUE
  )
  x.text.offset <- validate_direct_curve_scalar(x.text.offset, "x.text.offset")
  y.text.offset <- validate_direct_curve_scalar(y.text.offset, "y.text.offset")

  point <- direct_curve_label_point(
    x = x,
    y = y,
    placement = placement,
    x.offset = x.offset,
    peak.fraction = peak.fraction,
    x.text.offset = x.text.offset,
    y.text.offset = y.text.offset
  )

  old.xpd <- graphics::par("xpd")
  on.exit(graphics::par(xpd = old.xpd), add = TRUE)
  graphics::par(xpd = xpd)

  graphics::text(
    x = point[["x"]],
    y = point[["y"]],
    labels = label,
    adj = adj,
    col = col,
    cex = cex,
    font = font,
    ...
  )

  invisible(point)
}

#' Validate direct-curve coordinate input
#'
#' @param x Coordinate vector.
#' @param name Argument name.
#'
#' @return Numeric vector.
#' @noRd
validate_direct_curve_xy <- function(x, name) {
  if (!is.numeric(x)) {
    stop("`", name, "` must be numeric.", call. = FALSE)
  }
  if (any(!is.finite(x))) {
    stop("`", name, "` must contain only finite values.", call. = FALSE)
  }
  as.numeric(x)
}

#' Validate direct-curve coordinates against the active log axis
#'
#' @param x Coordinate vector.
#' @param axis Axis name, either `"x"` or `"y"`.
#'
#' @return Invisibly returns `NULL`.
#' @noRd
validate_direct_curve_log_axis <- function(x, axis) {
  axis <- match.arg(axis, c("x", "y"))
  if (graphics_axis_is_log(axis) && any(x <= 0)) {
    stop(
      "`", axis, "` must contain only positive values on a log-scale ",
      axis,
      " axis.",
      call. = FALSE
    )
  }

  invisible(NULL)
}

#' Validate a direct-curve scalar setting
#'
#' @param x Setting value.
#' @param name Argument name.
#' @param lower,upper Optional finite bounds.
#' @param lower.inclusive,upper.inclusive Should bounds include equality?
#'
#' @return A numeric scalar.
#' @noRd
validate_direct_curve_scalar <- function(x, name,
                                         lower = NULL,
                                         upper = NULL,
                                         lower.inclusive = TRUE,
                                         upper.inclusive = TRUE) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x)) {
    stop("`", name, "` must be a finite numeric scalar.", call. = FALSE)
  }
  if (!is.null(lower)) {
    too.low <- if (isTRUE(lower.inclusive)) x < lower else x <= lower
    if (too.low) {
      bound <- if (isTRUE(lower.inclusive)) "greater than or equal to" else "greater than"
      stop("`", name, "` must be ", bound, " ", lower, ".", call. = FALSE)
    }
  }
  if (!is.null(upper)) {
    too.high <- if (isTRUE(upper.inclusive)) x > upper else x >= upper
    if (too.high) {
      bound <- if (isTRUE(upper.inclusive)) "less than or equal to" else "less than"
      stop("`", name, "` must be ", bound, " ", upper, ".", call. = FALSE)
    }
  }

  as.numeric(x)
}

#' Validate a direct-curve label
#'
#' @param label Label input.
#'
#' @return Label input.
#' @noRd
validate_direct_curve_label <- function(label) {
  if (missing(label) || length(label) != 1L) {
    stop("`label` must be a single label.", call. = FALSE)
  }
  if (is.character(label) && !nzchar(label)) {
    stop("`label` must not be empty.", call. = FALSE)
  }

  label
}

#' Choose a direct label point on a curve
#'
#' @param x,y Numeric curve coordinates.
#' @param placement Placement rule.
#' @param x.offset,peak.fraction,x.text.offset,y.text.offset Placement settings.
#'
#' @return Numeric vector `c(x = ..., y = ...)`.
#' @noRd
direct_curve_label_point <- function(x, y,
                                     placement,
                                     x.offset,
                                     peak.fraction,
                                     x.text.offset,
                                     y.text.offset) {
  keep <- is.finite(x) & is.finite(y)
  if (!any(keep)) {
    stop("`x` and `y` must contain at least one finite coordinate pair.",
         call. = FALSE)
  }

  panel.width <- graphics_user_span("x", fallback = x[keep], name = "x")
  panel.height <- graphics_user_span("y", fallback = y[keep], name = "y")

  keep.index <- which(keep)
  peak.index <- keep.index[which.max(y[keep.index])]
  peak.x <- x[[peak.index]]
  peak.y <- y[[peak.index]]
  after.index <- keep.index[keep.index > peak.index & x[keep.index] > peak.x]

  point <- switch(
    placement,
    x_offset = direct_curve_label_point_x_offset(
      x = x,
      y = y,
      keep.index = keep.index,
      after.index = after.index,
      peak.x = peak.x,
      x.offset = x.offset,
      panel.width = panel.width
    ),
    peak_fraction = direct_curve_label_point_peak_fraction(
      x = x,
      y = y,
      keep.index = keep.index,
      after.index = after.index,
      peak.index = peak.index,
      peak.x = peak.x,
      peak.y = peak.y,
      peak.fraction = peak.fraction
    )
  )

  point.user <- c(
    x = graphics_data_to_user(point[["x"]], "x", name = "x"),
    y = graphics_data_to_user(point[["y"]], "y", name = "y")
  )
  point <- c(
    x = graphics_user_to_data(
      point.user[["x"]] + x.text.offset * panel.width,
      "x"
    ),
    y = graphics_user_to_data(
      point.user[["y"]] + y.text.offset * panel.height,
      "y"
    )
  )
  if (any(!is.finite(point))) {
    stop("Could not compute a finite direct-curve label point.", call. = FALSE)
  }

  point
}

#' Choose an x-offset label point
#'
#' @return Numeric vector `c(x = ..., y = ...)`.
#' @noRd
direct_curve_label_point_x_offset <- function(x, y,
                                              keep.index,
                                              after.index,
                                              peak.x,
                                              x.offset,
                                              panel.width) {
  target.x <- graphics_data_to_user(peak.x, "x", name = "x") +
    x.offset * panel.width
  candidate <- after.index
  if (length(candidate) == 0L) {
    candidate <- keep.index
  }
  candidate.x <- graphics_data_to_user(x[candidate], "x", name = "x")
  label.index <- candidate[which.min(abs(candidate.x - target.x))]
  c(x = x[[label.index]], y = y[[label.index]])
}

#' Choose a peak-fraction label point
#'
#' @return Numeric vector `c(x = ..., y = ...)`.
#' @noRd
direct_curve_label_point_peak_fraction <- function(x, y,
                                                   keep.index,
                                                   after.index,
                                                   peak.index,
                                                   peak.x,
                                                   peak.y,
                                                   peak.fraction) {
  if (peak.fraction == 1) {
    return(c(x = peak.x, y = peak.y))
  }

  target.y <- peak.fraction * peak.y
  candidate <- after.index
  crossing <- candidate[y[candidate] <= target.y]
  if (length(crossing) == 0L) {
    candidate <- if (length(candidate) > 0L) candidate else keep.index
    label.index <- candidate[which.max(x[candidate])]
    return(c(x = x[[label.index]], y = y[[label.index]]))
  }

  index.right <- crossing[[1L]]
  previous <- c(peak.index, candidate[candidate < index.right])
  index.left <- previous[[length(previous)]]
  x.left <- x[[index.left]]
  x.right <- x[[index.right]]
  y.left <- y[[index.left]]
  y.right <- y[[index.right]]

  if (is.finite(y.left) && is.finite(y.right) &&
      y.left != y.right &&
      is.finite(x.left) && is.finite(x.right)) {
    frac <- (target.y - y.left) / (y.right - y.left)
    if (is.finite(frac) && frac >= 0 && frac <= 1) {
      return(c(
        x = x.left + frac * (x.right - x.left),
        y = target.y
      ))
    }
  }

  c(x = x.right, y = y.right)
}
