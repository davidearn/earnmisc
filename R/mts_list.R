#' Native-grid multivariate time-series lists
#'
#' `mts_list()` creates a list-like multivariate time-series object for panel
#' plotting when each series has its own native time grid. Each element stores
#' one numeric time vector and one numeric value vector. Use [mts_plot()] to draw
#' one panel per element or to overlay all selected elements on one panel.
#'
#' `mts_list` objects are intended for native-grid panel plotting. They do not
#' interpolate series onto a common grid. [mts_lines()] can overlay another
#' `mts_list` on an `mts_list` plot, using each overlay series' own native
#' time grid.
#'
#' @param x Non-empty list of univariate numeric series. Each element may be a
#'   numeric vector, a univariate `ts` object, or a list with components `time`
#'   and `value`.
#' @param time Optional list of numeric time vectors, one for each element of
#'   `x`. If `NULL`, times are taken from `ts` elements, from per-element
#'   `time` components, or from `seq_along(value)`.
#' @param names Optional character vector of panel/series names. If `NULL`,
#'   names are taken from `x` and missing names are replaced by element indices.
#' @param ... Additional arguments are currently unsupported and must be empty.
#'
#' @return A list with class `c("mts_list", "list")`. Each element is a list
#'   with numeric components `time` and `value`.
#'
#' @examples
#' x <- mts_list(
#'   list(a = 1:5, b = 11:16),
#'   time = list(a = 0:4, b = seq(0, 10, length.out = 6))
#' )
#' mts_plot(x, nrow = 1, ncol = 2)
#'
#' @export
mts_list <- function(x, time = NULL, names = NULL, ...) {
  validate_mts_list_dots(list(...))
  if (!is.list(x) || length(x) == 0L) {
    stop("`mts_list()` requires `x` to be a non-empty list.", call. = FALSE)
  }
  if (!is.null(time) && (!is.list(time) || length(time) != length(x))) {
    stop("`time` must be `NULL` or a list with one element per series.", call. = FALSE)
  }

  out <- vector("list", length(x))
  for (i in seq_along(x)) {
    element.time <- if (is.null(time)) NULL else time[[i]]
    out[[i]] <- normalise_mts_list_element(x[[i]], time = element.time, i = i)
  }

  names(out) <- resolve_mts_list_names(x, names = names)
  class(out) <- c("mts_list", "list")
  out
}

