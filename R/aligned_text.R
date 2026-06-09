#' Draw an aligned three-column text block
#'
#' `aligned_text()` draws a compact base-graphics text block with three
#' aligned columns. The columns are named `lhs`, `mid`, and `rhs` for
#' convenience.
#'
#' Labels are passed through [nice_text()] before drawing, so TeX-like labels
#' work on ordinary graphics devices and tikz devices. The block can be placed
#' either by supplying a numeric top-left anchor `(x, y)` or by supplying a
#' legend-style keyword such as `"bottomright"` or `"topleft"`.
#'
#' @param x Numeric x-coordinate for the top-left anchor, or one of the
#'   legend-style keyword positions `"bottomright"`, `"bottom"`,
#'   `"bottomleft"`, `"left"`, `"center"`, `"right"`, `"topleft"`, `"top"`,
#'   or `"topright"`. The spelling `"centre"` is also accepted.
#' @param y Numeric y-coordinate for the top-left anchor when `x` is numeric.
#'   Must be `NULL` when `x` is a keyword.
#' @param lhs,mid,rhs Character vectors for the left, middle, and right
#'   columns. They must have the same positive length.
#' @param inset Numeric scalar or length-two vector. For keyword placement,
#'   gives the inset from the plot region as a fraction of the plotting range,
#'   following the same convention as [graphics::legend()]. A scalar is used
#'   for both horizontal and vertical insets.
#' @param cex Text size passed to [graphics::text()].
#' @param col Text colour passed to [graphics::text()].
#' @param line.spacing Positive multiplier applied to the maximum row height
#'   to determine vertical spacing between rows.
#' @param gap Horizontal gap between adjacent columns in user coordinates. If
#'   `NULL`, `0.3` times the width of `"m"` at the requested `cex` is used.
#' @param lhs.adj,mid.adj,rhs.adj Horizontal adjustment values passed to
#'   [graphics::text()] for the corresponding column. Defaults are
#'   `lhs.adj = 1`, `mid.adj = 0.5`, and `rhs.adj = 0`, giving
#'   right-justified, centred, and left-justified columns.
#' @param use.tikz Optional logical scalar passed to [nice_text()]. If `NULL`,
#'   [nice_text()] resolves tikz mode from the caller or active graphics device.
#' @param ... Additional graphical parameters passed to [graphics::text()], for
#'   example `font`, `family`, or `xpd`. The `x`, `y`, `labels`, and `adj`
#'   arguments are controlled by `aligned_text()` and cannot be supplied in
#'   `...`.
#'
#' @return Invisibly returns an `earnmisc_aligned_text_info` list containing
#'   the original and rendered labels, keyword or numeric placement metadata,
#'   the top-left anchor, column positions and widths, row positions, gap,
#'   line spacing, block size, graphical settings, current `usr`, and device.
#'
#' @examples
#' plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1), las = 1)
#' aligned_text(
#'   "bottomright",
#'   lhs = c("$x$", "$y$", "$\\R_{0,\\textrm{min}}$"),
#'   mid = c("$=$", "$=$", "$\\simeq$"),
#'   rhs = c("$0.999$", "$0.001$", "$2$")
#' )
#'
#' plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1), las = 1)
#' aligned_text(
#'   0.1, 0.9,
#'   lhs = c("alpha", "beta"),
#'   mid = c("is", "is"),
#'   rhs = c("one", "two")
#' )
#'
#' @export
aligned_text <- function(x, y = NULL,
                         lhs, mid, rhs,
                         inset = 0.02,
                         cex = 1,
                         col = graphics::par("col"),
                         line.spacing = 1.25,
                         gap = NULL,
                         lhs.adj = 1,
                         mid.adj = 0.5,
                         rhs.adj = 0,
                         use.tikz = NULL,
                         ...) {
  if (missing(lhs)) {
    stop("`lhs` must be supplied.", call. = FALSE)
  }
  if (missing(mid)) {
    stop("`mid` must be supplied.", call. = FALSE)
  }
  if (missing(rhs)) {
    stop("`rhs` must be supplied.", call. = FALSE)
  }

  dots <- list(...)
  validate_aligned_text_dots(dots)

  columns <- validate_aligned_text_columns(lhs = lhs, mid = mid, rhs = rhs)
  inset <- validate_aligned_text_inset(inset)
  cex <- validate_aligned_text_positive_scalar(cex, "cex")
  line.spacing <- validate_aligned_text_positive_scalar(
    line.spacing,
    "line.spacing"
  )
  lhs.adj <- validate_aligned_text_numeric_scalar(lhs.adj, "lhs.adj")
  mid.adj <- validate_aligned_text_numeric_scalar(mid.adj, "mid.adj")
  rhs.adj <- validate_aligned_text_numeric_scalar(rhs.adj, "rhs.adj")

  rendered <- list(
    lhs = nice_text(columns$lhs, use.tikz = use.tikz, warn = FALSE),
    mid = nice_text(columns$mid, use.tikz = use.tikz, warn = FALSE),
    rhs = nice_text(columns$rhs, use.tikz = use.tikz, warn = FALSE)
  )

  column.widths <- vapply(
    rendered,
    function(label) max(graphics::strwidth(label, cex = cex)),
    numeric(1)
  )
  if (is.null(gap)) {
    gap <- 0.3 * graphics::strwidth("m", cex = cex)
  } else {
    gap <- validate_aligned_text_nonnegative_scalar(gap, "gap")
  }

  all.labels <- c(rendered$lhs, rendered$mid, rendered$rhs)
  row.height <- max(graphics::strheight(all.labels, cex = cex))
  row.step <- row.height * line.spacing
  n.rows <- length(columns$lhs)
  block.width <- sum(column.widths) + 2 * gap
  block.height <- row.height + (n.rows - 1L) * row.step
  placement <- resolve_aligned_text_anchor(
    x = x,
    y = y,
    inset = inset,
    block.width = block.width,
    block.height = block.height
  )

  column.left <- placement$x + c(
    0,
    column.widths[["lhs"]] + gap,
    column.widths[["lhs"]] + gap + column.widths[["mid"]] + gap
  )
  names(column.left) <- c("lhs", "mid", "rhs")
  adj <- c(lhs = lhs.adj, mid = mid.adj, rhs = rhs.adj)
  column.x <- column.left + adj * column.widths
  row.y <- placement$y - (seq_len(n.rows) - 1L) * row.step

  draw_aligned_text_column(
    x = column.x[["lhs"]],
    y = row.y,
    labels = rendered$lhs,
    adj = lhs.adj,
    cex = cex,
    col = col,
    dots = dots
  )
  draw_aligned_text_column(
    x = column.x[["mid"]],
    y = row.y,
    labels = rendered$mid,
    adj = mid.adj,
    cex = cex,
    col = col,
    dots = dots
  )
  draw_aligned_text_column(
    x = column.x[["rhs"]],
    y = row.y,
    labels = rendered$rhs,
    adj = rhs.adj,
    cex = cex,
    col = col,
    dots = dots
  )

  out <- aligned_text_info(
    original = columns,
    rendered = rendered,
    placement = placement,
    column.left = column.left,
    column.x = column.x,
    column.widths = column.widths,
    row.y = row.y,
    row.height = row.height,
    row.step = row.step,
    block.width = block.width,
    block.height = block.height,
    gap = gap,
    inset = inset,
    adj = adj,
    cex = cex,
    col = col
  )

  invisible(out)
}

