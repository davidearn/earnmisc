#' Named user coordinate limits
#'
#' Return `graphics::par("usr")` with stable names.
#'
#' @return A named numeric vector with elements `left`, `right`, `bottom`,
#'   and `top`.
#'
#' @examples
#' plot(1:3, 1:3)
#' named_par_usr()
#'
#' @export
named_par_usr <- function() {
  par.usr <- graphics::par("usr")
  names(par.usr) <- c("left", "right", "bottom", "top")
  par.usr
}

#' Named plot margins
#'
#' Return `graphics::par("mar")` with stable names.
#'
#' @return A named numeric vector with elements `bottom`, `left`, `top`, and
#'   `right`.
#'
#' @examples
#' plot(1:3, 1:3)
#' named_par_mar()
#'
#' @export
named_par_mar <- function() {
  par.mar <- graphics::par("mar")
  names(par.mar) <- c("bottom", "left", "top", "right")
  par.mar
}

#' Base graphics plot metadata
#'
#' Return a small list of metadata about the current base graphics plot.
#'
#' @param xlim Optional numeric vector describing the x-axis limits to include
#'   in the returned metadata.
#' @param ylim Optional numeric vector describing the y-axis limits to include
#'   in the returned metadata.
#'
#' @return A list with elements `xlim`, `ylim`, `par.usr`, `par.mar`, and
#'   `par.list`.
#'
#' @examples
#' plot(1:3, 1:3)
#' plot_metadata()
#'
#' @export
plot_metadata <- function(xlim = NULL, ylim = NULL) {
  list(
    xlim = as.numeric(xlim),
    ylim = as.numeric(ylim),
    par.usr = named_par_usr(),
    par.mar = named_par_mar(),
    par.list = graphics::par(no.readonly = TRUE)
  )
}