#' Plot a native-grid mts list
#'
#' Draw selected elements of an [mts_list()] object, using each element's own
#' native time grid. With `panel = "separate"`, each selected element is drawn
#' in its own panel. With `panel = "overlay"`, all selected elements are drawn
#' on one panel. The returned plot metadata has the same
#' `earnmisc_mts_plot_info` class used by ordinary [mts_plot()] output.
#'
#' @param x Object created by [mts_list()].
#' @param columns Optional element names or indices to plot.
#' @param panel Panel mode. `"separate"` draws one panel per selected element.
#'   `"overlay"` draws all selected elements on one panel.
#' @param nrow,ncol Optional panel layout dimensions.
#' @param blank.panels Optional positive integer vector of full layout panel
#'   indices to reserve.
#' @param legend Simple legend control for `panel = "overlay"`. Use `FALSE` or
#'   `NULL` for no legend, `TRUE` for `"topright"`, or one of `"topright"`,
#'   `"bottomright"`, `"topleft"`, or `"bottomleft"`. Direct labels are not
#'   implemented.
#' @param main Optional outer title.
#' @param xlab X-axis label.
#' @param ylab Optional y-axis label. If `NULL`, each panel uses its element
#'   name in separate-panel mode and no y-axis label in overlay mode.
#' @param col,lty,lwd,type Graphical parameters for base curves. `col`, `lty`,
#'   and `lwd` may be scalar, vectorised by selected element, or named by
#'   element. In overlay mode, missing or `NULL` `col` uses the extended
#'   Okabe-Ito palette, recycled if needed.
#' @param source Optional source label for the base curves.
#' @param axes,frame.plot Logical values passed to [graphics::plot.default()].
#' @param mar,oma Optional margin settings passed to [graphics::par()].
#' @param las Axis-label orientation passed to [graphics::plot.default()].
#' @param xlim,ylim Optional common limits for all panels. If `NULL`, each
#'   panel uses its own native range in separate-panel mode. In overlay mode,
#'   default limits use the range of all selected native time and value vectors.
#' @param ... Additional arguments passed to [graphics::plot.default()].
#'
#' @return Invisibly returns an `earnmisc_mts_plot_info` list containing panel
#'   metadata and a `curves` registry.
#'
#' @export
mts_plot.mts_list <- function(
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
  if (!inherits(x, "mts_list")) {
    stop("`mts_plot.mts_list()` requires an object inheriting from 'mts_list'.",
         call. = FALSE)
  }

  panel <- match.arg(panel)
  source <- normalise_mts_source(substitute(x), source = source)
  series.names <- names(x)
  selected.columns <- resolve_mts_columns(
    columns,
    column.names = series.names,
    ncol = length(x),
    argument.name = "columns"
  )
  selected.names <- series.names[selected.columns]

  if (identical(panel, "overlay")) {
    validate_mts_list_overlay_layout(
      nrow = nrow,
      ncol = ncol,
      blank.panels = blank.panels
    )
    legend.position <- resolve_mts_list_overlay_legend(legend)
    if (missing(col) || is.null(col)) {
      col <- default_mts_list_overlay_colours(length(selected.columns))
    }

    return(mts_plot_mts_list_overlay(
      x = x,
      selected.columns = selected.columns,
      selected.names = selected.names,
      series.names = series.names,
      source = source,
      main = main,
      xlab = xlab,
      ylab = ylab,
      col = col,
      lty = lty,
      lwd = lwd,
      type = type,
      axes = axes,
      frame.plot = frame.plot,
      mar = mar,
      oma = oma,
      las = las,
      xlim = xlim,
      ylim = ylim,
      legend.position = legend.position,
      ...
    ))
  }

  if (!isFALSE(legend) && !is.null(legend)) {
    stop("`legend` is only supported when `panel = \"overlay\"`.",
         call. = FALSE)
  }

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
  panel.xlim <- vector("list", total.panels)
  panel.ylim <- vector("list", total.panels)
  panel.names <- rep(NA_character_, total.panels)
  panel.columns <- rep(NA_integer_, total.panels)

  for (panel.index in seq_len(total.panels)) {
    if (panel.roles[[panel.index]] == "blank") {
      graphics::plot.new()
      graphics::plot.window(xlim = c(0, 1), ylim = c(0, 1), xaxs = "i", yaxs = "i")
      usr[[panel.index]] <- graphics::par("usr")
      mfg[[panel.index]] <- graphics::par("mfg")
      panel.xlim[[panel.index]] <- c(0, 1)
      panel.ylim[[panel.index]] <- c(0, 1)
      next
    }

    data.index <- match(panel.index, data.panels)
    column.index <- selected.columns[[data.index]]
    panel.name <- selected.names[[data.index]]
    panel.ylab <- if (is.null(ylab)) panel.name else ylab
    series <- x[[column.index]]
    current.xlim <- if (is.null(xlim)) range(series$time, finite = TRUE) else xlim
    current.ylim <- if (is.null(ylim)) range(series$value, finite = TRUE) else ylim

    graphics::plot.default(
      x = series$time,
      y = series$value,
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
      xlim = current.xlim,
      ylim = current.ylim,
      ...
    )

    usr[[panel.index]] <- graphics::par("usr")
    mfg[[panel.index]] <- graphics::par("mfg")
    panel.xlim[[panel.index]] <- current.xlim
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
    data = x[selected.columns],
    columns = selected.columns,
    column.names = selected.names,
    original.column.names = series.names,
    panel.mode = "separate",
    panel.order = data.panels,
    layout = layout,
    time = lapply(x[selected.columns], `[[`, "time"),
    usr = usr,
    mfg = mfg,
    xlim = range(unlist(lapply(x[selected.columns], `[[`, "time"), use.names = FALSE), finite = TRUE),
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
      xlim = panel.xlim,
      ylim = panel.ylim
    ),
    device = unname(grDevices::dev.cur()),
    created_at = Sys.time(),
    legend = NULL,
    curves = curves
  )
  class(plot.info) <- c("earnmisc_mts_plot_info", "list")
  store_mts_plot_info(plot.info)

  invisible(plot.info)
}

