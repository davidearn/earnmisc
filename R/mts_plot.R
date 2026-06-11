mts_plot_store <- new.env(parent = emptyenv())
mts_plot_store$last <- NULL

#' Plot a multivariate time series in panels
#'
#' Plot selected columns of a multivariate time series, one column per panel,
#' and return metadata that [mts_lines()], [mts_abline()], and
#' [mts_xys_line()] can use for later overlays.
#'
#' These helpers provide a coherent base-graphics workflow for `mts` overlays:
#' call `mts_plot()` first, then pass the returned object to `mts_lines()`.
#' Overlaying onto arbitrary existing [stats::plot.ts()] or `plot.mts()` output
#' is not supported because base R does not expose a stable public panel map.
#' Curve sources are recorded in the `curves` registry. The `source` column is
#' a character key used for grouping and inspection. The `source.label`
#' list-column preserves the display label, including expression-like labels
#' used by [graphics::legend()].
#'
#' @param x Multivariate time-series object, or an object safely coercible to a
#'   matrix with a regular sequence time index.
#' @param columns Optional column names or indices to plot.
#' @param panel Panel mode. `"separate"` draws one panel per selected series.
#'   `"overlay"` draws all selected series on one panel for classes that
#'   support overlay-panel plotting.
#' @param nrow,ncol Optional panel layout dimensions.
#' @param blank.panels Optional positive integer vector of full layout panel
#'   indices to reserve for later legends, annotations, or custom graphics.
#'   Reserved panels are blank after `mts_plot()` finishes.
#' @param legend Simple legend control for overlay-panel methods.
#' @param main Optional outer title.
#' @param xlab X-axis label.
#' @param ylab Optional y-axis label. If `NULL`, each panel uses its column name.
#' @param col,lty,lwd,type Graphical parameters for base curves. `col`, `lty`,
#'   and `lwd` may be scalar, vectorised by selected column, or named by column.
#' @param source Optional source label for the base curves. It may be a
#'   non-empty character scalar or a scalar expression-like label, including
#'   output from [nice_text()]. If `NULL`, a label is inferred from the
#'   expression supplied for `x`.
#' @param axes,frame.plot Logical values passed to [graphics::plot.default()].
#' @param mar,oma Optional margin settings passed to [graphics::par()].
#' @param las Axis-label orientation passed to [graphics::plot.default()].
#' @param xlim,ylim Optional axis limits.
#' @param ... Additional arguments passed to [graphics::plot.default()].
#'
#' @return Invisibly returns an `earnmisc_mts_plot_info` list containing panel
#'   metadata and a `curves` registry. The registry is used by [mts_legend()]
#'   and can also be inspected directly.
#'
#' @examples
#' x <- stats::ts(cbind(a = 1:10, b = 11:20))
#' y <- stats::ts(cbind(a = 2:11, b = 10:19))
#' plot.info <- mts_plot(x)
#' plot.info <- mts_lines(y, plot.info = plot.info)
#' plot.info$curves
#' plot.info <- mts_plot(x, source = "baseline")
#' plot.info <- mts_lines(y, plot.info = plot.info, source = "comparison")
#' mts_legend(plot.info, by = "source", panel = 1)
#' plot.info <- mts_plot(x, source = expression(R[0] == 8))
#' plot.info <- mts_lines(y, plot.info = plot.info, source = expression(R[0] == 4))
#' mts_legend(plot.info, by = "source", panel = 1)
#'
#' x3 <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))
#' y3 <- stats::ts(cbind(a = 2:11, b = 10:19, c = 20:29))
#' plot.info <- mts_plot(x3, blank.panels = 1)
#' plot.info <- mts_lines(y3, plot.info = plot.info, source = "overlay")
#' mts_legend(plot.info)
#'
#' plot.info <- mts_plot(x3, blank.panels = c(1, 4))
#' mts_set_panel(4, plot.info)
#' graphics::text(0.5, 0.5, "Notes")
#'
#' @export
mts_plot <- function(
  x,
  columns = NULL,
  panel = c("separate", "overlay"),
  nrow = NULL,
  ncol = NULL,
  blank.panels = NULL,
  legend = FALSE,
  main = NULL,
  xlab = "Time",
  ylab = NULL,
  col = "black",
  lty = 1,
  lwd = 1,
  type = "l",
  source = NULL,
  axes = TRUE,
  frame.plot = TRUE,
  mar = NULL,
  oma = NULL,
  las = 1,
  xlim = NULL,
  ylim = NULL,
  ...
) {
  UseMethod("mts_plot")
}

#' @rdname mts_plot
#' @export
mts_plot.default <- function(
  x,
  columns = NULL,
  panel = c("separate", "overlay"),
  nrow = NULL,
  ncol = NULL,
  blank.panels = NULL,
  legend = FALSE,
  main = NULL,
  xlab = "Time",
  ylab = NULL,
  col = "black",
  lty = 1,
  lwd = 1,
  type = "l",
  source = NULL,
  axes = TRUE,
  frame.plot = TRUE,
  mar = NULL,
  oma = NULL,
  las = 1,
  xlim = NULL,
  ylim = NULL,
  ...
) {
  panel <- match.arg(panel)
  if (identical(panel, "overlay")) {
    stop("`panel = \"overlay\"` is only supported for classes with native overlay-panel methods.",
         call. = FALSE)
  }
  if (!isFALSE(legend) && !is.null(legend)) {
    stop("`legend` is only supported when `panel = \"overlay\"`.",
         call. = FALSE)
  }

  source <- normalise_mts_source(substitute(x), source = source)
  mts.data <- as_mts_matrix(x)
  selected.columns <- resolve_mts_columns(
    columns,
    column.names = mts.data$column.names,
    ncol = ncol(mts.data$matrix),
    argument.name = "columns"
  )
  selected.names <- mts.data$column.names[selected.columns]
  blank.panels <- resolve_blank_panels(blank.panels, n.data.panels = length(selected.columns))
  total.panels <- length(selected.columns) + length(blank.panels)
  data.panels <- setdiff(seq_len(total.panels), blank.panels)
  panel.roles <- mts_panel_roles(total.panels, blank.panels)
  layout <- mts_layout_dims(total.panels, nrow = nrow, ncol = ncol)
  graphics.parameters <- resolve_mts_graphics(
    n = length(selected.columns),
    col = col,
    lty = lty,
    lwd = lwd,
    column.names = selected.names
  )

  if (!is.null(mar)) {
    graphics::par(mar = mar)
  }
  if (!is.null(oma)) {
    graphics::par(oma = oma)
  }
  graphics::par(mfrow = c(layout$nrow, layout$ncol))

  usr <- vector("list", total.panels)
  mfg <- vector("list", total.panels)
  plot.xlim <- if (is.null(xlim)) range(mts.data$time, finite = TRUE) else xlim
  panel.ylim <- vector("list", total.panels)
  panel.names <- rep(NA_character_, total.panels)
  panel.columns <- rep(NA_integer_, total.panels)

  for (panel.index in seq_len(total.panels)) {
    if (panel.roles[[panel.index]] == "blank") {
      graphics::plot.new()
      graphics::plot.window(xlim = c(0, 1), ylim = c(0, 1), xaxs = "i", yaxs = "i")
      usr[[panel.index]] <- graphics::par("usr")
      mfg[[panel.index]] <- graphics::par("mfg")
      panel.ylim[[panel.index]] <- c(0, 1)
      next
    }

    data.index <- match(panel.index, data.panels)
    column.index <- selected.columns[[data.index]]
    panel.name <- selected.names[[data.index]]
    panel.ylab <- if (is.null(ylab)) panel.name else ylab
    current.ylim <- if (is.null(ylim)) {
      range(mts.data$matrix[, column.index], finite = TRUE)
    } else {
      ylim
    }

    graphics::plot.default(
      x = mts.data$time,
      y = mts.data$matrix[, column.index],
      type = type,
      xlab = xlab,
      ylab = panel.ylab,
      main = panel.name,
      col = graphics.parameters$col[[data.index]],
      lty = graphics.parameters$lty[[data.index]],
      lwd = graphics.parameters$lwd[[data.index]],
      axes = axes,
      frame.plot = frame.plot,
      las = las,
      xlim = plot.xlim,
      ylim = current.ylim,
      ...
    )

    usr[[panel.index]] <- graphics::par("usr")
    mfg[[panel.index]] <- graphics::par("mfg")
    panel.ylim[[panel.index]] <- current.ylim
    panel.names[[panel.index]] <- panel.name
    panel.columns[[panel.index]] <- column.index
  }

  if (!is.null(main)) {
    graphics::mtext(main, side = 3, outer = TRUE, line = 0)
  }

  curves <- make_mts_curve_registry(
    source = source$key,
    source.label = source$label,
    object.index = 0L,
    column = selected.columns,
    name = selected.names,
    panel.index = data.panels,
    panel.name = selected.names,
    col = graphics.parameters$col,
    lty = graphics.parameters$lty,
    lwd = graphics.parameters$lwd,
    type = type,
    drawn = TRUE,
    reason = NA_character_
  )

  plot.info <- list(
    x = x,
    data = mts.data$matrix,
    columns = selected.columns,
    column.names = selected.names,
    original.column.names = mts.data$original.column.names,
    panel.mode = "separate",
    panel.order = data.panels,
    layout = layout,
    time = mts.data$time,
    usr = usr,
    mfg = mfg,
    xlim = plot.xlim,
    ylim = panel.ylim,
    blank.panels = if (length(blank.panels) == 0L) NULL else blank.panels,
    data.panels = data.panels,
    panel.roles = panel.roles,
    panels = make_mts_panel_metadata(
      panel.index = seq_len(total.panels),
      role = panel.roles,
      name = panel.names,
      column = panel.columns,
      mfg = mfg,
      usr = usr,
      xlim = rep(list(plot.xlim), total.panels),
      ylim = panel.ylim
    ),
    device = unname(grDevices::dev.cur()),
    created_at = Sys.time(),
    curves = curves
  )
  class(plot.info) <- c("earnmisc_mts_plot_info", "list")
  store_mts_plot_info(plot.info)

  invisible(plot.info)
}

