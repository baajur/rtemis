# d.TSNE.R
# ::rtemis::
# 2016 Efstathios D. Gennatas egenn.github.io

#' t-distributed Stochastic Neighbor Embedding
#'
#' Perform t-SNE decomposition using \code{Rtsne::Rtsne}
#'
#' @param x Input matrix
#' @param k Integer. Number of t-SNE components required
#' @param initial.dims Integer: Number of dimensions to retain in initial PCA. Default = 50
#' @param perplexity Numeric: Perplexity parameter
#' @param theta Float: 0.0: exact TSNE. Increase for higher speed, lower accuracy. Default = 0
#' @param check.duplicates Logical: If TRUE, Checks whether duplicates are present. Best to set test manually
#' @param pca Logical: If TRUE, perform initial PCA step. Default = TRUE
#' @param max.iter Integer: Maximum number of iterations. Default = 1000
#' @param scale Logical: If TRUE, scale before running t-SNE using \code{base::scale}. Default = FALSE
#' @param center Logical: If TRUE, and \code{scale = TRUE}, also center. Default = FALSE
#' @param is.distance Logical: If TRUE, \code{x} should be a distance matrix. Default = FALSE
#' @param verbose Logical: If TRUE, print messages to output
#' @param ... Options for \code{Rtsne::Rtsne}
#' @param outdir Path to output directory
#' @return \link{rtDecom} object
#' @author Efstathios D. Gennatas
#' @family Decomposition
#' @export

d.TSNE <- function(x,
                   k = 3,
                   initial.dims = 50,
                   perplexity = 15,
                   theta = 0,
                   check.duplicates = TRUE,
                   pca = TRUE,
                   max.iter = 1000,
                   scale = FALSE,
                   center = FALSE,
                   # labeledNifti = NULL,
                   is.distance = FALSE,
                   verbose = TRUE,
                   outdir = "./") {

  # [ INTRO ] ====
  start.time <- intro(verbose = verbose)
  if (verbose) msg("Running t-distributed Stochastic Neighbot Embedding")
  decom.name <- "TSNE"

  # [ DEPENDENCIES ] ====
  if (!depCheck("Rtsne", verbose = FALSE)) {
    cat("\n"); stop("Please install dependencies and try again")
  }

  # [ ARGUMENTS ] ====
  if (missing(x)) {
    print(args(d.TSNE))
    stop("x is missing")
  }

  # [ DATA ] ====
  x <- as.data.frame(x)
  n <- NROW(x)
  p <- NCOL(x)
  if (verbose) {
    msg("||| Input has dimensions ", n, " rows by ", p, " columns,", sep = "")
    msg("    interpreted as", n, "cases with", p, "features.")
  }
  if (is.null(colnames(x))) colnames(x) <- paste0("Feature_", seq(NCOL(x)))
  xnames <- colnames(x)
  # if (!is.null(x.test)) colnames(x.test) <- xnames
  x <- scale(x, scale = scale, center = center)
  # if (!is.null(x.test)) x.test <- scale(x.test, scale = scale, center = center)

  # [ t-SNE ] ====
  if (verbose) msg("Running t-SNE...")
  decom <- Rtsne::Rtsne(X = x,
                        dims = k,
                        initial_dims = initial.dims,
                        perplexity = perplexity,
                        theta = theta,
                        check_duplicates = check.duplicates,
                        pca = pca,
                        max_iter = max.iter,
                        verbose = verbose,
                        is_distance = is.distance)

  # # [ WRITE TO NIFTIs ] ====
  # if (!is.null(labeledNifti)) {
  #   prefix <- paste0(outdir, "s.tSNE")
  #   cat("Writing results to nifti...\n")
  #   tryCatch(labels2niftis(decom$Y, labeledNifti, prefix),
  #            error = function(e) cat("Error saving nifti files (s.tSNE > labels2niftis)\n"))
  #   cat("+ + + Saved nifti files under", outdir, "\n")
  # }

  # [ OUTPUT ] ====
  extra <- list()
  rt <- rtDecom$new(decom.name = decom.name,
                    decom = decom,
                    xnames = xnames,
                    projections.train = decom$Y,
                    projections.test = NULL,
                    parameters = list(k = k,
                                      initial.dims = initial.dims,
                                      perplexity = perplexity,
                                      theta = theta,
                                      check.duplicates = check.duplicates,
                                      pca = pca,
                                      max.iter = max.iter,
                                      scale = scale,
                                      center = center),
                    extra = extra)
  outro(start.time, verbose = verbose)
  rt

} # rtemis::d.tSNE
