# figureS2_halo_grid_s6.R ------------------------------------------------------
# SI figure: the within-block moral halo (Study 6), as an "unfolded" Figure 3A.
#
# Figure 3A (figure_coefplot_s4_s5_s6.R, Panel A) shows ONE Study 6 row of a-path
# coefficients -- the sacred condition's effect on perceived sacralization of each
# foundation, pooled over vignette blocks. This figure unfolds that single row into
# FIVE sub-rows, one per vignette block, to show the halo holds block by block. Same
# idiom as the parent: horizontal coefficient plot, colour-coded foundations, a
# dashed zero reference, faceted ncol = 1. The one addition is a black ring marking
# each block's own (targeted) foundation -- the diagonal of the 5x5 halo grid.
#
# Metric: standardized coefficient (beta). Within a block the design is
# between-subjects (each participant contributes one row), so the standardized simple
# regression coefficient of a 0-1 sacralization score on the binary sacred condition
# equals the point-biserial correlation -- the single-level analog of the parent
# figure's standardized a-path. 95% CIs are the Fisher-z intervals from cor.test.
#
# Output: Figures/figureS2_halo_grid_s6.pdf  (+.png at 300 dpi)
# Run from project root:  Rscript scripts/R/figureS2_halo_grid_s6.R
# ------------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
  library(ggplot2)
})

set.seed(20260629)

# --- paths ------------------------------------------------------------------
find_root <- function(start = getwd(), marker = "osf") {
  d <- normalizePath(start, winslash = "/", mustWork = FALSE)
  repeat {
    if (dir.exists(file.path(d, marker))) return(d)
    parent <- dirname(d)
    if (identical(parent, d)) stop("Cannot locate 'osf/' from ", start)
    d <- parent
  }
}

ROOT    <- find_root()
OUT_DIR <- file.path(ROOT, "Figures")
dir.create(OUT_DIR, showWarnings = FALSE, recursive = TRUE)

# --- palette + foundation order (identical to the parent figure) ------------
FOUNDATIONS <- c("Harm", "Fairness", "Authority", "Loyalty", "Purity")
FND_COLS <- c(
  Harm      = "#C62828",
  Fairness  = "#1565C0",
  Authority = "#6A1B9A",
  Loyalty   = "#2E7D32",
  Purity    = "#E65100"
)
MEDS <- c(Harm = "Harm_Sacred_Prop", Fairness = "Fair_Sacred_Prop",
          Authority = "Auth_Sacred_Prop", Loyalty = "Loya_Sacred_Prop",
          Purity = "Pure_Sacred_Prop")

# --- load Study 6 long data -------------------------------------------------
d6 <- read_sav(file.path(ROOT, "osf",
  "Study 6 - Sacralization of Moral Foundations",
  "OSF SV Trust - Study 6 Long Dataset.sav")) |>
  filter(Exclusions == 0)

d6$FVcode       <- as.numeric(as.character(as_factor(d6$FoundationVignette)))
d6$SV_Condition <- as.numeric(d6$SV_Condition)
for (v in MEDS) d6[[v]] <- as.numeric(d6[[v]])
d6$Block <- factor(d6$FVcode, levels = 1:5,
                   labels = c("Harm", "Fairness", "Authority", "Loyalty", "Purity"))

# --- self-verify the block -> foundation mapping (see reproducibility_study_6.Rmd) --
# FoundationVignette carries no value labels; the mapping is recovered from the
# per-participant assignment columns and asserted here so a mislabelling fails loudly.
decode01 <- function(x) { s <- as.character(as_factor(x)); ifelse(grepl("NSV", s), 0L, ifelse(grepl("SV", s), 1L, NA_integer_)) }
assign01 <- sapply(FOUNDATIONS, function(f) decode01(d6[[f]]))
agree    <- sapply(FOUNDATIONS, function(f) tapply(assign01[, f] == d6$SV_Condition, d6$FVcode, mean, na.rm = TRUE))
stopifnot("Block->foundation mapping is not the assumed 1..5 = Harm,Fair,Auth,Loya,Pure" =
          identical(colnames(agree)[apply(agree, 1, which.max)], FOUNDATIONS))

# --- standardized a-path (point-biserial r) per block x foundation ----------
rows <- list()
for (bl in FOUNDATIONS) {
  sub <- d6[d6$Block == bl, ]
  for (fnd in FOUNDATIONS) {
    ct <- cor.test(sub$SV_Condition, sub[[MEDS[[fnd]]]])   # standardized beta = point-biserial r
    rows[[length(rows) + 1]] <- data.frame(
      block      = bl,
      foundation = fnd,
      beta       = unname(ct$estimate),
      lo         = ct$conf.int[1],
      hi         = ct$conf.int[2],
      own        = identical(bl, fnd),
      sig        = ct$conf.int[1] > 0 | ct$conf.int[2] < 0
    )
  }
}
halo <- dplyr::bind_rows(rows) |>
  mutate(
    foundation = factor(foundation, levels = rev(FOUNDATIONS)),
    block      = factor(block, levels = FOUNDATIONS,
                        labels = paste0(FOUNDATIONS, " vignette"))
  )

cat(sprintf("Cells: %d | all positive: %s | all sig: %s | beta range %.2f-%.2f\n",
            nrow(halo), all(halo$beta > 0), all(halo$sig), min(halo$beta), max(halo$beta)))

# --- plot: unfolded Figure 3A ------------------------------------------------
xmax <- max(halo$hi)
p <- ggplot(halo, aes(x = beta, y = foundation, colour = foundation)) +
  geom_vline(xintercept = 0, colour = "grey70", linewidth = 0.4, linetype = "dashed") +
  geom_errorbar(aes(xmin = lo, xmax = hi), width = 0.22, linewidth = 0.65) +
  geom_point(size = 2.8) +
  # ring the block's own (targeted) foundation -- the diagonal of the halo grid
  geom_point(data = dplyr::filter(halo, own),
             shape = 21, fill = NA, colour = "grey15", size = 4.3, stroke = 0.9) +
  scale_colour_manual(values = FND_COLS) +
  scale_x_continuous(expand = expansion(mult = c(0.02, 0.10))) +
  coord_cartesian(xlim = c(0, xmax * 1.06)) +
  facet_wrap(~block, ncol = 1) +
  labs(
    title    = "Sacralization of foundations, within each vignette block (Study 6)",
    subtitle = "Unfolds the Study 6 row of Fig. 3A; open ring marks the block's targeted foundation",
    x = "Standardized coefficient (95% CI)", y = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_blank(),
    strip.text         = element_text(face = "bold", size = 9.5, hjust = 0,
                                       margin = margin(b = 3)),
    axis.title.x       = element_text(size = 9, colour = "grey30", margin = margin(t = 6)),
    axis.text.y        = element_text(colour = FND_COLS[rev(FOUNDATIONS)],
                                      face = "bold", size = 9.5),
    plot.title         = element_text(face = "bold", size = 11),
    plot.subtitle      = element_text(colour = "grey40", size = 8.5),
    legend.position    = "none"
  )

# --- save (ASCII labels only, matching the parent figure -> base pdf device) --
ggsave(file.path(OUT_DIR, "figureS2_halo_grid_s6.pdf"), plot = p,
       width = 6.2, height = 8.6, device = "pdf")
ggsave(file.path(OUT_DIR, "figureS2_halo_grid_s6.png"), plot = p,
       width = 6.2, height = 8.6, dpi = 300)

cat("Saved: Figures/figureS2_halo_grid_s6.pdf and .png\n")
