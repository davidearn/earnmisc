#' Plot phase-plane trajectories
#'
#' `pp_plot()` is an S3 generic for phase-plane trajectory plots. Methods should
#' plot one variable against another and return plot metadata that [pp_lines()]
#' can use for overlays.
#'
#' @param x Object to plot.
#' @param ... Additional arguments passed to methods.
#'
#' @return Invisibly returns method-specific plot metadata.
#'
#' @examples
#' time <- seq(0, 2 * pi, length.out = 100)
#' x <- stats::ts(cbind(sin = sin(time), cos = cos(time)))
#' info <- pp_plot(x, h.var = "sin", v.var = "cos")
#' y <- stats::ts(cbind(sin = 0.8 * sin(time), cos = 0.8 * cos(time)))
#' pp_lines(y, plot.info = info, lty = 2)
#'
#' @export
pp_plot <- function(x, ...) {
  UseMethod("pp_plot")
}

#' Overlay phase-plane trajectories
#'
#' `pp_lines()` is an S3 generic for adding phase-plane trajectories to an
#' existing phase-plane plot.
#'
#' @param x Object to overlay.
#' @param ... Additional arguments passed to methods.
#'
#' @return Invisibly returns updated method-specific plot metadata.
#'
#' @examples
#' time <- seq(0, 2 * pi, length.out = 100)
#' x <- stats::ts(cbind(sin = sin(time), cos = cos(time)))
#' info <- pp_plot(x, h.var = "sin", v.var = "cos")
#' y <- stats::ts(cbind(sin = 0.8 * sin(time), cos = 0.8 * cos(time)))
#' pp_lines(y, plot.info = info, lty = 2)
#'
#' @export
pp_lines <- function(x, ...) {
  UseMethod("pp_lines")
}

