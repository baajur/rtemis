# hytreenow.R
# ::rtemis::
# 2018 Efstathios D. Gennatas egenn.github.io

#' \pkg{rtemis} internal: Low-level Hybrid Tree procedure
#'
#' Train a Hard Hybrid Tree (no weights) for Regression
#'
#' Note that lambda is treated differently by \code{glmnet::glmnet} and \code{MASS::lm.ridge}
#' @inheritParams s.HYTREE
#' @param x data.frame
#' @author Efstathios D. Gennatas
#' @keywords internal

hytreenow <- function(x, y,
                      max.depth = 5,
                      shrinkage = 1,
                      init = mean(y),
                      # lincoef --
                      alpha = 1,
                      lambda = .1,
                      lambda.seq = NULL,
                      lin.type = "glmnet",
                      cv.glmnet.nfolds = 5,
                      which.cv.glmnet.lambda = "lambda.min",
                      # rpart --
                      minobsinnode = 2,
                      minobsinnode.lin = 10,
                      part.minsplit = 2,
                      part.xval = 0,
                      part.max.depth = 1,
                      part.cp = 0,
                      part.minbucket = 5,
                      verbose = FALSE,
                      trace = 0) {

  # [ Check y is not constant ] ====
  if (is.constant(y)) {
    coefs <- list(rep(0, NCOL(x) + 1))
    names(coefs) <- c("(Intercept)", colnames(x))
    .mod <- list(init = init,
                 shrinkage = shrinkage,
                 rules = "TRUE",
                 coefs = coefs)
    class(.mod) <- c("hytreenow", "list")
    return(.mod)
  }

  # [ GLOBAL ] ====
  .env <- environment()

  # [ lin1 ] ====
  if (verbose) msg("Training Hybrid Tree (max depth = ", max.depth, ")...", sep = "")

  coef.c <- lincoef(x, y, method = lin.type,
                    alpha = alpha, lambda = lambda, lambda.seq = lambda.seq,
                    cv.glmnet.nfolds = cv.glmnet.nfolds,
                    which.cv.glmnet.lambda = which.cv.glmnet.lambda)
  Fval <- init + shrinkage * (data.matrix(cbind(1, x)) %*% coef.c)[, 1]
  if (trace > 0) msg("hytreenow Fval is", head(Fval), color = crayon::red)

  # [ Run hyt ] ====
  root <- list(x = x,
               y = y,
               Fval = Fval,
               index = rep(1, length(y)),
               depth = 0,
               partlin = NULL,    # To hold the output of partLm()
               left = NULL,       # \  To hold the left and right nodes,
               right = NULL,      # /  if partLm splits
               lin = NULL,
               part = NULL,
               coef.c = coef.c,
               terminal = FALSE,
               type = NULL,
               rule = "TRUE")
  mod <- hyt(node = root,
             max.depth = max.depth,
             minobsinnode = minobsinnode,
             minobsinnode.lin = minobsinnode.lin,
             shrinkage = shrinkage,
             alpha = alpha,
             lambda = lambda,
             lambda.seq = lambda.seq,
             coef.c = coef.c,
             part.minsplit = part.minsplit,
             part.xval = part.xval,
             part.max.depth = part.max.depth,
             part.cp = part.cp,
             part.minbucket = part.minbucket,
             .env = .env,
             keep.x = FALSE,
             simplify = TRUE,
             lin.type = lin.type,
             cv.glmnet.nfolds = cv.glmnet.nfolds,
             verbose = verbose,
             trace = trace)

  # [ MOD ] ====
  .mod <- list(init = init,
               shrinkage = shrinkage,
               rules = .env$leaf.rule,
               coefs = .env$leaf.coef)
  class(.mod) <- c("hytreenow", "list")

  .mod

} # rtemis::hytreenow


