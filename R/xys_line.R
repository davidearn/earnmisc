#' Draw lines through points with specified slopes
#'
#' `xys_line()` is an S3 generic. The default method draws straight lines
#' through all combinations of numeric `x`, `y`, and `slope` values. Other
#' packages can provide methods for their own classes while reusing the same
#' point/slope convention.
#'
#' @param object Object used for S3 method dispatch. For ordinary numeric use,
#'   this is the x-coordinate of a point on the line. Calls using the
#'   user-facing name `x =` are also supported by the default method.
#' @param ... Additional arguments passed to methods. For the default method,
#'   graphical parameters passed to [graphics::abline()]. When more than one
#'   line is drawn, vector graphical parameters are recycled across lines using
#'   R's usual recycling rules.
#' @param y Numeric vector giving y-coordinates of points on the lines.
#' @param slope Numeric vector giving slopes of the lines. Infinite slopes draw
#'   vertical lines through `x`.
#'
#' @return For scalar input, invisibly returns a named numeric vector with
#'   elements `intercept` and `slope`; vertical lines have
#'   `intercept = NA_real_`. For vector input, invisibly returns a data frame
#'   with columns `x`, `y`, `slope`, and `intercept`, one row per plotted line.
#'   Any expanded graphical parameters are stored in the
#'   `graphics.parameters` attribute of the returned value.
#'
#' @details
#' For ordinary numeric use, call `xys_line(x, y, slope, ...)`. The generic uses
#' `object` as its dispatch formal so downstream packages can define methods for
#' their own classes without confusing the dispatch object with the numeric
#' x-coordinate used by the default method.
#'
#' @examples
#' plot(1:10, 1:10)
#' xys_line(3, 4, slope = 1)
#' xys_line(x = 3, y = 4, slope = 1)
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
xys_line <- function(object, ...) {
  UseMethod("xys_line")
}

#' @rdname xys_line
#' @export
xys_line.default <- function(object, y, slope, ...) {
  dots <- list(...)
  if (missing(object)) {
    if (!("x" %in% names(dots))) {
      stop("`x` must be supplied for the default `xys_line()` method.", call. = FALSE)
    }
    x.index <- match("x", names(dots))
    object <- dots[[x.index]]
    dots <- dots[-x.index]
  }

  x <- object
  validate_xys_line_inputs(x = x, y = y, slope = slope)
  line.parameters <- xys_line_parameters(x = x, y = y, slope = slope)
  line.count <- nrow(line.parameters)
  graphics.parameters <- recycle_graphics_parameters(dots, line.count)

  draw_xys_lines(
    line.parameters = line.parameters,
    graphics.parameters = graphics.parameters
  )

  invisible(xys_line_return_value(
    line.parameters = line.parameters,
    graphics.parameters = graphics.parameters
  ))
}

#' Validate xys line inputs
#'
#' Validate numeric vectors used to define point/slope lines.
#'
#' @param x,y,slope Numeric vectors.
#'
#' @return Invisibly returns `TRUE`.
#' @noRd
validate_xys_line_inputs <- function(x, y, slope) {
  if (!is.numeric(x) || length(x) < 1L || anyNA(x)) {
    stop("`x` must be a numeric vector with no missing values.", call. = FALSE)
  }
  if (!is.numeric(y) || length(y) < 1L || anyNA(y)) {
    stop("`y` must be a numeric vector with no missing values.", call. = FALSE)
  }
  if (!is.numeric(slope) || length(slope) < 1L || anyNA(slope)) {
    stop("`slope` must be a numeric vector with no missing values.", call. = FALSE)
  }

  invisible(TRUE)
}

#' Build xys line parameters
#'
#' Expand point/slope inputs to all combinations and compute intercepts.
#'
#' @param x,y,slope Numeric vectors.
#'
#' @return A data frame with columns `x`, `y`, `slope`, and `intercept`.
#' @noRd
xys_line_parameters <- function(x, y, slope) {
  line.parameters <- expand.grid(
    x = x,
    y = y,
    slope = slope,
    KEEP.OUT.ATTRS = FALSE
  )
  line.parameters$intercept <- line.parameters$y - line.parameters$slope * line.parameters$x
  line.parameters$intercept[is.infinite(line.parameters$slope)] <- NA_real_

  line.parameters
}

#' Draw expanded xys lines
#'
#' Draw each expanded point/slope line with matching graphical parameters.
#'
#' @param line.parameters Data frame from [xys_line_parameters()].
#' @param graphics.parameters Recycled graphical parameter list.
#'
#' @return Invisibly returns `line.parameters`.
#' @noRd
draw_xys_lines <- function(line.parameters, graphics.parameters) {
  line.count <- nrow(line.parameters)
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

  invisible(line.parameters)
}

#' Return xys line parameters in the documented shape
#'
#' Return a scalar named vector for one line or a data frame for multiple
#' expanded lines.
#'
#' @param line.parameters Data frame from [xys_line_parameters()].
#' @param graphics.parameters Recycled graphical parameter list.
#'
#' @return A named numeric vector or data frame.
#' @noRd
xys_line_return_value <- function(line.parameters, graphics.parameters) {
  if (nrow(line.parameters) == 1L) {
    return(c(
      intercept = line.parameters$intercept,
      slope = line.parameters$slope
    ))
  }

  attr(line.parameters, "graphics.parameters") <- graphics.parameters
  line.parameters
}

#' Recycle graphical parameters over xys lines
#'
#' Recycle graphical parameters to one value per expanded line.
#'
#' @param graphics.parameters Named list of graphical parameters.
#' @param line.count Number of expanded lines.
#'
#' @return A named list with values recycled to `line.count`.
#' @noRd
recycle_graphics_parameters <- function(graphics.parameters, line.count) {
  if (length(graphics.parameters) == 0L) {
    return(list())
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

#' Select graphical parameters for one xys line
#'
#' Select scalar graphical parameters for one expanded line.
#'
#' @param graphics.parameters Recycled graphical parameter list.
#' @param line.number Line index.
#'
#' @return A named list of graphical parameters.
#' @noRd
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