#' Plot phase-plane panels for mts-like data
#'
#' Plot one or more phase-plane panels from a multivariate time series or
#' matrix-like object. Each panel plots one selected vertical variable against
#' one selected horizontal variable. The returned plot metadata records the
#' plotted pairs, panel layout, coordinate ranges, labels, and graphics state so
#' [mts_pp_lines()] can add matching overlays.
#'
#' @param x Multivariate time-series object, or an object safely coercible to a
#'   numeric matrix.
#' @param h.var Horizontal variable names or indices. If `h.var` and `v.var` are
#'   both supplied, all non-identical Cartesian pairs are plotted.
#' @param v.var Vertical variable names or indices. If `h.var` and `v.var` are
#'   both supplied, all non-identical Cartesian pairs are plotted.
#' @param pairs Explicit phase-plane pairs. This overrides `h.var` and `v.var`.
#'   Supply either a two-column matrix/data frame, preferably with columns
#'   `h.var` and `v.var`, or a list whose elements are length-two pairs. Pair
#'   entries may be column names or column indices.
#' @param max.panels Positive integer scalar giving the maximum number of panels
#'   to draw. If the requested pairs exceed this value, the function stops before
#'   plotting and reports how to raise the limit or restrict the pairs.
#' @param label.map Optional named character vector or named list mapping column
#'   names to display labels. Labels are passed through [nice_text()] so TeX-like
#'   labels can be used in ordinary and tikz graphics contexts.
#' @param use.tikz Optional logical scalar passed to [nice_text()]. If `NULL`,
#'   [nice_text()] resolves the mode from the calling context or active device.
#' @param xlim,ylim Optional finite numeric length-two ranges. When supplied,
#'   these override the automatically computed horizontal or vertical axis
#'   ranges for every phase-plane panel. Limits for log-scaled axes must be
#'   strictly positive.
#' @param log Character scalar passed to [graphics::plot.default()]. When the
#'   horizontal axis is log-scaled, points with non-positive horizontal values
#'   are omitted before drawing and range calculation. When the vertical axis is
#'   log-scaled, points with non-positive vertical values are omitted in the
#'   same way.
#' @param col,lty,lwd,type Graphical parameters for base trajectories. `col`,
#'   `lty`, and `lwd` may be scalar, vectorised by phase-plane pair, or named by
#'   pair name such as `"x-y"`.
#' @param axes,frame.plot Logical values passed to [graphics::plot.default()].
#' @param las Axis tick-label orientation passed to
#'   [graphics::plot.default()]. The default `las = 1` draws horizontal tick
#'   labels.
#' @param ... Additional arguments passed to [graphics::plot.default()].
#'
#' @return Invisibly returns an `earnmisc_pp_plot_info` list containing at least
#'   `pairs`, `layout`, `xlim`, `ylim`, `labels`, `panels`, and `curves`.
#'
#' @details
#' If `pairs` is supplied, it is used exactly. If both `h.var` and `v.var` are
#' supplied, all Cartesian combinations are used except pairs where the
#' horizontal and vertical variables are identical. If neither `pairs` nor
#' `h.var`/`v.var` is supplied, all unordered column pairs are used once; for
#' columns `x`, `y`, and `z`, the default pairs are `x-y`, `x-z`, and `y-z`.
#'
#' For reliable multi-panel overlays, pass the returned object to
#' [mts_pp_lines()]. This lets overlays reuse the same pair ordering, panel
#' layout, and coordinate ranges:
#'
#' `info <- mts_pp_plot(x1, h.var = "x", v.var = "y")`
#' `info <- mts_pp_lines(x2, plot.info = info, lty = 2)`
#'
#' @examples
#' time <- seq(0, 2 * pi, length.out = 100)
#' x <- cbind(
#'   sin = sin(time),
#'   cos = cos(time),
#'   decay = exp(-time / 4)
#' )
#' x <- stats::ts(x)
#' info <- mts_pp_plot(x, h.var = "sin", v.var = "cos")
#' info$pairs
#'
#' labels <- c(sin = "$s$", cos = "$c$")
#' mts_pp_plot(x, h.var = "sin", v.var = "cos", label.map = labels)
#'
#' @export
mts_pp_plot <- function(
  x,
  h.var = NULL,
  v.var = NULL,
  pairs = NULL,
  max.panels = 16,
  label.map = NULL,
  use.tikz = NULL,
  xlim = NULL,
  ylim = NULL,
  log = "",
  col = "black",
  lty = 1,
  lwd = 1,
  type = "l",
  axes = TRUE,
  frame.plot = TRUE,
  las = 1,
  ...
) {
  max.panels <- validate_pp_max_panels(max.panels)
  log.axes <- validate_pp_log(log)
  xlim.override <- validate_pp_axis_override(xlim, "xlim", log.axis = log.axes$x)
  ylim.override <- validate_pp_axis_override(ylim, "ylim", log.axis = log.axes$y)
  mts.data <- as_mts_matrix(x)
  pair.data <- resolve_pp_pairs(
    h.var = h.var,
    v.var = v.var,
    pairs = pairs,
    column.names = mts.data$column.names,
    ncol = ncol(mts.data$matrix)
  )
  validate_pp_panel_count(nrow(pair.data), max.panels)

  pair.names <- pp_pair_names(pair.data)
  graphics.parameters <- resolve_mts_graphics(
    n = nrow(pair.data),
    col = col,
    lty = lty,
    lwd = lwd,
    column.names = pair.names
  )
  label.map <- normalise_pp_label_map(label.map)
  labels <- resolve_pp_labels(pair.data, label.map = label.map, use.tikz = use.tikz)
  layout <- mts_layout_dims(nrow(pair.data))

  graphics::par(mfrow = c(layout$nrow, layout$ncol))

  usr <- vector("list", nrow(pair.data))
  mfg <- vector("list", nrow(pair.data))
  xlim.resolved <- vector("list", nrow(pair.data))
  ylim.resolved <- vector("list", nrow(pair.data))
  point.summary <- vector("list", nrow(pair.data))

  for (panel.index in seq_len(nrow(pair.data))) {
    h.values <- pp_column_values(mts.data$matrix, pair.data$h.column[[panel.index]])
    v.values <- pp_column_values(mts.data$matrix, pair.data$v.column[[panel.index]])
    filtered <- pp_filter_log_points(h.values, v.values, log.axes = log.axes)
    point.summary[[panel.index]] <- filtered$summary
    xlim.resolved[[panel.index]] <- if (is.null(xlim.override)) {
      pp_axis_range(filtered$h.range, pair.names[[panel.index]], "horizontal")
    } else {
      xlim.override
    }
    ylim.resolved[[panel.index]] <- if (is.null(ylim.override)) {
      pp_axis_range(filtered$v.range, pair.names[[panel.index]], "vertical")
    } else {
      ylim.override
    }

    graphics::plot.default(
      x = filtered$h.draw,
      y = filtered$v.draw,
      type = type,
      xlim = xlim.resolved[[panel.index]],
      ylim = ylim.resolved[[panel.index]],
      log = log.axes$value,
      xlab = labels$h.label[[panel.index]],
      ylab = labels$v.label[[panel.index]],
      col = graphics.parameters$col[[panel.index]],
      lty = graphics.parameters$lty[[panel.index]],
      lwd = graphics.parameters$lwd[[panel.index]],
      axes = axes,
      frame.plot = frame.plot,
      las = las,
      ...
    )

    usr[[panel.index]] <- graphics::par("usr")
    mfg[[panel.index]] <- graphics::par("mfg")
  }

  pair.data$panel.index <- seq_len(nrow(pair.data))
  pair.data$pair.name <- pair.names
  curves <- make_pp_curve_registry(
    object.index = 0L,
    pair.data = pair.data,
    col = graphics.parameters$col,
    lty = graphics.parameters$lty,
    lwd = graphics.parameters$lwd,
    type = type,
    drawn = TRUE,
    reason = NA_character_,
    point.summary = point.summary
  )

  plot.info <- list(
    x = x,
    data = mts.data$matrix,
    column.names = mts.data$column.names,
    original.column.names = mts.data$original.column.names,
    pairs = pair.data,
    pair.names = pair.names,
    layout = layout,
    usr = usr,
    mfg = mfg,
    xlim = xlim.resolved,
    ylim = ylim.resolved,
    log = log.axes$value,
    log.axes = list(x = log.axes$x, y = log.axes$y),
    point.summary = point.summary,
    las = las,
    labels = labels,
    panels = make_pp_panel_metadata(
      pair.data,
      mfg = mfg,
      usr = usr,
      xlim = xlim.resolved,
      ylim = ylim.resolved,
      las = las,
      log = log.axes,
      point.summary = point.summary
    ),
    device = unname(grDevices::dev.cur()),
    created_at = Sys.time(),
    curves = curves
  )
  class(plot.info) <- c("earnmisc_pp_plot_info", "list")

  invisible(plot.info)
}

