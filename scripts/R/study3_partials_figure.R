#!/usr/bin/env Rscript
# ============================================================================
# study3_partials_figure.R
# ----------------------------------------------------------------------------
# Main-text Figure 2: the Study-3 TRUSTWORTHINESS panel. Keeps the stiff
# (k = 3) REML GAM fit but DROPS the scatter cloud, so the vertical axis can
# zoom to the fitted curve and its 95% band -- making the relationship legible
# by eye.
#
# Single panel now. The investor-trust panel (Tru_diff ~ s(NetRev)) that this
# figure used to carry as panel A was retired from the main text: the graduated
# investor result is the binary revelation contrast, drawn as a violin and moved
# to the SI (scripts/R/study3_investor_binary_violin.R). What remains here is the
# preregistered, dose-response trustworthiness result:
#   Trustworthiness : Wor_agg_avg ~ s(SacPers, k = 3)   (sacred values held)
# exactly the g5_m1 smooth from the reproducibility audit (reproducibility_study_3.Rmd),
# nothing re-fit.
#
# Two artefacts are written:
#   _outputs/study3_partials_figure.png  -- diagnostic: title + F/p/edf on panel
#   Figures/study3_trustgame_partials.pdf -- manuscript: clean, no title, no
#       on-panel stats (the caption carries the numbers, matched to the text).
#
# This script is NOT part of the reproducibility audit -- it produces a figure
# only, and carries no audit targets.
# ============================================================================

suppressPackageStartupMessages({
  library(haven)    # read Stata .dta
  library(dplyr)    # data manipulation
  library(mgcv)     # GAMs (same engine as the audit)
  library(ggplot2)  # figure
})
set.seed(20260619)

## ---- locate data + repo (the 'osf' symlink sits in the repo root) ----------
find_root <- function(start = getwd(), marker = "osf") {
  d <- normalizePath(start, winslash = "/", mustWork = FALSE)
  repeat {
    if (dir.exists(file.path(d, marker))) return(d)
    parent <- dirname(d)
    if (identical(parent, d))
      stop("Could not locate the 'osf' data directory from ", start, call. = FALSE)
    d <- parent
  }
}
REPO    <- find_root()
S3_DIR  <- file.path(REPO, "osf", "Study 3 - Lab Study",
                     "Replication Documentation", "Processing and Analysis", "Analysis Data")
s3_file <- file.path(S3_DIR, "combined-ult-trust-withfactors.dta")
stopifnot("Study 3 analysis .dta not found" = file.exists(s3_file))

OUT_DIR <- file.path(REPO, "scripts", "R", "_outputs")
FIG_DIR <- file.path(REPO, "Figures")
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)
out_png <- file.path(OUT_DIR, "study3_partials_figure.png")
out_pdf <- file.path(FIG_DIR, "study3_trustgame_partials.pdf")

## ---- minimal prep: trust-game trustee frame --------------------------------
trustees <- read_dta(s3_file) %>%
  filter(as_factor(treatment) == "trust", role_a_b == 2)

## ---- the stiff (k = 3) smooth-only GAM for trustworthiness ------------------
g_worthy <- gam(Wor_agg_avg ~ s(SacPers, k = 3), data = trustees, method = "REML")

## ---- predicted curve + 95% band over the observed predictor range ----------
predict_band <- function(fit, xvar, n = 200) {
  x  <- fit$model[[xvar]]
  gx <- seq(min(x, na.rm = TRUE), max(x, na.rm = TRUE), length.out = n)
  nd <- setNames(data.frame(gx), xvar)
  pr <- predict(fit, nd, se.fit = TRUE)
  data.frame(x = gx, fit = pr$fit,
             lwr = pr$fit - 1.96 * pr$se.fit,
             upr = pr$fit + 1.96 * pr$se.fit)
}
rug_pts <- function(fit, xvar) {
  data.frame(x = fit$model[[xvar]][!is.na(fit$model[[xvar]])])
}
smooth_txt <- function(fit) {
  s <- summary(fit)$s.table[1, ]
  sprintf("F = %.2f   p = %s   edf = %.2f",
          s["F"], format.pval(s["p-value"], digits = 2, eps = 1e-3), s["edf"])
}

band <- predict_band(g_worthy, "SacPers")
rug  <- rug_pts(g_worthy, "SacPers")
# No-effect reference: the best flat line = mean predicted level.
y0   <- mean(band$fit)

## ---- base figure: curve + band only, axis zoomed, scatter removed ----------
p_base <- ggplot(band, aes(x, fit)) +
  geom_hline(yintercept = y0, linetype = "dashed", colour = "grey60", linewidth = 0.4) +
  geom_ribbon(aes(ymin = lwr, ymax = upr), fill = "#1a73e8", alpha = 0.18) +
  geom_line(colour = "#1a73e8", linewidth = 1) +
  geom_rug(data = rug, aes(x = x), inherit.aes = FALSE,
           sides = "b", colour = "#1a73e8", alpha = 0.45) +
  scale_y_continuous(expand = expansion(mult = 0.12)) +
  labs(x = "Sacred values held",
       y = "Proportion returned (trustworthiness)") +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank(),
        axis.title.y     = element_text(margin = margin(r = 8)))

## ---- diagnostic PNG: title + on-panel stats --------------------------------
p_png <- p_base +
  annotate("text", x = min(band$x), y = max(band$upr),
           label = smooth_txt(g_worthy), hjust = 0, vjust = 1,
           size = 3.3, colour = "grey25") +
  labs(title = "Study 3 -- trustworthiness on sacred values held (k = 3 GAM, scatter removed)",
       caption = paste("Line: GAM partial fit (k = 3, REML).  Band: 95% CI.",
                       "Dashed: no-effect reference (mean predicted level).",
                       "Ticks: observed predictor values.")) +
  theme(plot.title   = element_text(face = "bold"),
        plot.caption = element_text(colour = "grey45", hjust = 0))
ggsave(out_png, p_png, width = 5.2, height = 4.4, dpi = 200)

## ---- manuscript PDF: clean, no title, no on-panel stats --------------------
# Base pdf() device (cairo unavailable here); text is ASCII so it renders clean.
ggsave(out_pdf, p_base, width = 5.2, height = 4.4)

cat("Smooth (trustworthiness): ", smooth_txt(g_worthy), "\n")
cat("Wrote PNG: ", out_png, "\n")
cat("Wrote PDF: ", out_pdf, "\n")