#' Overlay multivariate time-series columns on `mts_plot()` panels
#'
#' Overlay selected columns from an `mts`-like object onto panels created by
#' [mts_plot()]. This function is not intended for arbitrary existing
#' `plot.mts()` output. When [mts_plot()] has reserved blank panels,
#' `mts_lines()` overlays on the correct data panels and skips reserved panels.
#' If `source` is `NULL`, the source label is inferred from the expression
#' supplied for `y`, so repeated direct calls with different inputs remain
#' distinct in [mts_legend()] when `by = "source"`.
#' For `mts_list` objects, [mts_lines()] overlays one native-grid series onto
#' each plotted data panel. The `mts_list` method matches panels by position by
#' default; set `match = "name"` to match by panel/series name.
#'
#' @param y Overlay multivariate time-series object.
#' @param plot.info Plot metadata returned by [mts_plot()]. If `NULL`, the most
#'   recent `mts_plot()` result is used.
#' @param columns Optional overlay column names or indices.
#' @param match Column matching mode: `"name"` or `"position"`.
#' @param unmatched Behaviour for unmatched overlay columns: `"warn"`,
#'   `"error"`, or `"ignore"`.
#' @param col,lty,lwd,type Overlay graphical parameters. `col`, `lty`, and
#'   `lwd` may be scalar, vectorised by selected overlay column, or named by
#'   overlay column.
#' @param source Optional curve source label. It may be a non-empty character
#'   scalar or a scalar expression-like label, including output from
#'   [nice_text()]. If `NULL`, a label is inferred from the expression supplied
#'   for `y`.
#' @param object.index Optional overlay object index for the curve registry.
#' @param ... Additional arguments passed to [graphics::lines()].
#'
#' @return Invisibly returns the updated `plot.info` object with appended curve
#'   registry rows.
#'
#' @examples
#' x <- stats::ts(cbind(a = 1:10, b = 11:20))
#' y <- stats::ts(cbind(b = 10:19, a = 2:11))
#' plot.info <- mts_plot(x)
#' plot.info <- mts_lines(y, plot.info = plot.info)
#'
#' @name mts_lines
#' @export
mts_lines <- function(
  y,
  plot.info = NULL,
  columns = NULL,
  match = c("name", "position"),
  unmatched = c("warn", "error", "ignore"),
  col = "red",
  lty = 1,
  lwd = 1,
  type = "l",
  source = NULL,
  object.index = NULL,
  ...
) {
  UseMethod("mts_lines")
}

#' @rdname mts_lines
#' @export
mts_lines.default <- function(
  y,
  plot.info = NULL,
  columns = NULL,
  match = c("name", "position"),
  unmatched = c("warn", "error", "ignore"),
  col = "red",
  lty = 1,
  lwd = 1,
  type = "l",
  source = NULL,
  object.index = NULL,
  ...
) {
  source <- normalise_mts_source(substitute(y), source = source)
  if (is.null(plot.info)) {
    plot.info <- last_mts_plot_info()
    if (is.null(plot.info)) {
      stop("`mts_lines()` requires a `plot.info` object from `mts_plot()` or a prior call to `mts_plot()`.", call. = FALSE)
    }
  }
  validate_mts_plot_info(plot.info)
  match <- match.arg(match)
  unmatched <- match.arg(unmatched)

  y.data <- as_mts_matrix(y)
  selected.columns <- resolve_mts_columns(
    columns,
    column.names = y.data$column.names,
    ncol = ncol(y.data$matrix),
    argument.name = "columns"
  )
  selected.names <- y.data$column.names[selected.columns]
  graphics.parameters <- resolve_mts_graphics(
    n = length(selected.columns),
    col = col,
    lty = lty,
    lwd = lwd,
    column.names = selected.names
  )
  matched.panels <- match_mts_columns(
    y.column.names = y.data$original.column.names,
    y.columns = selected.columns,
    plot.info = plot.info,
    match = match
  )
  matched <- !is.na(matched.panels)

  if (any(!matched)) {
    unmatched.names <- selected.names[!matched]
    message <- paste0("Unmatched mts column", if (sum(!matched) == 1L) "" else "s", ": ", paste(unmatched.names, collapse = ", "))

    if (identical(unmatched, "error")) {
      stop(message, call. = FALSE)
    }
    if (identical(unmatched, "warn")) {
      warning(message, call. = FALSE)
    }
  }

  if (is.null(object.index)) {
    object.index <- next_mts_object_index(plot.info)
  }

  new.curves <- vector("list", length(selected.columns))

  for (selected.index in seq_along(selected.columns)) {
    y.column <- selected.columns[[selected.index]]
    panel.index <- matched.panels[[selected.index]]
    drawn <- !is.na(panel.index)
    reason <- if (drawn) NA_character_ else "unmatched"
    panel.name <- if (drawn) plot.info$panels[[panel.index]]$name else NA_character_

    if (drawn) {
      graphics::par(mfg = plot.info$mfg[[panel.index]])
      graphics::par(usr = plot.info$usr[[panel.index]])
      graphics::lines(
        x = y.data$time,
        y = y.data$matrix[, y.column],
        type = type,
        col = graphics.parameters$col[[selected.index]],
        lty = graphics.parameters$lty[[selected.index]],
        lwd = graphics.parameters$lwd[[selected.index]],
        ...
      )
    }

    new.curves[[selected.index]] <- make_mts_curve_registry(
      source = source$key,
      source.label = source$label,
      object.index = object.index,
      column = y.column,
      name = selected.names[[selected.index]],
      panel.index = if (drawn) panel.index else NA_integer_,
      panel.name = panel.name,
      col = graphics.parameters$col[[selected.index]],
      lty = graphics.parameters$lty[[selected.index]],
      lwd = graphics.parameters$lwd[[selected.index]],
      type = type,
      drawn = drawn,
      reason = reason
    )
  }

  plot.info$curves <- rbind(plot.info$curves, do.call(rbind, new.curves))
  store_mts_plot_info(plot.info)
  invisible(plot.info)
}

