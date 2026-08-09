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

`data/` is now a real, git-ignored folder inside this repo (2026-08-09
consolidation — see below), so this edit is Dropbox-backed even though it's
still outside git; the earlier "only exists on disk in Downloads" risk no
longer applies.

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

## Data consolidation (done 2026-08-09)

`data/` was a symlink to `~/Downloads/osfstorage-archive (2)`, one of four+
drifting local copies of the OSF archive scattered across Dropbox and
Downloads (see the file-hygiene audit that day). Replaced with a real,
git-ignored `data/` folder inside this repo, rebuilt from the newest clean
download (`ju9rq-osfstorage-archive`, Jul 27), with today's `Wor_pre` ->
`Wor_agg_avg` Stata edit carried forward. All four notebooks re-rendered
clean against the new folder; Study 3's audit summary unchanged (37 claims,
0 DIFFERS). The old in-Dropbox `osfstorage-archive/` (an older,
pre-reorganization vintage) was moved to `Sacred Values
Experiment/_archive/osfstorage-archive-2026-06-19-superseded/`, not deleted.
