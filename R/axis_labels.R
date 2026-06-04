#' Place labels near axis ends
#'
#' Add TeX-aware axis labels to the current base graphics plot without relying
#' on the usual centred `xlab` and `ylab` margins. Along-axis labels are drawn
#' with [graphics::mtext()] on the same line as numerical tick labels. Axis-end
#' labels are drawn with [graphics::text()] just inside the plotting region near
#' the right or top end of an axis.
#'
#' `axis_labels()` is intended to be called after a plot has already been drawn,
#' usually with `xlab = ""`, `ylab = ""`, and `las = 1`.
#'
#' @param xlab,ylab Optional character scalar labels for the horizontal and
#'   vertical axes. Non-`NULL` labels are passed through [nice_text()] before
#'   drawing, so TeX-like labels work in ordinary and tikz graphics contexts.
#' @param x.pos Position for `xlab`. `"right"` and `"left"` place the label
#'   along the bottom tick-label margin near the corresponding end of the axis.
#'   `"centre"` and `"center"` place it at the centre. `"end"` places it just
#'   inside the right end of the x-axis using [graphics::text()].
#' @param y.pos Position for `ylab`. `"top"` and `"bottom"` place the label
#'   along the left tick-label margin near the corresponding end of the axis.
#'   `"centre"` and `"center"` place it at the centre. `"end"` places it just
#'   inside the top end of the y-axis using [graphics::text()].
#' @param x.at,y.at Optional explicit user-coordinate positions. `x.at`
#'   overrides the default tick-based horizontal position for `xlab`; `y.at`
#'   overrides the default tick-based vertical position for `ylab`.
#' @param x.frac,y.frac Fractions of the current plotting range used as
#'   fallbacks for along-axis placement when fewer than two usable tick marks
#'   are available. For example, `x.pos = "right"` falls back to `x.frac`, while
#'   `x.pos = "left"` falls back to `1 - x.frac`.
#' @param x.end.offset,y.end.offset Fractions of the current plotting range used
#'   to move axis-end labels just inside the plot region. This avoids clipping
#'   and avoids requiring extra margins.
#' @param line Margin line passed to [graphics::mtext()] for along-axis labels.
#'   The default `par("mgp")[2]` aligns labels with numerical tick labels.
#' @param cex Text size passed to [graphics::mtext()] and [graphics::text()].
#' @param las Text orientation passed to [graphics::mtext()]. The default
#'   `las = 1` draws horizontal along-axis labels.
#' @param col Text colour passed to [graphics::mtext()] and [graphics::text()].
#' @param use.tikz Optional logical scalar passed to [nice_text()]. If `NULL`,
#'   [nice_text()] resolves tikz mode from the caller or active graphics device.
#' @param ... Additional graphical arguments passed to [graphics::mtext()] and
#'   [graphics::text()], such as `font`, `adj`, or `xpd`.
#'
#' @return Invisibly returns an `earnmisc_axis_labels_info` list containing the
#'   original and rendered labels, resolved positions, placement source, tick
#'   values used for tick-based placement, drawing method for each label,
#'   graphical settings, current `usr`, and log-axis state.
#'
#' @details
#' For `x.pos = "right"`, `"left"`, `"centre"`, and `"center"`, the horizontal
#' label is drawn on side 1 with [graphics::mtext()]. For `y.pos = "top"`,
#' `"bottom"`, `"centre"`, and `"center"`, the vertical label is drawn on side 2
#' with [graphics::mtext()]. These labels use `line = par("mgp")[2]` by default,
#' matching the tick-label line and avoiding extra margin requirements.
#' `"right"` and `"top"` default to the midpoint between the largest two usable
#' tick marks on that axis. `"left"` and `"bottom"` use the midpoint between the
#' smallest two usable tick marks. If fewer than two usable ticks are available,
#' `x.frac` or `y.frac` supplies the fallback position. Explicit `x.at` and
#' `y.at` always override tick and fractional placement.
#'
#' For `x.pos = "end"` and `y.pos = "end"`, labels are drawn with
#' [graphics::text()] inside the plot region. The x-axis end label is placed
#' near the lower-right corner; the y-axis end label is placed near the
#' upper-left corner. The offsets are measured as fractions of the visible plot
#' range in the current graphics coordinate system. On log axes, fractions are
#' computed on the transformed axis scale and then converted back to ordinary
#' user coordinates for drawing.
#'
#' @examples
#' x <- seq(0, 1, length.out = 100)
#' plot(x, x * (1 - x), xlab = "", ylab = "", las = 1)
#' axis_labels("$x$", "$y$", x.pos = "right", y.pos = "top")
#'
#' plot(x, sin(2 * pi * x), xlab = "", ylab = "", las = 1)
#' axis_labels("$\\tau$", "$\\iota$", x.pos = "end", y.pos = "end")
#'
#' @export
axis_labels <- function(
  xlab = NULL,
  ylab = NULL,
  x.pos = c("right", "left", "centre", "center", "end"),
  y.pos = c("top", "bottom", "centre", "center", "end"),
  x.at = NULL,
  y.at = NULL,
  x.frac = 0.96,
  y.frac = 0.96,
  x.end.offset = 0.02,
  y.end.offset = 0.02,
  line = graphics::par("mgp")[2],
  cex = 1.5,
  las = 1,
  col = graphics::par("col.axis"),
  use.tikz = NULL,
  ...
) {
  xlab <- validate_axis_label_text(xlab, "xlab")
  ylab <- validate_axis_label_text(ylab, "ylab")
  x.pos <- normalise_axis_label_position(
    x.pos,
    choices = c("right", "left", "centre", "center", "end"),
    name = "x.pos"
  )
  y.pos <- normalise_axis_label_position(
    y.pos,
    choices = c("top", "bottom", "centre", "center", "end"),
    name = "y.pos"
  )
  x.at <- validate_axis_label_optional_numeric(x.at, "x.at")
  y.at <- validate_axis_label_optional_numeric(y.at, "y.at")
  x.frac <- validate_axis_label_fraction(x.frac, "x.frac")
  y.frac <- validate_axis_label_fraction(y.frac, "y.frac")
  x.end.offset <- validate_axis_label_fraction(x.end.offset, "x.end.offset")
  y.end.offset <- validate_axis_label_fraction(y.end.offset, "y.end.offset")
  line <- validate_axis_label_numeric_scalar(line, "line")
  cex <- validate_axis_label_positive_numeric(cex, "cex")
  las <- validate_axis_label_las(las)
  col <- validate_axis_label_colour(col)

  usr <- graphics::par("usr")
  xlog <- graphics::par("xlog")
  ylog <- graphics::par("ylog")
  rendered.xlab <- render_axis_label_text(xlab, use.tikz = use.tikz)
  rendered.ylab <- render_axis_label_text(ylab, use.tikz = use.tikz)

  x.info <- draw_axis_label(
    axis = "x",
    label = rendered.xlab,
    original.label = xlab,
    position = x.pos,
    at = x.at,
    frac = x.frac,
    end.offset = x.end.offset,
    cross.offset = y.end.offset,
    usr = usr,
    axis.log = xlog,
    cross.log = ylog,
    line = line,
    cex = cex,
    las = las,
    col = col,
    ...
  )
  y.info <- draw_axis_label(
    axis = "y",
    label = rendered.ylab,
    original.label = ylab,
    position = y.pos,
    at = y.at,
    frac = y.frac,
    end.offset = y.end.offset,
    cross.offset = x.end.offset,
    usr = usr,
    axis.log = ylog,
    cross.log = xlog,
    line = line,
    cex = cex,
    las = las,
    col = col,
    ...
  )

  labels <- rbind(x.info, y.info)
  rownames(labels) <- NULL

  out <- list(
    xlab = xlab,
    ylab = ylab,
    rendered.xlab = rendered.xlab,
    rendered.ylab = rendered.ylab,
    x.pos = x.pos,
    y.pos = y.pos,
    x.at = x.info$at,
    y.at = y.info$at,
    x.placement.source = x.info$placement.source,
    y.placement.source = y.info$placement.source,
    x.tick.values = axis_label_tick_values(x.info),
    y.tick.values = axis_label_tick_values(y.info),
    x.frac = x.frac,
    y.frac = y.frac,
    x.end.offset = x.end.offset,
    y.end.offset = y.end.offset,
    labels = labels,
    line = line,
    cex = cex,
    las = las,
    col = col,
    usr = usr,
    xlog = xlog,
    ylog = ylog,
    device = unname(grDevices::dev.cur())
  )
  class(out) <- c("earnmisc_axis_labels_info", "list")

  invisible(out)
}