#' Add reference lines to mts plot panels
#'
#' Add [graphics::abline()] reference lines to panels created by [mts_plot()].
#' This helper is part of the `mts_plot()` workflow and is not intended for
#' arbitrary existing `plot.mts()` output. By default, it draws on all data
#' panels and skips reserved blank panels.
#'
#' @param plot.info Plot metadata returned by [mts_plot()]. If `NULL`, the most
#'   recent `mts_plot()` result is used.
#' @param panels Optional full layout panel indices. If supplied, these panels
#'   are used directly and may include blank panels.
#' @param columns Optional plotted data columns. Character values are matched to
#'   plotted column names; numeric values are interpreted as positions among the
#'   plotted columns.
#' @param a,b,h,v,reg,coef,untf Arguments passed to [graphics::abline()]. Only
#'   non-`NULL` line-definition arguments are passed.
#' @param source Source label used when recording the reference lines. It may be
#'   a non-empty character scalar or scalar expression-like label, including
#'   output from [nice_text()].
#' @param record Logical. If `TRUE`, append reference-line rows to the
#'   `plot.info$curves` registry for later legend construction.
#' @param col,lty,lwd Common graphical arguments passed to
#'   [graphics::abline()]. They may be scalar, vectorised by selected panel, or
#'   named by plotted column where possible.
#' @param ... Additional graphical arguments passed to [graphics::abline()].
#'
#' @return Invisibly returns the updated `earnmisc_mts_plot_info` object.
#'
#' @examples
#' x <- stats::ts(cbind(a = 1:10, b = 11:20))
#' plot.info <- mts_plot(x)
#' plot.info <- mts_abline(
#'   plot.info = plot.info,
#'   h = 0,
#'   col = "grey70",
#'   lty = 2
#' )
#'
#' plot.info <- mts_plot(x, blank.panels = 1)
#' plot.info <- mts_abline(plot.info = plot.info, h = 0)
#' mts_legend(plot.info)
#'
#' @export
mts_abline <- function(
  plot.info = NULL,
  panels = NULL,
  columns = NULL,
  a = NULL,
  b = NULL,
  h = NULL,
  v = NULL,
  reg = NULL,
  coef = NULL,
  untf = FALSE,
  source = "abline",
  record = TRUE,
  col = NULL,
  lty = NULL,
  lwd = NULL,
  ...
) {
  plot.info <- resolve_mts_plot_info(plot.info, caller = "mts_abline")
  source <- normalise_mts_source(substitute(source), source = source)
  selected.panels <- select_mts_panels(
    plot.info = plot.info,
    panels = panels,
    columns = columns
  )
  panel.args <- resolve_mts_abline_graphics(
    dots = mts_abline_graphical_args(col = col, lty = lty, lwd = lwd, dots = list(...)),
    panel.names = selected.panels$panel.names
  )
  abline.args <- mts_abline_args(
    a = a,
    b = b,
    h = h,
    v = v,
    reg = reg,
    coef = coef,
    untf = untf
  )

  for (panel.index in seq_along(selected.panels$panels)) {
    enter_mts_panel(plot.info, selected.panels$panels[[panel.index]])
    do.call(graphics::abline, c(abline.args, panel.args[[panel.index]]))
  }

  if (isTRUE(record)) {
    new.curves <- make_mts_abline_registry(
      plot.info = plot.info,
      selected.panels = selected.panels,
      panel.args = panel.args,
      source = source
    )
    plot.info$curves <- rbind(plot.info$curves, new.curves)
    store_mts_plot_info(plot.info)
  }

  invisible(plot.info)
}

#' Add point/slope reference lines to mts plot panels
#'
#' Add point/slope reference lines to panels created by [mts_plot()]. This is
#' analogous to [mts_abline()], but uses the default numeric [xys_line()]
#' convention: finite slopes draw `y - slope * x` intercept lines and infinite
#' slopes draw vertical lines through `x`. This helper is part of the
#' `mts_plot()` workflow and is not intended for arbitrary existing
#' `plot.mts()` output. By default, it draws on all data panels and skips
#' reserved blank panels.
#'
#' @param x,y,slope Numeric vectors defining points and slopes. All
#'   combinations of `x`, `y`, and `slope` are drawn in each selected panel.
#'   Infinite slopes draw vertical lines through `x`.
#' @param plot.info Plot metadata returned by [mts_plot()]. If `NULL`, the most
#'   recent `mts_plot()` result is used.
#' @param panels Optional full layout panel indices. If supplied, these panels
#'   are used directly and may include blank panels.
#' @param columns Optional plotted data columns. Character values are matched to
#'   plotted column names; numeric values are interpreted as positions among the
#'   plotted columns.
#' @param source Source label used when recording the reference lines. It may be
#'   a non-empty character scalar or scalar expression-like label, including
#'   output from [nice_text()].
#' @param record Logical. If `TRUE`, append point/slope rows to the
#'   `plot.info$curves` registry for later legend construction.
#' @param col,lty,lwd Common graphical arguments passed to
#'   [graphics::abline()] through [xys_line()]. They may be scalar, vectorised
#'   over selected panels and generated lines, or named by plotted column where
#'   possible.
#' @param ... Graphical arguments passed to [graphics::abline()] through
#'   [xys_line()].
#'
#' @return Invisibly returns the updated `earnmisc_mts_plot_info` object.
#'
#' @examples
#' z <- stats::ts(cbind(a = 1:10, b = 11:20))
#' plot.info <- mts_plot(z)
#' plot.info <- mts_xys_line(0, 5, 1, plot.info = plot.info, col = "grey50")
#' plot.info <- mts_xys_line(
#'   0,
#'   c(0.1, -0.1),
#'   1,
#'   plot.info = plot.info,
#'   col = c("blue", "red")
#' )
#'
#' plot.info <- mts_plot(z, blank.panels = 1)
#' plot.info <- mts_xys_line(0, 0, 1, plot.info = plot.info)
#'
#' @export
mts_xys_line <- function(
  x,
  y,
  slope,
  plot.info = NULL,
  panels = NULL,
  columns = NULL,
  source = "xys_line",
  record = TRUE,
  col = NULL,
  lty = NULL,
  lwd = NULL,
  ...
) {
  plot.info <- resolve_mts_plot_info(plot.info, caller = "mts_xys_line")
  source <- normalise_mts_source(substitute(source), source = source)
  validate_xys_line_inputs(x = x, y = y, slope = slope)
  line.parameters <- xys_line_parameters(x = x, y = y, slope = slope)
  selected.panels <- select_mts_panels(
    plot.info = plot.info,
    panels = panels,
    columns = columns
  )
  panel.args <- resolve_mts_xys_graphics(
    dots = mts_abline_graphical_args(col = col, lty = lty, lwd = lwd, dots = list(...)),
    panel.names = selected.panels$panel.names,
    line.count = nrow(line.parameters)
  )

  for (panel.index in seq_along(selected.panels$panels)) {
    enter_mts_panel(plot.info, selected.panels$panels[[panel.index]])
    draw_xys_lines(
      line.parameters = line.parameters,
      graphics.parameters = panel.args[[panel.index]]
    )
  }

  if (isTRUE(record)) {
    new.curves <- make_mts_xys_registry(
      plot.info = plot.info,
      selected.panels = selected.panels,
      panel.args = panel.args,
      source = source,
      line.parameters = line.parameters
    )
    plot.info$curves <- rbind(plot.info$curves, new.curves)
    store_mts_plot_info(plot.info)
  }

  invisible(plot.info)
}

