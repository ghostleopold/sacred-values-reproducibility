# 07_collinearity_diagnostic.R -----------------------------------------------
# Referee concern #2: are the five moral-foundation mediators discriminable, or
# is "Harm dominates" a partialling artifact of near-collinear predictors?
#
# For each of Studies 4-6 this reports, for the model trust ~ 5 foundations:
#   - zero-order r of each foundation with trust,
#   - the standardized partial (multiple-regression) beta -- a sign flip vs the
#     zero-order r is a suppression tell (the source of the negative indirect
#     effects the referee flagged),
#   - the VIF (collinearity; > ~5 = meaningful SE inflation),
#   - Johnson's relative weight and Budescu's general dominance, each as a share
#     of the model R2 (order-independent, suppression-free importance),
#   - a bootstrap 95% CI on the relative-weight share (cluster bootstrap on
#     participant for the within-subjects Study 6).
#
# Read-only: reads osf/ .sav files, writes only to scripts/R/_outputs/.
# Run from project root:  Rscript scripts/R/07_collinearity_diagnostic.R
# ---------------------------------------------------------------------------

suppressMessages({ library(haven) })

# Locate project root (dir containing the `osf` symlink), like the .Rmd pipelines.
find_data_root <- function(start = getwd(), marker = "osf") {
  d <- normalizePath(start, winslash = "/", mustWork = FALSE)
  repeat {
    if (dir.exists(file.path(d, marker))) return(d)
    parent <- dirname(d)
    if (identical(parent, d))
      stop("Could not locate the 'osf' data directory from ", start, call. = FALSE)
    d <- parent
  }
}
ROOT <- find_data_root()
source(file.path(ROOT, "scripts", "R", "collinearity_helpers.R"))

OUT <- file.path(ROOT, "scripts", "R", "_outputs")
dir.create(OUT, showWarnings = FALSE, recursive = TRUE)
sink(file.path(OUT, "collinearity_studies_4-6.txt"), split = TRUE)

cat("==========================================================\n")
cat(" DISCRIMINANT VALIDITY OF THE FIVE FOUNDATION MEDIATORS\n")
cat("   VIF + relative weights + general dominance (Studies 4-6)\n")
cat("   (referee concern #2: collinearity artifact check)\n")
cat("==========================================================\n")

LABELS <- c("Harm", "Fairness", "Authority", "Loyalty", "Purity")

report <- function(title, tab) {
  cat("\n----------------------------------------------------------\n")
  cat(title, "\n")
  cat(sprintf("Full-model R2 (trust ~ 5 foundations) = %.3f\n", attr(tab, "R2")))
  cat("----------------------------------------------------------\n")
  disp <- tab
  disp$RW_CI <- sprintf("[%.1f, %.1f]", disp$RW_lo, disp$RW_hi)
  disp$RW_lo <- disp$RW_hi <- NULL
  print(disp, row.names = FALSE)
}

results <- list()

# ---- Study 4 (between-subjects, N = 289) -----------------------------------
d4 <- read_sav(file.path(ROOT, "osf",
  "Study 4 - Pork Investment - Moral Character Mediation",
  "OSF SV Trust - Study 4.sav"))
d4 <- d4[d4$Exclusions == 0, ]
s4_meds <- c("Harm_SV", "Fair_SV", "Auth_SV", "Loya_SV", "Pure_SV")
for (v in c("Trust_Att", s4_meds)) d4[[v]] <- as.numeric(d4[[v]])
results$S4 <- collinearity_table(as.data.frame(d4), "Trust_Att", s4_meds, LABELS)
report("STUDY 4 (N = 289, between-subjects)", results$S4)

# ---- Study 5 (between-subjects, N = 288) -----------------------------------
d5 <- read_sav(file.path(ROOT, "osf",
  "Study 5 - Environmental Sacred Values", "OSF Study 5.sav"))
d5 <- d5[d5$Exclusion == 0, ]
s5_meds <- c("Never_Harm", "Never_Fair", "Never_Auth", "Never_InGrp", "Never_Pure")
for (v in c("Trust_Att", s5_meds)) d5[[v]] <- as.numeric(d5[[v]])
results$S5 <- collinearity_table(as.data.frame(d5), "Trust_Att", s5_meds, LABELS)
report("STUDY 5 (N = 288, between-subjects)", results$S5)

# ---- Study 6 (within-subjects; cluster bootstrap on participant) -----------
d6 <- read_sav(file.path(ROOT, "osf",
  "Study 6 - Sacralization of Moral Foundations",
  "OSF SV Trust - Study 6 Long Dataset.sav"))
d6 <- d6[d6$Exclusions == 0, ]
s6_meds <- c("Harm_Sacred_Prop", "Fair_Sacred_Prop", "Auth_Sacred_Prop",
             "Loya_Sacred_Prop", "Pure_Sacred_Prop")
for (v in c("Trustworthiness", s6_meds)) d6[[v]] <- as.numeric(d6[[v]])
d6$Participant_ID <- as.character(d6$Participant_ID)
results$S6 <- collinearity_table(as.data.frame(d6), "Trustworthiness", s6_meds,
                                 LABELS, cluster = "Participant_ID")
report("STUDY 6 (N = 972 participants; cluster bootstrap)", results$S6)

# ---- Machine-readable output -----------------------------------------------
tidy <- do.call(rbind, lapply(names(results), function(s) {
  t <- results[[s]]
  data.frame(Study = s, R2 = round(attr(t, "R2"), 3), t, row.names = NULL)
}))
write.csv(tidy, file.path(OUT, "collinearity_studies_4-6.csv"), row.names = FALSE)

cat("\nRW = Johnson relative weight (% of R2); Dominance = Budescu general\n")
cat("dominance (% of R2); both order-independent and summing to 100%.\n")
cat("VIF > ~5 flags meaningful SE inflation; r_trust vs beta_partial sign flip = suppression.\n")
cat(sprintf("\nWrote: %s\n", file.path(OUT, "collinearity_studies_4-6.csv")))
sink()
