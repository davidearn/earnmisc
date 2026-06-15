#' Label a curve along its path
#'
#' `along_curve_label()` places one text label on or near a plotted curve or
#' polyline in the active base-graphics panel. It can place the label by
#' displayed arclength fraction, coordinate crossing, row index, nearest point,
#' or line intersection. Labels can be rotated along the local curve tangent,
#' kept upright, offset from the selected curve point, converted with
#' [nice_text()], and drawn over a rotated knockout background.
#'
#' @param x,y Numeric vectors giving the curve coordinates in data space.
#'   Coordinates must be compatible with the active log-axis state. Missing or
#'   infinite coordinate pairs are ignored when resolving the curve, but at
#'   least two adjacent finite usable points are required.
#' @param label Single label to draw. Character labels are converted with
#'   [nice_text()] when `nice.text = TRUE`; expression-like labels are used as
#'   supplied.
#' @param at Placement mode. `"fraction"` uses displayed arclength fraction;
#'   `"x"` and `"y"` use coordinate crossings; `"index"` uses a row index;
#'   `"point"` uses the nearest displayed point on the curve to `point`;
#'   `"line"` uses intersection with a line `y - line["y"] =
#'   line["slope"] * (x - line["x"])`.
#' @param fraction Arclength fraction for `at = "fraction"`. Must be between
#'   zero and one, inclusive.
#' @param x.at,y.at Finite coordinate target for `at = "x"` or `at = "y"`.
#' @param index Integer row index for `at = "index"`.
#' @param point Numeric coordinate pair for `at = "point"`.
#' @param line Named numeric vector or list with `x`, `y`, and `slope` entries
#'   for `at = "line"`. Infinite slopes are treated as vertical lines at
#'   `x = line["x"]`.
#' @param crossing Crossing-selection rule used by `"x"`, `"y"`, and `"line"`
#'   placement when more than one crossing is available. `"nearest"` selects
#'   the crossing nearest the middle of the displayed curve arclength.
#' @param offset Numeric vector `c(dx, dy)` applied after the curve point is
#'   selected.
#' @param offset.units Units for `offset`. `"npc"` interprets offsets as
#'   fractions of the current panel width and height on the displayed scale;
#'   `"data"` uses additive data-coordinate offsets; `"inches"` uses device
#'   inches.
#' @param rotate Logical scalar. If `TRUE`, compute a local tangent rotation in
#'   device coordinates.
#' @param srt Optional explicit rotation angle in degrees. If supplied, it
#'   overrides automatic tangent rotation.
#' @param upright Logical scalar. If `TRUE`, automatic angles are mapped to the
#'   readable range `[-90, 90]` degrees.
#' @param adj Text adjustment passed to [graphics::text()].
#' @param nice.text Logical scalar. If `TRUE`, character labels are converted
#'   with [nice_text()].
#' @param nice.text.args List of additional arguments passed to [nice_text()].
#'   The default conversion uses `warn = FALSE` unless overridden here.
#' @param knockout Logical scalar. If `TRUE`, draw a rotated rectangular
#'   background behind the label before drawing the text.
#' @param knockout.col,knockout.border Fill and border colours for the
#'   knockout polygon.
#' @param knockout.pad Positive numeric scalar or length-two vector multiplying
#'   the label width and height to determine the knockout size.
#' @param knockout.lwd Optional positive line width for the knockout border.
#' @param col,cex,font,xpd Graphical parameters passed to [graphics::text()].
#'   The previous `xpd` value is restored on exit when drawing occurs.
#' @param draw Logical scalar. If `FALSE`, resolve placement metadata without
#'   drawing the knockout or text.
#' @param ... Additional graphical parameters passed to [graphics::text()].
#'
#' @return Invisibly returns an `earnmisc_along_curve_label_info` list with the
#'   selected curve point, final text point, displayed/user coordinates,
#'   selected segment, tangent angle, final `srt`, rendered label, knockout
#'   metadata, and drawing flags.
#'
#' @examples
#' theta <- seq(0, 4 * pi, length.out = 300)
#' radius <- exp(-0.12 * theta)
#' x <- radius * cos(theta)
#' y <- radius * sin(theta)
#' plot(x, y, type = "l", asp = 1)
#' along_curve_label(x, y, "spiral", fraction = 0.55)
#'
#' x <- seq(-3, 3, length.out = 200)
#' y <- x^2 + 1
#' plot(x, y, type = "l")
#' along_curve_label(x, y, "$Y = \\hat{Y}$", at = "x", x.at = 1,
#'                   nice.text.args = list(warn = FALSE))
#'
#' x <- seq(0, 2 * pi, length.out = 200)
#' y <- sin(x)
#' plot(x, y, type = "l")
#' along_curve_label(x, y, "knockout", at = "fraction", fraction = 0.3,
#'                   knockout = TRUE)
#'
#' x <- seq(0.1, 10, length.out = 200)
#' y <- exp(-0.4 * x) + 0.02
#' plot(x, y, type = "l", log = "y")
#' along_curve_label(x, y, "$p = 0.1$", at = "fraction", fraction = 0.45,
#'                   nice.text.args = list(warn = FALSE))
#'
#' t <- seq(0, 2 * pi, length.out = 200)
#' x <- cos(t)
#' y <- 0.5 * sin(t)
#' plot(x, y, type = "l", asp = 1)
#' along_curve_label(x, y, "level set", at = "point", point = c(0.4, 0.25))
#'
#' @export
along_curve_label <- function(x, y, label,
                              at = c("fraction", "x", "y", "index",
                                     "point", "line"),
                              fraction = 0.5,
                              x.at = NULL,
                              y.at = NULL,
                              index = NULL,
                              point = NULL,
                              line = NULL,
                              crossing = c("nearest", "first", "last",
                                           "increasing", "decreasing"),
                              offset = c(0, 0),
                              offset.units = c("npc", "data", "inches"),
                              rotate = TRUE,
                              srt = NULL,
                              upright = TRUE,
                              adj = c(0.5, 0.5),
                              nice.text = TRUE,
                              nice.text.args = list(),
                              knockout = FALSE,
                              knockout.col = "white",
                              knockout.border = NA,
                              knockout.pad = c(1.15, 1.25),
                              knockout.lwd = NULL,
                              col = "black",
                              cex = 1,
                              font = 1,
                              xpd = NA,
                              draw = TRUE,
                              ...) {
  x <- validate_along_curve_coordinate(x, "x")
  y <- validate_along_curve_coordinate(y, "y")
  if (length(x) != length(y)) {
    stop("`x` and `y` must have the same length.", call. = FALSE)
  }

  label.original <- validate_along_curve_label(label)
  at <- match.arg(at)
  crossing <- match.arg(crossing)
  offset.units <- match.arg(offset.units)
  fraction <- validate_along_curve_scalar(
    fraction, "fraction", lower = 0, upper = 1
  )
  offset <- validate_along_curve_numeric_pair(offset, "offset")
  adj <- validate_along_curve_numeric_pair(adj, "adj")
  rotate <- validate_along_curve_logical(rotate, "rotate")
  upright <- validate_along_curve_logical(upright, "upright")
  nice.text <- validate_along_curve_logical(nice.text, "nice.text")
  knockout <- validate_along_curve_logical(knockout, "knockout")
  draw <- validate_along_curve_logical(draw, "draw")
  cex <- validate_along_curve_scalar(cex, "cex", lower = 0,
                                     lower.inclusive = FALSE)
  font <- validate_along_curve_scalar(font, "font")
  srt <- validate_along_curve_optional_scalar(srt, "srt")
  knockout.col <- validate_along_curve_colour_scalar(
    knockout.col, "knockout.col"
  )
  knockout.border <- validate_along_curve_optional_border(knockout.border)
  knockout.pad <- validate_along_curve_pad(knockout.pad, "knockout.pad")
  knockout.lwd <- validate_along_curve_optional_lwd(knockout.lwd)
  nice.text.args <- validate_along_curve_nice_text_args(nice.text.args)

  curve <- prepare_along_curve(x, y)
  placement <- resolve_along_curve_placement(
    curve = curve,
    at = at,
    fraction = fraction,
    x.at = x.at,
    y.at = y.at,
    index = index,
    point = point,
    line = line,
    crossing = crossing
  )
  final.point <- offset_along_curve_point(
    placement = placement,
    curve = curve,
    offset = offset,
    offset.units = offset.units
  )

  direction <- along_curve_direction(curve, placement$segment)
  angle <- direction$angle
  label.srt <- if (!is.null(srt)) {
    srt
  } else if (rotate) {
    if (upright) readable_along_curve_angle(angle) else angle
  } else {
    0
  }

  label.rendered <- render_along_curve_label(
    label = label.original,
    nice.text = nice.text,
    nice.text.args = nice.text.args
  )

  knockout.polygon <- NULL
  if (knockout) {
    knockout.polygon <- resolve_along_curve_knockout_polygon(
      label = label.rendered,
      x = final.point$point[["x"]],
      y = final.point$point[["y"]],
      srt = label.srt,
      cex = cex,
      font = font,
      adj = adj,
      knockout.pad = knockout.pad
    )
  }

  if (draw) {
    old.xpd <- graphics::par("xpd")
    on.exit(graphics::par(xpd = old.xpd), add = TRUE)
    graphics::par(xpd = xpd)

    if (knockout) {
      draw_along_curve_knockout(
        polygon = knockout.polygon,
        knockout.col = knockout.col,
        knockout.border = knockout.border,
        knockout.lwd = knockout.lwd
      )
    }

    graphics::text(
      x = final.point$point[["x"]],
      y = final.point$point[["y"]],
      labels = label.rendered,
      adj = adj,
      srt = label.srt,
      col = col,
      cex = cex,
      font = font,
      ...
    )
  }

  out <- list(
    point = final.point$point,
    anchor = placement$point,
    point.user = final.point$point.user,
    anchor.user = placement$point.user,
    segment = placement$segment,
    segment.fraction = placement$segment.fraction,
    angle = angle,
    srt = label.srt,
    srt.source = if (!is.null(srt)) "explicit" else if (rotate) "automatic" else "unrotated",
    at = at,
    crossing = placement$crossing,
    label = label.original,
    plotting.label = label.rendered,
    nice.text = nice.text,
    offset = offset,
    offset.units = offset.units,
    knockout = knockout,
    knockout.drawn = isTRUE(draw) && isTRUE(knockout),
    knockout.polygon = knockout.polygon,
    text.drawn = isTRUE(draw),
    drawn = isTRUE(draw)
  )
  class(out) <- c("earnmisc_along_curve_label_info", "list")
  invisible(out)
}

