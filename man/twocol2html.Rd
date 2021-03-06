% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dplot3.shytree.R
\name{twocol2html}
\alias{twocol2html}
\title{Create html table from a data.frame with 2 columns: Var name, and Coefs}
\usage{
twocol2html(
  x,
  font.family = "'Helvetica Neue'",
  font.col = "#ffffff",
  font.size = "14px",
  header.bg = "#404040",
  table.bg = "#7F7F7F",
  dat.col = rep("#525252", NROW(x)),
  dat.font.col = "#ffffff",
  height = "50px",
  head.padding = "4px",
  dat.padding = "4px"
)
}
\description{
Create html table from a data.frame with 2 columns: Var name, and Coefs
}
\examples{
\dontrun{
x <- data.frame(ID = c("Int", paste0("V", 1:10)),
   Coef = rnorm(11))
twocol2html(x)
}
}
