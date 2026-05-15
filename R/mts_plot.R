mts_plot_store <- new.env(parent = emptyenv())
mts_plot_store$last <- NULL

#' Plot a multivariate time series in panels
#'
#' Plot selected columns of a multivariate time series, one column per panel,
#' and return metadata that [lines_mts()] can use for later overlays.
#'
#' These helpers provide a coherent base-graphics workflow for `mts` overlays:
#' call `plot_mts()` first, then pass the returned object to `lines_mts()`.
#' Overlaying onto arbitrary existing [stats::plot.ts()] or `plot.mts()` output
#' is not supported because base R does not expose a stable public panel map.
#'
#' @param x Multivariate time-series object, or an object safely coercible to a
#'   matrix with a regular sequence time index.
#' @param columns Optional column names or indices to plot.
#' @param nrow,ncol Optional panel layout dimensions.
#' @param main Optional outer title.
#' @param xlab X-axis label.
#' @param ylab Optional y-axis label. If `NULL`, each panel uses its column name.
#' @param col,lty,lwd,type Graphical parameters for base curves. `col`, `lty`,
#'   and `lwd` may be scalar, vectorised by selected column, or named by column.
#' @param axes,frame.plot Logical values passed to [graphics::plot.default()].
#' @param mar,oma Optional margin settings passed to [graphics::par()].
#' @param ... Additional arguments passed to [graphics::plot.default()].
#'
#' @return Invisibly returns an `earnmisc_mts_plot_info` list containing panel
#'   metadata and a `curves` registry.
#'
#' @examples
#' x <- stats::ts(cbind(a = 1:10, b = 11:20))
#' y <- stats::ts(cbind(a = 2:11, b = 10:19))
#' plot.info <- plot_mts(x)
#' plot.info <- lines_mts(y, plot.info = plot.info)
#' plot.info$curves
#'
#' @export
plot_mts <- function(
  x,
  columns = NULL,
  nrow = NULL,
  ncol = NULL,
  main = NULL,
  xlab = "Time",
  ylab = NULL,
  col = "black",
  lty = 1,
  lwd = 1,
  type = "l",
  axes = TRUE,
  frame.plot = TRUE,
  mar = NULL,
  oma = NULL,
  ...
) {
  mts.data <- as_mts_matrix(x)
  selected.columns <- resolve_mts_columns(
    columns,
    column.names = mts.data$column.names,
    ncol = ncol(mts.data$matrix),
    argument.name = "columns"
  )
  selected.names <- mts.data$column.names[selected.columns]
  layout <- mts_layout_dims(length(selected.columns), nrow = nrow, ncol = ncol)
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

  usr <- vector("list", length(selected.columns))
  mfg <- vector("list", length(selected.columns))
  xlim <- range(mts.data$time, finite = TRUE)
  ylim <- vector("list", length(selected.columns))

  for (panel.index in seq_along(selected.columns)) {
    column.index <- selected.columns[[panel.index]]
    panel.name <- selected.names[[panel.index]]
    panel.ylab <- if (is.null(ylab)) panel.name else ylab

    graphics::plot.default(
      x = mts.data$time,
      y = mts.data$matrix[, column.index],
      type = type,
      xlab = xlab,
      ylab = panel.ylab,
      main = panel.name,
      col = graphics.parameters$col[[panel.index]],
      lty = graphics.parameters$lty[[panel.index]],
      lwd = graphics.parameters$lwd[[panel.index]],
      axes = axes,
      frame.plot = frame.plot,
      ...
    )

    usr[[panel.index]] <- graphics::par("usr")
    mfg[[panel.index]] <- graphics::par("mfg")
    ylim[[panel.index]] <- range(mts.data$matrix[, column.index], finite = TRUE)
  }

  if (!is.null(main)) {
    graphics::mtext(main, side = 3, outer = TRUE, line = 0)
  }

  curves <- make_mts_curve_registry(
    source = "base",
    object.index = 0L,
    column = selected.columns,
    name = selected.names,
    panel.index = seq_along(selected.columns),
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
    panel.order = seq_along(selected.columns),
    layout = layout,
    time = mts.data$time,
    usr = usr,
    mfg = mfg,
    xlim = xlim,
    ylim = ylim,
    device = unname(grDevices::dev.cur()),
    created_at = Sys.time(),
    curves = curves
  )
  class(plot.info) <- c("earnmisc_mts_plot_info", "list")
  store_mts_plot_info(plot.info)

  invisible(plot.info)
}