#' Validate along-curve coordinate input
#'
#' @return Numeric vector.
#' @noRd
validate_along_curve_coordinate <- function(x, name) {
  if (!is.numeric(x)) {
    stop("`", name, "` must be numeric.", call. = FALSE)
  }
  as.numeric(x)
}

#' Validate an along-curve label
#'
#' @return Label object.
#' @noRd
validate_along_curve_label <- function(label) {
  if (missing(label)) {
    stop("`label` must be supplied.", call. = FALSE)
  }
  if (is.character(label)) {
    if (length(label) != 1L || is.na(label) || !nzchar(label)) {
      stop("`label` must be a single non-empty label.", call. = FALSE)
    }
    return(label)
  }
  if (is.expression(label)) {
    if (length(label) != 1L) {
      stop("`label` must be a single label.", call. = FALSE)
    }
    return(label)
  }
  if (is.call(label) || is.name(label)) {
    return(label)
  }
  if (length(label) != 1L) {
    stop("`label` must be a single label.", call. = FALSE)
  }
  if (is.atomic(label) && anyNA(label)) {
    stop("`label` must not be missing.", call. = FALSE)
  }
  label
}

#' Validate a finite numeric scalar
#'
#' @return Numeric scalar.
#' @noRd
validate_along_curve_scalar <- function(x, name,
                                        lower = NULL,
                                        upper = NULL,
                                        lower.inclusive = TRUE,
                                        upper.inclusive = TRUE) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || !is.finite(x)) {
    stop("`", name, "` must be a finite numeric scalar.", call. = FALSE)
  }
  if (!is.null(lower)) {
    too.low <- if (lower.inclusive) x < lower else x <= lower
    if (too.low) {
      bound <- if (lower.inclusive) "greater than or equal to" else "greater than"
      stop("`", name, "` must be ", bound, " ", lower, ".", call. = FALSE)
    }
  }
  if (!is.null(upper)) {
    too.high <- if (upper.inclusive) x > upper else x >= upper
    if (too.high) {
      bound <- if (upper.inclusive) "less than or equal to" else "less than"
      stop("`", name, "` must be ", bound, " ", upper, ".", call. = FALSE)
    }
  }
  as.numeric(x)
}

