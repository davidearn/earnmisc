#' Okabe-Ito colours
#'
#' Return the standard Okabe-Ito colourblind-friendly palette.
#'
#' @param alpha Optional numeric scalar in `[0, 1]` giving the alpha
#'   transparency to apply with [grDevices::adjustcolor()]. If `NULL`, colours
#'   are returned as opaque hexadecimal RGB values.
#'
#' @return A named character vector of hexadecimal colour values.
#'
#' @examples
#' okabe_ito_colours()
#' okabe_ito_colours(alpha = 0.5)
#'
#' @export
okabe_ito_colours <- function(alpha = NULL) {
  colours <- c(
    black = "#000000",
    orange = "#E69F00",
    sky_blue = "#56B4E9",
    bluish_green = "#009E73",
    yellow = "#F0E442",
    blue = "#0072B2",
    vermillion = "#D55E00",
    reddish_purple = "#CC79A7"
  )

  apply_alpha(colours, alpha = alpha)
}

#' Okabe-Ito palette
#'
#' Return the first `n` colours from the standard Okabe-Ito palette.
#'
#' @param n Integer scalar giving the number of colours to return.
#' @param alpha Optional numeric scalar in `[0, 1]` giving the alpha
#'   transparency to apply with [grDevices::adjustcolor()]. If `NULL`, colours
#'   are returned as opaque hexadecimal RGB values.
#'
#' @return A named character vector of `n` hexadecimal colour values.
#'
#' @examples
#' okabe_ito_palette(3)
#' okabe_ito_palette(4, alpha = 0.75)
#'
#' @export
okabe_ito_palette <- function(n = length(okabe_ito_colours()), alpha = NULL) {
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 0 || n != floor(n)) {
    stop("`n` must be a non-negative integer scalar.", call. = FALSE)
  }

  colours <- okabe_ito_colours(alpha = alpha)

  if (n > length(colours)) {
    stop("`n` must be no larger than the number of available colours.", call. = FALSE)
  }

  colours[seq_len(n)]
}

apply_alpha <- function(colours, alpha = NULL) {
  if (is.null(alpha)) {
    return(colours)
  }

  if (!is.numeric(alpha) || length(alpha) != 1L || is.na(alpha) ||
      alpha < 0 || alpha > 1) {
    stop("`alpha` must be a numeric scalar in [0, 1].", call. = FALSE)
  }

  adjusted.colours <- grDevices::adjustcolor(colours, alpha.f = alpha)
  names(adjusted.colours) <- names(colours)
  adjusted.colours
}
