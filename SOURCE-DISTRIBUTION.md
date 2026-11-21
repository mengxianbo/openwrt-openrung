# Build #24 corresponding source distribution

This document describes the separate source archive for the preserved stable Build #24.

## Exact revisions

- Historical GitHub Actions run: `44885434847`
- Packaging repository commit: `ea2385243c93440fcede94923a7f83477d27af70`
- Upstream OpenRung commit: `5cba4f0b9da642dcc9cc1904f861eb1d59c23a04`

## Distribution contents

The manually triggered workflow `OpenRung #24 Corresponding Source` creates a separate Actions artifact containing:

1. The packaging repository tree at the exact historical #24 commit.
2. The upstream OpenRung source tree at the exact pinned upstream commit, including Go dependency source generated with `go mod vendor`.
3. The upstream `LICENSE` and a distributor-rendered copy of `THIRD_PARTY_NOTICES.md`, with the two upstream distribution-specific placeholders filled in.
4. `DISTRIBUTION-NOTICE-ADDENDUM.md`, which records the distributor contact and exact upstream source location.
5. The repository license-scope document, dependency-audit scope, and this source-distribution notice.
6. A source manifest and SHA256 checksums for the source-distribution files.

The workflow checks the pinned revisions, verifies that the archives can be listed, verifies the vendored module inventory, and validates all SHA256 entries before uploading the artifact.

## Preservation boundary

This workflow is independent of the IPK build. It does not rebuild, replace, delete, or republish the stable #24 IPKs. It does not modify the historical #24 Actions run, the original IPK SHA256 values, or existing Release assets. The source artifact is uploaded separately to the workflow run and retained for 90 days.

The packaging and upstream source trees are kept distinct. See [LICENSES.md](LICENSES.md) for the repository's license-scope declarations. A source-presence check is not, by itself, a legal opinion that every third-party obligation has been satisfied.


## Upstream notice placeholder handling

The upstream source archive is an exact snapshot of commit
`5cba4f0b9da642dcc9cc1904f861eb1d59c23a04`; its original
`THIRD_PARTY_NOTICES.md` is not edited. In the separately distributed notice
copy only, the contact placeholder is filled with the repository Issues URL
and the public-source placeholder with the upstream repository URL. The
addendum explains this distributor-supplied completion. The source workflow
fails if either placeholder remains in the rendered copy.

## Dependency license audit

The target-specific Go dependency audit is defined in
[DEPENDENCY-LICENSE-AUDIT.md](DEPENDENCY-LICENSE-AUDIT.md). Its manual mode
defaults to the exact #24 upstream commit; after future successful package
builds, it runs automatically against the exact upstream commit embedded in
the resulting IPK. Its report is a separate Actions artifact and does not
modify or rebuild the package.
