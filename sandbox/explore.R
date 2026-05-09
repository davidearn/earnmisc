rs()
library(earnmisc)
?earnmisc
plot(0,0)
xys_line(0, 1, 2)
xys.out <- xys_line(c(0,0.05), c(0.1,-0.1), c(1,-0.5)
         , col = c("blue","red")
         , lty = c("solid","dotted","dashed")
         , lwd = c(3,1)
         )
xys.out
example(xys_line)
