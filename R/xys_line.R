#' Draw a line through a point with a specified slope
#'
#' Draw a straight line through point `(x, y)` with the specified slope.
#'
#' @param x Numeric scalar giving the x-coordinate of a point on the line.
#' @param y Numeric scalar giving the y-coordinate of a point on the line.
#' @param slope Numeric scalar giving the slope of the line.
#' @param ... Additional graphical parameters passed to [graphics::abline()].
#'
#' @return Invisibly returns a named numeric vector with elements `intercept`
#'   and `slope`.
#'
#' @examples
#' plot(1:10, 1:10)
#' xys_line(3, 4, slope = 1)
#' xys_line(5, 8, slope = -0.5, col = "red", lty = 2)
#'
#' @export
xys_line <- function(x, y, slope, ...) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x)) {
    stop("`x` must be a numeric scalar.", call. = FALSE)
  }
  if (!is.numeric(y) || length(y) != 1L || is.na(y)) {
    stop("`y` must be a numeric scalar.", call. = FALSE)
  }
  if (!is.numeric(slope) || length(slope) != 1L || is.na(slope)) {
    stop("`slope` must be a numeric scalar.", call. = FALSE)
  }

  intercept <- y - slope * x
  line.parameters <- c(intercept = intercept, slope = slope)

  graphics::abline(a = intercept, b = slope, ...)

  invisible(line.parameters)
}
