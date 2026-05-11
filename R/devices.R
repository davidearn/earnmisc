#' Is the active graphics device a tikz device?
#'
#' Return whether the currently active graphics device appears to be a tikz
#' device opened by [tikzDevice::tikz()] or [tikz_open()].
#'
#' This is a lightweight helper based on the active device name and, when
#' available, metadata stored by [tikz_open()]. It returns `FALSE` for the null
#' device and when no user graphics device is active.
#'
#' @return A scalar logical value.
#'
#' @examples
#' dev_is_tikz()
#' if (requireNamespace("tikzDevice", quietly = TRUE)) {
#'   # tikzDevice can be used with dev_is_tikz() in plotting workflows.
#' }
#'
#' @export
dev_is_tikz <- function() {
  device.name <- dev_name()

  if (identical(device.name, "null device")) {
    return(FALSE)
  }

  if (grepl("tikz", device.name, ignore.case = TRUE, fixed = FALSE)) {
    return(TRUE)
  }

  current.device <- unname(grDevices::dev.cur())
  current.info <- tikz_info(current.device)

  is.list(current.info) && identical(current.info$device, current.device)
}

#' Is the active graphics device a PDF device?
#'
#' Return whether the currently active graphics device appears to be a PDF
#' device opened by [grDevices::pdf()].
#'
#' This is a lightweight helper based on the active device name. It returns
#' `FALSE` for the null device and when no user graphics device is active.
#'
#' @return A scalar logical value.
#'
#' @examples
#' dev_is_pdf()
#'
#' @export
dev_is_pdf <- function() {
  identical(dev_name(), "pdf")
}

#' Current graphics device name
#'
#' Return the name of the currently active graphics device as reported by
#' [grDevices::dev.cur()].
#'
#' @return A character scalar. The null device is returned as `"null device"`.
dev_name <- function() {
  device <- grDevices::dev.cur()
  device.name <- names(device)

  if (is.null(device.name) || length(device.name) != 1L || is.na(device.name)) {
    return("")
  }

  device.name
}