hyt <- function(node = list(x = NULL,
                            y = NULL,
                            Fval = NULL,
                            index = NULL,
                            depth = NULL,
                            partlin = NULL,    # To hold the output of partLm()
                            left = NULL,       # \  To hold the left and right nodes,
                            right = NULL,      # /  if partLm splits
                            lin = NULL,
                            part = NULL,
                            coef.c = NULL,
                            terminal = NULL,
                            type = NULL,
                            rule = NULL),
                coef.c = 0,
                max.depth = 7,
                minobsinnode = 2,
                minobsinnode.lin = 5,
                shrinkage = 1,
                alpha = .1,
                lambda = .1,
                lambda.seq = NULL,
                part.minsplit = 2,
                part.xval = 0,
                part.max.depth = 1,
                part.minbucket = 5,
                part.cp = 0,
                .env = NULL,
                keep.x = FALSE,
                simplify = TRUE,
                lin.type = "glmnet",
                cv.glmnet.nfolds = 5,
                which.cv.glmnet.lambda = "lambda.min",
                verbose = TRUE,
                trace = 0) {

  # [ EXIT ] ====
  if (node$terminal) return(node)

  x <- node$x
  y <- node$y
  depth <- node$depth
  Fval <- node$Fval
  # if (trace > 1) msg("y is", y)
  # if (trace > 1) msg("Fval is", head(Fval))
  resid <- y - Fval
  if (trace > 0) msg("hyt Fval   is", head(Fval), color = crayon::red)
  if (trace > 0) msg("hyt resid   is", head(resid), color = crayon::red)
  nobsinnode <- length(node$index)

  # [ Add partlin to node ] ====
  if (node$depth < max.depth && nobsinnode >= minobsinnode) {
    if (trace > 1) msg("y1 (resid) is", resid)
    node$partlin <- partLm(x1 = x, y1 = resid,
                           lambda = lambda,
                           lambda.seq = lambda.seq,
                           part.minsplit = part.minsplit,
                           part.xval = part.xval,
                           part.max.depth = part.max.depth,
                           part.cp = part.cp,
                           part.minbucket = part.minbucket,
                           minobsinnode.lin = minobsinnode.lin,
                           lin.type = lin.type,
                           cv.glmnet.nfolds = cv.glmnet.nfolds,
                           verbose = verbose,
                           trace = trace)

    if (trace > 1) msg("Fval is", head(Fval))

    # '- If node split ====
    if (!node$partlin$terminal) {
      node$type <- "split"
      left.index <- node$partlin$left.index
      right.index <- node$partlin$right.index
      if (trace > 1) msg("Depth:", depth, "left.index:", node$partlin$left.index)
      x.left <- x[left.index, , drop = FALSE]
      x.right <- x[right.index, , drop = FALSE]
      y.left <- y[left.index]
      y.right <- y[right.index]
      if (trace > 1) msg("y.left is", y.left)
      if (trace > 1) msg("y.right is", y.right)
      Fval.left <- Fval[left.index] + shrinkage * (node$partlin$part.val[left.index] + node$partlin$lin.val.left)
      Fval.right <- Fval[right.index] + shrinkage * (node$partlin$part.val[right.index] + node$partlin$lin.val.right)
      coef.c.left <- coef.c.right <- coef.c

      # Cumulative sum of coef.c
      coef.c.left <- coef.c.left + c(node$partlin$lin.coef.left[1] + node$partlin$part.c.left,
                                     node$partlin$lin.coef.left[-1])
      coef.c.right <- coef.c.right + c(node$partlin$lin.coef.right[1] + node$partlin$part.c.right,
                                       node$partlin$lin.coef.right[-1])
      if (trace > 1) msg("coef.c.left is", coef.c.left, "coef.c.right is", coef.c.right)
      if (!is.null(node$partlin$cutFeat.point)) {
        rule.left <- node$partlin$split.rule
        rule.right <- gsub("<", ">=", node$partlin$split.rule)
      } else {
        rule.left <- node$partlin$split.rule
        rule.right <- paste0("!", rule.left) # fix: get cutFeat.name levels and find complement
      }

      # Init Left and Right nodes
      node$left <- list(x = x.left,
                        y = y.left,
                        Fval = Fval.left,
                        index = left.index,
                        depth = depth + 1,
                        coef.c = coef.c.left,
                        partlin = NULL,    # To hold the output of partLm()
                        left = NULL,       # \  To hold the left and right nodes,
                        right = NULL,      # /  if partLm splits
                        terminal = FALSE,
                        type = NULL,
                        rule = paste0(node$rule, " & ", node$partlin$rule.left))
      node$right <- list(x = x.right,
                         y = y.right,
                         Fval = Fval.right,
                         index = right.index,
                         depth = depth + 1,
                         coef.c = coef.c.right,
                         partlin = NULL,    # To hold the output of partLm()
                         left = NULL,       # \  To hold the right and right nodes,
                         right = NULL,      # /  if partLm splits
                         terminal = FALSE,
                         type = NULL,
                         rule = paste0(node$rule, " & ", node$partlin$rule.right))

      if (!keep.x) node$x <- NULL
      node$split.rule <- node$partlin$split.rule
      if (simplify) {
        node$y <- node$Fval <- node$index <- node$depth <- node$lin <- node$part <- node$type <- node$partlin <- NULL
      }

      # Run Left and Right nodes
      # [ LEFT ] ====
      if (trace > 0) msg("Depth = ", depth + 1, "; Working on Left node...", sep = "")
      node$left <- hyt(node$left,
                       coef.c = coef.c.left,
                       max.depth = max.depth,
                       minobsinnode = minobsinnode,
                       minobsinnode.lin = minobsinnode.lin,
                       shrinkage = shrinkage,
                       alpha = alpha,
                       lambda = lambda,
                       lambda.seq = lambda.seq,
                       part.minsplit = part.minsplit,
                       part.xval = part.xval,
                       part.max.depth = part.max.depth,
                       part.cp = part.cp,
                       part.minbucket = part.minbucket,
                       .env = .env,
                       keep.x = keep.x,
                       simplify = simplify,
                       lin.type = lin.type,
                       verbose = verbose,
                       trace = trace)
      # [ RIGHT ] ====
      if (trace > 0) msg("Depth = ", depth + 1, "; Working on Right node...", sep = "")
      node$right <- hyt(node$right,
                        coef.c = coef.c.right,
                        max.depth = max.depth,
                        minobsinnode = minobsinnode,
                        minobsinnode.lin = minobsinnode.lin,
                        shrinkage = shrinkage,
                        alpha = alpha,
                        lambda = lambda,
                        lambda.seq = lambda.seq,
                        part.minsplit = part.minsplit,
                        part.xval = part.xval,
                        part.max.depth = part.max.depth,
                        part.cp = part.cp,
                        part.minbucket = part.minbucket,
                        .env = .env,
                        keep.x = keep.x,
                        simplify = simplify,
                        lin.type = lin.type,
                        verbose = verbose,
                        trace = trace)
      if (simplify) node$coef.c <- NULL
    } else {
      # partLm did not split
      node$terminal <- TRUE
      .env$leaf.rule <- c(.env$leaf.rule, node$rule)
      .env$leaf.coef <- c(.env$leaf.coef, list(node$coef.c))
      node$type <- "nosplit"
      if (trace > 0) msg("STOP: nosplit")
      if (simplify) node$x <- node$y <- node$Fval <- node$index <- node$depth <- node$type <- node$partlin <- NULL
    } # !node$terminal

  } else {
    # max.depth or minobsinnode reached
    node$terminal <- TRUE
    .env$leaf.rule <- c(.env$leaf.rule, node$rule)
    .env$leaf.coef <- c(.env$leaf.coef, list(node$coef.c))
    if (node$depth == max.depth) {
      if (trace > 0) msg("STOP: max.depth")
      node$type <- "max.depth"
    } else if (nobsinnode < minobsinnode) {
      if (trace > 0) msg("STOP: minobsinnode")
      node$type <- "minobsinnode"
    }
    if (simplify) node$x <- node$y <- node$Fval <- node$index <- node$depth <- node$type <- node$partlin <- NULL
    return(node)
  } # max.depth, minobsinnode

  node

} # rtemis::hyt


