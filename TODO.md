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

**Done (2026-08-10):**

1. [x] Ran the edited `.do` file in Stata; recorded the new group means for all
       three religiosity splits (affiliation, belief in God, religion-is-sacred).
2. [x] Revised SI table `s3-religiosity` in `SI.md` with the confirmed
       `Wor_agg_avg` figures, relabelled the row "Trustworthiness over both
       phases", and split the *N* row into "N (all participants)" / "N
       (trustees)" — the trustworthiness and trust-received rows are
       trustee-restricted (121), the sacred-values row is not (242), so one *N*
       row could not serve both. Caption now says so.
3. [x] Updated `reproducibility_study_3.Rmd`'s `si-religiosity` chunk: dropped
       the reconstructed-`Wor_pre` block, computed `Trustworthy (both)` from
       `Wor_agg_avg` (trustee-restricted), added the second *N* column, and
       replaced the "Descriptive flag" callout with an unqualified
       reproduction note. All 30 table cells match the revised SI; audit
       unchanged at 37 claims / 0 DIFFERS.

**Still to do:** re-upload the archive to OSF (`scripts/osf_upload.sh` in the
manuscript repo) so the published `.do` file and rendered notebook match.

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