#' Validate an optional finite numeric scalar
#'
#' @return `NULL` or numeric scalar.
#' @noRd
validate_along_curve_optional_scalar <- function(x, name) {
  if (is.null(x)) {
    return(NULL)
  }
  validate_along_curve_scalar(x, name)
}

#' Validate a finite numeric pair
#'
#' @return Numeric vector with names `x` and `y`.
#' @noRd
validate_along_curve_numeric_pair <- function(x, name) {
  if (!is.numeric(x) || length(x) != 2L || anyNA(x) || any(!is.finite(x))) {
    stop("`", name, "` must be a finite numeric vector of length two.",
         call. = FALSE)
  }
  out <- as.numeric(x)
  names(out) <- c("x", "y")
  out
}

#' Validate a logical scalar
#'
#' @return Logical scalar.
#' @noRd
validate_along_curve_logical <- function(x, name) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop("`", name, "` must be a logical scalar.", call. = FALSE)
  }
  x
}

#' Validate a colour scalar
#'
#' @return Character scalar.
#' @noRd
validate_along_curve_colour_scalar <- function(x, name) {
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    stop("`", name, "` must be a character scalar.", call. = FALSE)
  }
  x
}

#' Validate knockout border
#'
#' @return Border value.
#' @noRd
validate_along_curve_optional_border <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }
  if (length(x) == 1L && is.na(x)) {
    return(NA)
  }
  validate_along_curve_colour_scalar(x, "knockout.border")
}