#' Plot an mts-list object in one overlay panel
#'
#' @inheritParams mts_plot.mts_list
#' @param selected.columns Integer indices of selected series.
#' @param selected.names Names of selected series.
#' @param series.names Names of all series.
#' @param source Normalised mts source label.
#' @param legend.position Optional legend position.
#'
#' @return Invisibly returns an `earnmisc_mts_plot_info` object.
#' @noRd
mts_plot_mts_list_overlay <- function(x,
                                      selected.columns,
                                      selected.names,
                                      series.names,
                                      source,
                                      main,
                                      xlab,
                                      ylab,
                                      col,
                                      lty,
                                      lwd,
                                      type,
                                      axes,
                                      frame.plot,
                                      mar,
                                      oma,
                                      las,
                                      xlim,
                                      ylim,
                                      legend.position,
                                      ...) {
  selected.series <- x[selected.columns]
  graphics.parameters <- resolve_mts_graphics(
    n = length(selected.columns),
    col = col,
    lty = lty,
    lwd = lwd,
    column.names = selected.names
  )
  all.time <- unlist(lapply(selected.series, `[[`, "time"), use.names = FALSE)
  all.value <- unlist(lapply(selected.series, `[[`, "value"), use.names = FALSE)
  current.xlim <- if (is.null(xlim)) range(all.time, finite = TRUE) else xlim
  current.ylim <- if (is.null(ylim)) range(all.value, finite = TRUE) else ylim

  if (!is.null(mar)) {
    graphics::par(mar = mar)
  }
  if (!is.null(oma)) {
    graphics::par(oma = oma)
  }
  graphics::par(mfrow = c(1L, 1L))

  first.series <- selected.series[[1L]]
  graphics::plot.default(
    x = first.series$time,
    y = first.series$value,
    type = type,
    xlab = xlab,
    ylab = ylab,
    main = main,
    col = graphics.parameters$col[[1L]],
    lty = graphics.parameters$lty[[1L]],
    lwd = graphics.parameters$lwd[[1L]],
    axes = axes,
    frame.plot = frame.plot,
    las = las,
    xlim = current.xlim,
    ylim = current.ylim,
    ...
  )

  if (length(selected.series) > 1L) {
    for (series.index in seq.int(2L, length(selected.series))) {
      series <- selected.series[[series.index]]
      graphics::lines(
        x = series$time,
        y = series$value,
        type = type,
        col = graphics.parameters$col[[series.index]],
        lty = graphics.parameters$lty[[series.index]],
        lwd = graphics.parameters$lwd[[series.index]],
        ...
      )
    }
  }

  legend.info <- NULL
  if (!is.null(legend.position)) {
    legend.result <- graphics::legend(
      legend.position,
      legend = selected.names,
      col = graphics.parameters$col,
      lty = graphics.parameters$lty,
      lwd = graphics.parameters$lwd,
      bty = "n"
    )
    legend.info <- list(
      position = legend.position,
      labels = selected.names,
      col = graphics.parameters$col,
      lty = graphics.parameters$lty,
      lwd = graphics.parameters$lwd,
      result = legend.result
    )
  }

  usr <- list(graphics::par("usr"))
  mfg <- list(graphics::par("mfg"))
  panel.roles <- "data"
  data.panels <- rep(1L, length(selected.columns))
  panel.xlim <- list(current.xlim)
  panel.ylim <- list(current.ylim)
  panel.name <- if (is.null(ylab)) "overlay" else as.character(ylab)[[1L]]

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
    data = selected.series,
    columns = selected.columns,
    column.names = selected.names,
    original.column.names = series.names,
    panel.mode = "overlay",
    panel.order = 1L,
    layout = list(nrow = 1L, ncol = 1L),
    time = lapply(selected.series, `[[`, "time"),
    usr = usr,
    mfg = mfg,
    xlim = current.xlim,
    ylim = panel.ylim,
    blank.panels = NULL,
    data.panels = data.panels,
    panel.roles = panel.roles,
    panels = make_mts_panel_metadata(
      panel.index = 1L,
      role = panel.roles,
      name = panel.name,
      column = NA_integer_,
      mfg = mfg,
      usr = usr,
      xlim = panel.xlim,
      ylim = panel.ylim
    ),
    device = unname(grDevices::dev.cur()),
    created_at = Sys.time(),
    legend = legend.info,
    curves = curves
  )
  class(plot.info) <- c("earnmisc_mts_plot_info", "list")
  store_mts_plot_info(plot.info)

  invisible(plot.info)
}

