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
3. The upstream `LICENSE` and `THIRD_PARTY_NOTICES.md`.
4. The repository license-scope document and this source-distribution notice.
5. A source manifest and SHA256 checksums for the source-distribution files.

The workflow checks the pinned revisions, verifies that the archives can be listed, verifies the vendored module inventory, and validates all SHA256 entries before uploading the artifact.

## Preservation boundary

This workflow is independent of the IPK build. It does not rebuild, replace, delete, or republish the stable #24 IPKs. It does not modify the historical #24 Actions run, the original IPK SHA256 values, or existing Release assets. The source artifact is uploaded separately to the workflow run and retained for 90 days.

The packaging and upstream source trees are kept distinct. See [LICENSES.md](LICENSES.md) for the repository's license-scope declarations. A source-presence check is not, by itself, a legal opinion that every third-party obligation has been satisfied.