#' Validate an axis label string
#'
#' @param label Candidate label.
#' @param name Argument name.
#'
#' @return `NULL` or a character scalar.
#' @noRd
validate_axis_label_text <- function(label, name) {
  if (is.null(label)) {
    return(NULL)
  }
  if (!is.character(label) || length(label) != 1L || is.na(label)) {
    stop("`", name, "` must be NULL or a character scalar.", call. = FALSE)
  }
  label
}

#' Normalise an axis label position
#'
#' @param position Candidate position.
#' @param choices Allowed positions.
#' @param name Argument name.
#'
#' @return Normalised position.
#' @noRd
normalise_axis_label_position <- function(position, choices, name) {
  if (!is.character(position) || length(position) < 1L || anyNA(position)) {
    stop("`", name, "` must be one of: ", paste(choices, collapse = ", "), ".",
         call. = FALSE)
  }
  position <- tryCatch(
    match.arg(position, choices = choices),
    error = function(error) {
      stop("`", name, "` must be one of: ", paste(choices, collapse = ", "), ".",
           call. = FALSE)
    }
  )
  if (identical(position, "center")) {
    return("centre")
  }
  position
}

#' Validate an optional numeric scalar
#'
#' @param value Candidate value.
#' @param name Argument name.
#'
#' @return `NULL` or a finite numeric scalar.
#' @noRd
validate_axis_label_optional_numeric <- function(value, name) {
  if (is.null(value)) {
    return(NULL)
  }
  validate_axis_label_numeric_scalar(value, name)
}