#' Plot an mts object with one or more overlays
#'
#' Convenience wrapper that calls [mts_plot()] once and [mts_lines()] once for
#' each overlay object supplied in `...`. Source labels are inferred from the
#' input expressions unless `source.x` or `overlay.names` are supplied.
#'
#' @param x Base multivariate time-series object.
#' @param ... One or more overlay multivariate time-series objects.
#' @param columns.x Optional base columns.
#' @param columns.y Optional overlay columns used for each overlay object.
#' @param match,unmatched Matching and unmatched-column behaviour passed to
#'   [mts_lines()].
#' @param col.x,lty.x,lwd.x Base graphical parameters.
#' @param col.y,lty.y,lwd.y Overlay graphical parameters. If `NULL`, simple
#'   defaults are used. If a list, each element is used for the corresponding
#'   overlay object; otherwise the value is reused for each overlay object.
#' @param source.x Optional source label for the base object. It may be a
#'   non-empty character scalar or scalar expression-like label. If `NULL`, a
#'   label is inferred from the expression supplied for `x`.
#' @param overlay.names Optional source labels for overlay objects. A character
#'   vector or expression vector must contain one label per overlay object. If
#'   `NULL`, labels are inferred from the expressions supplied in `...`.
#' @param plot.args Additional arguments passed to [mts_plot()]. Same-named
#'   values override base plotting defaults such as `col.x`, `lty.x`, and
#'   `lwd.x`. Core arguments `x`, `columns`, and `source` cannot be supplied
#'   here.
#' @param lines.args Additional arguments passed to [mts_lines()]. Same-named
#'   values override overlay defaults such as `col.y`, `lty.y`, and `lwd.y`.
#'   Core arguments `y`, `plot.info`, `columns`, `source`, and `object.index`
#'   cannot be supplied here.
#'
#' @return Invisibly returns the final updated plot-info object.
#'
#' @examples
#' x <- stats::ts(cbind(a = 1:10, b = 11:20))
#' y <- stats::ts(cbind(a = 2:11, b = 10:19))
#' z <- stats::ts(cbind(a = 3:12, b = 9:18))
#' plot.info <- mts_plot_overlay(x, y)
#' plot.info <- mts_plot_overlay(x, y, z)
#' plot.info$curves
#' plot.info <- mts_plot_overlay(
#'   x, y, z,
#'   source.x = "baseline",
#'   overlay.names = c("comparison 1", "comparison 2")
#' )
#'
#' @export
mts_plot_overlay <- function(
  x,
  ...,
  columns.x = NULL,
  columns.y = NULL,
  match = c("name", "position"),
  unmatched = c("warn", "error", "ignore"),
  col.x = "black",
  lty.x = 1,
  lwd.x = 1,
  col.y = NULL,
  lty.y = NULL,
  lwd.y = NULL,
  source.x = NULL,
  overlay.names = NULL,
  plot.args = list(),
  lines.args = list()
) {
  overlay.expressions <- as.list(substitute(list(...)))[-1L]
  overlays <- list(...)

  if (length(overlays) == 0L) {
    stop("At least one overlay object must be supplied in `...`.", call. = FALSE)
  }
  if (!is.list(plot.args)) {
    stop("`plot.args` must be a list.", call. = FALSE)
  }
  if (!is.list(lines.args)) {
    stop("`lines.args` must be a list.", call. = FALSE)
  }
  match <- match.arg(match)
  unmatched <- match.arg(unmatched)
  overlay.names <- normalise_mts_source_vector(
    sources = overlay.names,
    expressions = overlay.expressions,
    n = length(overlays),
    argument.name = "overlay.names"
  )
  source.x <- normalise_mts_source(substitute(x), source = source.x)

  plot.call.args <- merge_call_args(
    defaults = list(
      x = x,
      columns = columns.x,
      col = col.x,
      lty = lty.x,
      lwd = lwd.x,
      source = source.x$label
    ),
    overrides = plot.args,
    protected = c("x", "columns", "source"),
    argument.name = "plot.args"
  )
  plot.info <- do.call(mts_plot, plot.call.args)

  for (overlay.index in seq_along(overlays)) {
    lines.call.args <- merge_call_args(
      defaults = list(
        y = overlays[[overlay.index]],
        plot.info = plot.info,
        columns = columns.y,
        match = match,
        unmatched = unmatched,
        col = overlay_graphic_parameter(col.y, overlay.index, default = default_mts_overlay_colour(overlay.index)),
        lty = overlay_graphic_parameter(lty.y, overlay.index, default = overlay.index),
        lwd = overlay_graphic_parameter(lwd.y, overlay.index, default = 1),
        source = overlay.names[[overlay.index]]$label,
        object.index = overlay.index
      ),
      overrides = lines.args,
      protected = c("y", "plot.info", "columns", "source", "object.index"),
      argument.name = "lines.args"
    )
    plot.info <- do.call(mts_lines, lines.call.args)
  }

  invisible(plot.info)
}

#' Reinitialise an mts plot panel
#'
#' Select a panel from a layout created by [mts_plot()], clear it with
#' [graphics::plot.new()], and initialise a simple coordinate system with
#' [graphics::plot.window()]. This is intended mainly for reserved blank panels
#' used for legends, notes, or later custom graphics. It clears the selected
#' panel, so it is not intended for adding annotations on top of an already
#' drawn data panel; a future `mts_add_to_panel()` helper may support that.
#'
#' @param panel Full layout panel index.
#' @param plot.info Plot metadata returned by [mts_plot()]. If `NULL`, the most
#'   recent `mts_plot()` result is used.
#' @param xlim,ylim Coordinate limits passed to [graphics::plot.window()].
#' @param axes Logical value. If `TRUE`, simple axes and a box are drawn after
#'   the plot window is initialised.
#' @param xaxs,yaxs Axis style arguments passed to [graphics::plot.window()].
#' @param ... Additional arguments passed to [graphics::plot.window()].
#'
#' @return Invisibly returns metadata for the selected panel.
#'
#' @examples
#' x <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))
#' plot.info <- mts_plot(x, blank.panels = c(1, 4))
#' mts_set_panel(4, plot.info)
#' graphics::text(0.5, 0.5, "Notes")
#'
#' @export
mts_set_panel <- function(
  panel,
  plot.info = NULL,
  xlim = c(0, 1),
  ylim = c(0, 1),
  axes = FALSE,
  xaxs = "i",
  yaxs = "i",
  ...
) {
  plot.info <- resolve_mts_plot_info(plot.info, caller = "mts_set_panel")
  panel <- validate_mts_panel_index(panel, plot.info)

  graphics::par(mfg = plot.info$mfg[[panel]])
  graphics::plot.new()
  graphics::plot.window(xlim = xlim, ylim = ylim, xaxs = xaxs, yaxs = yaxs, ...)
  if (isTRUE(axes)) {
    graphics::axis(1)
    graphics::axis(2)
    graphics::box()
  }

  panel.metadata <- plot.info$panels[[panel]]
  panel.metadata$usr <- graphics::par("usr")
  panel.metadata$mfg <- graphics::par("mfg")
  panel.metadata$xlim <- xlim
  panel.metadata$ylim <- ylim

  invisible(panel.metadata)
}

#' Add a legend to an mts plot panel
#'
#' Draw a legend for curves recorded by [mts_plot()], [mts_lines()],
#' [mts_abline()], and [mts_xys_line()]. By default, the legend is grouped by
#' source label and drawn in the first panel reserved with `blank.panels`;
#' otherwise supply `panel` explicitly. For `by = "source"`, grouping uses the
#' character `source` key, while labels come from the preserved `source.label`
#' values so plotmath and [nice_text()] labels can be rendered by
#' [graphics::legend()]. Explicit `legend` labels override source-derived
#' labels.
#'
#' @param plot.info Plot metadata returned by [mts_plot()]. If `NULL`, the most
#'   recent `mts_plot()` result is used.
#' @param panel Optional full layout panel index. If `NULL`, the first blank
#'   panel in `plot.info$blank.panels` is used.
#' @param by Legend grouping: `"source"`, `"curve"`, or `"column"`.
#' @param legend Optional legend labels. If `NULL`, labels are constructed from
#'   the selected curve grouping.
#' @param x,inset,bty Arguments passed to [graphics::legend()].
#' @param ... Additional arguments passed to [graphics::legend()]. Same-named
#'   values such as `col`, `lty`, or `lwd` override the defaults constructed
#'   from `plot.info$curves`.
#'
#' @return Invisibly returns a list containing the legend panel, grouping,
#'   labels, graphical parameters, selected curves, and the result from
#'   [graphics::legend()].
#'
#' @examples
#' x <- stats::ts(cbind(a = 1:10, b = 11:20, c = 21:30))
#' y <- stats::ts(cbind(a = 2:11, b = 10:19, c = 20:29))
#' plot.info <- mts_plot(x, blank.panels = 1)
#' plot.info <- mts_lines(y, plot.info = plot.info, source = "overlay")
#' mts_legend(plot.info)
#'
#' @export
mts_legend <- function(
  plot.info = NULL,
  panel = NULL,
  by = c("source", "curve", "column"),
  legend = NULL,
  x = "center",
  inset = 0,
  bty = "n",
  ...
) {
  plot.info <- resolve_mts_plot_info(plot.info, caller = "mts_legend")
  by <- match.arg(by)

  if (is.null(panel)) {
    if (is.null(plot.info$blank.panels) || length(plot.info$blank.panels) == 0L) {
      stop("`mts_legend()` needs `panel` or a plot with reserved `blank.panels`.", call. = FALSE)
    }
    panel <- plot.info$blank.panels[[1L]]
  }
  panel <- validate_mts_panel_index(panel, plot.info)

  selected.curves <- select_mts_legend_curves(plot.info$curves, by = by)
  if (nrow(selected.curves) == 0L) {
    stop("No drawn mts curves are available for a legend.", call. = FALSE)
  }
  if (is.null(legend)) {
    legend <- make_mts_legend_labels(selected.curves, by = by)
  }

  mts_set_panel(panel, plot.info = plot.info)
  legend.args <- merge_call_args(
    defaults = list(
      x = x,
      legend = legend,
      col = selected.curves$col,
      lty = mts_legend_lty(selected.curves$lty),
      lwd = selected.curves$lwd,
      inset = inset,
      bty = bty
    ),
    overrides = list(...),
    protected = character(),
    argument.name = "..."
  )
  legend.result <- do.call(graphics::legend, legend.args)

  out <- list(
    panel = panel,
    by = by,
    legend = legend,
    col = legend.args$col,
    lty = legend.args$lty,
    lwd = legend.args$lwd,
    curves = selected.curves,
    legend.result = legend.result
  )

  invisible(out)
}

