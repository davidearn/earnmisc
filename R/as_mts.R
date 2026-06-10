#' Convert objects to multivariate time series
#'
#' `as_mts()` is an S3 generic for converting supported objects to
#' multivariate time-series objects suitable for [mts_plot()] and related
#' `mts_*` helpers.
#'
#' Methods should return an object that [mts_plot()] can safely treat as
#' multivariate time-series data, typically an object inheriting from `mts`.
#'
#' @param x Object to convert.
#' @param ... Additional arguments passed to methods.
#'
#' @return An object suitable for [mts_plot()] and related helpers.
#'
#' @examples
#' x <- stats::ts(cbind(a = 1:5, b = 6:10))
#' mts_plot(x)
#'
#' @export
as_mts <- function(x, ...) {
  UseMethod("as_mts")
}