#' Overlay phase-plane trajectories for mts-like data
#'
#' Add one or more phase-plane trajectories to existing panels created by
#' [mts_pp_plot()]. Passing `plot.info` is recommended for multi-panel overlays
#' because it reuses the original pair ordering, panel layout, and coordinate
#' ranges. If `plot.info` is supplied, the pairs recorded in `plot.info` are used
#' by default.
#'
#' @param x Overlay multivariate time-series object, or an object safely
#'   coercible to a numeric matrix.
#' @param h.var,v.var,pairs Pair selectors used only when `plot.info` is `NULL`.
#'   They follow the same rules as [mts_pp_plot()] when supplied. Without
#'   `plot.info`, `mts_pp_lines()` intentionally does not default to all
#'   unordered pairs; multi-column objects require `pairs` or both `h.var` and
#'   `v.var`.
#' @param plot.info Optional metadata returned by [mts_pp_plot()]. If supplied,
#'   overlays use the recorded pairs and panels.
#' @param label.map Optional named character vector or named list mapping column
#'   names to display labels. Used only when `plot.info` is `NULL`.
#' @param use.tikz Optional logical scalar passed to [nice_text()]. Used only
#'   when `plot.info` is `NULL`.
#' @param log Optional character scalar used only when `plot.info` is `NULL`.
#'   When omitted, the current plot's log-axis state is used. When `plot.info`
#'   is supplied, overlays use the log-axis settings recorded by
#'   [mts_pp_plot()].
#' @param col,lty,lwd,type Graphical parameters for overlay trajectories. `col`,
#'   `lty`, and `lwd` may be scalar, vectorised by phase-plane pair, or named by
#'   pair name such as `"x-y"`.
#' @param ... Additional arguments passed to [graphics::lines()].
#'
#' @return Invisibly returns an updated `earnmisc_pp_plot_info` object.
#'
#' @examples
#' time <- seq(0, 2 * pi, length.out = 100)
#' x <- stats::ts(cbind(
#'   sin = sin(time),
#'   cos = cos(time),
#'   decay = exp(-time / 4)
#' ))
#' info <- mts_pp_plot(x, h.var = "sin", v.var = "cos")
#' # Overlay a second, smaller trajectory.
#' info <- mts_pp_lines(0.7 * x, plot.info = info, col = "red", lty = 2)
#'
#' @export
mts_pp_lines <- function(
  x,
  h.var = NULL,
  v.var = NULL,
  pairs = NULL,
  plot.info = NULL,
  label.map = NULL,
  use.tikz = NULL,
  log = NULL,
  col = "red",
  lty = 1,
  lwd = 1,
  type = "l",
  ...
) {
  mts.data <- as_mts_matrix(x)

  if (is.null(plot.info)) {
    log.axes <- if (is.null(log)) {
      pp_current_log_axes()
    } else {
      validate_pp_log(log)
    }
    pair.data <- resolve_pp_line_pairs(
      h.var = h.var,
      v.var = v.var,
      pairs = pairs,
      column.names = mts.data$column.names,
      ncol = ncol(mts.data$matrix)
    )
    pair.names <- pp_pair_names(pair.data)
    pair.data$panel.index <- seq_len(nrow(pair.data))
    pair.data$pair.name <- pair.names
    layout <- mts_layout_dims(nrow(pair.data))
    label.map <- normalise_pp_label_map(label.map)
    labels <- resolve_pp_labels(pair.data, label.map = label.map, use.tikz = use.tikz)
    usr <- rep(list(graphics::par("usr")), nrow(pair.data))
    mfg <- lapply(seq_len(nrow(pair.data)), pp_panel_mfg, layout = layout)
    xlim <- rep(list(NA_real_), nrow(pair.data))
    ylim <- rep(list(NA_real_), nrow(pair.data))
    plot.info <- list(
      x = NULL,
      data = NULL,
      column.names = mts.data$column.names,
      original.column.names = mts.data$original.column.names,
      pairs = pair.data,
      pair.names = pair.names,
      layout = layout,
      usr = usr,
      mfg = mfg,
      xlim = xlim,
      ylim = ylim,
      log = log.axes$value,
      log.axes = list(x = log.axes$x, y = log.axes$y),
      point.summary = NULL,
      labels = labels,
      panels = make_pp_panel_metadata(pair.data, mfg = mfg, usr = usr, xlim = xlim, ylim = ylim, log = log.axes),
      device = unname(grDevices::dev.cur()),
      created_at = Sys.time(),
      curves = empty_pp_curve_registry()
    )
    class(plot.info) <- c("earnmisc_pp_plot_info", "list")
  } else {
    validate_pp_plot_info(plot.info)
    if (!is.null(pairs) || !is.null(h.var) || !is.null(v.var)) {
      stop("When `plot.info` is supplied, do not also supply `pairs`, `h.var`, or `v.var`.", call. = FALSE)
    }
    pair.data <- resolve_pp_pairs_from_plot_info(plot.info, mts.data)
    pair.names <- plot.info$pair.names
    log.axes <- pp_plot_info_log_axes(plot.info)
  }

  graphics.parameters <- resolve_mts_graphics(
    n = nrow(pair.data),
    col = col,
    lty = lty,
    lwd = lwd,
    column.names = pair.names
  )

  point.summary <- vector("list", nrow(pair.data))
  for (panel.index in seq_len(nrow(pair.data))) {
    graphics::par(mfg = plot.info$mfg[[panel.index]])
    if (!anyNA(plot.info$usr[[panel.index]])) {
      graphics::par(usr = plot.info$usr[[panel.index]])
    }
    filtered <- pp_filter_log_points(
      h.values = pp_column_values(mts.data$matrix, pair.data$h.column[[panel.index]]),
      v.values = pp_column_values(mts.data$matrix, pair.data$v.column[[panel.index]]),
      log.axes = log.axes
    )
    point.summary[[panel.index]] <- filtered$summary
    graphics::lines(
      x = filtered$h.draw,
      y = filtered$v.draw,
      type = type,
      col = graphics.parameters$col[[panel.index]],
      lty = graphics.parameters$lty[[panel.index]],
      lwd = graphics.parameters$lwd[[panel.index]],
      ...
    )
  }

  plot.info$curves <- rbind(
    plot.info$curves,
    make_pp_curve_registry(
      object.index = next_pp_object_index(plot.info),
      pair.data = pair.data,
      col = graphics.parameters$col,
      lty = graphics.parameters$lty,
      lwd = graphics.parameters$lwd,
      type = type,
      drawn = TRUE,
      reason = NA_character_,
      point.summary = point.summary
    )
  )

  invisible(plot.info)
}

