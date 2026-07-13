# Figure 1: Trust distributions, Studies 1 & 2
# Two-panel violin plot replacing the mediation path diagram.
# Output: Figures/figure1_violin_s1_s2.pdf  (+ .png at 300 dpi)

suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
  library(ggplot2)
})

set.seed(20260619)

# --- data root ----------------------------------------------------------
find_data_root <- function(start = getwd(), marker = "osf") {
  d <- normalizePath(start, winslash = "/", mustWork = FALSE)
  repeat {
    if (dir.exists(file.path(d, marker))) return(d)
    parent <- dirname(d)
    if (identical(parent, d)) stop("Cannot locate 'osf/' from ", start)
    d <- parent
  }
}

DATA_DIR <- file.path(find_data_root(), "osf")
OUT_DIR  <- file.path(find_data_root(), "Figures")

composite <- function(df, items) {
  rowMeans(sapply(items, function(v) as.numeric(df[[v]])), na.rm = TRUE)
}

# Shared condition levels for both studies -- study-specific details go in
# the strip title so the fill scale stays clean (exactly 2 levels).
COND_LEVELS <- c("Non-sacred", "Sacred")
COND_COLORS <- c("Non-sacred" = "#9aa0a6", "Sacred" = "#1a73e8")

# --- Study 1 ------------------------------------------------------------
s1_raw <- read_sav(file.path(DATA_DIR, "Study 1 - Sacred Ring",
                              "OSF SV Trust - Study 1.sav")) %>%
  filter(Exclusion == 0)

s1 <- s1_raw %>%
  mutate(
    study = "(A)  Study 1 – wedding ring",
    x     = as.integer(as_factor(Condition) == "Sacred"),
    cond  = factor(ifelse(x == 1, "Sacred", "Non-sacred"), levels = COND_LEVELS),
    trust = composite(s1_raw, paste0("Trust_Att_", 1:6))
  ) %>%
  select(study, cond, trust)

# --- Study 2 ------------------------------------------------------------
s2_raw <- read_sav(file.path(DATA_DIR, "Study 2 - Pork Investment",
                              "OSF SV Trust - Study 2.sav")) %>%
  filter(Exclusions == 0)

s2 <- s2_raw %>%
  mutate(
    study = "(B) Study 2 – Islamic taboo investment",
    x     = as.numeric(Cond_01),
    cond  = factor(ifelse(x == 1, "Sacred", "Non-sacred"), levels = COND_LEVELS),
    trust = composite(s2_raw, paste0("Trust_Att_", 1:6))
  ) %>%
  select(study, cond, trust)

d <- bind_rows(s1, s2)
d$study <- factor(d$study, levels = c(
  "(A)  Study 1 – wedding ring",
  "(B) Study 2 – Islamic taboo investment"
))

# --- plot ---------------------------------------------------------------
p <- ggplot(d, aes(x = cond, y = trust, fill = cond)) +
  geom_violin(alpha = 0.45, colour = NA, width = 0.85, trim = TRUE) +
  geom_jitter(width = 0.07, height = 0, alpha = 0.20, size = 0.75,
              colour = "grey30") +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 4,
               fill = "white", colour = "black", stroke = 0.8) +
  scale_fill_manual(values = COND_COLORS, guide = "none") +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 25)) +
  facet_wrap(~ study) +
  labs(x = NULL, y = "Trustworthiness attribution (0-100)") +
  theme_minimal(base_size = 12) +
  theme(
    strip.text         = element_text(face = "bold", size = 10.5, hjust = 0),
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    axis.text.x        = element_text(size = 11),
    axis.title.y       = element_text(margin = margin(r = 8))
  )

# --- save ---------------------------------------------------------------
ggsave(file.path(OUT_DIR, "figure1_violin_s1_s2.pdf"),
       plot = p, width = 7, height = 3.8, device = "pdf")

ggsave(file.path(OUT_DIR, "figure1_violin_s1_s2.png"),
       plot = p, width = 7, height = 3.8, dpi = 300)

cat("Saved to Figures/figure1_violin_s1_s2.pdf and .png\n")
