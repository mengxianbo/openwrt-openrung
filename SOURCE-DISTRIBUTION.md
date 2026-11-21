# Build #24 corresponding source distribution

This document describes the separate source package for stable build #24.

## Pinned source revisions

- Packaging repository: `ea2385243c93440fcede94923a7f83477d27af70`
- Upstream OpenRung: `5cba4f0b9da642dcc9cc1904f861eb1d59c23a04`
- Historical stable build: GitHub Actions run `44885434847`

## What the workflow produces

The manually triggered workflow `OpenRung #24 Source Distribution` creates an independent artifact containing:

1. The packaging repository source archive at the exact #24 packaging commit.
2. The complete upstream source tree at the exact upstream commit, with Go module dependencies vendored from the pinned module graph.
3. The exact upstream LICENSE and THIRD_PARTY_NOTICES files.
4. `LICENSES.md`, this document, and `SOURCE-MANIFEST.txt`.
5. `SHA256SUMS-SOURCE` and a checksum for that checksum file.

The workflow verifies the archive contents and all SHA256 entries before uploading the artifact. It does not publish to the stable release and has no build or write permission for repository contents.

## Preservation boundary

The workflow does not run the IPK build, does not alter the #24 workflow run, does not replace the #24 IPK files, and does not change the historical `SHA256SUMS` for those IPKs. Source artifacts are retained separately as an Actions artifact.