#' Validate knockout padding
#'
#' @return Numeric vector of length two.
#' @noRd
validate_along_curve_pad <- function(x, name) {
  if (is.numeric(x) && length(x) == 1L) {
    x <- rep(x, 2L)
  }
  if (!is.numeric(x) || length(x) != 2L || anyNA(x) ||
      any(!is.finite(x)) || any(x <= 0)) {
    stop("`", name, "` must be a positive finite numeric scalar or length-two vector.",
         call. = FALSE)
  }
  as.numeric(x)
}

#' Validate optional knockout line width
#'
#' @return `NULL` or positive scalar.
#' @noRd
validate_along_curve_optional_lwd <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }
  validate_along_curve_scalar(
    x, "knockout.lwd", lower = 0, lower.inclusive = FALSE
  )
}

#' Validate nice-text argument list
#'
#' @return List.
#' @noRd
validate_along_curve_nice_text_args <- function(x) {
  if (!is.list(x)) {
    stop("`nice.text.args` must be a list.", call. = FALSE)
  }
  x
}

#' Prepare curve coordinates
#'
#' @return List of curve coordinates and drawable segments.
#' @noRd
prepare_along_curve <- function(x, y) {
  finite.x <- is.finite(x)
  finite.y <- is.finite(y)
  finite <- finite.x & finite.y
  if (graphics_axis_is_log("x") && any(finite.x & x <= 0)) {
    stop("`x` must contain only positive finite values on a log-scale x axis.",
         call. = FALSE)
  }
  if (graphics_axis_is_log("y") && any(finite.y & y <= 0)) {
    stop("`y` must contain only positive finite values on a log-scale y axis.",
         call. = FALSE)
  }
  if (sum(finite) < 2L) {
    stop("`x` and `y` must contain at least two finite coordinate pairs.",
         call. = FALSE)
  }

  x.user <- rep(NA_real_, length(x))
  y.user <- rep(NA_real_, length(y))
  x.user[finite] <- graphics_data_to_user(x[finite], "x", name = "x")
  y.user[finite] <- graphics_data_to_user(y[finite], "y", name = "y")

  from <- which(finite[-length(finite)] & finite[-1L])
  to <- from + 1L
  if (length(from) == 0L) {
    stop("`x` and `y` must contain at least two adjacent finite coordinate pairs.",
         call. = FALSE)
  }

  x0.in <- graphics::grconvertX(x[from], from = "user", to = "inches")
  x1.in <- graphics::grconvertX(x[to], from = "user", to = "inches")
  y0.in <- graphics::grconvertY(y[from], from = "user", to = "inches")
  y1.in <- graphics::grconvertY(y[to], from = "user", to = "inches")
  length.inches <- sqrt((x1.in - x0.in)^2 + (y1.in - y0.in)^2)
  drawable <- is.finite(length.inches) & length.inches > 0
  if (!any(drawable)) {
    stop("`x` and `y` do not contain a non-zero drawable curve segment.",
         call. = FALSE)
  }

  segments <- data.frame(
    from = from[drawable],
    to = to[drawable],
    length.inches = length.inches[drawable],
    stringsAsFactors = FALSE
  )
  cum.end <- cumsum(segments$length.inches)
  segments$cum.start <- c(0, cum.end[-length(cum.end)])
  segments$cum.end <- cum.end

  list(
    x = x,
    y = y,
    x.user = x.user,
    y.user = y.user,
    finite = finite,
    segments = segments,
    total.length = sum(segments$length.inches)
  )
}

