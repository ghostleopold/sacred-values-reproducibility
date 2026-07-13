#!/usr/bin/env Rscript
# =============================================================================
# SI figure: Study 3 investor side, the categorical (binary) trust contrast.
# =============================================================================
# Graduated from explorations/study3_netrev_decomposition/R/binary_violin_fig2a.R
# (Tru_diff variant; see that exploration's README for the two-candidate compare).
#
# Draws the graduated main-text result -- investors' change in trust toward
# trustees who revealed >=1 sacred value (SacRev > 0) vs those who revealed only
# tradeable values (SacRev == 0) -- as a violin plot in the idiom of Figure 1
# (scripts/R/figure1_violin_s1_s2.R). DV is Tru_diff, the change in the SHARE of
# the 4-unit endowment sent between Trust Game 2 (post-revelation) and Game 1.
#
# Output: Figures/study3_investor_binary_violin.pdf (+ .png at 200 dpi).
# Not part of the reproducibility audit -- produces a figure only.
#
# NOTE ON DISCRETENESS. Tru_diff moves in steps of 0.25, so jittered points band
# at the discrete levels (jitter is horizontal only, as in Figure 1); the violin's
# kernel density smooths across it. Read the diamond (group mean) as the headline.
# Base pdf()/png() devices only (no cairo on this machine) -> ASCII labels.
# -----------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
  library(ggplot2)
})
set.seed(20260709)

# --- locate data + output (osf symlink at repo root) ------------------------
find_root <- function(start = getwd(), marker = "osf") {
  d <- normalizePath(start, winslash = "/", mustWork = FALSE)
  repeat {
    if (dir.exists(file.path(d, marker))) return(d)
    parent <- dirname(d)
    if (identical(parent, d)) stop("Cannot locate 'osf/' from ", start)
    d <- parent
  }
}
REPO    <- find_root()
S3_DIR  <- file.path(REPO, "osf", "Study 3 - Lab Study",
                     "Replication Documentation", "Processing and Analysis", "Analysis Data")
FIG_DIR <- file.path(REPO, "Figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

# --- trustee frame + the binary revelation split ----------------------------
trustees <- read_dta(file.path(S3_DIR, "combined-ult-trust-withfactors.dta")) %>%
  filter(as_factor(treatment) == "trust", role_a_b == 2) %>%
  mutate(
    Tru_diff = as.numeric(Tru_diff),
    grp = factor(ifelse(SacRev > 0, "Revealed >=1\nsacred value",
                                    "Revealed only\ntradeable values"),
                 levels = c("Revealed only\ntradeable values",
                            "Revealed >=1\nsacred value"))
  )

n0 <- sum(trustees$SacRev == 0)
n1 <- sum(trustees$SacRev >  0)
cat(sprintf("Dyads: %d  (only-tradeable %d | some-sacred %d)\n", nrow(trustees), n0, n1))

# Colours mirror Figure 1: grey = tradeable/non-sacred, blue = sacred.
GRP_COLORS <- c("Revealed only\ntradeable values" = "#9aa0a6",
                "Revealed >=1\nsacred value"       = "#1a73e8")

p <- ggplot(trustees, aes(x = grp, y = Tru_diff, fill = grp)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey60", linewidth = 0.4) +
  geom_violin(alpha = 0.45, colour = NA, width = 0.85, trim = TRUE) +
  geom_jitter(width = 0.07, height = 0, alpha = 0.20, size = 0.75, colour = "grey30") +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 4,
               fill = "white", colour = "black", stroke = 0.8) +
  scale_fill_manual(values = GRP_COLORS, guide = "none") +
  scale_y_continuous(limits = c(-1, 1), breaks = seq(-1, 1, 0.5)) +
  labs(x = NULL, y = "Change in share of endowment sent\n(Game 2 - Game 1)") +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    axis.text.x        = element_text(size = 10.5, lineheight = 0.95),
    axis.title.y       = element_text(margin = margin(r = 8))
  )

ggsave(file.path(FIG_DIR, "study3_investor_binary_violin.pdf"), p, width = 4.2, height = 4.0)
ggsave(file.path(FIG_DIR, "study3_investor_binary_violin.png"), p, width = 4.2, height = 4.0, dpi = 200)

smry <- trustees %>% group_by(grp) %>%
  summarise(n = n(), mean_Tru_diff = mean(Tru_diff, na.rm = TRUE), .groups = "drop")
cat("\nGroup means:\n"); print(as.data.frame(smry), digits = 3, row.names = FALSE)
cat("\nWrote Figures/study3_investor_binary_violin.{pdf,png}\n")
