% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dplot3.bar.R
\name{dplot3.bar}
\alias{dplot3.bar}
\title{Interactive Barplots}
\usage{
dplot3.bar(
  x,
  main = NULL,
  xlab = NULL,
  ylab = NULL,
  col = NULL,
  alpha = 0.8,
  bg = NULL,
  plot.bg = NULL,
  theme = getOption("rt.theme", "darkgrid"),
  palette = getOption("rt.palette", "rtCol1"),
  barmode = c("group", "relative", "stack", "overlay"),
  group.names = NULL,
  feature.names = NULL,
  font.size = 16,
  font.alpha = 0.8,
  font.col = NULL,
  axes.col = NULL,
  labs.col = NULL,
  grid.col = NULL,
  grid.lwd = 1,
  grid.alpha = 0.8,
  tick.col = NULL,
  legend = TRUE,
  legend.col = NULL,
  margin = list(b = 50, l = 50, t = 50, r = 20),
  padding = 0,
  filename = NULL,
  file.width = 500,
  file.height = 500,
  ...
)
}
\arguments{
\item{x}{data.frame: Input where rows are groups (can be 1 row), columns are features}

\item{main}{Character: Plot title. Default = NULL}

\item{xlab}{Character: x-axis label. Default = NULL}

\item{ylab}{Character: y-axis label. Default = NULL}

\item{col}{Color, vector: Color for bars. Default NULL, which will draw colors from \code{palette}}

\item{alpha}{Float (0, 1]: Transparency for bar colors. Default = .8}

\item{bg}{Color: Background color. Default = "white"}

\item{plot.bg}{Color: Background color for plot area. Default = "white"}

\item{theme}{Character: THeme to use: "light", "dark", "lightgrid", "darkgrid". Default = "lightgrid"}

\item{palette}{Character: Name of `rtemis` palette to use. Default = "rtCol1". Only used if \code{col = NULL}}

\item{barmode}{Character: Type of bar plot to make: "group", "relative", "stack", "overlay". Default = "group". Use
"relative" for stacked bars, which handles negative values correctly, unlike "stack", as of writing.}

\item{group.names}{Character, vector, length = NROW(x): Group names. Default = NULL, which uses \code{rownames(x)}}

\item{feature.names}{Character, vector, length = NCOL(x): Feature names. Default = NULL, which uses
\code{colnames(x)}}

\item{font.size}{Float: Font size for all labels. Default = 16}

\item{font.alpha}{Float (0, 1]: Transparency for fonts. Default = .8}

\item{font.col}{Color: Font color. Default = "black"}

\item{axes.col}{Color: Axes color. Default = NULL, determined, by theme}

\item{labs.col}{Color: Labels' color. Default = NULL, determined by theme}

\item{grid.col}{Color: Grid color. Default = "gray85"}

\item{grid.lwd}{Float: Grid line width. Default = 1}

\item{grid.alpha}{Float (0, 1]: Transparency for \code{grid.col}. Default = .8}

\item{tick.col}{Color: Color for ticks and tick labels. Default = NULL, determined, by theme}

\item{legend}{Logical: If TRUE, draw legend. Default = TRUE}

\item{legend.col}{Color: Legend text color. Default = NULL, determined by theme}

\item{margin}{Named list: plot margins. Default = \code{list(b = 50, l = 50, t = 50, r = 20)}}

\item{padding}{Integer: N pixels to pad plot. Default = 0}

\item{filename}{Character: Path to file to save static plot. Default = NULL}

\item{file.width}{Integer: File width in pixels for when \code{filename} is set. Default = 500}

\item{file.height}{Integer: File height in pixels for when \code{filename} is set. Default = 500}

\item{font.family}{String: Font family to use. Default = "Helvetica Neue"}

\item{main.col}{Color: Title color. Default = NULL, determined by theme}
}
\description{
Draw interactive barplots using \code{plotly}
}
\examples{
\dontrun{
dplot3.bar(VADeaths)
}
}
\author{
Efstathios D. Gennatas
}