#' Return plain numeric phase-plane column values
#'
#' Extract one data column as a plain numeric vector. Subsetting an `mts` object
#' can preserve a `"ts"` class on the column, which would make
#' [graphics::lines()] dispatch to `lines.ts()` instead of drawing an ordinary
#' x-y trajectory.
#'
#' @param x Numeric matrix-like object.
#' @param column Column index.
#'
#' @return Plain numeric vector.
#' @noRd
pp_column_values <- function(x, column) {
  as.numeric(x[, column])
}

#' Resolve phase-plane line overlay pairs
#'
#' Resolve pairs for [mts_pp_lines()]. Unlike [mts_pp_plot()], line overlays do
#' not infer all unordered pairs without plot metadata because there may be only
#' one current panel.
#'
#' @param h.var,v.var,pairs Pair selectors.
#' @param column.names Column names.
#' @param ncol Number of columns.
#'
#' @return A data frame describing resolved phase-plane pairs.
#' @noRd
resolve_pp_line_pairs <- function(h.var = NULL, v.var = NULL, pairs = NULL, column.names, ncol) {
  if (!is.null(pairs) || !is.null(h.var) || !is.null(v.var)) {
    return(resolve_pp_pairs(
      h.var = h.var,
      v.var = v.var,
      pairs = pairs,
      column.names = column.names,
      ncol = ncol
    ))
  }

  if (ncol == 2L) {
    return(make_pp_pair_data(1L, 2L, column.names = column.names))
  }

  stop(
    "`mts_pp_lines()` without `plot.info` requires `pairs`, both `h.var` and `v.var`, ",
    "or an object with exactly two columns.",
    call. = FALSE
  )
}

#' @rdname mts_pp_plot
#' @export
pp_plot.mts <- function(x, ...) {
  mts_pp_plot(x, ...)
}

#' @rdname mts_pp_lines
#' @export
pp_lines.mts <- function(x, ...) {
  mts_pp_lines(x, ...)
}

#' Validate the maximum phase-plane panel count
#'
#' @param max.panels Candidate maximum panel count.
#'
#' @return A positive integer scalar.
#' @noRd
validate_pp_max_panels <- function(max.panels) {
  if (!is.numeric(max.panels) || length(max.panels) != 1L ||
      is.na(max.panels) || max.panels < 1 || max.panels != floor(max.panels)) {
    stop("`max.panels` must be a positive integer scalar.", call. = FALSE)
  }

  as.integer(max.panels)
}

#' Validate requested phase-plane panel count
#'
#' @param panel.count Number of required panels.
#' @param max.panels Maximum allowed panels.
#'
#' @return Invisibly returns `TRUE`.
#' @noRd
validate_pp_panel_count <- function(panel.count, max.panels) {
  if (panel.count > max.panels) {
    stop(
      "Phase-plane plot would require ",
      panel.count,
      " panels, which exceeds max.panels = ",
      max.panels,
      ". Use max.panels = ",
      panel.count,
      " to show all panels, or specify h.var, v.var, or pairs.",
      call. = FALSE
    )
  }

  invisible(TRUE)
}