#' Coerce an object to mts plotting data
#'
#' Return matrix data, time index, and column names for an mts-like object.
#'
#' @param x Object to coerce.
#'
#' @return A list containing `matrix`, `time`, `column.names`, and
#'   `original.column.names`.
#' @noRd
as_mts_matrix <- function(x) {
  if (stats::is.ts(x)) {
    time <- as.numeric(stats::time(x))
    matrix <- as.matrix(x)
  } else {
    matrix <- as.matrix(x)
    time <- seq_len(nrow(matrix))
  }

  if (!is.numeric(matrix) && !is.integer(matrix)) {
    stop("`x` and overlay objects must contain numeric time-series data.", call. = FALSE)
  }
  if (is.null(dim(matrix)) || ncol(matrix) < 1L) {
    stop("`x` and overlay objects must have at least one column.", call. = FALSE)
  }

  original.column.names <- colnames(matrix)
  column.names <- mts_column_names(matrix)
  colnames(matrix) <- column.names

  list(
    matrix = matrix,
    time = time,
    column.names = column.names,
    original.column.names = original.column.names
  )
}

#' Return mts column names
#'
#' Return existing column names or stable fallback names for a matrix.
#'
#' @param x Matrix.
#'
#' @return A character vector of column names.
#' @noRd
mts_column_names <- function(x) {
  column.names <- colnames(x)

  if (is.null(column.names)) {
    return(paste0("Series ", seq_len(ncol(x))))
  }

  column.names
}

#' Compute mts panel layout
#'
#' Compute a compact panel layout with enough cells.
#'
#' @param n Number of panels.
#' @param nrow,ncol Optional layout dimensions.
#'
#' @return A list with integer `nrow` and `ncol`.
#' @noRd
mts_layout_dims <- function(n, nrow = NULL, ncol = NULL) {
  colour_grid_dims(n, nrow = nrow, ncol = ncol)
}

#' Resolve blank mts panels
#'
#' Validate reserved blank panel indices for a full mts layout.
#'
#' @param blank.panels Optional vector of reserved panel indices.
#' @param n.data.panels Number of panels needed for data series.
#'
#' @return Integer vector of blank panel indices, possibly length zero.
#' @noRd
resolve_blank_panels <- function(blank.panels, n.data.panels) {
  if (is.null(blank.panels)) {
    return(integer())
  }
  if (!is.numeric(blank.panels) || length(blank.panels) == 0L ||
      anyNA(blank.panels) || any(blank.panels != floor(blank.panels))) {
    stop("`blank.panels` must be `NULL` or a positive integer vector.", call. = FALSE)
  }

  blank.panels <- as.integer(blank.panels)
  total.panels <- n.data.panels + length(blank.panels)

  if (any(blank.panels < 1L)) {
    stop("`blank.panels` must contain positive integers.", call. = FALSE)
  }
  if (anyDuplicated(blank.panels)) {
    stop("`blank.panels` must contain unique panel indices.", call. = FALSE)
  }
  if (any(blank.panels > total.panels)) {
    stop("`blank.panels` contains panel indices outside the full layout range.", call. = FALSE)
  }

  sort(blank.panels)
}

#' Return mts panel roles
#'
#' Build a character vector describing whether each full layout panel is data
#' or blank.
#'
#' @param total.panels Total number of layout panels.
#' @param blank.panels Integer vector of blank panels.
#'
#' @return Character vector with values `"data"` and `"blank"`.
#' @noRd
mts_panel_roles <- function(total.panels, blank.panels) {
  panel.roles <- rep("data", total.panels)
  panel.roles[blank.panels] <- "blank"
  panel.roles
}

#' Create mts panel metadata
#'
#' Combine full-layout panel metadata into a list indexed by panel number.
#'
#' @param panel.index Integer panel indices.
#' @param role Character panel roles.
#' @param name Panel names.
#' @param column Source data column indices.
#' @param mfg,usr,xlim,ylim Lists of graphics metadata.
#'
#' @return A named list of panel metadata lists.
#' @noRd
make_mts_panel_metadata <- function(panel.index,
                                    role,
                                    name,
                                    column,
                                    mfg,
                                    usr,
                                    xlim,
                                    ylim) {
  panels <- vector("list", length(panel.index))
  for (index in seq_along(panel.index)) {
    panels[[index]] <- list(
      panel.index = panel.index[[index]],
      role = role[[index]],
      name = name[[index]],
      column = column[[index]],
      mfg = mfg[[index]],
      usr = usr[[index]],
      xlim = xlim[[index]],
      ylim = ylim[[index]]
    )
  }
  names(panels) <- as.character(panel.index)
  panels
}

#' Resolve mts columns
#'
#' Resolve optional numeric or character column selections.
#'
#' @param columns Optional column selection.
#' @param column.names Column names.
#' @param ncol Number of columns.
#' @param argument.name Name for error messages.
#'
#' @return Integer column indices.
#' @noRd
resolve_mts_columns <- function(columns, column.names, ncol, argument.name) {
  if (is.null(columns)) {
    return(seq_len(ncol))
  }
  if (is.numeric(columns)) {
    if (anyNA(columns) || any(columns != floor(columns)) ||
        any(columns < 1L) || any(columns > ncol)) {
      stop("`", argument.name, "` contains invalid column indices.", call. = FALSE)
    }
    return(as.integer(columns))
  }
  if (is.character(columns)) {
    if (is.null(column.names)) {
      stop("`", argument.name, "` cannot be character when columns are unnamed.", call. = FALSE)
    }
    missing.columns <- setdiff(columns, column.names)
    if (length(missing.columns) > 0L) {
      stop("Unknown column name: ", paste(missing.columns, collapse = ", "), call. = FALSE)
    }
    return(match(columns, column.names))
  }

  stop("`", argument.name, "` must be `NULL`, numeric, or character.", call. = FALSE)
}

#' Match overlay columns to mts panels
#'
#' Match selected overlay columns to panels by name or position.
#'
#' @param y.column.names Original overlay column names, possibly `NULL`.
#' @param y.columns Selected overlay column indices.
#' @param plot.info Plot metadata from [mts_plot()].
#' @param match Matching mode.
#'
#' @return Integer panel indices with `NA` for unmatched columns.
#' @noRd
match_mts_columns <- function(y.column.names, y.columns, plot.info, match) {
  if (identical(match, "name")) {
    if (is.null(y.column.names) || is.null(plot.info$original.column.names)) {
      warning("Column names are not available on both objects; falling back to position matching.", call. = FALSE)
      return(match_mts_columns(y.column.names, y.columns, plot.info, match = "position"))
    }

    selected.names <- y.column.names[y.columns]
    data.positions <- match(selected.names, plot.info$column.names)
    return(plot.info$data.panels[data.positions])
  }

  data.positions <- match(y.columns, plot.info$columns)
  plot.info$data.panels[data.positions]
}

#' Resolve mts graphical parameters
#'
#' Resolve `col`, `lty`, and `lwd` for a set of columns.
#'
#' @param n Number of selected columns.
#' @param col,lty,lwd Graphical parameter vectors.
#' @param column.names Selected column names.
#'
#' @return A list with character/numeric vectors `col`, `lty`, and `lwd`.
#' @noRd
resolve_mts_graphics <- function(n, col, lty, lwd, column.names) {
  list(
    col = resolve_mts_graphic_parameter(col, n = n, column.names = column.names, parameter.name = "col"),
    lty = resolve_mts_graphic_parameter(lty, n = n, column.names = column.names, parameter.name = "lty"),
    lwd = resolve_mts_graphic_parameter(lwd, n = n, column.names = column.names, parameter.name = "lwd")
  )
}

#' Resolve one mts graphical parameter
#'
#' Resolve one graphical parameter by name, vector position, or recycling.
#'
#' @param value Graphical parameter value.
#' @param n Number of selected columns.
#' @param column.names Selected column names.
#' @param parameter.name Parameter name for warning messages.
#'
#' @return A vector of length `n`.
#' @noRd
resolve_mts_graphic_parameter <- function(value, n, column.names, parameter.name) {
  if (!is.null(names(value)) && all(column.names %in% names(value))) {
    return(unname(value[column.names]))
  }

  value.length <- length(value)
  if (value.length == 0L) {
    stop("`", parameter.name, "` must have length at least one.", call. = FALSE)
  }
  if (n %% value.length != 0L) {
    warning(
      "`",
      parameter.name,
      "` length is not a multiple of the number of selected columns; recycling values.",
      call. = FALSE
    )
  }

  rep(value, length.out = n)
}

