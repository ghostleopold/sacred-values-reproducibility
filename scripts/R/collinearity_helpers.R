# collinearity_helpers.R ------------------------------------------------------
# Discriminant-validity / relative-importance diagnostics for the five
# moral-foundation mediators (Studies 4-6). Addresses methods-referee concern #2
# ("Harm dominates may be a collinearity artifact"): the parallel-mediation
# b-paths partial shared variance among near-collinear mediators arbitrarily, so
# we corroborate the pathway ranking with order-independent, suppression-free
# decompositions -- Johnson's (2000) relative weights and Budescu's (1993)
# general dominance -- alongside VIFs that quantify the collinearity directly.
#
# Base R only (no car/relaimpo/rwa dependency); everything is derived from the
# predictor correlation matrix, so it is fast and transparent.
#
# Public entry point:
#   collinearity_table(df, ynm, xnms, labels, cluster = NULL, B = 5000, seed = 2024)
#     -> data.frame (one row per mediator) with columns
#        Foundation, r_trust (zero-order), beta_partial (std multiple-regression
#        coefficient; a sign flip vs r_trust is a suppression tell), VIF,
#        RW_pct (relative weight as % of model R2), Dominance_pct (general
#        dominance as % of R2), RW_lo / RW_hi (bootstrap 95% CI on RW_pct).
#        attr(., "R2") holds the full-model R2.
# ---------------------------------------------------------------------------

# R2 of Y on a subset of standardized predictors, from correlation matrices.
.r2_from_cor <- function(Rxx, rxy, idx) {
  if (length(idx) == 0L) return(0)
  as.numeric(t(rxy[idx]) %*% solve(Rxx[idx, idx, drop = FALSE]) %*% rxy[idx])
}

# Standardized multiple-regression coefficients (b-path analogues).
.std_betas <- function(Rxx, rxy) as.numeric(solve(Rxx) %*% rxy)

# Variance inflation factors = diagonal of the inverse correlation matrix.
.vifs <- function(Rxx) diag(solve(Rxx))

# Johnson's (2000) relative weights: epsilon_j sums to the model R2.
.relative_weights <- function(Rxx, rxy) {
  eig    <- eigen(Rxx, symmetric = TRUE)
  Lambda <- eig$vectors %*% diag(sqrt(pmax(eig$values, 0))) %*% t(eig$vectors)
  beta   <- solve(Lambda) %*% rxy
  as.numeric((Lambda^2) %*% (beta^2))
}

# Budescu (1993) general dominance: mean incremental R2 over all subset sizes.
.general_dominance <- function(Rxx, rxy) {
  p <- length(rxy); preds <- seq_len(p); gd <- numeric(p)
  for (j in preds) {
    others <- setdiff(preds, j)
    by_size <- numeric(p)                       # subsets of "others", sizes 0..p-1
    for (k in 0:(p - 1)) {
      combs <- if (k == 0) list(integer(0)) else combn(others, k, simplify = FALSE)
      inc   <- vapply(combs, function(S)
        .r2_from_cor(Rxx, rxy, c(S, j)) - .r2_from_cor(Rxx, rxy, S), numeric(1))
      by_size[k + 1] <- mean(inc)
    }
    gd[j] <- mean(by_size)
  }
  gd
}

collinearity_table <- function(df, ynm, xnms, labels = xnms,
                               cluster = NULL, B = 5000L, seed = 2024L) {
  df  <- df[stats::complete.cases(df[, c(ynm, xnms)]), , drop = FALSE]
  y   <- as.numeric(df[[ynm]])
  X   <- as.matrix(df[, xnms])
  Rxx <- stats::cor(X); rxy <- as.numeric(stats::cor(X, y))
  R2  <- .r2_from_cor(Rxx, rxy, seq_along(xnms))
  rw  <- .relative_weights(Rxx, rxy)
  gd  <- .general_dominance(Rxx, rxy)

  out <- data.frame(
    Foundation    = labels,
    r_trust       = round(rxy, 3),
    beta_partial  = round(.std_betas(Rxx, rxy), 3),
    VIF           = round(.vifs(Rxx), 2),
    RW_pct        = round(100 * rw / sum(rw), 1),
    Dominance_pct = round(100 * gd / sum(gd), 1),
    stringsAsFactors = FALSE
  )

  # Bootstrap 95% CI on the relative-weight shares. Ordinary resample for
  # between-subjects designs; cluster (participant) resample when `cluster` set.
  clu <- if (is.null(cluster)) NULL else as.character(df[[cluster]])
  idx_by_cluster <- if (is.null(clu)) NULL else split(seq_len(nrow(df)), clu)
  cluster_ids    <- names(idx_by_cluster)
  n <- nrow(df)

  set.seed(seed)
  bx <- matrix(NA_real_, B, length(xnms))
  for (b in seq_len(B)) {
    idx <- if (is.null(clu)) sample.int(n, replace = TRUE) else
      unlist(idx_by_cluster[sample(cluster_ids, length(cluster_ids), replace = TRUE)],
             use.names = FALSE)
    Xs <- X[idx, , drop = FALSE]; ys <- y[idx]
    Rb <- suppressWarnings(stats::cor(Xs))
    if (any(!is.finite(Rb))) next
    rwb <- tryCatch(.relative_weights(Rb, as.numeric(stats::cor(Xs, ys))),
                    error = function(e) rep(NA_real_, length(xnms)))
    bx[b, ] <- 100 * rwb / sum(rwb)
  }
  ci <- t(apply(bx, 2, stats::quantile, c(.025, .975), na.rm = TRUE))
  out$RW_lo <- round(ci[, 1], 1)
  out$RW_hi <- round(ci[, 2], 1)

  attr(out, "R2") <- R2
  out
}