#' Validate overlay-panel layout inputs for mts-list plots
#'
#' @param nrow,ncol Optional layout dimensions.
#' @param blank.panels Optional reserved panels.
#'
#' @return Invisibly returns `NULL`.
#' @noRd
validate_mts_list_overlay_layout <- function(nrow, ncol, blank.panels) {
  if (!is.null(blank.panels)) {
    stop("`blank.panels` is not supported when `panel = \"overlay\"`.",
         call. = FALSE)
  }

  if (!is.null(nrow)) {
    nrow <- validate_grid_dimension(nrow, "nrow")
    if (nrow != 1L) {
      stop("`nrow` must be `NULL` or 1 when `panel = \"overlay\"`.",
           call. = FALSE)
    }
  }
  if (!is.null(ncol)) {
    ncol <- validate_grid_dimension(ncol, "ncol")
    if (ncol != 1L) {
      stop("`ncol` must be `NULL` or 1 when `panel = \"overlay\"`.",
           call. = FALSE)
    }
  }

  invisible(NULL)
}

#' Resolve mts-list overlay legend control
#'
#' @param legend User-supplied legend control.
#'
#' @return Legend position or `NULL`.
#' @noRd
resolve_mts_list_overlay_legend <- function(legend) {
  if (is.null(legend) || isFALSE(legend)) {
    return(NULL)
  }
  if (isTRUE(legend)) {
    return("topright")
  }

  positions <- c("topright", "bottomright", "topleft", "bottomleft")
  if (!is.character(legend) ||
      length(legend) != 1L ||
      is.na(legend) ||
      !(legend %in% positions)) {
    stop(
      "`legend` must be FALSE, TRUE, NULL, or one of: ",
      paste(sprintf("\"%s\"", positions), collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  legend
}

#' Return default overlay colours for mts-list plots
#'
#' @param n Number of colours needed.
#'
#' @return Character vector of colours.
#' @noRd
default_mts_list_overlay_colours <- function(n) {
  colours <- unname(okabe_ito_colours(extended = TRUE))
  rep(colours, length.out = n)
}

#' @rdname mts_lines
#' @name mts_lines
#' @export
mts_lines.mts_list <- function(
  y,
  plot.info = NULL,
  columns = NULL,
  match = c("position", "name"),
  unmatched = c("error", "warn", "ignore"),
  col = "red",
  lty = 1,
  lwd = 1,
  type = "l",
  source = NULL,
  object.index = NULL,
  ...
) {
  if (!inherits(y, "mts_list")) {
    stop("`mts_lines.mts_list()` requires an object inheriting from 'mts_list'.",
         call. = FALSE)
  }

  source <- normalise_mts_source(substitute(y), source = source)
  plot.info <- resolve_mts_plot_info(plot.info, caller = "mts_lines")
  match <- match.arg(match)
  unmatched <- match.arg(unmatched)

  series.names <- names(y)
  selected.columns <- resolve_mts_columns(
    columns,
    column.names = series.names,
    ncol = length(y),
    argument.name = "columns"
  )
  selected.names <- series.names[selected.columns]
  graphics.parameters <- resolve_mts_graphics(
    n = length(selected.columns),
    col = col,
    lty = lty,
    lwd = lwd,
    column.names = selected.names
  )
  matched.panels <- match_mts_list_panels(
    y.names = series.names,
    y.columns = selected.columns,
    plot.info = plot.info,
    match = match
  )
  matched <- !is.na(matched.panels)

  if (any(!matched)) {
    unmatched.names <- selected.names[!matched]
    message <- paste0(
      "Unmatched mts_list series",
      if (sum(!matched) == 1L) "" else "s",
      ": ",
      paste(unmatched.names, collapse = ", ")
    )

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
      series <- y[[y.column]]
      enter_mts_panel(plot.info, panel.index)
      graphics::lines(
        x = series$time,
        y = series$value,
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

#' Match native-grid series to mts panels
#'
#' @param y.names Names of the overlay series.
#' @param y.columns Selected overlay series indices.
#' @param plot.info Plot metadata from [mts_plot()].
#' @param match Matching mode.
#'
#' @return Integer panel indices with `NA` for unmatched names.
#' @noRd
match_mts_list_panels <- function(y.names, y.columns, plot.info, match) {
  if (identical(plot.info$panel.mode, "overlay")) {
    return(rep(plot.info$panel.order[[1L]], length(y.columns)))
  }

  if (identical(match, "name")) {
    selected.names <- y.names[y.columns]
    data.positions <- match(selected.names, plot.info$column.names)
    return(plot.info$data.panels[data.positions])
  }

  n.overlay <- length(y.columns)
  n.panels <- length(plot.info$data.panels)
  if (n.overlay != n.panels) {
    stop(sprintf(
      "mts_lines.mts_list(): overlay series count must match plotted data panel count for position matching: %d != %d.",
      n.overlay,
      n.panels
    ), call. = FALSE)
  }

  plot.info$data.panels
}

#' Validate mts-list constructor dots
#'
#' @param dots List of `...` arguments.
#'
#' @return Invisibly returns `NULL`.
#' @noRd
validate_mts_list_dots <- function(dots) {
  if (length(dots) == 0L) {
    return(invisible(NULL))
  }
  dot.names <- names(dots)
  if (is.null(dot.names)) {
    dot.names <- rep("", length(dots))
  }
  unnamed <- is.na(dot.names) | !nzchar(dot.names)
  if (any(unnamed)) {
    stop("`mts_list()` does not support unnamed arguments in `...`.",
         call. = FALSE)
  }
  stop(sprintf(
    "`mts_list()` does not support argument%s in `...`: %s.",
    if (length(dot.names) == 1L) "" else "s",
    paste(sprintf("'%s'", dot.names), collapse = ", ")
  ), call. = FALSE)
}

#' Resolve names for mts-list elements
#'
#' @param x Input series list.
#' @param names Optional user-supplied names.
#'
#' @return Character vector.
#' @noRd
resolve_mts_list_names <- function(x, names = NULL) {
  n <- length(x)
  if (!is.null(names)) {
    if (!is.character(names) || length(names) != n ||
        anyNA(names) || any(!nzchar(names))) {
      stop("`names` must be `NULL` or a non-empty character vector with one name per series.",
           call. = FALSE)
    }
    return(names)
  }

  out <- base::names(x)
  if (is.null(out)) {
    return(as.character(seq_len(n)))
  }
  missing.names <- is.na(out) | !nzchar(out)
  out[missing.names] <- as.character(which(missing.names))
  out
}

#' Normalise one mts-list element
#'
#' @param element Input element.
#' @param time Optional externally supplied time vector.
#' @param i Element index.
#'
#' @return List with numeric `time` and `value`.
#' @noRd
normalise_mts_list_element <- function(element, time = NULL, i) {
  if (is.null(time) && is.list(element) && all(c("time", "value") %in% names(element))) {
    time <- element$time
    value <- element$value
  } else if (stats::is.ts(element)) {
    time <- if (is.null(time)) stats::time(element) else time
    value <- element
  } else {
    value <- element
    if (is.null(time)) {
      time <- seq_along(as.vector(value))
    }
  }

  value <- as_mts_list_numeric_vector(value, what = "value", i = i)
  time <- as_mts_list_numeric_vector(time, what = "time", i = i)

  if (length(value) == 0L) {
    stop(sprintf("`mts_list()` element %d must contain at least one value.", i),
         call. = FALSE)
  }
  if (length(time) != length(value)) {
    stop(sprintf(
      "`mts_list()` element %d has mismatched time and value lengths: %d != %d.",
      i, length(time), length(value)
    ), call. = FALSE)
  }
  if (any(!is.finite(time))) {
    stop(sprintf("`mts_list()` element %d has non-finite time values.", i),
         call. = FALSE)
  }
  if (any(!is.finite(value))) {
    stop(sprintf("`mts_list()` element %d has non-finite series values.", i),
         call. = FALSE)
  }

  list(time = time, value = value)
}

#' Coerce one mts-list vector component
#'
#' @param x Input component.
#' @param what Component name for error messages.
#' @param i Element index.
#'
#' @return Numeric vector.
#' @noRd
as_mts_list_numeric_vector <- function(x, what, i) {
  if (is.data.frame(x)) {
    x <- as.matrix(x)
  }
  if (!is.null(dim(x))) {
    if (length(dim(x)) != 2L || ncol(x) != 1L) {
      stop(sprintf(
        "`mts_list()` element %d %s must be a vector or one-column object.",
        i, what
      ), call. = FALSE)
    }
    x <- x[, 1L]
  }
  if (!is.numeric(x) && !is.integer(x)) {
    stop(sprintf("`mts_list()` element %d %s must be numeric.", i, what),
         call. = FALSE)
  }

  as.numeric(x)
}