#' Resolve an along-curve label placement
#'
#' @return List with data/user point and segment metadata.
#' @noRd
resolve_along_curve_placement <- function(curve, at, fraction, x.at, y.at,
                                          index, point, line, crossing) {
  switch(
    at,
    fraction = along_curve_placement_fraction(curve, fraction),
    x = along_curve_placement_axis(curve, "x", x.at, crossing),
    y = along_curve_placement_axis(curve, "y", y.at, crossing),
    index = along_curve_placement_index(curve, index),
    point = along_curve_placement_point(curve, point),
    line = along_curve_placement_line(curve, line, crossing)
  )
}

#' Build a placement object
#'
#' @return Placement list.
#' @noRd
along_curve_placement <- function(curve, segment.row, frac,
                                  at, crossing = NA_character_) {
  segment <- curve$segments[segment.row, , drop = FALSE]
  frac <- max(0, min(1, as.numeric(frac)))
  from <- segment$from[[1L]]
  to <- segment$to[[1L]]
  point.user <- c(
    x = curve$x.user[[from]] + frac * (curve$x.user[[to]] - curve$x.user[[from]]),
    y = curve$y.user[[from]] + frac * (curve$y.user[[to]] - curve$y.user[[from]])
  )
  point <- c(
    x = graphics_user_to_data(point.user[["x"]], "x"),
    y = graphics_user_to_data(point.user[["y"]], "y")
  )
  names(point) <- c("x", "y")
  names(point.user) <- c("x", "y")

  list(
    point = point,
    point.user = point.user,
    segment = c(from = from, to = to),
    segment.row = segment.row,
    segment.fraction = frac,
    at = at,
    crossing = crossing
  )
}

#' Placement by displayed arclength fraction
#'
#' @return Placement list.
#' @noRd
along_curve_placement_fraction <- function(curve, fraction) {
  if (curve$total.length <= 0) {
    stop("Could not resolve displayed arclength for the curve.", call. = FALSE)
  }
  target <- fraction * curve$total.length
  if (fraction == 0) {
    return(along_curve_placement(curve, 1L, 0, "fraction"))
  }
  if (fraction == 1) {
    return(along_curve_placement(
      curve, nrow(curve$segments), 1, "fraction"
    ))
  }

  segment.row <- which(curve$segments$cum.end >= target)[[1L]]
  segment <- curve$segments[segment.row, , drop = FALSE]
  frac <- (target - segment$cum.start[[1L]]) / segment$length.inches[[1L]]
  along_curve_placement(curve, segment.row, frac, "fraction")
}

#' Placement by x or y crossing
#'
#' @return Placement list.
#' @noRd
along_curve_placement_axis <- function(curve, axis, target, crossing) {
  axis <- match.arg(axis, c("x", "y"))
  name <- if (identical(axis, "x")) "x.at" else "y.at"
  if (is.null(target)) {
    stop("`", name, "` must be supplied when `at = \"", axis, "\"`.",
         call. = FALSE)
  }
  target <- validate_along_curve_scalar(target, name)
  target.user <- graphics_data_to_user(target, axis, name = name)

  values <- if (identical(axis, "x")) curve$x.user else curve$y.user
  candidates <- find_along_curve_crossings(
    curve = curve,
    g = values - target.user,
    crossing = crossing,
    at = axis
  )
  selected <- select_along_curve_crossing(curve, candidates, crossing)
  along_curve_placement(
    curve = curve,
    segment.row = selected$segment.row,
    frac = selected$frac,
    at = axis,
    crossing = selected$crossing
  )
}

#' Placement by row index
#'
#' @return Placement list.
#' @noRd
along_curve_placement_index <- function(curve, index) {
  if (is.null(index)) {
    stop("`index` must be supplied when `at = \"index\"`.", call. = FALSE)
  }
  index <- validate_along_curve_scalar(index, "index")
  if (index != round(index)) {
    stop("`index` must be a whole-number row index.", call. = FALSE)
  }
  index <- as.integer(index)
  if (index < 1L || index > length(curve$x)) {
    stop("`index` must identify a row of `x` and `y`.", call. = FALSE)
  }
  if (!curve$finite[[index]]) {
    stop("`index` must identify a finite coordinate pair.", call. = FALSE)
  }

  starts <- which(curve$segments$from == index)
  if (length(starts) > 0L) {
    return(along_curve_placement(curve, starts[[1L]], 0, "index"))
  }
  ends <- which(curve$segments$to == index)
  if (length(ends) > 0L) {
    return(along_curve_placement(curve, ends[[length(ends)]], 1, "index"))
  }

  stop("`index` must be part of a non-zero drawable curve segment.",
       call. = FALSE)
}

