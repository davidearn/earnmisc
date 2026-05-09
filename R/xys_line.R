#' Draw lines through points with specified slopes
#'
#' Draw straight lines through all combinations of `x`, `y`, and `slope`.
#'
#' @param x Numeric vector giving x-coordinates of points on the lines.
#' @param y Numeric vector giving y-coordinates of points on the lines.
#' @param slope Numeric vector giving slopes of the lines. Infinite slopes draw
#'   vertical lines through `x`.
#' @param ... Additional graphical parameters passed to [graphics::abline()].
#'   When more than one line is drawn, vector graphical parameters are recycled
#'   across lines using R's usual recycling rules.
#'
#' @return For scalar input, invisibly returns a named numeric vector with
#'   elements `intercept` and `slope`; vertical lines have
#'   `intercept = NA_real_`. For vector input, invisibly returns a data frame
#'   with columns `x`, `y`, `slope`, and `intercept`, one row per plotted line.
#'   Any expanded graphical parameters are stored in the
#'   `graphics.parameters` attribute of the returned value.
#'
#' @examples
#' plot(1:10, 1:10)
#' xys_line(3, 4, slope = 1)
#' xys_line(5, 8, slope = -0.5, col = "red", lty = 2)
#'
#' plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))
#' xys_line(0, c(0.1, -0.1), slope = 1,
#'          col = c("blue", "red"), lty = c("solid", "dotted"))
#'
#' plot(0, 0, type = "n", xlim = c(-1, 1), ylim = c(-1, 1))
#' xys_line(c(-0.5, 0.5), 0, slope = Inf, col = c("blue", "red"))
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
  line.parameters$intercept[is.infinite(line.parameters$slope)] <- NA_real_

  line.count <- nrow(line.parameters)
  graphics.parameters <- recycle_graphics_parameters(list(...), line.count)

  for (line.number in seq_len(line.count)) {
    line.graphics.parameters <- graphics_parameters_for_line(
      graphics.parameters,
      line.number
    )

    if (is.infinite(line.parameters$slope[line.number])) {
      do.call(
        graphics::abline,
        c(list(v = line.parameters$x[line.number]), line.graphics.parameters)
      )
    } else {
      do.call(
        graphics::abline,
        c(
          list(
            a = line.parameters$intercept[line.number],
            b = line.parameters$slope[line.number]
          ),
          line.graphics.parameters
        )
      )
    }
  }

  if (line.count == 1L) {
    scalar.parameters <- c(
      intercept = line.parameters$intercept,
      slope = line.parameters$slope
    )
    return(invisible(scalar.parameters))
  }

  attr(line.parameters, "graphics.parameters") <- graphics.parameters
  invisible(line.parameters)
}

recycle_graphics_parameters <- function(graphics.parameters, line.count) {
  if (length(graphics.parameters) == 0L) {
    return(graphics.parameters)
  }

  for (parameter.name in names(graphics.parameters)) {
    parameter.value <- graphics.parameters[[parameter.name]]
    parameter.length <- length(parameter.value)

    if (parameter.length == 0L) {
      next
    }

    if (line.count %% parameter.length != 0L) {
      warning(
        "longer object length is not a multiple of shorter object length",
        call. = FALSE
      )
    }

    graphics.parameters[[parameter.name]] <- rep(
      parameter.value,
      length.out = line.count
    )
  }

  graphics.parameters
}

graphics_parameters_for_line <- function(graphics.parameters, line.number) {
  if (length(graphics.parameters) == 0L) {
    return(graphics.parameters)
  }

  for (parameter.name in names(graphics.parameters)) {
    parameter.value <- graphics.parameters[[parameter.name]]

    if (length(parameter.value) == 0L) {
      graphics.parameters[[parameter.name]] <- parameter.value
    } else {
      graphics.parameters[[parameter.name]] <- parameter.value[line.number]
    }
  }

  graphics.parameters
}
