#' Okabe-Ito colour constants
#'
#' Convenient constants for the Okabe-Ito colours and two Okabe-Ito-style
#' extensions. The first eight colours are the original Okabe-Ito
#' colourblind-friendly palette. `oi.grey` and `oi.amber` are extensions used
#' for convenience.
#'
#' These constants are actual R colour strings. Use them directly, for example
#' `col = oi.orange`. Quoted strings such as `"oi.orange"` are not special R
#' colours.
#'
#' @name oi_colours
#'
#' @return Character strings containing hexadecimal RGB colours.
#'
#' @examples
#' oi.orange
#' oi.sky_blue
#'
NULL

#' @rdname oi_colours
#' @export
oi.black <- "#000000"

#' @rdname oi_colours
#' @export
oi.orange <- "#E69F00"

#' @rdname oi_colours
#' @export
oi.sky_blue <- "#56B4E9"

#' @rdname oi_colours
#' @export
oi.bluish_green <- "#009E73"

#' @rdname oi_colours
#' @export
oi.yellow <- "#F0E442"

#' @rdname oi_colours
#' @export
oi.blue <- "#0072B2"

#' @rdname oi_colours
#' @export
oi.vermillion <- "#D55E00"

#' @rdname oi_colours
#' @export
oi.reddish_purple <- "#CC79A7"

#' @rdname oi_colours
#' @export
oi.grey <- "#999999"

#' @rdname oi_colours
#' @export
oi.amber <- "#EECC66"

#' Okabe-Ito colour palettes
#'
#' Return the extended Okabe-Ito-style palette by default, or only the original
#' Okabe-Ito colourblind-friendly palette if requested.
#'
#' The first eight colours are the original Okabe-Ito colourblind-friendly
#' palette. The extended palette appends `grey` and `amber`, which are
#' convenience additions for plots where the original palette is not quite
#' enough.
#'
#' @param extended Logical scalar. If `TRUE`, return the extended palette. If
#'   `FALSE`, return only the original eight-colour Okabe-Ito palette.
#' @param alpha Optional numeric scalar in `[0, 1]` giving the alpha
#'   transparency to apply with [oi_alpha()]. If `NULL`, colours are returned
#'   as opaque hexadecimal RGB values.
#'
#' @return A named character vector of hexadecimal colour values.
#'
#' @examples
#' okabe_ito_colours()
#' okabe_ito_colours(extended = FALSE)
#' okabe_ito_colours(alpha = 0.5)
#'
#' @export
okabe_ito_colours <- function(extended = TRUE, alpha = NULL) {
  validate_extended(extended)

  colours <- okabe_ito_colours_raw(extended = extended)

  if (is.null(alpha)) {
    return(colours)
  }

  oi_alpha(colours, alpha = alpha)
}

#' Okabe-Ito palette
#'
#' Return the first `n` colours from an Okabe-Ito palette.
#'
#' By default, this uses the extended palette. Set `extended = FALSE` to draw
#' only from the original eight-colour Okabe-Ito palette.
#'
#' @param n Integer scalar giving the number of colours to return.
#' @param extended Logical scalar. If `TRUE`, use the extended palette. If
#'   `FALSE`, use only the original eight-colour Okabe-Ito palette.
#' @param alpha Optional numeric scalar in `[0, 1]` giving the alpha
#'   transparency to apply with [oi_alpha()]. If `NULL`, colours are returned
#'   as opaque hexadecimal RGB values.
#'
#' @return A named character vector of `n` hexadecimal colour values.
#'
#' @examples
#' okabe_ito_palette(3)
#' okabe_ito_palette(8, extended = FALSE)
#' okabe_ito_palette(4, alpha = 0.75)
#'
#' @export
okabe_ito_palette <- function(n = length(okabe_ito_colours(extended = extended)),
                              extended = TRUE,
                              alpha = NULL) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 0 || n != floor(n)) {
    stop("`n` must be a non-negative integer scalar.", call. = FALSE)
  }
  validate_extended(extended)

  colours <- okabe_ito_colours(extended = extended, alpha = alpha)

  if (n > length(colours)) {
    stop("`n` must be no larger than the number of available colours.", call. = FALSE)
  }

  colours[seq_len(n)]
}