#' Validate a finite numeric scalar
#'
#' @param value Candidate value.
#' @param name Argument name.
#'
#' @return Finite numeric scalar.
#' @noRd
validate_axis_label_numeric_scalar <- function(value, name) {
  if (!is.numeric(value) || length(value) != 1L ||
      is.na(value) || !is.finite(value)) {
    stop("`", name, "` must be a finite numeric scalar.", call. = FALSE)
  }
  as.numeric(value)
}

#' Validate a fraction
#'
#' @param value Candidate value.
#' @param name Argument name.
#'
#' @return Numeric scalar in `[0, 1]`.
#' @noRd
validate_axis_label_fraction <- function(value, name) {
  value <- validate_axis_label_numeric_scalar(value, name)
  if (value < 0 || value > 1) {
    stop("`", name, "` must be a numeric scalar in [0, 1].", call. = FALSE)
  }
  value
}

#' Validate a positive numeric scalar
#'
#' @param value Candidate value.
#' @param name Argument name.
#'
#' @return Positive numeric scalar.
#' @noRd
validate_axis_label_positive_numeric <- function(value, name) {
  value <- validate_axis_label_numeric_scalar(value, name)
  if (value <= 0) {
    stop("`", name, "` must be positive.", call. = FALSE)
  }
  value
}

#' Validate an axis label las value
#'
#' @param las Candidate value.
#'
#' @return Integer-like numeric scalar.
#' @noRd
validate_axis_label_las <- function(las) {
  las <- validate_axis_label_numeric_scalar(las, "las")
  if (!(las %in% 0:3)) {
    stop("`las` must be one of 0, 1, 2, or 3.", call. = FALSE)
  }
  las
}

#' Validate an axis label colour
#'
#' @param col Candidate colour.
#'
#' @return Scalar colour value.
#' @noRd
validate_axis_label_colour <- function(col) {
  if ((!is.character(col) && !is.numeric(col)) || length(col) != 1L ||
      is.na(col)) {
    stop("`col` must be a non-missing character or numeric scalar.", call. = FALSE)
  }
  col
}

#' Render an axis label
#'
#' @param label Original label.
#' @param use.tikz Optional tikz mode.
#'
#' @return `NULL` or a rendered label.
#' @noRd
render_axis_label_text <- function(label, use.tikz) {
  if (is.null(label)) {
    return(NULL)
  }
  nice_text(label, use.tikz = use.tikz, warn = FALSE)
}