#' Resolve abline graphical arguments by panel
#'
#' Resolve graphical arguments supplied through `...` to one list per selected
#' panel.
#'
#' @param dots Named list of graphical arguments.
#' @param panel.names Names of selected panels, where available.
#'
#' @return List of argument lists, one per selected panel.
#' @noRd
resolve_mts_abline_graphics <- function(dots, panel.names) {
  n <- length(panel.names)
  panel.args <- rep(list(list()), n)

  if (length(dots) == 0L) {
    return(panel.args)
  }
  if (is.null(names(dots)) || any(!nzchar(names(dots)))) {
    stop("Arguments in `...` must be named.", call. = FALSE)
  }

  for (argument.name in names(dots)) {
    values <- resolve_mts_panel_argument(
      value = dots[[argument.name]],
      n = n,
      panel.names = panel.names,
      argument.name = argument.name
    )
    for (panel.index in seq_len(n)) {
      panel.args[[panel.index]][[argument.name]] <- values[[panel.index]]
    }
  }

  panel.args
}

#' Resolve xys-line graphical arguments by panel and line
#'
#' Resolve graphical arguments supplied through `...` to one list per selected
#' panel. Each list contains values recycled to one value per generated
#' point/slope line.
#'
#' @param dots Named list of graphical arguments.
#' @param panel.names Names of selected panels, where available.
#' @param line.count Number of generated point/slope lines per panel.
#'
#' @return List of argument lists, one per selected panel.
#' @noRd
resolve_mts_xys_graphics <- function(dots, panel.names, line.count) {
  n <- length(panel.names)
  panel.args <- rep(list(list()), n)

  if (length(dots) == 0L) {
    return(panel.args)
  }
  if (is.null(names(dots)) || any(!nzchar(names(dots)))) {
    stop("Arguments in `...` must be named.", call. = FALSE)
  }

  for (argument.name in names(dots)) {
    values <- resolve_mts_xys_panel_line_argument(
      value = dots[[argument.name]],
      n = n,
      panel.names = panel.names,
      line.count = line.count,
      argument.name = argument.name
    )
    for (panel.index in seq_len(n)) {
      panel.args[[panel.index]][[argument.name]] <- values[[panel.index]]
    }
  }

  panel.args
}

#' Resolve one per-panel argument
#'
#' Resolve one vector argument by selected panel, using column names when
#' available and otherwise ordinary recycling.
#'
#' @param value Argument value.
#' @param n Number of selected panels.
#' @param panel.names Selected panel names.
#' @param argument.name Name for warning messages.
#'
#' @return List of scalar values.
#' @noRd
resolve_mts_panel_argument <- function(value, n, panel.names, argument.name) {
  if (length(value) == 0L) {
    stop("`", argument.name, "` must have length at least one.", call. = FALSE)
  }

  value.names <- names(value)
  named.panels <- !is.na(panel.names) & nzchar(panel.names)
  if (!is.null(value.names) && any(named.panels) &&
      all(panel.names[named.panels] %in% value.names)) {
    out <- vector("list", n)
    for (index in seq_len(n)) {
      if (named.panels[[index]]) {
        out[[index]] <- value[[match(panel.names[[index]], value.names)]]
      } else {
        out[[index]] <- value[[((index - 1L) %% length(value)) + 1L]]
      }
    }
    return(out)
  }

  if (n %% length(value) != 0L) {
    warning(
      "`",
      argument.name,
      "` length is not a multiple of the number of selected panels; recycling values.",
      call. = FALSE
    )
  }

  lapply(seq_len(n), function(index) value[[((index - 1L) %% length(value)) + 1L]])
}

#' Resolve one per-panel and per-line argument
#'
#' Resolve one vector argument over selected panels and generated point/slope
#' lines. Named vectors are matched by selected panel name where possible.
#'
#' @param value Argument value.
#' @param n Number of selected panels.
#' @param panel.names Selected panel names.
#' @param line.count Number of generated point/slope lines per panel.
#' @param argument.name Name for warning messages.
#'
#' @return List of vectors, one vector per selected panel.
#' @noRd
resolve_mts_xys_panel_line_argument <- function(value,
                                                n,
                                                panel.names,
                                                line.count,
                                                argument.name) {
  if (length(value) == 0L) {
    stop("`", argument.name, "` must have length at least one.", call. = FALSE)
  }

  value.names <- names(value)
  named.panels <- !is.na(panel.names) & nzchar(panel.names)
  if (!is.null(value.names) && any(named.panels) &&
      all(panel.names[named.panels] %in% value.names)) {
    out <- vector("list", n)
    for (index in seq_len(n)) {
      if (named.panels[[index]]) {
        out[[index]] <- rep(value[[match(panel.names[[index]], value.names)]], length.out = line.count)
      } else {
        out[[index]] <- rep(value[[((index - 1L) %% length(value)) + 1L]], length.out = line.count)
      }
    }
    return(out)
  }

  total.count <- n * line.count
  if (total.count %% length(value) != 0L) {
    warning(
      "`",
      argument.name,
      "` length is not a multiple of the number of selected panel-line combinations; recycling values.",
      call. = FALSE
    )
  }

  values <- rep(value, length.out = total.count)
  lapply(seq_len(n), function(index) {
    first <- (index - 1L) * line.count + 1L
    last <- index * line.count
    values[first:last]
  })
}

#' Build abline arguments
#'
#' Build a list of [graphics::abline()] arguments, omitting `NULL` line
#' definitions.
#'
#' @param a,b,h,v,reg,coef,untf Arguments from [mts_abline()].
#'
#' @return List of arguments.
#' @noRd
mts_abline_args <- function(a, b, h, v, reg, coef, untf) {
  args <- list()
  if (!is.null(a)) {
    args$a <- a
  }
  if (!is.null(b)) {
    args$b <- b
  }
  if (!is.null(h)) {
    args$h <- h
  }
  if (!is.null(v)) {
    args$v <- v
  }
  if (!is.null(reg)) {
    args$reg <- reg
  }
  if (!is.null(coef)) {
    args$coef <- coef
  }
  args$untf <- untf
  args
}

#' Build abline graphical arguments
#'
#' Combine explicit common graphical arguments with additional arguments from
#' `...`.
#'
#' @param col,lty,lwd Optional common graphical arguments.
#' @param dots Additional argument list.
#'
#' @return Named list of graphical arguments.
#' @noRd
mts_abline_graphical_args <- function(col = NULL, lty = NULL, lwd = NULL, dots = list()) {
  args <- list()
  if (!is.null(col)) {
    args$col <- col
  }
  if (!is.null(lty)) {
    args$lty <- lty
  }
  if (!is.null(lwd)) {
    args$lwd <- lwd
  }

  c(args, dots)
}

#' Create mts curve-registry rows
#'
#' Create data-frame rows describing base or overlay curves.
#'
#' @return A data frame suitable for `plot.info$curves`.
#' @noRd
make_mts_curve_registry <- function(source,
                                    source.label,
                                    object.index,
                                    column,
                                    name,
                                    panel.index,
                                    panel.name,
                                    col,
                                    lty,
                                    lwd,
                                    type,
                                    drawn,
                                    reason,
                                    x = NA_real_,
                                    y = NA_real_,
                                    slope = NA_real_,
                                    intercept = NA_real_) {
  n <- length(column)
  data.frame(
    source = rep(source, n),
    source.label = I(rep(list(source.label), n)),
    object.index = as.integer(rep(object.index, n)),
    column = as.integer(column),
    name = as.character(name),
    panel.index = as.integer(panel.index),
    panel.name = as.character(panel.name),
    col = as.character(col),
    lty = as.character(lty),
    lwd = as.numeric(lwd),
    type = as.character(rep(type, n)),
    drawn = as.logical(rep(drawn, n)),
    reason = as.character(reason),
    x = as.numeric(rep(x, length.out = n)),
    y = as.numeric(rep(y, length.out = n)),
    slope = as.numeric(rep(slope, length.out = n)),
    intercept = as.numeric(rep(intercept, length.out = n)),
    stringsAsFactors = FALSE
  )
}

#' Create abline curve-registry rows
#'
#' Create registry rows for reference lines added by [mts_abline()].
#'
#' @param plot.info Plot metadata.
#' @param selected.panels Selected panel metadata from [select_mts_panels()].
#' @param panel.args Per-panel graphical arguments.
#' @param source Normalised source label.
#'
#' @return A data frame suitable for appending to `plot.info$curves`.
#' @noRd
make_mts_abline_registry <- function(plot.info,
                                     selected.panels,
                                     panel.args,
                                     source) {
  n <- length(selected.panels$panels)
  current.col <- graphics::par("col")
  current.lty <- graphics::par("lty")
  current.lwd <- graphics::par("lwd")
  col <- vapply(panel.args, function(args) {
    as.character(if (!is.null(args$col)) args$col else current.col)
  }, character(1))
  lty <- vapply(panel.args, function(args) {
    as.character(if (!is.null(args$lty)) args$lty else current.lty)
  }, character(1))
  lwd <- vapply(panel.args, function(args) {
    as.numeric(if (!is.null(args$lwd)) args$lwd else current.lwd)
  }, numeric(1))
  panel.names <- selected.panels$panel.names
  panel.names[is.na(panel.names)] <- NA_character_

  make_mts_curve_registry(
    source = source$key,
    source.label = source$label,
    object.index = next_mts_object_index(plot.info),
    column = selected.panels$columns,
    name = panel.names,
    panel.index = selected.panels$panels,
    panel.name = panel.names,
    col = col,
    lty = lty,
    lwd = lwd,
    type = "abline",
    drawn = TRUE,
    reason = NA_character_
  )
}