#' Resolve phase-plane pairs
#'
#' @param h.var,v.var,pairs Pair selectors.
#' @param column.names Column names.
#' @param ncol Number of columns.
#'
#' @return A data frame describing resolved phase-plane pairs.
#' @noRd
resolve_pp_pairs <- function(h.var = NULL, v.var = NULL, pairs = NULL, column.names, ncol) {
  if (!is.null(pairs)) {
    return(resolve_explicit_pp_pairs(pairs, column.names = column.names, ncol = ncol))
  }

  if (xor(is.null(h.var), is.null(v.var))) {
    stop("Supply both `h.var` and `v.var`, or neither.", call. = FALSE)
  }

  if (!is.null(h.var) && !is.null(v.var)) {
    h.columns <- resolve_mts_columns(h.var, column.names = column.names, ncol = ncol, argument.name = "h.var")
    v.columns <- resolve_mts_columns(v.var, column.names = column.names, ncol = ncol, argument.name = "v.var")
    grid <- expand.grid(
      h.column = h.columns,
      v.column = v.columns,
      KEEP.OUT.ATTRS = FALSE
    )
    grid <- grid[grid$h.column != grid$v.column, , drop = FALSE]
    if (nrow(grid) == 0L) {
      stop("No non-identical phase-plane pairs were selected.", call. = FALSE)
    }
    return(make_pp_pair_data(grid$h.column, grid$v.column, column.names = column.names))
  }

  if (ncol < 2L) {
    stop("Phase-plane plotting requires at least two columns.", call. = FALSE)
  }
  combinations <- utils::combn(seq_len(ncol), 2)
  make_pp_pair_data(combinations[1, ], combinations[2, ], column.names = column.names)
}

#' Resolve explicit phase-plane pairs
#'
#' @param pairs Explicit pair specification.
#' @param column.names Column names.
#' @param ncol Number of columns.
#'
#' @return A data frame describing resolved phase-plane pairs.
#' @noRd
resolve_explicit_pp_pairs <- function(pairs, column.names, ncol) {
  if (is.matrix(pairs) || is.data.frame(pairs)) {
    if (ncol(pairs) != 2L) {
      stop("`pairs` must have exactly two columns.", call. = FALSE)
    }
    pair.names <- colnames(pairs)
    if (!is.null(pair.names) && all(c("h.var", "v.var") %in% pair.names)) {
      h.values <- pairs[, "h.var"]
      v.values <- pairs[, "v.var"]
    } else {
      h.values <- pairs[, 1L]
      v.values <- pairs[, 2L]
    }
    return(resolve_pp_pair_vectors(h.values, v.values, column.names = column.names, ncol = ncol))
  }

  if (is.list(pairs)) {
    if (length(pairs) == 0L) {
      stop("`pairs` must contain at least one pair.", call. = FALSE)
    }
    h.values <- vector("list", length(pairs))
    v.values <- vector("list", length(pairs))
    for (index in seq_along(pairs)) {
      pair <- pairs[[index]]
      if (is.list(pair) && all(c("h.var", "v.var") %in% names(pair))) {
        h.values[[index]] <- pair$h.var
        v.values[[index]] <- pair$v.var
      } else {
        if (length(pair) != 2L) {
          stop("Each element of `pairs` must be a length-two pair.", call. = FALSE)
        }
        h.values[[index]] <- pair[[1L]]
        v.values[[index]] <- pair[[2L]]
      }
    }
    return(resolve_pp_pair_vectors(h.values, v.values, column.names = column.names, ncol = ncol))
  }

  stop("`pairs` must be a two-column matrix/data frame or a list of length-two pairs.", call. = FALSE)
}

#' Resolve vectors of pair variables
#'
#' @param h.values,v.values Pair variable vectors or lists.
#' @param column.names Column names.
#' @param ncol Number of columns.
#'
#' @return A data frame describing resolved phase-plane pairs.
#' @noRd
resolve_pp_pair_vectors <- function(h.values, v.values, column.names, ncol) {
  if (length(h.values) == 0L || length(v.values) == 0L || length(h.values) != length(v.values)) {
    stop("`pairs` must contain at least one complete horizontal/vertical pair.", call. = FALSE)
  }

  h.columns <- integer(length(h.values))
  v.columns <- integer(length(v.values))
  for (index in seq_along(h.values)) {
    h.columns[[index]] <- resolve_pp_single_column(h.values[[index]], column.names, ncol, "pairs")
    v.columns[[index]] <- resolve_pp_single_column(v.values[[index]], column.names, ncol, "pairs")
  }

  make_pp_pair_data(h.columns, v.columns, column.names = column.names)
}

#' Resolve one phase-plane column selector
#'
#' @param value Column selector.
#' @param column.names Column names.
#' @param ncol Number of columns.
#' @param argument.name Argument name for errors.
#'
#' @return Integer column index.
#' @noRd
resolve_pp_single_column <- function(value, column.names, ncol, argument.name) {
  column <- resolve_mts_columns(value, column.names = column.names, ncol = ncol, argument.name = argument.name)
  if (length(column) != 1L) {
    stop("Each `pairs` entry must resolve to exactly one column.", call. = FALSE)
  }

  column
}

#' Build phase-plane pair data
#'
#' @param h.columns,v.columns Horizontal and vertical column indices.
#' @param column.names Column names.
#'
#' @return A data frame describing resolved phase-plane pairs.
#' @noRd
make_pp_pair_data <- function(h.columns, v.columns, column.names) {
  data.frame(
    h.var = column.names[h.columns],
    v.var = column.names[v.columns],
    h.column = as.integer(h.columns),
    v.column = as.integer(v.columns),
    stringsAsFactors = FALSE
  )
}

