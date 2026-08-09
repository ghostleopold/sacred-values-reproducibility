# Sacred values — reproducibility archive

Analysis code for *Sacred values as index signals of trustworthy character*. The
notebooks in `Analysis code and reproducibility/` reproduce every statistic, table, and
figure in the paper and its Supporting Information, and audit each computed value
against the number the paper prints.

This repository mirrors the layout of the OSF project it is published to
([osf.io/ju9rq](https://osf.io/ju9rq)) — two folders at the root, nothing else:

```
.
├── data/                              # the six Study 1 … Study 6 folders (not in git)
└── Analysis code and reproducibility/ # notebooks, rendered .html, scripts/
```

Keeping the two in the same shape means the code needs no rearranging to be published,
and a reader who downloads the OSF project gets a working tree with no setup at all.

## Getting the data

`data/` is **not in this repository** — the study files are large and belong to the OSF
archive, so `.gitignore` keeps them out of git. A fresh clone therefore can't run
anything until you add them:

1. Download the whole project from [osf.io/ju9rq](https://osf.io/ju9rq), keeping its
   folder structure intact.
2. Copy its six `Study 1 …` – `Study 6 …` folders into a `data/` folder at this repo's
   root.

Don't copy the OSF project's own `Analysis code and reproducibility/` folder over the
one here — the OSF copy is a published snapshot, and this repo is the living version.

Once `data/` is in place, see
[`Analysis code and reproducibility/README.md`](Analysis%20code%20and%20reproducibility/README.md)
for what each notebook covers, how to run them, and the package requirements.

## Notes for maintainers

- `TODO.md` tracks open analysis questions. It is a working note for this repository
  and is deliberately excluded when the code is published to OSF.
- Publishing to OSF is handled by `scripts/osf_upload.sh` in the parent `PNAS version/`
  manuscript repo. It uploads this repo's two folders directly, building a temporary
  filtered copy of the code folder (dropping knitr caches, `Figures/`, and git
  metadata) so nothing local leaks into the archive.
