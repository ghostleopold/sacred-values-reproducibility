# TODO

## s3-religiosity: switch trustworthiness measure to Wor_agg_avg (opened 2026-08-09)

`SI.md` table `s3-religiosity` currently reports trustworthiness-in-game-1
figures computed from `Wor_pre` (the trustee's realized return at the
investment level the paired investor actually chose). Decision: switch to
`Wor_agg_avg` (mean of `Wor_pre_avg` and `Wor_post_avg`, averaged across both
games) — it carries the same signal as the game-1-only measure with less
noise, per the main text's own reasoning for preferring it there.

Edited: `data/Study 3 - Lab Study/Replication Documentation/Processing and
Analysis/Legacy Stata processing (superseded)/hypothesis 1 - other
results.do`, "Are religious people more trustworthy?" block — `Wor_pre` swapped
for `Wor_agg_avg` in all three `summarize`/`ranksum` calls. See the `TODO(...)`
comment inline.

**Caveat: this .do file is not git-tracked.** `data/` is a symlink to
`~/Downloads/osfstorage-archive (2)` and is gitignored in this repo. The edit
exists only on disk at that path — back it up or copy it somewhere durable
before it can be lost (e.g. Downloads folder cleanup).

**Remaining steps:**

1. [ ] Run the edited `.do` file in Stata; record the new group means and
       ranksum z/p for all three religiosity splits (affiliation, belief in
       God, religion-is-sacred).
2. [ ] Revise SI table `s3-religiosity` in `SI.md` (main PNAS repo) with the
       confirmed `Wor_agg_avg` figures, and update the row label from
       "Trustworthiness in initial game" to something reflecting the
       both-games measure (e.g. "Trustworthiness (both games, averaged)").
3. [ ] Once (1)-(2) are confirmed, update `reproducibility_study_3.Rmd`'s
       `si-religiosity` chunk: drop the reconstructed-`Wor_pre` block, compute
       the `Trustworthy` column from `Wor_agg_avg` (trustee-restricted, as the
       `Trust received` column already is) instead, and rewrite the
       "Descriptive flag" callout to report full, unqualified reproduction
       rather than a resolved-but-noteworthy residual.