#' Return phase-plane pair names
#'
#' @param pair.data Resolved pair data.
#'
#' @return Character vector of pair names.
#' @noRd
pp_pair_names <- function(pair.data) {
  paste(pair.data$h.var, pair.data$v.var, sep = "-")
}

#' Normalise phase-plane label map
#'
#' @param label.map Optional named character vector or list.
#'
#' @return A named character vector.
#' @noRd
normalise_pp_label_map <- function(label.map) {
  if (is.null(label.map)) {
    return(character())
  }

  if (is.list(label.map) && !is.data.frame(label.map)) {
    if (is.null(names(label.map)) || any(!nzchar(names(label.map)))) {
      stop("`label.map` list entries must be named.", call. = FALSE)
    }
    values <- vapply(label.map, function(value) {
      if (!is.character(value) || length(value) != 1L || is.na(value)) {
        stop("`label.map` values must be character scalars.", call. = FALSE)
      }
      value
    }, character(1))
    label.map <- values
  }

  if (!is.character(label.map) || is.null(names(label.map)) ||
      any(!nzchar(names(label.map))) || anyNA(label.map)) {
    stop("`label.map` must be a named character vector or named list of character scalars.", call. = FALSE)
  }
  if (anyDuplicated(names(label.map))) {
    stop("`label.map` names must be unique.", call. = FALSE)
  }

  label.map
}

#' Resolve phase-plane display labels
#'
#' @param pair.data Resolved pair data.
#' @param label.map Named character vector.
#' @param use.tikz Optional tikz mode.
#'
#' @return A list containing raw and rendered labels.
#' @noRd
resolve_pp_labels <- function(pair.data, label.map, use.tikz) {
  h.raw <- pp_raw_labels(pair.data$h.var, label.map)
  v.raw <- pp_raw_labels(pair.data$v.var, label.map)
  h.rendered <- nice_text(h.raw, use.tikz = use.tikz, warn = FALSE)
  v.rendered <- nice_text(v.raw, use.tikz = use.tikz, warn = FALSE)

  list(
    h.raw = h.raw,
    v.raw = v.raw,
    h.label = pp_label_list(h.rendered),
    v.label = pp_label_list(v.rendered)
  )
}

#' Return raw labels for variables
#'
#' @param variables Variable names.
#' @param label.map Named character vector.
#'
#' @return Character vector.
#' @noRd
pp_raw_labels <- function(variables, label.map) {
  mapped <- variables %in% names(label.map)
  out <- variables
  out[mapped] <- label.map[variables[mapped]]
  out
}

#' Convert rendered labels to a list of scalar labels
#'
#' @param labels Rendered labels.
#'
#' @return List of scalar labels.
#' @noRd
pp_label_list <- function(labels) {
  lapply(seq_along(labels), function(index) labels[index])
}

#' Compute a robust axis range
#'
#' @param values Numeric vector.
#' @param pair.name Pair name for errors.
#' @param direction Axis direction for errors.
#'
#' @return Numeric vector of length two.
#' @noRd
pp_axis_range <- function(values, pair.name, direction) {
  finite <- is.finite(values)
  if (!any(finite)) {
    stop("Pair `", pair.name, "` has no finite ", direction, " values.", call. = FALSE)
  }

  range <- range(values[finite])
  if (identical(range[1L], range[2L])) {
    padding <- if (range[1L] == 0) 0.5 else abs(range[1L]) * 0.04
    range <- range + c(-padding, padding)
  }

  range
}

#' Validate a phase-plane log-axis specification
#'
#' @param log Candidate `log` argument.
#'
#' @return A list containing canonical log text and x/y logical flags.
#' @noRd
validate_pp_log <- function(log) {
  if (is.null(log)) {
    log <- ""
  }
  if (!is.character(log) || length(log) != 1L || is.na(log)) {
    stop("`log` must be a character scalar containing only 'x' and/or 'y'.", call. = FALSE)
  }

  chars <- strsplit(log, "", fixed = TRUE)[[1L]]
  if (length(chars) == 0L) {
    chars <- character()
  }
  if (!all(chars %in% c("x", "y"))) {
    stop("`log` must be '', 'x', 'y', or 'xy'.", call. = FALSE)
  }

  xlog <- "x" %in% chars
  ylog <- "y" %in% chars
  list(
    value = paste0(c(if (xlog) "x", if (ylog) "y"), collapse = ""),
    x = xlog,
    y = ylog
  )
}

#' Return the current plot log-axis state
#'
#' @return A list containing canonical log text and x/y logical flags.
#' @noRd
pp_current_log_axes <- function() {
  xlog <- isTRUE(graphics::par("xlog"))
  ylog <- isTRUE(graphics::par("ylog"))
  list(
    value = paste0(c(if (xlog) "x", if (ylog) "y"), collapse = ""),
    x = xlog,
    y = ylog
  )
}

