if (interactive()) rs()
library(earnmisc)
use.tikz <- TRUE
if (!interactive()) use.tikz <- TRUE
if (use.tikz) {
    ##library(tikzDevice)
    ##tikz.out <- tikz("explore.tex", standAlone = TRUE)
    tikz.info <- tikz_open("explore.tex")
}
if (interactive()) ?earnmisc
plot(0,0)
(xys_line(0, 1, 2))
oi.blue.2 <- oi_colour("blue", alpha = 0.2)
xys.out <- xys_line(c(0,0.05), c(0.1,-0.1), c(1,-0.5)
         , col = c("blue","red",oi.blue.2)
         , lty = c("solid","dotted","dashed")
         , lwd = c(4,2,1)
         )
xys.out
##example(xys_line)
if (interactive()) ?okabe_ito_colours
oi.orange
if (interactive()) ?nice_text
plot(0,0, las = 1, xlab = "", ylab = "")
cx <- 2
text(0, 0.2, nice_text(r"($\Rn$)"), cex = cx)
text(0, -0.2, nice_text(r"($\lambdakm$)"), cex = cx)
text(0.4, 0, nice_text(r"($\Ykm$)"), cex = cx)

if (!interactive()) {
  dev.off()
  tikz.pdf <- tikz_compile(tikz.info, clean = TRUE)
  system(paste0("open ", tikz.pdf))
}