#' Placement by nearest point on a segment
#'
#' @return Placement list.
#' @noRd
along_curve_placement_point <- function(curve, point) {
  if (is.null(point)) {
    stop("`point` must be supplied when `at = \"point\"`.", call. = FALSE)
  }
  point <- validate_along_curve_numeric_pair(point, "point")
  point.user <- c(
    x = graphics_data_to_user(point[["x"]], "x", name = "point[1]"),
    y = graphics_data_to_user(point[["y"]], "y", name = "point[2]")
  )
  point.inches <- c(
    x = graphics::grconvertX(point[["x"]], from = "user", to = "inches"),
    y = graphics::grconvertY(point[["y"]], from = "user", to = "inches")
  )

  distances <- rep(Inf, nrow(curve$segments))
  fractions <- rep(NA_real_, nrow(curve$segments))
  for (i in seq_len(nrow(curve$segments))) {
    segment <- curve$segments[i, , drop = FALSE]
    from <- segment$from[[1L]]
    to <- segment$to[[1L]]
    a <- c(
      x = graphics::grconvertX(curve$x[[from]], from = "user", to = "inches"),
      y = graphics::grconvertY(curve$y[[from]], from = "user", to = "inches")
    )
    b <- c(
      x = graphics::grconvertX(curve$x[[to]], from = "user", to = "inches"),
      y = graphics::grconvertY(curve$y[[to]], from = "user", to = "inches")
    )
    delta <- b - a
    denom <- sum(delta^2)
    if (!is.finite(denom) || denom <= 0) {
      next
    }
    frac <- sum((point.inches - a) * delta) / denom
    frac <- max(0, min(1, frac))
    nearest <- a + frac * delta
    distances[[i]] <- sum((point.inches - nearest)^2)
    fractions[[i]] <- frac
  }

  segment.row <- which.min(distances)
  if (!is.finite(distances[[segment.row]])) {
    stop("Could not resolve the nearest point on the curve.", call. = FALSE)
  }
  along_curve_placement(curve, segment.row, fractions[[segment.row]], "point")
}

#' Placement by line intersection
#'
#' @return Placement list.
#' @noRd
along_curve_placement_line <- function(curve, line, crossing) {
  line <- validate_along_curve_line(line)
  if (is.infinite(line[["slope"]])) {
    g <- curve$x - line[["x"]]
  } else {
    g <- curve$y - (line[["y"]] + line[["slope"]] * (curve$x - line[["x"]]))
  }
  candidates <- find_along_curve_crossings(
    curve = curve,
    g = g,
    crossing = crossing,
    at = "line"
  )
  selected <- select_along_curve_crossing(curve, candidates, crossing)
  along_curve_placement(
    curve = curve,
    segment.row = selected$segment.row,
    frac = selected$frac,
    at = "line",
    crossing = selected$crossing
  )
}

#' Validate line-intersection input
#'
#' @return Named numeric vector with x, y, and slope.
#' @noRd
validate_along_curve_line <- function(line) {
  if (is.null(line)) {
    stop("`line` must be supplied when `at = \"line\"`.", call. = FALSE)
  }
  required <- c("x", "y", "slope")
  if (is.list(line) && !is.data.frame(line)) {
    if (!all(required %in% names(line))) {
      stop("`line` list values must contain named elements x, y, and slope.",
           call. = FALSE)
    }
    line <- vapply(required, function(name) line[[name]], numeric(1L))
  }
  if (!is.numeric(line) || is.null(names(line)) ||
      !all(required %in% names(line))) {
    stop("`line` must be a named numeric vector or list with x, y, and slope.",
         call. = FALSE)
  }
  out <- vapply(required, function(name) line[[name]], numeric(1L))
  if (anyNA(out) || any(!is.finite(out[c("x", "y")]))) {
    stop("`line` x and y values must be finite.", call. = FALSE)
  }
  if (is.na(out[["slope"]]) || is.nan(out[["slope"]])) {
    stop("`line` slope must not be missing or NaN.", call. = FALSE)
  }
  out
}

