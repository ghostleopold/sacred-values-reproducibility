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

`data/` at the repo root is a real, git-ignored folder — not a symlink — holding the
OSF project's six `Study 1 …` – `Study 6 …` folders. The notebooks and scripts locate
it automatically by walking up the directory tree for that `data/` folder, so no
manual setup is needed once it's in place. It is deliberately kept out of GitHub via
`.gitignore` rather than out of Dropbox: it lives inside this repo's own folder so
there's exactly one copy, backed up the same way as everything else here.

If you're setting this up fresh (e.g. on a new machine): download the whole OSF
project (osf.io/ju9rq) and copy its six `Study 1 …` – `Study 6 …` folders into
`data/` at this repo's root. Don't copy the OSF project's own `Analysis code and
reproducibility/` folder into `data/` — that's a stale bundled snapshot of this same
code; the notebooks in this repo are authoritative.

**Do not rename the `data/` folder, the study folders, or the data files.** The
scripts reference them by exact name and path; renaming will break the reproduction.

For pushing a refreshed copy of this code back to OSF, see
`../scripts/build_osf_staging.sh` and `../scripts/osf_upload.sh` in the parent
`PNAS version/` repo — they rebuild and upload the OSF-side `Analysis code and
reproducibility/` folder from this repo on demand, rather than keeping a
manually-maintained copy in sync.

## Which file feeds which study

- **Studies 1, 2, 4, 5, 6** read the SPSS `.sav` files in each study folder.
- **Study 3** reads three analysis-ready Stata `.dta` files (`combined-ult-trust-withfactors.dta`, `trust-combined.dta`, `combined-ult-trust-means.dta`), which are the cleaned datasets. The raw oTree session data and the original Stata build scripts are archived alongside, under the Study 3 folder, for provenance; they are not needed to run these notebooks.

## Requirements

A recent version of R, plus `knitr` and `rmarkdown` to knit the notebooks. The authoritative dependency list for any given notebook is its `packages` chunk, at the top of the file; the standalone scripts likewise load what they need in their opening lines. Across all of them the third-party packages are `car`, `coin`, `dplyr`, `effectsize`, `ggplot2`, `haven`, `lavaan`, `lme4`, `lmerTest`, `mgcv`, `tibble`, and `tidyr`. No notebook needs all twelve. Each prints its session information at the end, so the exact environment that produced the rendered `.html` can be checked.
