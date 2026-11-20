# AGENTS.md

## What this repository is

Docker images for QGIS Server (`camptocamp/qgis-server`, also a `-desktop` image), built
from the QGIS sources of the branch given by `QGIS_BRANCH` in the `Makefile`.

- `master`: builds QGIS `master` (development version).
- `<X.Y>-gdal<A.B>`: one stabilization branch per supported QGIS version, where `gdal<A.B>`
  is the GDAL version of the `ghcr.io/osgeo/gdal` base image used in the `Dockerfile`.

The Docker tags (`latest`, `lr`, `ltr`, `X.Y`, `X.Y-gdal<A.B>`, ...) are computed by
`tag-publish` from the `SECURITY.md` table (`Alternate Tag` column) of the version branch.

## Adding a new QGIS version (e.g. 4.4)

1. Check the upstream release exists: branch `release-4_4` and tag `final-4_4_0` (or later
   point release) in <https://github.com/qgis/QGIS>. `checkout_release` builds the last
   `final-4_4_*` tag found on the cloned branch.
2. Pull request on `master` titled `Add version 4.4`, label `chore`, updating `SECURITY.md`:
   - move the `lr, latest` alternate tags from the previous version row to the new
     `4.4-gdal3.13` row;
   - add the rows `4.4` (Best effort) and `4.4-gdal3.13` (Best effort,
     `4.4, lr, latest`, `Version based on Ubuntu 26.04`);
   - keep the `ltr` tag untouched, it is moved only when the release becomes the official
     LTR (see the [upstream roadmap](https://qgis.org/resources/roadmap/): a new LTR
     replaces the previous one in the LTR repositories only when the next LR is released);
   - let `pre-commit` (tool `prek`) reformat the Markdown table.
3. In parallel, no need to wait for the merge of the pull request, create the version branch:
   - `git worktree add --detach ...` from the current `master`, branch name `4.4-gdal3.13`;
   - set `QGIS_BRANCH = release-4_4` in the `Makefile`;
   - commit `Use QGIS branch 4.4` and push the branch;
   - create the signed annotated tag `4.4.0` (message `4.4.0`) on that commit and push the tag.
4. The CI (`.github/workflows/main.yaml`, triggered by the branch pattern
   `[0-9]+.[0-9]+-gdal[0-9]+.[0-9]+` and by tags) builds the images and publishes them with
   `tag-publish` (the publish job runs only if the build job succeeded).
5. Renovate's `baseBranchPatterns` and the GHCI backport labels are updated automatically
   from `SECURITY.md`, don't edit them manually.

## Build / CI gotchas

- A QGIS version bump can need new build or runtime dependencies: if the acceptance tests
  fail with `error while loading shared libraries: libQt6XXX.so.6`, add the matching apt
  package (e.g. `libqt6xml6`, `libqt6svg6`, `libqt6printsupport6`, `libqt6webenginecore6`)
  to the `runner` stage of the `Dockerfile`, on the version branch.
- The full build takes hours; never wait for it locally, let the CI run and check its status.