#' Draw one axis label
#'
#' @param axis Axis name, `"x"` or `"y"`.
#' @param label Rendered label.
#' @param original.label Original label.
#' @param position Normalised label position.
#' @param at Optional explicit axis coordinate.
#' @param frac Fraction for along-axis placement.
#' @param end.offset Offset along the labelled axis.
#' @param cross.offset Offset along the cross axis.
#' @param usr Current `par("usr")`.
#' @param axis.log,cross.log Log-axis flags.
#' @param line,cex,las,col Graphical settings.
#' @param ... Additional graphical parameters.
#'
#' @return One-row data frame of resolved drawing metadata.
#' @noRd
draw_axis_label <- function(axis,
                            label,
                            original.label,
                            position,
                            at,
                            frac,
                            end.offset,
                            cross.offset,
                            usr,
                            axis.log,
                            cross.log,
                            line,
                            cex,
                            las,
                            col,
                            ...) {
  if (is.null(original.label)) {
    return(axis_label_row(
      axis = axis,
      original.label = NA_character_,
      position = position,
      method = "none",
      side = NA_integer_,
      at = NA_real_,
      x = NA_real_,
      y = NA_real_,
      line = line,
      cex = cex,
      las = las,
      col = col,
      placement.source = NA_character_,
      tick.lower = NA_real_,
      tick.upper = NA_real_,
      drawn = FALSE
    ))
  }

  if (identical(position, "end")) {
    coordinates <- axis_label_end_coordinates(
      axis = axis,
      at = at,
      end.offset = end.offset,
      cross.offset = cross.offset,
      usr = usr,
      axis.log = axis.log,
      cross.log = cross.log
    )
    graphics::text(
      x = coordinates$x,
      y = coordinates$y,
      labels = label,
      cex = cex,
      col = col,
      ...
    )
    return(axis_label_row(
      axis = axis,
      original.label = original.label,
      position = position,
      method = "text",
      side = if (identical(axis, "x")) 1L else 2L,
      at = if (identical(axis, "x")) coordinates$x else coordinates$y,
      x = coordinates$x,
      y = coordinates$y,
      line = line,
      cex = cex,
      las = las,
      col = col,
      placement.source = if (is.null(at)) "end" else "explicit",
      tick.lower = NA_real_,
      tick.upper = NA_real_,
      drawn = TRUE
    ))
  }

  side <- if (identical(axis, "x")) 1L else 2L
  placement <- resolve_axis_label_at(
    axis = axis,
    side = side,
    position = position,
    at = at,
    frac = frac,
    usr = usr,
    log.axis = axis.log
  )
  graphics::mtext(
    text = label,
    side = side,
    line = line,
    at = placement$at,
    las = las,
    cex = cex,
    col = col,
    ...
  )

  axis_label_row(
    axis = axis,
    original.label = original.label,
    position = position,
    method = "mtext",
    side = side,
    at = placement$at,
    x = if (identical(axis, "x")) placement$at else NA_real_,
    y = if (identical(axis, "y")) placement$at else NA_real_,
    line = line,
    cex = cex,
    las = las,
    col = col,
    placement.source = placement$placement.source,
    tick.lower = placement$tick.lower,
    tick.upper = placement$tick.upper,
    drawn = TRUE
  )
}

#' Return an axis label metadata row
#'
#' @return One-row data frame.
#' @noRd
axis_label_row <- function(axis,
                           original.label,
                           position,
                           method,
                           side,
                           at,
                           x,
                           y,
                           line,
                           cex,
                           las,
                           col,
                           placement.source,
                           tick.lower,
                           tick.upper,
                           drawn) {
  data.frame(
    axis = axis,
    label = original.label,
    position = position,
    method = method,
    side = side,
    at = at,
    x = x,
    y = y,
    line = line,
    cex = cex,
    las = las,
    col = as.character(col),
    placement.source = placement.source,
    tick.lower = tick.lower,
    tick.upper = tick.upper,
    drawn = drawn,
    stringsAsFactors = FALSE
  )
}

#' Resolve the axis coordinate for an along-axis label
#'
#' @param axis Axis name.
#' @param side Base graphics axis side.
#' @param position Normalised non-end position.
#' @param at Optional explicit coordinate.
#' @param frac Fallback fractional position.
#' @param usr Current `par("usr")`.
#' @param log.axis Log-axis flag.
#'
#' @return List with resolved coordinate, placement source, and tick metadata.
#' @noRd
resolve_axis_label_at <- function(axis, side, position, at, frac, usr, log.axis) {
  if (!is.null(at)) {
    return(list(
      at = at,
      placement.source = "explicit",
      tick.lower = NA_real_,
      tick.upper = NA_real_
    ))
  }

  if (!identical(position, "centre")) {
    tick.at <- axis_label_tick_midpoint(
      ticks = axis_label_usable_ticks(
        side = side,
        axis = axis,
        usr = usr,
        log.axis = log.axis
      ),
      position = position,
      log.axis = log.axis
    )
    if (!is.null(tick.at)) {
      return(tick.at)
    }
  }

  list(
    at = axis_label_fraction_coordinate(
      usr = usr,
      axis = axis,
      fraction = axis_label_position_fraction(position, frac),
      log.axis = log.axis
    ),
    placement.source = "fraction",
    tick.lower = NA_real_,
    tick.upper = NA_real_
  )
}

#' Return usable tick positions for axis-label placement
#'
#' @param side Base graphics axis side.
#' @param axis Axis name.
#' @param usr Current `par("usr")`.
#' @param log.axis Log-axis flag.
#'
#' @return Sorted numeric vector of finite visible tick values.
#' @noRd
axis_label_usable_ticks <- function(side, axis, usr, log.axis) {
  ticks <- graphics::axTicks(side)
  if (length(ticks) == 0L) {
    return(numeric())
  }

  limits <- axis_label_visible_limits(usr = usr, axis = axis, log.axis = log.axis)
  ticks <- ticks[
    is.finite(ticks) &
      ticks >= min(limits) &
      ticks <= max(limits)
  ]
  if (log.axis) {
    ticks <- ticks[ticks > 0]
  }
  sort(unique(ticks))
}