#' Overlay multivariate time-series columns on `plot_mts()` panels
#'
#' Overlay selected columns from an `mts`-like object onto panels created by
#' [plot_mts()]. This function is not intended for arbitrary existing
#' `plot.mts()` output.
#'
#' @param y Overlay multivariate time-series object.
#' @param plot.info Plot metadata returned by [plot_mts()]. If `NULL`, the most
#'   recent `plot_mts()` result is used.
#' @param columns Optional overlay column names or indices.
#' @param match Column matching mode: `"name"` or `"position"`.
#' @param unmatched Behaviour for unmatched overlay columns: `"warn"`,
#'   `"error"`, or `"ignore"`.
#' @param col,lty,lwd Overlay graphical parameters. They may be scalar,
#'   vectorised by selected overlay column, or named by overlay column.
#' @param source Optional curve source label.
#' @param object.index Optional overlay object index for the curve registry.
#' @param ... Additional arguments passed to [graphics::lines()].
#'
#' @return Invisibly returns the updated `plot.info` object with appended curve
#'   registry rows.
#'
#' @examples
#' x <- stats::ts(cbind(a = 1:10, b = 11:20))
#' y <- stats::ts(cbind(b = 10:19, a = 2:11))
#' plot.info <- plot_mts(x)
#' plot.info <- lines_mts(y, plot.info = plot.info)
#'
#' @export
lines_mts <- function(
  y,
  plot.info = NULL,
  columns = NULL,
  match = c("name", "position"),
  unmatched = c("warn", "error", "ignore"),
  col = "red",
  lty = 1,
  lwd = 1,
  source = NULL,
  object.index = NULL,
  ...
) {
  if (is.null(plot.info)) {
    plot.info <- last_mts_plot_info()
    if (is.null(plot.info)) {
      stop("`lines_mts()` requires a `plot.info` object from `plot_mts()` or a prior call to `plot_mts()`.", call. = FALSE)
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

  if (is.null(source)) {
    source <- "overlay"
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
    panel.name <- if (drawn) plot.info$column.names[[panel.index]] else NA_character_

    if (drawn) {
      graphics::par(mfg = plot.info$mfg[[panel.index]])
      graphics::par(usr = plot.info$usr[[panel.index]])
      graphics::lines(
        x = y.data$time,
        y = y.data$matrix[, y.column],
        col = graphics.parameters$col[[selected.index]],
        lty = graphics.parameters$lty[[selected.index]],
        lwd = graphics.parameters$lwd[[selected.index]],
        ...
      )
    }

    new.curves[[selected.index]] <- make_mts_curve_registry(
      source = source,
      object.index = object.index,
      column = y.column,
      name = selected.names[[selected.index]],
      panel.index = if (drawn) panel.index else NA_integer_,
      panel.name = panel.name,
      col = graphics.parameters$col[[selected.index]],
      lty = graphics.parameters$lty[[selected.index]],
      lwd = graphics.parameters$lwd[[selected.index]],
      type = "l",
      drawn = drawn,
      reason = reason
    )
  }

  plot.info$curves <- rbind(plot.info$curves, do.call(rbind, new.curves))
  store_mts_plot_info(plot.info)
  invisible(plot.info)
}

#' Plot an mts object with one or more overlays
#'
#' Convenience wrapper that calls [plot_mts()] once and [lines_mts()] once for
#' each overlay object supplied in `...`.
#'
#' @param x Base multivariate time-series object.
#' @param ... One or more overlay multivariate time-series objects.
#' @param columns.x Optional base columns.
#' @param columns.y Optional overlay columns used for each overlay object.
#' @param match,unmatched Matching and unmatched-column behaviour passed to
#'   [lines_mts()].
#' @param col.x,lty.x,lwd.x Base graphical parameters.
#' @param col.y,lty.y,lwd.y Overlay graphical parameters. If `NULL`, simple
#'   defaults are used. If a list, each element is used for the corresponding
#'   overlay object; otherwise the value is reused for each overlay object.
#' @param overlay.names Optional source labels for overlay objects.
#' @param plot.args Additional arguments passed to [plot_mts()]. Same-named
#'   values override base plotting defaults such as `col.x`, `lty.x`, and
#'   `lwd.x`. Core arguments `x` and `columns` cannot be supplied here.
#' @param lines.args Additional arguments passed to [lines_mts()]. Same-named
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
#' plot.info <- plot_mts_overlay(x, y)
#' plot.info <- plot_mts_overlay(x, y, z)
#' plot.info$curves
#'
#' @export
plot_mts_overlay <- function(
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
  overlay.names = NULL,
  plot.args = list(),
  lines.args = list()
) {
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
  if (!is.null(overlay.names) &&
      (!is.character(overlay.names) || length(overlay.names) != length(overlays) || anyNA(overlay.names))) {
    stop("`overlay.names` must be `NULL` or a character vector matching the number of overlays.", call. = FALSE)
  }

  match <- match.arg(match)
  unmatched <- match.arg(unmatched)
  if (is.null(overlay.names)) {
    overlay.names <- paste0("overlay", seq_along(overlays))
  }

  plot.call.args <- merge_call_args(
    defaults = list(
      x = x,
      columns = columns.x,
      col = col.x,
      lty = lty.x,
      lwd = lwd.x
    ),
    overrides = plot.args,
    protected = c("x", "columns"),
    argument.name = "plot.args"
  )
  plot.info <- do.call(plot_mts, plot.call.args)

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
        source = overlay.names[[overlay.index]],
        object.index = overlay.index
      ),
      overrides = lines.args,
      protected = c("y", "plot.info", "columns", "source", "object.index"),
      argument.name = "lines.args"
    )
    plot.info <- do.call(lines_mts, lines.call.args)
  }

  invisible(plot.info)
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
#' @param plot.info Plot metadata from [plot_mts()].
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
    return(match(selected.names, plot.info$column.names))
  }

  match(y.columns, plot.info$columns)
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

