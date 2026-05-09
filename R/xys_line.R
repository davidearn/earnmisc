#' Draw lines through points with specified slopes
#'
#' Draw straight lines through all combinations of `x`, `y`, and `slope`.
#'
#' @param x Numeric vector giving x-coordinates of points on the lines.
#' @param y Numeric vector giving y-coordinates of points on the lines.
#' @param slope Numeric vector giving slopes of the lines.
#' @param ... Additional graphical parameters passed to [graphics::abline()].
#'
#' @return For scalar input, invisibly returns a named numeric vector with
#'   elements `intercept` and `slope`. For vector input, invisibly returns a
#'   data frame with columns `x`, `y`, `slope`, and `intercept`, one row per
#'   plotted line.
#'
#' @examples
#' plot(1:10, 1:10)
#' xys_line(3, 4, slope = 1)
#' xys_line(5, 8, slope = -0.5, col = "red", lty = 2)
#'
#' plot(0:1, 0:1, type = "n")
#' xys_line(0, c(0.1, -0.1), slope = 1, col = "grey")
#'
#' @export
xys_line <- function(x, y, slope, ...) {
  if (!is.numeric(x) || length(x) < 1L || anyNA(x)) {
    stop("`x` must be a numeric vector with no missing values.", call. = FALSE)
  }
  if (!is.numeric(y) || length(y) < 1L || anyNA(y)) {
    stop("`y` must be a numeric vector with no missing values.", call. = FALSE)
  }
  if (!is.numeric(slope) || length(slope) < 1L || anyNA(slope)) {
    stop("`slope` must be a numeric vector with no missing values.", call. = FALSE)
  }

  line.parameters <- expand.grid(
    x = x,
    y = y,
    slope = slope,
    KEEP.OUT.ATTRS = FALSE
  )
  line.parameters$intercept <- line.parameters$y - line.parameters$slope * line.parameters$x

  for (line.number in seq_len(nrow(line.parameters))) {
    graphics::abline(
      a = line.parameters$intercept[line.number],
      b = line.parameters$slope[line.number],
      ...
    )
  }

  if (nrow(line.parameters) == 1L) {
    scalar.parameters <- c(
      intercept = line.parameters$intercept,
      slope = line.parameters$slope
    )
    return(invisible(scalar.parameters))
  }

  invisible(line.parameters)
}