#' Find segment crossings of a scalar function
#'
#' @return Data frame of crossings.
#' @noRd
find_along_curve_crossings <- function(curve, g, crossing, at) {
  rows <- list()
  for (i in seq_len(nrow(curve$segments))) {
    segment <- curve$segments[i, , drop = FALSE]
    from <- segment$from[[1L]]
    to <- segment$to[[1L]]
    g0 <- g[[from]]
    g1 <- g[[to]]
    if (!is.finite(g0) || !is.finite(g1)) {
      next
    }

    frac <- NA_real_
    if (g0 == 0 && g1 == 0) {
      frac <- 0
    } else if (g0 == 0) {
      frac <- 0
    } else if (g1 == 0) {
      frac <- 1
    } else if ((g0 < 0 && g1 > 0) || (g0 > 0 && g1 < 0)) {
      frac <- -g0 / (g1 - g0)
    }

    if (!is.finite(frac) || frac < 0 || frac > 1) {
      next
    }
    direction <- if (g1 >= g0) "increasing" else "decreasing"
    distance <- segment$cum.start[[1L]] + frac * segment$length.inches[[1L]]
    rows[[length(rows) + 1L]] <- data.frame(
      segment.row = i,
      frac = frac,
      crossing = direction,
      distance = distance,
      stringsAsFactors = FALSE
    )
  }

  if (length(rows) == 0L) {
    stop("No curve crossing was found for `at = \"", at, "\"`.",
         call. = FALSE)
  }
  candidates <- do.call(rbind, rows)
  rownames(candidates) <- NULL

  if (crossing %in% c("increasing", "decreasing")) {
    candidates <- candidates[candidates$crossing == crossing, , drop = FALSE]
    if (nrow(candidates) == 0L) {
      stop("No ", crossing, " curve crossing was found for `at = \"", at, "\"`.",
           call. = FALSE)
    }
  }

  candidates
}

#' Select one crossing from candidates
#'
#' @return One-row data frame.
#' @noRd
select_along_curve_crossing <- function(curve, candidates, crossing) {
  if (crossing == "first" || crossing %in% c("increasing", "decreasing")) {
    return(candidates[1L, , drop = FALSE])
  }
  if (crossing == "last") {
    return(candidates[nrow(candidates), , drop = FALSE])
  }

  middle <- curve$total.length / 2
  candidates[which.min(abs(candidates$distance - middle)), , drop = FALSE]
}

#' Apply a post-placement offset
#'
#' @return List with final data and user points.
#' @noRd
offset_along_curve_point <- function(placement, curve, offset, offset.units) {
  anchor <- placement$point
  anchor.user <- placement$point.user

  if (identical(offset.units, "data")) {
    point <- c(
      x = anchor[["x"]] + offset[["x"]],
      y = anchor[["y"]] + offset[["y"]]
    )
    point.user <- c(
      x = graphics_data_to_user(point[["x"]], "x", name = "offset x"),
      y = graphics_data_to_user(point[["y"]], "y", name = "offset y")
    )
  } else if (identical(offset.units, "npc")) {
    point.user <- c(
      x = anchor.user[["x"]] +
        offset[["x"]] * graphics_user_span("x", curve$x, name = "x"),
      y = anchor.user[["y"]] +
        offset[["y"]] * graphics_user_span("y", curve$y, name = "y")
    )
    point <- c(
      x = graphics_user_to_data(point.user[["x"]], "x"),
      y = graphics_user_to_data(point.user[["y"]], "y")
    )
  } else {
    point.inches <- c(
      x = graphics::grconvertX(anchor[["x"]], from = "user", to = "inches") +
        offset[["x"]],
      y = graphics::grconvertY(anchor[["y"]], from = "user", to = "inches") +
        offset[["y"]]
    )
    point <- c(
      x = graphics::grconvertX(point.inches[["x"]], from = "inches", to = "user"),
      y = graphics::grconvertY(point.inches[["y"]], from = "inches", to = "user")
    )
    point.user <- c(
      x = graphics_data_to_user(point[["x"]], "x", name = "offset x"),
      y = graphics_data_to_user(point[["y"]], "y", name = "offset y")
    )
  }

  if (any(!is.finite(point)) || any(!is.finite(point.user))) {
    stop("Could not compute a finite along-curve label point.", call. = FALSE)
  }
  names(point) <- c("x", "y")
  names(point.user) <- c("x", "y")
  list(point = point, point.user = point.user)
}