#' Validate aligned-text column inputs
#'
#' @return Named list of character vectors.
#' @noRd
validate_aligned_text_columns <- function(lhs, mid, rhs) {
  columns <- list(lhs = lhs, mid = mid, rhs = rhs)
  for (column.name in names(columns)) {
    column <- columns[[column.name]]
    if (!is.character(column) || length(column) < 1L || anyNA(column)) {
      stop("`", column.name, "` must be a non-empty character vector with no missing values.",
           call. = FALSE)
    }
  }

  lengths <- vapply(columns, length, integer(1))
  if (!all(lengths == lengths[[1L]])) {
    stop("`lhs`, `mid`, and `rhs` must have the same length.", call. = FALSE)
  }

  columns
}

#' Validate aligned-text unsupported dots
#'
#' @return Invisibly returns `NULL`.
#' @noRd
validate_aligned_text_dots <- function(dots) {
  if (length(dots) == 0L) {
    return(invisible(NULL))
  }

  dot.names <- names(dots)
  if (is.null(dot.names)) {
    dot.names <- rep("", length(dots))
  }
  controlled <- intersect(dot.names, c("x", "y", "labels", "adj"))
  if (length(controlled) > 0L) {
    stop(
      "`aligned_text()` controls these graphics::text() arguments: ",
      paste(controlled, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  invisible(NULL)
}

#' Validate a finite numeric scalar
#'
#' @return Numeric scalar.
#' @noRd
validate_aligned_text_numeric_scalar <- function(value, name) {
  if (!is.numeric(value) || length(value) != 1L ||
      is.na(value) || !is.finite(value)) {
    stop("`", name, "` must be a finite numeric scalar.", call. = FALSE)
  }
  as.numeric(value)
}

#' Validate a positive numeric scalar
#'
#' @return Positive numeric scalar.
#' @noRd
validate_aligned_text_positive_scalar <- function(value, name) {
  value <- validate_aligned_text_numeric_scalar(value, name)
  if (value <= 0) {
    stop("`", name, "` must be positive.", call. = FALSE)
  }
  value
}

#' Validate a non-negative numeric scalar
#'
#' @return Non-negative numeric scalar.
#' @noRd
validate_aligned_text_nonnegative_scalar <- function(value, name) {
  value <- validate_aligned_text_numeric_scalar(value, name)
  if (value < 0) {
    stop("`", name, "` must be non-negative.", call. = FALSE)
  }
  value
}

#' Validate aligned-text inset
#'
#' @return Numeric vector of length two.
#' @noRd
validate_aligned_text_inset <- function(inset) {
  if (!is.numeric(inset) || !(length(inset) %in% c(1L, 2L)) ||
      anyNA(inset) || any(!is.finite(inset)) || any(inset < 0)) {
    stop("`inset` must be a non-negative finite numeric scalar or length-two vector.",
         call. = FALSE)
  }
  rep(as.numeric(inset), length.out = 2L)
}

#' Resolve an aligned-text top-left anchor
#'
#' @return List with placement metadata.
#' @noRd
resolve_aligned_text_anchor <- function(x, y, inset, block.width,
                                        block.height) {
  if (is.character(x)) {
    position <- normalise_aligned_text_position(x)
    if (!is.null(y)) {
      stop("`y` must be NULL when `x` is a keyword position.", call. = FALSE)
    }
    anchor <- aligned_text_keyword_anchor(
      position = position,
      inset = inset,
      block.width = block.width,
      block.height = block.height
    )
    return(c(
      list(type = "keyword", position = position),
      anchor
    ))
  }

  if (!is.numeric(x) || length(x) != 1L || is.na(x) || !is.finite(x)) {
    stop("`x` must be a finite numeric scalar or a keyword position.",
         call. = FALSE)
  }
  if (!is.numeric(y) || length(y) != 1L || is.na(y) || !is.finite(y)) {
    stop("`y` must be a finite numeric scalar when `x` is numeric.",
         call. = FALSE)
  }

  list(
    type = "numeric",
    position = NA_character_,
    x = as.numeric(x),
    y = as.numeric(y),
    horizontal = "explicit",
    vertical = "explicit",
    usr = graphics::par("usr")
  )
}

#' Normalise an aligned-text keyword position
#'
#' @return Character scalar.
#' @noRd
normalise_aligned_text_position <- function(position) {
  choices <- c(
    "bottomright", "bottom", "bottomleft",
    "left", "center", "centre", "right",
    "topleft", "top", "topright"
  )
  if (!is.character(position) || length(position) != 1L || is.na(position)) {
    stop("`x` must be a finite numeric scalar or one keyword position.",
         call. = FALSE)
  }
  if (!(position %in% choices)) {
    stop(
      "`x` keyword position must be one of: ",
      paste(setdiff(choices, "centre"), collapse = ", "),
      ".",
      call. = FALSE
    )
  }
  if (identical(position, "centre")) {
    return("center")
  }
  position
}

#' Resolve a keyword top-left anchor
#'
#' @return List with anchor and keyword metadata.
#' @noRd
aligned_text_keyword_anchor <- function(position, inset, block.width,
                                        block.height) {
  usr <- graphics::par("usr")
  x.span <- usr[[2L]] - usr[[1L]]
  y.span <- usr[[4L]] - usr[[3L]]
  horizontal <- aligned_text_horizontal_position(position)
  vertical <- aligned_text_vertical_position(position)

  x.anchor <- switch(
    horizontal,
    left = usr[[1L]] + inset[[1L]] * x.span,
    center = usr[[1L]] + x.span / 2 - block.width / 2,
    right = usr[[2L]] - inset[[1L]] * x.span - block.width
  )
  y.anchor <- switch(
    vertical,
    top = usr[[4L]] - inset[[2L]] * y.span,
    center = usr[[3L]] + y.span / 2 + block.height / 2,
    bottom = usr[[3L]] + inset[[2L]] * y.span + block.height
  )

  list(
    x = x.anchor,
    y = y.anchor,
    horizontal = horizontal,
    vertical = vertical,
    usr = usr
  )
}

#' Resolve horizontal keyword component
#'
#' @return One of `"left"`, `"center"`, or `"right"`.
#' @noRd
aligned_text_horizontal_position <- function(position) {
  if (position %in% c("bottomleft", "left", "topleft")) {
    return("left")
  }
  if (position %in% c("bottomright", "right", "topright")) {
    return("right")
  }
  "center"
}

#' Resolve vertical keyword component
#'
#' @return One of `"bottom"`, `"center"`, or `"top"`.
#' @noRd
aligned_text_vertical_position <- function(position) {
  if (position %in% c("topleft", "top", "topright")) {
    return("top")
  }
  if (position %in% c("bottomleft", "bottom", "bottomright")) {
    return("bottom")
  }
  "center"
}

#' Draw one aligned-text column
#'
#' @return Invisibly returns `NULL`.
#' @noRd
draw_aligned_text_column <- function(x, y, labels, adj, cex, col, dots) {
  do.call(
    graphics::text,
    c(
      list(
        x = rep(x, length(y)),
        y = y,
        labels = labels,
        adj = c(adj, 1),
        cex = cex,
        col = col
      ),
      dots
    )
  )
  invisible(NULL)
}

#' Build aligned-text return metadata
#'
#' @return An `earnmisc_aligned_text_info` list.
#' @noRd
aligned_text_info <- function(original, rendered, placement, column.left,
                              column.x, column.widths, row.y, row.height,
                              row.step, block.width, block.height, gap, inset,
                              adj, cex, col) {
  columns <- data.frame(
    column = names(column.x),
    x = unname(column.x),
    left = unname(column.left),
    right = unname(column.left + column.widths),
    width = unname(column.widths),
    adj = unname(adj),
    stringsAsFactors = FALSE
  )
  rows <- data.frame(
    row = seq_along(row.y),
    y = row.y,
    stringsAsFactors = FALSE
  )

  out <- list(
    lhs = original$lhs,
    mid = original$mid,
    rhs = original$rhs,
    rendered = rendered,
    placement.type = placement$type,
    position = placement$position,
    horizontal = placement$horizontal,
    vertical = placement$vertical,
    anchor = c(x = placement$x, y = placement$y),
    columns = columns,
    rows = rows,
    column.x = column.x,
    row.y = row.y,
    column.widths = column.widths,
    row.height = row.height,
    row.step = row.step,
    block.width = block.width,
    block.height = block.height,
    gap = gap,
    inset = inset,
    adj = adj,
    cex = cex,
    col = col,
    usr = placement$usr,
    device = unname(grDevices::dev.cur())
  )
  class(out) <- c("earnmisc_aligned_text_info", "list")
  out
}
