% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mplot3.bar.R
\name{mplot3.bar}
\alias{mplot3.bar}
\title{\code{mplot3}: Barplot}
\usage{
mplot3.bar(
  x,
  error = NULL,
  col = NULL,
  error.col = "white",
  error.lwd = 2,
  alpha = 1,
  beside = TRUE,
  border = NA,
  width = 1,
  space = NULL,
  xlim = NULL,
  ylim = NULL,
  xlab = NULL,
  xlab.line = 1.5,
  ylab = NULL,
  ylab.line = 1.5,
  main = NULL,
  las = 1.5,
  xnames = NULL,
  xnames.srt = 0,
  xnames.adj = ifelse(xnames.srt == 0, 0.5, 1),
  xnames.line = 0.5,
  xnames.font = 1,
  xnames.cex = 1,
  xnames.y.pad = 0.08,
  xnames.at = NULL,
  color.bygroup = FALSE,
  group.legend = NULL,
  legend.adj = 0,
  legend.at = NA,
  group.names = NULL,
  legend.position = "topright",
  legend.inset = c(0, 0),
  legend.font = 1,
  bartoplabels = NULL,
  mar = c(3, 2.5, 2.5, 1),
  pty = "m",
  barplot.axes = FALSE,
  yaxis = TRUE,
  ylim.pad = 0.04,
  y.axis.padj = 1,
  tck = -0.015,
  theme = getOption("rt.theme", "lightgrid"),
  palette = getOption("rt.palette", "rtCol1"),
  par.reset = TRUE,
  pdf.width = 6,
  pdf.height = 6,
  filename = NULL,
  ...
)
}
\arguments{
\item{x}{Vector or Matrix: If Vector, each value will be drawn as a bar.
If Matrix, each column is a vector, so multiple columns signify a different group.
e.g. Columns could be months and rows could be N days sunshine, N days rainfall, N days snow, etc.}

\item{col}{Vector of colors to use}

\item{alpha}{Float: Alpha to be applied to \code{col}}

\item{border}{Color if you wish to draw border around bars, NA for no borders (Default)}

\item{space}{Float: Space left free on either side of the bars, as a fraction of bar width. A single number or a
vector, one value per bar. If \code{x} is a matrix, space can be length 2 vector, signifying space between bars
within group and between groups. Default = c(0, 1) if x is matrix and \code{beside = TRUE}, otherwise Default = .2}

\item{xlim}{Float vector, length 2: x-axis limits}

\item{ylim}{Float vector, length 2: y-axis limits}

\item{xlab}{Character: x-axis label}

\item{xlab.line}{Float: Adjustment for the x axis label position (See code{line} in \code{?mtext})}

\item{ylab}{Character: y-axis label}

\item{ylab.line}{Float: Similar to \code{xlab.line} for the y axis}

\item{main}{Character: Plot title}

\item{color.bygroup}{Logical: If TRUE, and input is a matrix, each group's bars will be given the same color,
otherwise bars across groups will be given the same sequence of colors. Default = FALSE}

\item{group.legend}{Logical: If TRUE, place \code{group.names} in a legend}

\item{group.names}{(Optional) If multiple groups are plotted, use these names if \code{group.title = TRUE}}

\item{mar}{Float, vector, length 4: Margins; see \code{par("mar")}}

\item{pty}{Character: "s" gives a square plot; "m" gives a plot that fills graphics device size. Default = "m"
(See \code{par("pty")})}

\item{y.axis.padj}{Float: Similar to \code{x.axis.padj} for the y axis}

\item{tck}{Float: Tick length. Can be negative (See \code{par("tck")})}

\item{theme}{Character: "black", "blackgrid", "darkgrid", "white", "whitegrid", "lightgrid"
Default = "lightgrid" if no default \code{"rt.fit"} is set using \code{options}.
You can set a system-wide default in your \code{.Rprofile} by including a line like
options(rt.theme = 'lightgrid')}

\item{palette}{Vector of colors, or Character defining a builtin palette - get all options with \code{rtPalette()}}

\item{par.reset}{Logical: If TRUE, reset \code{par} setting before exiting. Default = TRUE}

\item{pdf.width}{Float: Width in inches for pdf output (if \code{filename} is set). Default = 6}

\item{pdf.height}{Float: Height in inches for pdf output. Default = 6}

\item{filename}{Character: Path to file to save plot. Default = NULL}

\item{...}{Additional arguments to \code{graphics::barplot}}

\item{legend}{Logical: If TRUE, and input is matrix, draw legend for each case. Note: you may need to adjust
\code{mar} and \code{legend.inset} if you want to place the legend outside the plot
(can use e.g.\code{legend.inset = c(-.5, 0)})}
}
\description{
Draw barplots
}
\author{
Efstathios D. Gennatas
}
