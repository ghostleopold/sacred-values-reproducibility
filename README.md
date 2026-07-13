# Analysis code & reproducibility

These R notebooks reproduce every statistic, table, and figure reported in *Sacred values as index signals of trustworthy character* and its Supporting Information, from the archived study data. They are the definitive analysis for the paper. A living copy is maintained at https://github.com/ghostleopold/sacred-values-reproducibility.

## Contents

Notebooks (each with its rendered `.html`):

- `reproducibility_studies_1-2.Rmd` (+ `.html`) — Studies 1 and 2
- `reproducibility_study_3.Rmd` (+ `.html`) — Study 3, the trust game
- `reproducibility_studies_4-5.Rmd` (+ `.html`) — Studies 4 and 5
- `reproducibility_study_6.Rmd` (+ `.html`) — Study 6

The rendered `.html` reports let you read the full output, including all tables and figures, without installing anything or running the code.

`scripts/R/` holds the supporting scripts:

- `collinearity_helpers.R` — variance-inflation helpers **sourced** by the Studies 4–5 and Study 6 notebooks. Required to knit them.
- `07_collinearity_diagnostic.R` — standalone collinearity diagnostic (reads the raw data, sources `collinearity_helpers.R`).
- `figure1_violin_s1_s2.R`, `figureS1_spaghetti_s6.R`, `figureS2_halo_grid_s6.R`, `study3_investor_binary_violin.R`, `study3_partials_figure.R` — regenerate individual paper and SI figures directly from the archived data. Each is self-contained; run them the same way as the notebooks (see below). These figures are also embedded in the rendered notebook `.html`.

## Data layout the scripts expect

The notebooks and scripts locate the data by walking up the directory tree for a folder named `osf/`. To run them:

1. Download the six study-data folders from this OSF project (the `Study 1 …` – `Study 6 …` folders).
2. Put them, **with their names unchanged**, inside a folder named `osf/`.
3. Place that `osf/` folder beside the notebooks — i.e. inside this `Analysis code & reproducibility/` folder, as a sibling of `scripts/`.
4. Knit each `.Rmd`.

**Do not rename the data files or study folders.** The scripts reference them by exact name and path; renaming will break the reproduction.

## Which file feeds which study

- **Studies 1, 2, 4, 5, 6** read the SPSS `.sav` files in each study folder.
- **Study 3** reads three analysis-ready Stata `.dta` files (`combined-ult-trust-withfactors.dta`, `trust-combined.dta`, `combined-ult-trust-means.dta`), which are the cleaned datasets. The raw oTree session data and the original Stata build scripts are archived alongside, under the Study 3 folder, for provenance; they are not needed to run these notebooks.

## Requirements

A recent version of R with the packages named at the top of each notebook, including `haven`, `here`, the `tidyverse`, `lavaan`, and `mgcv`. Study 3's item-response factor analysis additionally uses `mirt`. Each notebook prints its session information so the exact environment can be checked.