#' \pkg{rtemis} internal: Ridge and Stump
#'
#' Fit a linear model on (x, y) and a tree on the residual yhat - y
#' @keywords internal
partLm <- function(x1, y1,
                   alpha = .1,
                   lambda = 1,
                   lambda.seq = NULL,
                   part.minsplit = 2,
                   part.xval = 0,
                   part.max.depth = 1,
                   part.cp = 0,
                   part.minbucket = 5,
                   minobsinnode.lin = 5,
                   lin.type = "glmnet",
                   cv.glmnet.nfolds = 5,
                   which.cv.glmnet.lambda = "lambda.min",
                   verbose = TRUE,
                   trace = 0) {

  # [ PART ] ====
  dat <- data.frame(x1, y1)
  part <- rpart::rpart(y1 ~., dat,
                       control = rpart::rpart.control(minsplit = part.minsplit,
                                                      xval = part.xval,
                                                      maxdepth = part.max.depth,
                                                      minbucket = part.minbucket,
                                                      cp = part.cp))
  part.val <- predict(part)

  if (is.null(part$splits)) {
    if (trace > 0) msg("Note: rpart did not split")
    terminal <- TRUE
    cutFeat.name <- cutFeat.point <- cutFeat.category <- NULL
    split.rule <- NULL
    part.c.left <- part.c.right <- 0
    left.index <- right.index <- split.rule.left <- split.rule.right <- NULL
    lin.val.left <- lin.val.right <- 0
    lin.coef.left <- lin.coef.right <- rep(0, NCOL(x1) + 1)
  } else {
    if (part$splits[1, 2] == 1) {
      left.yval.row <- 3
      right.yval.row <- 2
    } else {
      left.yval.row <- 2
      right.yval.row <- 3
    }
    part.c.left <- part$frame$yval[left.yval.row]
    part.c.right <- part$frame$yval[right.yval.row]
    terminal <- FALSE
    cutFeat.name <- rownames(part$splits)[1]
    cutFeat.point <- cutFeat.category <- NULL
    if (!is.null(cutFeat.name)) {
      cutFeat.index <- which(names(x1) == cutFeat.name)
      if (is.numeric(x1[[cutFeat.name]])) {
        cutFeat.point <- part$splits[1, "index"]
        if (trace > 0) msg("Split Feature is \"", cutFeat.name,
                           "\"; Cut Point = ", cutFeat.point,
                           sep = "")
        split.rule.left <- paste(cutFeat.name, "<", cutFeat.point)
        split.rule.right <- paste(cutFeat.name, ">=", cutFeat.point)
      } else {
        cutFeat.category <- levels(x1[[cutFeat.name]])[which(part$csplit[1, ] == 1)]
        if (trace > 0) msg("Split Feature is \"", cutFeat.name,
                           "\"; Cut Category is \"", cutFeat.category,
                           "\"", sep = "")
        split.rule.left <- paste0(cutFeat.name, " %in% ", "c(", paste(cutFeat.category, collapse = ", "))
        split.rule.right <- paste0("!", cutFeat.name, " %in% ", "c(", paste(cutFeat.category, collapse = ", "))

      }

      if (length(cutFeat.point) > 0) {
        left.index <- which(x1[, cutFeat.index] < cutFeat.point)
        right.index <- seq(NROW(x1))[-left.index]
      } else {
        left.index <- which(is.element(x1[, cutFeat.index], cutFeat.category))
        right.index <- seq(NROW(x1))[-left.index]
      }
    }
  }

  # [ LIN ] ====
  resid <- y1 - part.val
  resid.left <- resid[left.index]
  resid.right <- resid[right.index]
  if (!is.null(cutFeat.name)) {
    if (is.constant(resid.left) | all(sapply(x1[left.index, , drop = FALSE], is.constant)) | length(resid.left) < minobsinnode.lin) {
      if (trace > 0) msg("Not fitting any more lines here")
      lin.val.left <- rep(0, length(left.index))
      lin.coef.left <- rep(0, NCOL(x1) + 1)
    } else {
      lin.coef.left <- lincoef(x1[left.index, , drop = FALSE], resid.left,
                                    method = lin.type,
                                    alpha = alpha, lambda = lambda, lambda.seq = lambda.seq,
                                    cv.glmnet.nfolds = cv.glmnet.nfolds,
                                    which.cv.glmnet.lambda = which.cv.glmnet.lambda)
      lin.val.left <- (data.matrix(cbind(1, x1[left.index, ])) %*% lin.coef.left)[, 1]
    } # if (is.constant(resid.left))

    if (is.constant(resid.right) | all(sapply(x1[right.index, , drop = FALSE], is.constant)) | length(resid.right) < minobsinnode.lin) {
      if (trace > 0) msg("Not fitting any more lines here")
      lin.val.right <- rep(0, length(right.index))
      lin.coef.right <- rep(0, NCOL(x1) + 1)
    } else {
      lin.coef.right <- lincoef(x1[right.index, , drop = FALSE], resid.right,
                               method = lin.type,
                               alpha = alpha, lambda = lambda, lambda.seq = lambda.seq,
                               cv.glmnet.nfolds = cv.glmnet.nfolds,
                               which.cv.glmnet.lambda = which.cv.glmnet.lambda)
      lin.val.right <- (data.matrix(cbind(1, x1[right.index, ])) %*% lin.coef.right)[, 1]
    } # if (is.constant(resid.right))

  } # if (!is.null(cutFeat.name))

  # [ Output ] ====
  list(lin.coef.left = lin.coef.left,
       lin.coef.right = lin.coef.right,
       part.c.left = part.c.left,
       part.c.right = part.c.right,
       lin.val.left = lin.val.left,
       lin.val.right = lin.val.right,
       part.val = part.val,
       cutFeat.name = cutFeat.name,
       cutFeat.point = cutFeat.point,
       cutFeat.category = cutFeat.category,
       left.index = left.index,
       right.index = right.index,
       split.rule = split.rule.left,
       # split.rule.i = split.rule.i,
       rule.left = split.rule.left,
       rule.right = split.rule.right,
       terminal = terminal)

} # rtemis::partLm


