# Future IPK corresponding-source distribution

This workflow applies only to successful IPK builds completed after
`.github/workflows/future-source-distribution.yml` is merged into `main`.
It does not rebuild packages and does not modify existing releases or assets.

## What is generated

For each successful future `Build OpenRung OpenWrt IPK` run, the workflow:

1. Downloads that exact run's `openrung-openwrt-ipk` artifact.
2. Reads `SOURCE-INFO.txt` from the client IPK and requires its packaging
   commit to equal the build run's commit.
3. Verifies the client IPK contains its upstream `LICENSE`,
   `THIRD_PARTY_NOTICES.md`, distributor addendum, and exact source metadata.
   It also checks the notices contain no unresolved distributor placeholders.
4. Verifies the exact packaging and upstream source archives produced by the
   build workflow.
5. Runs `go mod vendor` against the exact upstream source snapshot and checks
   that the selected Linux amd64 client resolves using the same build tags.
6. Creates a separate vendor-inclusive corresponding-source archive, while
   retaining the original upstream source archive unchanged.
7. Publishes a 90-day Actions artifact containing the exact packaging source,
   exact upstream source, vendor-inclusive source, license texts, third-party
   notices, distributor addendum, build metadata, IPK checksums, and source
   SHA256 manifests.

The source artifact name includes the exact upstream commit. Its
`SOURCE-MANIFEST.txt` records both exact commits, target platform, Go
toolchain, build tags, and vendored module counts.

## Publishing with a future Release

The existing IPK workflow deliberately separates building from Release
publication. This source workflow therefore creates a matching Actions
artifact; it does not attach files to or overwrite the existing
`openwrt-latest` Release.

When publishing a future IPK build as a GitHub Release, attach the complete
contents of that build's `openrung-corresponding-source-<upstream-commit>`
Actions artifact to the *same* Release as the matching IPKs. Do not attach a
source artifact from another run, and do not replace the source for an older
binary with the current branch archive.

## Preservation boundary

- Historical Build #24 run `44885434847` is explicitly excluded.
- This workflow never runs the IPK build command.
- It never writes to, deletes, or replaces an IPK, tag, Release, or historical
  Actions artifact.
- It does not change the existing `openwrt-latest` Release.
- The original source snapshots are retained byte-for-byte; only the separate
  vendor-inclusive archive is generated.

A passing workflow confirms that the listed source, notice, and checksum
files exist and match the recorded revisions. It is not a legal opinion or a
substitute for manual review of dependency-specific license conditions.