#' Create xys-line curve-registry rows
#'
#' Create registry rows for point/slope lines added by [mts_xys_line()].
#'
#' @param plot.info Plot metadata.
#' @param selected.panels Selected panel metadata from [select_mts_panels()].
#' @param panel.args Per-panel graphical arguments.
#' @param source Normalised source label.
#' @param line.parameters Expanded point/slope line parameters.
#'
#' @return A data frame suitable for appending to `plot.info$curves`.
#' @noRd
make_mts_xys_registry <- function(plot.info,
                                  selected.panels,
                                  panel.args,
                                  source,
                                  line.parameters) {
  panel.count <- length(selected.panels$panels)
  line.count <- nrow(line.parameters)
  current.col <- graphics::par("col")
  current.lty <- graphics::par("lty")
  current.lwd <- graphics::par("lwd")

  col <- unlist(lapply(panel.args, function(args) {
    as.character(if (!is.null(args$col)) args$col else rep(current.col, line.count))
  }), use.names = FALSE)
  lty <- unlist(lapply(panel.args, function(args) {
    as.character(if (!is.null(args$lty)) args$lty else rep(current.lty, line.count))
  }), use.names = FALSE)
  lwd <- unlist(lapply(panel.args, function(args) {
    as.numeric(if (!is.null(args$lwd)) args$lwd else rep(current.lwd, line.count))
  }), use.names = FALSE)

  panel.names <- selected.panels$panel.names
  panel.names[is.na(panel.names)] <- NA_character_

  make_mts_curve_registry(
    source = source$key,
    source.label = source$label,
    object.index = next_mts_object_index(plot.info),
    column = rep(selected.panels$columns, each = line.count),
    name = rep(panel.names, each = line.count),
    panel.index = rep(selected.panels$panels, each = line.count),
    panel.name = rep(panel.names, each = line.count),
    col = col,
    lty = lty,
    lwd = lwd,
    type = "xys_line",
    drawn = TRUE,
    reason = NA_character_,
    x = rep(line.parameters$x, times = panel.count),
    y = rep(line.parameters$y, times = panel.count),
    slope = rep(line.parameters$slope, times = panel.count),
    intercept = rep(line.parameters$intercept, times = panel.count)
  )
}

#' Store mts plot metadata
#'
#' Store the most recent mts plot-info object for implicit [mts_lines()] use.
#'
#' @param plot.info Plot metadata.
#'
#' @return Invisibly returns `plot.info`.
#' @noRd
store_mts_plot_info <- function(plot.info) {
  mts_plot_store$last <- plot.info
  invisible(plot.info)
}

#' Return last mts plot metadata
#'
#' Return the most recently stored plot-info object.
#'
#' @return An `earnmisc_mts_plot_info` object or `NULL`.
#' @noRd
last_mts_plot_info <- function() {
  mts_plot_store$last
}

#' Validate mts plot metadata
#'
#' Check that an object looks like metadata returned by [mts_plot()].
#'
#' @param plot.info Object to validate.
#'
#' @return Invisibly returns `plot.info`.
#' @noRd
validate_mts_plot_info <- function(plot.info) {
  required.names <- c("columns", "column.names", "usr", "mfg", "curves", "data.panels", "panel.roles", "panels")

  if (!inherits(plot.info, "earnmisc_mts_plot_info") ||
      !all(required.names %in% names(plot.info))) {
    stop("`plot.info` must be an object returned by `mts_plot()`.", call. = FALSE)
  }

  invisible(plot.info)
}

#' Resolve mts plot metadata
#'
#' Use explicit plot metadata or the most recently stored [mts_plot()] result.
#'
#' @param plot.info Optional plot metadata.
#' @param caller Name of calling function for error messages.
#'
#' @return Validated `earnmisc_mts_plot_info` object.
#' @noRd
resolve_mts_plot_info <- function(plot.info = NULL, caller = "mts helper") {
  if (is.null(plot.info)) {
    plot.info <- last_mts_plot_info()
    if (is.null(plot.info)) {
      stop("`", caller, "()` requires a `plot.info` object from `mts_plot()` or a prior call to `mts_plot()`.", call. = FALSE)
    }
  }
  validate_mts_plot_info(plot.info)
  plot.info
}

#' Validate an mts panel index
#'
#' Validate a scalar full-layout panel index for an mts plot-info object.
#'
#' @param panel Panel index.
#' @param plot.info Plot metadata.
#'
#' @return Integer scalar panel index.
#' @noRd
validate_mts_panel_index <- function(panel, plot.info) {
  n.panels <- length(plot.info$panel.roles)
  if (!is.numeric(panel) || length(panel) != 1L || is.na(panel) ||
      panel != floor(panel) || panel < 1L || panel > n.panels) {
    stop("`panel` must be a valid full-layout panel index.", call. = FALSE)
  }

  as.integer(panel)
}

#' Select mts panels
#'
#' Select full layout panels for helpers that add to an existing mts plot.
#'
#' @param plot.info Plot metadata.
#' @param panels Optional full layout panel indices.
#' @param columns Optional plotted columns.
#'
#' @return A list containing selected panel indices and related metadata.
#' @noRd
select_mts_panels <- function(plot.info, panels = NULL, columns = NULL) {
  if (!is.null(panels) && !is.null(columns)) {
    stop("Only one of `panels` and `columns` can be supplied.", call. = FALSE)
  }

  if (!is.null(panels)) {
    panels <- validate_mts_panel_vector(panels, plot.info)
    panel.metadata <- plot.info$panels[as.character(panels)]
    return(list(
      panels = panels,
      columns = vapply(panel.metadata, function(panel) panel$column, integer(1)),
      panel.names = vapply(panel.metadata, function(panel) panel$name, character(1)),
      panel.roles = plot.info$panel.roles[panels]
    ))
  }

  if (!is.null(columns)) {
    column.positions <- resolve_mts_columns(
      columns,
      column.names = plot.info$column.names,
      ncol = length(plot.info$columns),
      argument.name = "columns"
    )
  } else {
    column.positions <- seq_along(plot.info$columns)
  }

  panels <- plot.info$data.panels[column.positions]
  list(
    panels = panels,
    columns = plot.info$columns[column.positions],
    panel.names = plot.info$column.names[column.positions],
    panel.roles = plot.info$panel.roles[panels]
  )
}

#' Validate mts panel indices
#'
#' Validate a vector of full-layout panel indices.
#'
#' @param panels Panel indices.
#' @param plot.info Plot metadata.
#'
#' @return Integer vector of panel indices.
#' @noRd
validate_mts_panel_vector <- function(panels, plot.info) {
  n.panels <- length(plot.info$panel.roles)
  if (!is.numeric(panels) || length(panels) == 0L || anyNA(panels) ||
      any(panels != floor(panels)) || any(panels < 1L) || any(panels > n.panels)) {
    stop("`panels` must contain valid full-layout panel indices.", call. = FALSE)
  }

  as.integer(panels)
}

#' Enter an mts panel without clearing it
#'
#' Restore panel graphics state so drawing commands add to an existing mts
#' panel. This is designed for helpers such as [mts_abline()] and a future
#' `mts_add_to_panel()`.
#'
#' @param plot.info Plot metadata.
#' @param panel Full layout panel index.
#'
#' @return Invisibly returns panel metadata.
#' @noRd
enter_mts_panel <- function(plot.info, panel) {
  panel <- validate_mts_panel_index(panel, plot.info)
  graphics::par(mfg = plot.info$mfg[[panel]])
  graphics::par(usr = plot.info$usr[[panel]])
  invisible(plot.info$panels[[panel]])
}

#' Return next overlay object index
#'
#' Compute the next object index for an overlay call.
#'
#' @param plot.info Plot metadata.
#'
#' @return Integer scalar.
#' @noRd
next_mts_object_index <- function(plot.info) {
  max(plot.info$curves$object.index, na.rm = TRUE) + 1L
}

