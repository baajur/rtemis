# mplot3.img.R
# ::rtemis::
# 2016 Efstathios D. Gennatas egenn.github.io
# rtTODO: make as.mat = F work

#' \code{mplot3}: Image (False color 2D)
#'
#' Draw a bitmap from a matrix of values. This is a good way to plot a large heatmap
#'
#' This function calls \code{image} which is a lot faster than drawing heatmaps
#'
#' @param z Input matrix
#' @param as.mat Logical: If FALSE, rows and columns of z correspond to x and y coordinates accoridngly.
#'   This is the \code{image} default.
#'   If TRUE (default), resulting image's cells will be in the same order as values appear when
#'   you print z in the console. This is \code{t(apply(z, 2, rev))}. In this case, you can think of z
#'   as a table of values you want to pictures with colors. For example, you can convert a correlation table
#'   to a figure. In this case, you might want to add \code{cell.labs} with the values. Consider first using
#'   \link{ddSci}.
#' @param col Colors to use. Defaults to \code{colorGrad(100)}
#' @param revR Logical: If TRUE, reverse rows. Defaults to TRUE for a top-left to bottom-right diagonal
#' @param cell.labs Matrix of same dimensions as z (Optional): Will be printed as strings over cells
#' @param cell.labs.col Color for \code{cell.labs}. If NULL, the upper and lower quartiles will be
#' set to "white", the rest "black".
#' @param bg Background color
#' @param filename String (Optional): Path to file where image should be saved. R-supported extensions:
#' ".pdf", ".jpeg", ".png", ".tiff".
#' @param file.width Output Width in inches
#' @param file.height Output height in inches
#' @param par.reset Logical: If TRUE, par will be reset to original settings before exit. Default = TRUE
#' @param ... Additional arguments to be passed to \code{graphics::image}
#' @author Efstathios D. Gennatas
#' @export