#' Predict method for \code{hytreeLite} object
#'
#' @method predict hytreenow
#' @param object \code{hytreenow}
#' @param newdata Data frame of predictors
#' @param n.feat [Internal use] Integer: Use first \code{n.feat} columns of newdata to predict.
#' Defaults to all
#' @param fixed.cxr [Internal use] Matrix: Cases by rules to use instead of matching cases to rules using
#' \code{newdata}
#' @param cxr.newdata [Internal use] Data frame: Use these values to match cases by rules
#' @param cxr Logical: If TRUE, return list which includes cases-by-rules matrix along with predicted values
#' @param cxrcoef Logical: If TRUE, return cases-by-rules * coefficients matrix along with predicted values
#' @param verbose Logical: If TRUE, print messages to console
#' @param trace Not used
#' @export
#' @author Efstathios D. Gennatas

predict.hytreenow <- function(object, newdata,
                              n.feat = NCOL(newdata),
                              fixed.cxr = NULL,
                              cxr.newdata = NULL,
                              cxr = FALSE,
                              cxrcoef = FALSE,
                              verbose = FALSE,
                              trace = 0, ...) {

  # [ newdata colnames ] ====
  if (is.null(colnames(newdata))) colnames(newdata) <- paste0("V", seq(NCOL(newdata)))

  # [ PREDICT ] ====
  newdata <- newdata[, seq(n.feat), drop = FALSE]
  rules <- plyr::ldply(object$rules)[, 1]
  if (is.null(fixed.cxr)) {
    cases <- if (is.null(cxr.newdata)) newdata else cxr.newdata
    .cxr <- matchCasesByRules(cases, rules, verbose = verbose)
  } else {
    .cxr <- fixed.cxr
  }

  coefs <- plyr::laply(object$coefs, c)
  # Match coefficients to each case by matrix multiplication
  # Each case only has "1" in .cxr for the corresponding leaf it belongs
  .cxrcoef <- .cxr %*% coefs
  # Add column of ones for intercept
  newdata <- data.matrix(cbind(1, newdata))
  yhat <- sapply(seq(NROW(newdata)), function(n)
    object$init + object$shrinkage * (newdata[n, ] %*% t(.cxrcoef[n, , drop = FALSE])))


  if (!cxrcoef & !cxr) {
    out <- yhat
  } else {
    out <- list(yhat = yhat)
    if (cxrcoef) out$cxrcoef <- .cxrcoef
    if (cxr) out$cxr <- .cxr
  }

  out

} # rtemis:: predict.hytreenow
