# figureS1_spaghetti_s6.R ------------------------------------------------------
# SI figure: within-person slopes, Study 6.
#
# Each participant (N = 972) contributes two points -- their mean trust
# in the sacred vignettes and their mean trust in the non-sacred vignettes,
# averaged across all five foundation vignette types. Lines connect them.
# The density of upward slopes makes the individual-level consistency of the
# sacred-value trust effect immediately legible.
#
# Output: Figures/figureS1_spaghetti_s6.pdf  (+.png at 300 dpi)
# Run from project root:  Rscript scripts/R/figureS1_spaghetti_s6.R
# ------------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
  library(tidyr)
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

# --- load Study 6 long data -------------------------------------------------
d6 <- read_sav(file.path(ROOT, "osf",
  "Study 6 - Sacralization of Moral Foundations",
  "OSF SV Trust - Study 6 Long Dataset.sav")) |>
  filter(Exclusions == 0) |>
  mutate(
    SV_Condition    = as.integer(SV_Condition),
    Trustworthiness = as.numeric(Trustworthiness),
    Participant_ID  = as.character(Participant_ID)
  )

# --- per-person means by condition ------------------------------------------
# Average trust across all 5 foundation vignette types within each condition.
person_means <- d6 |>
  group_by(Participant_ID, SV_Condition) |>
  summarise(mean_trust = mean(Trustworthiness, na.rm = TRUE), .groups = "drop") |>
  mutate(
    condition = factor(SV_Condition, levels = c(0L, 1L),
                       labels = c("Non-sacred", "Sacred"))
  )

# Grand means + 95% CI for overlay
grand <- person_means |>
  group_by(condition) |>
  summarise(
    m  = mean(mean_trust, na.rm = TRUE),
    se = sd(mean_trust, na.rm = TRUE) / sqrt(sum(!is.na(mean_trust))),
    .groups = "drop"
  ) |>
  mutate(lo = m - 1.96 * se, hi = m + 1.96 * se)

# Condition means for the delta annotation
delta <- diff(grand$m)

# --- plot -------------------------------------------------------------------
# Line colour: grey-blue for individual slopes; crimson for grand mean.
IND_COL  <- "#546E7A"
MEAN_COL <- "#C62828"

p <- ggplot(person_means,
            aes(x = condition, y = mean_trust, group = Participant_ID)) +
  # Individual slopes -- very thin and transparent to avoid overplotting
  geom_line(alpha = 0.07, colour = IND_COL, linewidth = 0.35) +
  geom_point(alpha = 0.09, colour = IND_COL, size = 0.7) +
  # Grand-mean line
  geom_line(data = grand, aes(x = condition, y = m, group = 1),
            colour = MEAN_COL, linewidth = 1.8, inherit.aes = FALSE) +
  # Grand-mean error bars
  geom_errorbar(data = grand,
                aes(x = condition, ymin = lo, ymax = hi, group = 1),
                colour = MEAN_COL, width = 0.06, linewidth = 1.1,
                inherit.aes = FALSE) +
  geom_point(data = grand, aes(x = condition, y = m),
             colour = MEAN_COL, size = 4.5, inherit.aes = FALSE) +
  # Delta annotation
  annotate("segment",
           x = 2.08, xend = 2.08,
           y = grand$m[grand$condition == "Non-sacred"],
           yend = grand$m[grand$condition == "Sacred"],
           colour = MEAN_COL, linewidth = 0.8,
           arrow = grid::arrow(ends = "both", length = grid::unit(0.06, "inches"))) +
  annotate("text",
           x = 2.18,
           y = mean(grand$m),
           label = sprintf("Delta = %.1f pts", delta),
           colour = MEAN_COL, fontface = "bold", size = 3.5, hjust = 0) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 25),
                     expand = expansion(mult = c(0.02, 0.02))) +
  scale_x_discrete(expand = expansion(add = c(0.3, 0.7))) +
  labs(
    title   = "Within-person trust slopes, Study 6 (N = 972)",
    subtitle = paste0(
      "Each line = one participant's mean trust across all five foundation vignettes. ",
      "Red = grand mean +/- 95% CI."
    ),
    x = NULL,
    y = "Mean trustworthiness (0-100)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor   = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.text.x        = element_text(size = 12, face = "bold"),
    axis.title.y       = element_text(margin = margin(r = 8)),
    plot.subtitle      = element_text(colour = "grey40", size = 9.5)
  )

# --- save -------------------------------------------------------------------
ggsave(file.path(OUT_DIR, "figureS1_spaghetti_s6.pdf"),
       plot = p, width = 5, height = 5, device = "pdf")

ggsave(file.path(OUT_DIR, "figureS1_spaghetti_s6.png"),
       plot = p, width = 5, height = 5, dpi = 300)

cat("Saved: Figures/figureS1_spaghetti_s6.pdf and .png\n")