#' Create mts curve-registry rows
#'
#' Create data-frame rows describing base or overlay curves.
#'
#' @return A data frame suitable for `plot.info$curves`.
#' @noRd
make_mts_curve_registry <- function(source,
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
                                    reason) {
  data.frame(
    source = rep(source, length(column)),
    object.index = as.integer(rep(object.index, length(column))),
    column = as.integer(column),
    name = as.character(name),
    panel.index = as.integer(panel.index),
    panel.name = as.character(panel.name),
    col = as.character(col),
    lty = as.character(lty),
    lwd = as.numeric(lwd),
    type = as.character(rep(type, length(column))),
    drawn = as.logical(rep(drawn, length(column))),
    reason = as.character(reason),
    stringsAsFactors = FALSE
  )
}

#' Store mts plot metadata
#'
#' Store the most recent mts plot-info object for implicit [lines_mts()] use.
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
#' Check that an object looks like metadata returned by [plot_mts()].
#'
#' @param plot.info Object to validate.
#'
#' @return Invisibly returns `plot.info`.
#' @noRd
validate_mts_plot_info <- function(plot.info) {
  required.names <- c("columns", "column.names", "usr", "mfg", "curves")

  if (!inherits(plot.info, "earnmisc_mts_plot_info") ||
      !all(required.names %in% names(plot.info))) {
    stop("`plot.info` must be an object returned by `plot_mts()`.", call. = FALSE)
  }

  invisible(plot.info)
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