#' Compute local tangent direction
#'
#' @return List with angle and segment endpoints.
#' @noRd
along_curve_direction <- function(curve, segment) {
  from <- segment[["from"]]
  to <- segment[["to"]]
  x.inches <- graphics::grconvertX(
    c(curve$x[[from]], curve$x[[to]]), from = "user", to = "inches"
  )
  y.inches <- graphics::grconvertY(
    c(curve$y[[from]], curve$y[[to]]), from = "user", to = "inches"
  )
  dx <- x.inches[[2L]] - x.inches[[1L]]
  dy <- y.inches[[2L]] - y.inches[[1L]]
  if (!is.finite(dx) || !is.finite(dy) || (dx == 0 && dy == 0)) {
    stop("Could not determine a non-zero local curve direction for label rotation.",
         call. = FALSE)
  }

  list(
    from = from,
    to = to,
    x0 = curve$x[[from]],
    y0 = curve$y[[from]],
    x1 = curve$x[[to]],
    y1 = curve$y[[to]],
    angle = as.numeric(atan2(dy, dx) * 180 / pi)
  )
}

#' Return a readable text angle
#'
#' @return Numeric scalar.
#' @noRd
readable_along_curve_angle <- function(angle) {
  while (angle > 90) {
    angle <- angle - 180
  }
  while (angle < -90) {
    angle <- angle + 180
  }
  angle
}

#' Render a label for drawing
#'
#' @return Label object for graphics::text().
#' @noRd
render_along_curve_label <- function(label, nice.text, nice.text.args) {
  if (!nice.text || !is.character(label)) {
    return(label)
  }
  args <- list(x = label, warn = FALSE)
  args[names(nice.text.args)] <- nice.text.args
  do.call(nice_text, args)
}

#' Resolve a rotated knockout polygon
#'
#' @return Data frame of polygon vertices.
#' @noRd
resolve_along_curve_knockout_polygon <- function(label, x, y, srt,
                                                 cex, font, adj,
                                                 knockout.pad) {
  width <- graphics::strwidth(label, cex = cex, font = font,
                              units = "inches") *
    knockout.pad[[1L]]
  height <- graphics::strheight(label, cex = cex, font = font,
                                units = "inches") *
    knockout.pad[[2L]]
  if (!is.finite(width) || width <= 0) {
    width <- graphics::strwidth("M", cex = cex, font = font,
                                units = "inches") *
      knockout.pad[[1L]]
  }
  if (!is.finite(height) || height <= 0) {
    height <- graphics::strheight("M", cex = cex, font = font,
                                  units = "inches") *
      knockout.pad[[2L]]
  }

  centre <- c(
    x = graphics::grconvertX(x, from = "user", to = "inches"),
    y = graphics::grconvertY(y, from = "user", to = "inches")
  )
  theta <- srt * pi / 180
  rotation <- matrix(
    c(cos(theta), -sin(theta), sin(theta), cos(theta)),
    nrow = 2L,
    byrow = TRUE
  )
  x.left <- -adj[[1L]] * width
  x.right <- (1 - adj[[1L]]) * width
  y.bottom <- -adj[[2L]] * height
  y.top <- (1 - adj[[2L]]) * height
  corners <- matrix(
    c(
      x.left, y.bottom,
      x.right, y.bottom,
      x.right, y.top,
      x.left, y.top
    ),
    ncol = 2L,
    byrow = TRUE
  )
  rotated <- t(rotation %*% t(corners))
  inches <- t(t(rotated) + centre)
  x.vertices <- graphics::grconvertX(
    inches[, 1L], from = "inches", to = "user"
  )
  y.vertices <- graphics::grconvertY(
    inches[, 2L], from = "inches", to = "user"
  )
  data.frame(
    vertex = seq_len(4L),
    x = x.vertices,
    y = y.vertices,
    x.user = graphics_data_to_user(x.vertices, "x", name = "knockout x"),
    y.user = graphics_data_to_user(y.vertices, "y", name = "knockout y"),
    x.inches = inches[, 1L],
    y.inches = inches[, 2L],
    width.inches = width,
    height.inches = height,
    adj.x = adj[[1L]],
    adj.y = adj[[2L]],
    stringsAsFactors = FALSE
  )
}

#' Draw a knockout polygon
#'
#' @return Invisibly returns `TRUE`.
#' @noRd
draw_along_curve_knockout <- function(polygon, knockout.col,
                                      knockout.border, knockout.lwd) {
  args <- list(
    x = polygon$x,
    y = polygon$y,
    col = knockout.col,
    border = knockout.border
  )
  if (!is.null(knockout.lwd)) {
    args$lwd <- knockout.lwd
  }
  do.call(graphics::polygon, args)
  invisible(TRUE)
}