#' Resolve log-axis state from phase-plane plot metadata
#'
#' @param plot.info Phase-plane plot metadata.
#'
#' @return A list containing canonical log text and x/y logical flags.
#' @noRd
pp_plot_info_log_axes <- function(plot.info) {
  if (!is.null(plot.info$log.axes) &&
      all(c("x", "y") %in% names(plot.info$log.axes))) {
    xlog <- isTRUE(plot.info$log.axes$x)
    ylog <- isTRUE(plot.info$log.axes$y)
    return(list(
      value = paste0(c(if (xlog) "x", if (ylog) "y"), collapse = ""),
      x = xlog,
      y = ylog
    ))
  }

  if (!is.null(plot.info$log)) {
    return(validate_pp_log(plot.info$log))
  }

  pp_current_log_axes()
}

#' Omit non-positive phase-plane points for log axes
#'
#' @param h.values,v.values Horizontal and vertical point coordinates.
#' @param log.axes Log-axis metadata from [validate_pp_log()].
#'
#' @return List containing draw vectors, range vectors, and count metadata.
#' @noRd
pp_filter_log_points <- function(h.values, v.values, log.axes) {
  if (length(h.values) != length(v.values)) {
    stop("Phase-plane coordinate vectors must have the same length.", call. = FALSE)
  }

  omitted.x <- if (isTRUE(log.axes$x)) {
    !is.na(h.values) & h.values <= 0
  } else {
    rep(FALSE, length(h.values))
  }
  omitted.y <- if (isTRUE(log.axes$y)) {
    !is.na(v.values) & v.values <= 0
  } else {
    rep(FALSE, length(v.values))
  }
  omitted <- omitted.x | omitted.y
  keep <- !omitted

  h.draw <- h.values
  v.draw <- v.values
  h.draw[omitted] <- NA_real_
  v.draw[omitted] <- NA_real_

  finite.draw <- keep & is.finite(h.values) & is.finite(v.values)
  summary <- list(
    n.total = length(h.values),
    n.kept = sum(keep),
    n.finite = sum(finite.draw),
    n.omitted.log = sum(omitted),
    n.omitted.log.x = sum(omitted.x),
    n.omitted.log.y = sum(omitted.y)
  )

  list(
    h.draw = h.draw,
    v.draw = v.draw,
    h.range = h.values[keep],
    v.range = v.values[keep],
    summary = summary
  )
}

#' Validate an optional phase-plane axis range override
#'
#' @param value Candidate range.
#' @param argument.name Argument name for error messages.
#' @param log.axis Whether the axis is log-scaled.
#'
#' @return `NULL` or a finite numeric vector of length two.
#' @noRd
validate_pp_axis_override <- function(value, argument.name, log.axis = FALSE) {
  if (is.null(value)) {
    return(NULL)
  }

  if (!is.numeric(value) || length(value) != 2L || anyNA(value) ||
      any(!is.finite(value))) {
    stop("`", argument.name, "` must be a finite numeric vector of length two.", call. = FALSE)
  }
  if (identical(value[1L], value[2L])) {
    stop("`", argument.name, "` values must not be identical.", call. = FALSE)
  }
  if (isTRUE(log.axis) && any(value <= 0)) {
    stop("`", argument.name, "` values must be strictly positive when the corresponding axis is log-scaled.",
         call. = FALSE)
  }

  as.numeric(value)
}

#' Make phase-plane panel metadata
#'
#' @param pair.data Resolved pair data.
#' @param mfg,usr,xlim,ylim Panel graphics metadata.
#' @param las Axis tick-label orientation, or `NULL` when no plot axes were
#'   drawn by [mts_pp_plot()].
#' @param log Optional log-axis metadata.
#' @param point.summary Optional list of point-count metadata.
#'
#' @return A named list of panel metadata.
#' @noRd
make_pp_panel_metadata <- function(pair.data,
                                   mfg,
                                   usr,
                                   xlim,
                                   ylim,
                                   las = NULL,
                                   log = NULL,
                                   point.summary = NULL) {
  panels <- vector("list", nrow(pair.data))
  for (index in seq_len(nrow(pair.data))) {
    panels[[index]] <- list(
      panel.index = pair.data$panel.index[[index]],
      pair.name = pair.data$pair.name[[index]],
      h.var = pair.data$h.var[[index]],
      v.var = pair.data$v.var[[index]],
      h.column = pair.data$h.column[[index]],
      v.column = pair.data$v.column[[index]],
      mfg = mfg[[index]],
      usr = usr[[index]],
      xlim = xlim[[index]],
      ylim = ylim[[index]],
      las = las,
      log = if (is.null(log)) NULL else log$value,
      log.axes = if (is.null(log)) NULL else list(x = log$x, y = log$y),
      point.summary = if (is.null(point.summary)) NULL else point.summary[[index]]
    )
  }
  names(panels) <- as.character(pair.data$panel.index)
  panels
}

