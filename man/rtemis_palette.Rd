% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rtPalette.R
\name{rtemis_palette}
\alias{rtemis_palette}
\title{Access rtemis palette colors}
\usage{
rtemis_palette(n, palette = getOption("rt.palette", "rtCol1"))
}
\arguments{
\item{n}{Integer: Number of colors to output}

\item{palette}{Character: Palette to use. See available options with \code{rtPalette()}.
Default = \code{getOption("rt.palette", "rtCol1")}}
}
\description{
Allows you to get `n` colors of a defined palette, useful for passing to other functions, like ggplot
}
\author{
Efstathios D Gennatas
}