mplot3.img <- function(z,
                       as.mat = TRUE,
                       col = colorGrad(101, space = "rgb"),
                       xnames = NULL,
                       xnames.y = 0,
                       ynames = NULL,
                       # ynames.x = 0,
                       main = "Row > Column",
                       main.adj = 0,
                       main.line = 1.5,
                       x.axis.side = 3,
                       y.axis.side = 2,
                       x.axis.line = -.5,
                       y.axis.line = -.5,
                       x.axis.las = 0,
                       y.axis.las = 1,
                       x.tick.labs.adj = NULL,
                       y.tick.labs.adj = NULL,
                       xlab = NULL,
                       ylab = NULL,
                       xlab.adj = .5,
                       ylab.adj = .5,
                       xlab.line = 1.7,
                       ylab.line = 1.7,
                       xlab.padj = 0,
                       ylab.padj = 0,
                       xlab.side = 1,
                       ylab.side = 2,
                       main.col = NULL,
                       # xnames.col = "black",
                       # ynames.col = "black",
                       axlab.col = NULL,
                       axes.col = NULL,
                       labs.col = NULL,
                       tick.col = NULL,
                       cell.lab.hi.col = NULL,
                       cell.lab.lo.col = NULL,
                       cex = 1.2,
                       cex.ax = NULL,
                       cex.x = NULL,
                       cex.y = NULL,
                       # x.srt = NULL,
                       # y.srt = 0,
                       zlim = NULL,
                       autorange = TRUE,
                       pty = "m",
                       mar = c(3, 3, 3, 3),
                       asp = NULL,
                       ann = FALSE,
                       axes = FALSE,
                       cell.labs = NULL,
                       cell.labs.col = NULL,
                       cell.labs.autocol = TRUE, # WIP add autocol w cutoffs at abs(.4)
                       bg = NULL,
                       theme = getOption("rt.theme", "white"),
                       filename = NULL,
                       file.width = NULL,
                       file.height = NULL,
                       par.reset = TRUE,
                       ...) {

  # [ ARGUMENTS ] ====
  # Compatibility with rtlayout()
  if (exists("rtpar")) par.reset <- FALSE

  # [ THEME ] ====
  extraargs <- list(...)
  if (is.character(theme)) {
    theme <- do.call(paste0("theme_", theme), extraargs)
  } else {
    # Override with extra arguments
    for (i in seq(extraargs)) {
      theme[[names(extraargs)[i]]] <- extraargs[[i]]
    }
  }

  # [ ZLIM ] ====
  if (is.null(zlim)) {
    if (autorange) {
      max.z <- max(abs(z))
      zlim <- c(-max.z, max.z)
    } else {
      zlim <- range(z)
    }
  }

  # [ AUTOSIZE cex.ax ] ====
  # at NROW == 50, cex.ax <- .5
  # at NROW == 20, cex.ax <- 1
  if (is.null(cex.ax)) {
    if (NROW(z) < 20) {
      cex.ax <- 1
    } else {
      cex.ax <- NROW(z) * -.01667 + 1.333
    }
  }
  if (is.null(cex.x)) cex.x <- cex.ax
  if (is.null(cex.y)) cex.y <- cex.ax

  # [ THEMES ] ====
  if (is.null(cell.lab.hi.col)) cell.lab.hi.col <- theme$fg
  if (is.null(cell.lab.lo.col)) cell.lab.lo.col <- theme$fg

  # [ IMAGE ] ====
  if (!is.null(filename)) {
    graphics <- gsub(".*\\.", "", filename)
    if (is.null(file.width)) {
      file.width <- file.height <- if (graphics == "pdf") 6 else 500
    }
  }
  if (as.mat) {
    x <- 1:NCOL(z)
    y <- 1:NROW(z)
    z <- t(apply(z, 2, rev))
    if (!is.null(ynames)) ynames <- rev(ynames)
  } else {
    x <- 1:NROW(z)
    y <- 1:NCOL(z)
  }

  # pdf() has argument "file", bmp(), jpeg(), png(), and tiff() have "filename";
  # "file" works in all
  if (!is.null(filename)) do.call(graphics, args = list(file = filename,
                                                        width = file.width, height = file.height))

  # rtlayout support
  if (exists("rtpar", envir = rtenv)) par.reset <- FALSE
  par.orig <- par(no.readonly = TRUE)
  if (par.reset) on.exit(suppressWarnings(par(par.orig)))
  par(pty = pty, mar = mar, bg = theme$bg)

  image(x, y, data.matrix(z), col = col, zlim = zlim,
        asp = asp, ann = ann, axes = axes, ...)

  # [ TICK NAMES ] ====
  if (is.null(xnames)) if (!is.null(colnames(z))) xnames <- rownames(z)
  if (is.null(ynames)) if (!is.null(rownames(z))) ynames <- colnames(z)
  NR <- NROW(z)
  NC <- NCOL(z)

  if (!is.null(xnames)) {
    axis(side = theme$x.axis.side, at = 1:NR,
         labels = xnames,
         col = theme$axes.col,
         tick = FALSE,
         las = x.axis.las,
         col.axis = theme$tick.labels.col,
         cex = theme$cex,
         family = theme$font.family)
  }
  if (!is.null(ynames)) {
    axis(side = theme$y.axis.side, at = 1:NC,
         labels = ynames,
         col = theme$axes.col,
         tick = FALSE,
         las = y.axis.las,
         col.axis = theme$tick.labels.col,
         cex = theme$cex,
         family = theme$font.family)
  }

  # [ MAIN TITLE ] ====
  if (exists("autolabel", envir = rtenv)) {
    autolab <- autolabel[rtenv$autolabel]
    main <- paste(autolab, main)
    rtenv$autolabel <- rtenv$autolabel + 1
  }

  if (length(main) > 0) {
    mtext(main, line = theme$main.line,
          font = theme$main.font, adj = theme$main.adj,
          cex = theme$cex, col = theme$main.col,
          family = theme$font.family)
  }

  # [ AXES & MAIN LABELS ] ====
  if (!is.null(xlab)) mtext(xlab, side = theme$x.axis.side,
        line = xlab.line, cex = theme$cex,
        adj = xlab.adj, col = theme$labs.col,
        family = theme$font.family)
  if (!is.null(ylab)) mtext(ylab, side = theme$y.axis.side,
        line = ylab.line, cex = theme$cex,
        adj = ylab.adj, col = theme$labs.col,
        family = theme$font.family)

  # [ CELL LABELS ] ====
  if (is.null(cell.labs.col)) {
    cell.labs.col <- ifelse(z >= quantile(zlim)[4], cell.lab.hi.col, cell.lab.lo.col)
  }

  # cell.labs
  if (!is.null(cell.labs)) {
    if (length(cell.labs.col) < length(z)) {
      cell.labs.col <- matrix(rep(cell.labs.col, length(z)/length(cell.labs.col)), NROW(z))
    }
    if (as.mat) {
      cell.labs <- t(apply(cell.labs, 2, rev))
    }
    text(rep(x, length(y)), rep(y, times = 1, each = length(x)), labels = cell.labs,
         col = cell.labs.col)
  }

  if (!is.null(filename)) grDevices::dev.off()

} # rtemis::mplot3.img