#' Create phase-plane curve-registry rows
#'
#' @param object.index Object index for this curve set.
#' @param pair.data Resolved pair data.
#' @param col,lty,lwd,type Graphical parameters.
#' @param drawn Logical drawn flag.
#' @param reason Reason for skipped drawing.
#' @param point.summary Optional list of point-count metadata.
#'
#' @return A data frame suitable for `plot.info$curves`.
#' @noRd
make_pp_curve_registry <- function(object.index,
                                   pair.data,
                                   col,
                                   lty,
                                   lwd,
                                   type,
                                   drawn,
                                   reason,
                                   point.summary = NULL) {
  n <- nrow(pair.data)
  point.counts <- pp_curve_point_counts(point.summary, n)
  data.frame(
    object.index = as.integer(rep(object.index, n)),
    h.column = as.integer(pair.data$h.column),
    v.column = as.integer(pair.data$v.column),
    h.var = as.character(pair.data$h.var),
    v.var = as.character(pair.data$v.var),
    pair.name = as.character(pair.data$pair.name),
    panel.index = as.integer(pair.data$panel.index),
    col = as.character(col),
    lty = as.character(lty),
    lwd = as.numeric(lwd),
    type = as.character(rep(type, n)),
    drawn = as.logical(rep(drawn, n)),
    reason = as.character(rep(reason, n)),
    n.points = point.counts$n.total,
    n.plotted = point.counts$n.finite,
    n.omitted.log = point.counts$n.omitted.log,
    n.omitted.log.x = point.counts$n.omitted.log.x,
    n.omitted.log.y = point.counts$n.omitted.log.y,
    stringsAsFactors = FALSE
  )
}

#' Convert point summaries into curve-registry columns
#'
#' @param point.summary Optional list of point-count metadata.
#' @param n Number of registry rows.
#'
#' @return List of integer vectors.
#' @noRd
pp_curve_point_counts <- function(point.summary, n) {
  fields <- c(
    "n.total",
    "n.finite",
    "n.omitted.log",
    "n.omitted.log.x",
    "n.omitted.log.y"
  )
  if (is.null(point.summary)) {
    out <- stats::setNames(rep(list(rep(NA_integer_, n)), length(fields)), fields)
    return(out)
  }
  if (length(point.summary) != n) {
    stop("Point-summary metadata length does not match the number of phase-plane pairs.",
         call. = FALSE)
  }

  stats::setNames(lapply(fields, function(field) {
    vapply(point.summary, function(summary) as.integer(summary[[field]]), integer(1))
  }), fields)
}

#' Validate phase-plane plot metadata
#'
#' @param plot.info Object to validate.
#'
#' @return Invisibly returns `plot.info`.
#' @noRd
validate_pp_plot_info <- function(plot.info) {
  required.names <- c("pairs", "pair.names", "layout", "usr", "mfg", "xlim", "ylim", "labels", "panels", "curves")
  if (!inherits(plot.info, "earnmisc_pp_plot_info") ||
      !all(required.names %in% names(plot.info))) {
    stop("`plot.info` must be an object returned by `mts_pp_plot()`.", call. = FALSE)
  }

  invisible(plot.info)
}

#' Resolve phase-plane pairs from plot metadata
#'
#' @param plot.info Phase-plane plot metadata.
#' @param mts.data Coerced mts data.
#'
#' @return Pair data with column indices resolved for `mts.data`.
#' @noRd
resolve_pp_pairs_from_plot_info <- function(plot.info, mts.data) {
  h.columns <- resolve_mts_columns(
    plot.info$pairs$h.var,
    column.names = mts.data$column.names,
    ncol = ncol(mts.data$matrix),
    argument.name = "plot.info$pairs$h.var"
  )
  v.columns <- resolve_mts_columns(
    plot.info$pairs$v.var,
    column.names = mts.data$column.names,
    ncol = ncol(mts.data$matrix),
    argument.name = "plot.info$pairs$v.var"
  )
  pair.data <- make_pp_pair_data(h.columns, v.columns, column.names = mts.data$column.names)
  pair.data$panel.index <- plot.info$pairs$panel.index
  pair.data$pair.name <- plot.info$pairs$pair.name

  pair.data
}

#' Return phase-plane panel mfg coordinates
#'
#' @param index Panel index.
#' @param layout Layout object.
#'
#' @return Integer vector suitable for [graphics::par()] `mfg`.
#' @noRd
pp_panel_mfg <- function(index, layout) {
  row <- ((index - 1L) %/% layout$ncol) + 1L
  col <- ((index - 1L) %% layout$ncol) + 1L
  c(row, col, layout$nrow, layout$ncol)
}

#' Return next phase-plane overlay object index
#'
#' @param plot.info Phase-plane plot metadata.
#'
#' @return Integer scalar.
#' @noRd
next_pp_object_index <- function(plot.info) {
  if (nrow(plot.info$curves) == 0L) {
    return(0L)
  }

  max(plot.info$curves$object.index, na.rm = TRUE) + 1L
}

#' Create an empty phase-plane curve registry
#'
#' @return An empty data frame with the same columns as `plot.info$curves`.
#' @noRd
empty_pp_curve_registry <- function() {
  data.frame(
    object.index = integer(),
    h.column = integer(),
    v.column = integer(),
    h.var = character(),
    v.var = character(),
    pair.name = character(),
    panel.index = integer(),
    col = character(),
    lty = character(),
    lwd = numeric(),
    type = character(),
    drawn = logical(),
    reason = character(),
    n.points = integer(),
    n.plotted = integer(),
    n.omitted.log = integer(),
    n.omitted.log.x = integer(),
    n.omitted.log.y = integer(),
    stringsAsFactors = FALSE
  )
}
