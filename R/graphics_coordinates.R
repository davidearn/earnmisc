#' Check whether a base-graphics axis is logarithmic
#'
#' @param axis Axis name, either `"x"` or `"y"`.
#'
#' @return Logical scalar.
#' @noRd
graphics_axis_is_log <- function(axis) {
  axis <- match.arg(axis, c("x", "y"))
  isTRUE(graphics::par(if (identical(axis, "x")) "xlog" else "ylog"))
}

#' Convert data coordinates to base-graphics user coordinates
#'
#' On log axes, `graphics::par("usr")` is stored on the log10 scale while
#' drawing functions such as [graphics::text()] accept data coordinates.
#'
#' @param value Numeric coordinate vector in data space.
#' @param axis Axis name, either `"x"` or `"y"`.
#' @param name Argument name for error messages.
#'
#' @return Numeric coordinate vector in the current user-coordinate scale.
#' @noRd
graphics_data_to_user <- function(value, axis, name = axis) {
  axis <- match.arg(axis, c("x", "y"))
  if (!graphics_axis_is_log(axis)) {
    return(value)
  }

  if (any(!is.finite(value) | value <= 0)) {
    stop(
      "`", name, "` must contain only positive finite values on a log-scale ",
      axis,
      " axis.",
      call. = FALSE
    )
  }

  log10(value)
}

#' Convert base-graphics user coordinates to data coordinates
#'
#' @param value Numeric coordinate vector in the current user-coordinate scale.
#' @param axis Axis name, either `"x"` or `"y"`.
#'
#' @return Numeric coordinate vector in data space.
#' @noRd
graphics_user_to_data <- function(value, axis) {
  axis <- match.arg(axis, c("x", "y"))
  if (graphics_axis_is_log(axis)) {
    return(10^value)
  }

  value
}

#' Current panel span in base-graphics user coordinates
#'
#' @param axis Axis name, either `"x"` or `"y"`.
#' @param fallback Optional finite data coordinates used if `par("usr")` does
#'   not provide a usable span.
#' @param name Argument name for fallback coordinate errors.
#'
#' @return Positive finite numeric scalar.
#' @noRd
graphics_user_span <- function(axis, fallback = NULL, name = axis) {
  axis <- match.arg(axis, c("x", "y"))
  usr <- graphics::par("usr")
  limits <- if (identical(axis, "x")) usr[1:2] else usr[3:4]
  span <- diff(limits)

  if ((!is.finite(span) || span == 0) && !is.null(fallback)) {
    fallback <- fallback[is.finite(fallback)]
    if (length(fallback) > 0L) {
      fallback.user <- graphics_data_to_user(fallback, axis, name = name)
      span <- diff(range(fallback.user))
    }
  }

  if (!is.finite(span) || span == 0) {
    span <- 1
  }

  abs(span)
}