#' Return visible axis limits in ordinary user coordinates
#'
#' @param usr Current `par("usr")`.
#' @param axis Axis name.
#' @param log.axis Log-axis flag.
#'
#' @return Numeric vector of length two.
#' @noRd
axis_label_visible_limits <- function(usr, axis, log.axis) {
  limits <- if (identical(axis, "x")) usr[1:2] else usr[3:4]
  if (log.axis) {
    return(10^limits)
  }
  limits
}

#' Return a midpoint between end ticks
#'
#' @param ticks Usable tick values.
#' @param position Normalised position.
#' @param log.axis Log-axis flag.
#'
#' @return `NULL` or tick-placement metadata.
#' @noRd
axis_label_tick_midpoint <- function(ticks, position, log.axis) {
  if (length(ticks) < 2L) {
    return(NULL)
  }

  tick.pair <- if (position %in% c("right", "top")) {
    ticks[(length(ticks) - 1L):length(ticks)]
  } else if (position %in% c("left", "bottom")) {
    ticks[1:2]
  } else {
    return(NULL)
  }

  midpoint <- if (log.axis) {
    10^mean(log10(tick.pair))
  } else {
    mean(tick.pair)
  }

  list(
    at = midpoint,
    placement.source = "ticks",
    tick.lower = tick.pair[[1L]],
    tick.upper = tick.pair[[2L]]
  )
}

#' Return tick values from one label metadata row
#'
#' @param label.info One-row label metadata.
#'
#' @return Numeric vector of tick values used for placement, or empty vector.
#' @noRd
axis_label_tick_values <- function(label.info) {
  if (!identical(label.info$placement.source[[1L]], "ticks")) {
    return(numeric())
  }
  c(label.info$tick.lower[[1L]], label.info$tick.upper[[1L]])
}

#' Resolve a positional fraction
#'
#' @param position Normalised non-end position.
#' @param frac User-supplied end fraction.
#'
#' @return Numeric scalar.
#' @noRd
axis_label_position_fraction <- function(position, frac) {
  switch(
    position,
    right = frac,
    left = 1 - frac,
    top = frac,
    bottom = 1 - frac,
    centre = 0.5
  )
}

#' Resolve a coordinate from a fractional axis position
#'
#' @param usr Current `par("usr")`.
#' @param axis Axis name.
#' @param fraction Fraction of transformed axis span.
#' @param log.axis Log-axis flag.
#'
#' @return Coordinate suitable for base graphics drawing calls.
#' @noRd
axis_label_fraction_coordinate <- function(usr, axis, fraction, log.axis) {
  limits <- if (identical(axis, "x")) usr[1:2] else usr[3:4]
  transformed <- limits[[1L]] + fraction * (limits[[2L]] - limits[[1L]])
  if (log.axis) {
    return(10^transformed)
  }
  transformed
}

#' Resolve axis-end label coordinates
#'
#' @param axis Axis name.
#' @param at Optional coordinate on labelled axis.
#' @param end.offset Offset along labelled axis.
#' @param cross.offset Offset along cross axis.
#' @param usr Current `par("usr")`.
#' @param axis.log,cross.log Log-axis flags.
#'
#' @return List with `x` and `y` coordinates.
#' @noRd
axis_label_end_coordinates <- function(axis,
                                       at,
                                       end.offset,
                                       cross.offset,
                                       usr,
                                       axis.log,
                                       cross.log) {
  if (identical(axis, "x")) {
    x <- if (is.null(at)) {
      axis_label_fraction_coordinate(
        usr = usr,
        axis = "x",
        fraction = 1 - end.offset,
        log.axis = axis.log
      )
    } else {
      at
    }
    y <- axis_label_fraction_coordinate(
      usr = usr,
      axis = "y",
      fraction = cross.offset,
      log.axis = cross.log
    )
    return(list(x = x, y = y))
  }

  x <- axis_label_fraction_coordinate(
    usr = usr,
    axis = "x",
    fraction = cross.offset,
    log.axis = cross.log
  )
  y <- if (is.null(at)) {
    axis_label_fraction_coordinate(
      usr = usr,
      axis = "y",
      fraction = 1 - end.offset,
      log.axis = axis.log
    )
  } else {
    at
  }
  list(x = x, y = y)
}
