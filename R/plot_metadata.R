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
  named_par_list()$usr
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
  named_par_list()$mar
}

#' Named graphics parameters
#'
#' Return the full set of readable base graphics parameters, with names added
#' to common vector-valued entries where the positions have stable meanings.
#'
#' @return A list like `graphics::par(no.readonly = TRUE)`, preserving all
#'   entries and adding names to common vector entries such as `usr`, `mar`,
#'   `oma`, `mai`, `omi`, `pin`, `plt`, and `fig`.
#'
#' @examples
#' plot(1:3, 1:3)
#' named_par_list()
#'
#' @export
named_par_list <- function() {
  par.list <- graphics::par(no.readonly = TRUE)

  vector.names <- list(
    usr = c("left", "right", "bottom", "top"),
    mar = c("bottom", "left", "top", "right"),
    oma = c("bottom", "left", "top", "right"),
    mai = c("bottom", "left", "top", "right"),
    omi = c("bottom", "left", "top", "right"),
    pin = c("width", "height"),
    plt = c("left", "right", "bottom", "top"),
    fig = c("left", "right", "bottom", "top"),
    fin = c("width", "height"),
    din = c("width", "height"),
    cin = c("width", "height"),
    cra = c("width", "height"),
    cxy = c("width", "height"),
    xaxp = c("minimum", "maximum", "intervals"),
    yaxp = c("minimum", "maximum", "intervals"),
    mfcol = c("rows", "columns"),
    mfrow = c("rows", "columns"),
    mfg = c("row", "column", "rows", "columns"),
    mgp = c("title", "labels", "line")
  )

  for (parameter.name in intersect(names(vector.names), names(par.list))) {
    if (length(par.list[[parameter.name]]) == length(vector.names[[parameter.name]])) {
      names(par.list[[parameter.name]]) <- vector.names[[parameter.name]]
    }
  }

  par.list
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
  par.list <- named_par_list()

  list(
    xlim = as.numeric(xlim),
    ylim = as.numeric(ylim),
    par.usr = par.list$usr,
    par.mar = par.list$mar,
    par.list = par.list
  )
}