#' Add alpha transparency to colours
#'
#' Return alpha-adjusted versions of actual R colour values.
#'
#' @param colour Character vector of R colour values, such as `oi.orange`,
#'   `"#E69F00"`, or `"orange"`.
#' @param alpha Numeric scalar in `[0, 1]` giving the alpha transparency to
#'   apply.
#'
#' @return A character vector of alpha-adjusted colours.
#'
#' @examples
#' oi_alpha(oi.orange, 0.5)
#' oi_alpha(c(oi.orange, oi.sky_blue), 0.25)
#'
#' @export
oi_alpha <- function(colour, alpha) {
  if (!is.character(colour) || length(colour) < 1L || anyNA(colour)) {
    stop("`colour` must be a character vector of R colour values.", call. = FALSE)
  }
  validate_alpha(alpha)

  adjusted.colours <- grDevices::adjustcolor(colour, alpha.f = alpha)
  names(adjusted.colours) <- names(colour)
  adjusted.colours
}

#' Select Okabe-Ito colours by name
#'
#' Return one or more colours from the Okabe-Ito palette by stable palette
#' colour name.
#'
#' @param name Character vector of palette colour names, such as `"orange"` or
#'   `"sky_blue"`.
#' @param alpha Optional numeric scalar in `[0, 1]` giving the alpha
#'   transparency to apply with [oi_alpha()]. If `NULL`, colours are returned
#'   unchanged.
#' @param extended Logical scalar. If `TRUE`, use the extended palette. If
#'   `FALSE`, use only the original eight-colour Okabe-Ito palette.
#'
#' @return A named character vector of colour values.
#'
#' @examples
#' oi_colour("orange")
#' oi_colour(c("orange", "sky_blue"), alpha = 0.4)
#' oi_colour("yellow", extended = FALSE)
#'
#' @export
oi_colour <- function(name, alpha = NULL, extended = TRUE) {
  if (!is.character(name) || length(name) < 1L || anyNA(name)) {
    stop("`name` must be a character vector of Okabe-Ito colour names.", call. = FALSE)
  }
  validate_extended(extended)

  colours <- okabe_ito_colours(extended = extended)
  unknown.names <- setdiff(name, names(colours))

  if (length(unknown.names) > 0L) {
    stop(
      "Unknown Okabe-Ito colour name: ",
      paste(unknown.names, collapse = ", "),
      call. = FALSE
    )
  }

  selected.colours <- colours[name]

  if (is.null(alpha)) {
    return(selected.colours)
  }

  oi_alpha(selected.colours, alpha = alpha)
}

okabe_ito_colours_raw <- function(extended = TRUE) {
  colours <- c(
    black = oi.black,
    orange = oi.orange,
    sky_blue = oi.sky_blue,
    bluish_green = oi.bluish_green,
    yellow = oi.yellow,
    blue = oi.blue,
    vermillion = oi.vermillion,
    reddish_purple = oi.reddish_purple
  )

  if (extended) {
    colours <- c(
      colours,
      grey = oi.grey,
      amber = oi.amber
    )
  }

  colours
}

validate_extended <- function(extended) {
  if (!is.logical(extended) || length(extended) != 1L || is.na(extended)) {
    stop("`extended` must be a logical scalar.", call. = FALSE)
  }

  invisible(extended)
}

validate_alpha <- function(alpha) {
  if (!is.numeric(alpha) || length(alpha) != 1L || is.na(alpha) ||
      alpha < 0 || alpha > 1) {
    stop("`alpha` must be a numeric scalar in [0, 1].", call. = FALSE)
  }

  invisible(alpha)
}