#' Select overlay graphical parameter for one object
#'
#' Select graphical parameters for one overlay object. Lists are indexed by
#' overlay object; non-lists are reused for every overlay.
#'
#' @param x Graphical parameter value or list of values.
#' @param index Overlay index.
#' @param default Default value when `x` is `NULL`.
#'
#' @return Graphical parameter value for one overlay object.
#' @noRd
overlay_graphic_parameter <- function(x, index, default) {
  if (is.null(x)) {
    return(default)
  }
  if (is.list(x)) {
    if (index > length(x)) {
      stop("Overlay graphical parameter lists must have one element per overlay.", call. = FALSE)
    }
    return(x[[index]])
  }

  x
}

#' Return a default mts overlay colour
#'
#' Return a valid base R colour for an overlay object index.
#'
#' @param index Overlay index.
#'
#' @return Character scalar colour.
#' @noRd
default_mts_overlay_colour <- function(index) {
  colours <- c("red", "blue", "darkgreen", "purple", "orange", "brown", "magenta", "cyan4")
  colours[((index - 1L) %% length(colours)) + 1L]
}

#' Normalise an mts source label
#'
#' Return a stable character key and a preserved display label for an mts source.
#'
#' @param expr Unevaluated expression.
#' @param source Optional explicit source label.
#'
#' @return A list with character `key` and preserved `label`.
#' @noRd
normalise_mts_source <- function(expr, source = NULL) {
  if (is.null(source)) {
    label <- paste(deparse(expr, width.cutoff = 60), collapse = " ")
    return(list(key = label, label = label))
  }

  if (is.character(source)) {
    if (length(source) != 1L || is.na(source) || !nzchar(source)) {
      stop("`source` must be `NULL`, a non-empty character scalar, or a scalar expression label.", call. = FALSE)
    }
    return(list(key = source, label = source))
  }

  if (is_mts_expression_label(source)) {
    return(list(key = deparse_mts_label(source), label = source))
  }

  stop("`source` must be `NULL`, a non-empty character scalar, or a scalar expression label.", call. = FALSE)
}

#' Normalise multiple mts source labels
#'
#' Return one normalised source label per overlay object.
#'
#' @param sources Optional supplied source labels.
#' @param expressions Unevaluated overlay expressions.
#' @param n Number of overlays.
#' @param argument.name Name for error messages.
#'
#' @return List of normalised source-label objects.
#' @noRd
normalise_mts_source_vector <- function(sources,
                                        expressions,
                                        n,
                                        argument.name) {
  if (is.null(sources)) {
    return(lapply(expressions, function(expr) normalise_mts_source(expr, source = NULL)))
  }

  if (is.character(sources)) {
    if (length(sources) != n || anyNA(sources) || any(!nzchar(sources))) {
      stop("`", argument.name, "` must be `NULL` or contain one valid source label per overlay.", call. = FALSE)
    }
    return(lapply(sources, function(source) normalise_mts_source(NULL, source = source)))
  }

  if (inherits(sources, "expression")) {
    if (length(sources) != n) {
      stop("`", argument.name, "` must be `NULL` or contain one valid source label per overlay.", call. = FALSE)
    }
    return(lapply(seq_len(n), function(index) {
      normalise_mts_source(NULL, source = as.expression(sources[index]))
    }))
  }

  stop("`", argument.name, "` must be `NULL` or contain one valid source label per overlay.", call. = FALSE)
}

#' Check for scalar expression-like labels
#'
#' Check whether an object is a scalar expression-like label suitable for
#' [graphics::legend()].
#'
#' @param x Object to check.
#'
#' @return Logical scalar.
#' @noRd
is_mts_expression_label <- function(x) {
  inherits(x, "expression") && length(x) == 1L
}

#' Deparse an mts label
#'
#' Deparse a character or expression-like legend label to a stable character key.
#'
#' @param x Label object.
#'
#' @return Character scalar.
#' @noRd
deparse_mts_label <- function(x) {
  paste(deparse(x, width.cutoff = 60), collapse = " ")
}

#' Select curves for an mts legend
#'
#' Select drawn curve-registry rows according to a legend grouping.
#'
#' @param curves Curve registry from a plot-info object.
#' @param by Grouping mode.
#'
#' @return Data frame of selected curve rows.
#' @noRd
select_mts_legend_curves <- function(curves, by) {
  drawn.curves <- curves[curves$drawn, , drop = FALSE]
  if (nrow(drawn.curves) == 0L) {
    return(drawn.curves)
  }

  if (identical(by, "curve")) {
    return(drawn.curves)
  }
  if (identical(by, "source")) {
    return(drawn.curves[!duplicated(drawn.curves$source), , drop = FALSE])
  }

  grouping <- drawn.curves$panel.name
  missing.grouping <- is.na(grouping) | !nzchar(grouping)
  grouping[missing.grouping] <- drawn.curves$name[missing.grouping]
  drawn.curves[!duplicated(grouping), , drop = FALSE]
}

#' Create default mts legend labels
#'
#' Create readable labels for selected curve-registry rows.
#'
#' @param curves Selected curve-registry rows.
#' @param by Grouping mode.
#'
#' @return Character vector of legend labels.
#' @noRd
make_mts_legend_labels <- function(curves, by) {
  if (identical(by, "source")) {
    return(combine_mts_legend_labels(curves$source.label))
  }
  if (identical(by, "column")) {
    labels <- curves$panel.name
    missing.labels <- is.na(labels) | !nzchar(labels)
    labels[missing.labels] <- curves$name[missing.labels]
    return(labels)
  }

  curve.names <- curves$panel.name
  missing.names <- is.na(curve.names) | !nzchar(curve.names)
  curve.names[missing.names] <- curves$name[missing.names]
  paste0(curves$source, ": ", curve.names)
}

#' Combine mts legend labels
#'
#' Combine list-column labels from the curve registry into an object suitable
#' for the `legend` argument of [graphics::legend()].
#'
#' @param labels List of scalar character or expression-like labels.
#'
#' @return Character vector or expression vector.
#' @noRd
combine_mts_legend_labels <- function(labels) {
  labels <- as.list(labels)
  expression.label <- vapply(labels, is_mts_expression_label, logical(1))

  if (!any(expression.label)) {
    return(vapply(labels, as.character, character(1)))
  }

  as.expression(lapply(labels, function(label) {
    if (is_mts_expression_label(label)) {
      return(label[[1L]])
    }
    as.character(label)
  }))
}

#' Normalise legend line types
#'
#' Convert numeric line types stored as character values in the curve registry
#' back to numeric values before calling [graphics::legend()].
#'
#' @param lty Line-type vector from the curve registry.
#'
#' @return Numeric or character line-type vector.
#' @noRd
mts_legend_lty <- function(lty) {
  numeric.lty <- suppressWarnings(as.numeric(lty))
  if (all(!is.na(numeric.lty))) {
    return(numeric.lty)
  }

  line.type.names <- c("blank", "solid", "dashed", "dotted", "dotdash", "longdash", "twodash")
  integer.lty <- suppressWarnings(as.integer(lty))
  numeric.text <- !is.na(integer.lty) & lty == as.character(integer.lty) &
    integer.lty >= 0L & integer.lty <= 6L
  lty[numeric.text] <- line.type.names[integer.lty[numeric.text] + 1L]
  lty
}

#' Merge constructed call arguments with user overrides
#'
#' Replace same-named defaults with user-supplied overrides and append new
#' arguments. Protected names error because they are controlled internally.
#'
#' @param defaults Named list of arguments constructed by a wrapper.
#' @param overrides List of user-supplied arguments.
#' @param protected Character vector of names that cannot be overridden.
#' @param argument.name Name of `overrides` for error messages.
#'
#' @return A list of merged call arguments.
#' @noRd
merge_call_args <- function(defaults,
                            overrides,
                            protected = character(),
                            argument.name = "overrides") {
  if (!is.list(defaults)) {
    stop("`defaults` must be a list.", call. = FALSE)
  }
  if (!is.list(overrides)) {
    stop("`", argument.name, "` must be a list.", call. = FALSE)
  }

  override.names <- names(overrides)
  if (is.null(override.names)) {
    override.names <- rep("", length(overrides))
  }
  named.overrides <- nzchar(override.names)
  protected.matches <- override.names[named.overrides & override.names %in% protected]

  if (length(protected.matches) > 0L) {
    stop(
      "`",
      argument.name,
      "` cannot override protected argument",
      if (length(protected.matches) == 1L) "" else "s",
      ": ",
      paste(unique(protected.matches), collapse = ", "),
      call. = FALSE
    )
  }

  out <- defaults
  for (arg.index in seq_along(overrides)) {
    arg.name <- override.names[[arg.index]]
    if (nzchar(arg.name) && arg.name %in% names(out)) {
      out[[arg.name]] <- overrides[[arg.index]]
    } else {
      next.arg <- overrides[arg.index]
      names(next.arg) <- arg.name
      out <- c(out, next.arg)
    }
  }

  out
}
