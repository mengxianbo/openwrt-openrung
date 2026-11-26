# License and source-disclosure guide

The project maintainer's copyright and redistribution policy is documented in [COPYRIGHT.md](COPYRIGHT.md). Third-party component boundaries and notice-preservation guidance are in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). The root [LICENSE](LICENSE) is the complete GPLv3 license text; the project's own original code is offered under GPL-3.0-or-later as stated below.

## License scope

The project permits both free and commercial redistribution. A distributor may charge for copies, firmware, installation, support, or warranty, but may not remove downstream GPL freedoms or withhold the corresponding source required by the license. See [GNU's GPL FAQ](https://www.gnu.org/licenses/gpl-faq.html#DoesTheGPLAllowMoney) for the distinction between charging for distribution and restricting recipients' rights.

- The packaging scripts, OpenWrt service integration, and LuCI management code maintained in this repository are released under **GNU GPL version 3 or (at your option) any later version (GPL-3.0-or-later)**.
- The root `LICENSE` file is the unmodified text of GNU GPL version 3. The "or later" grant for this repository's own code is stated in the project README and this file; it is not inferred merely from the license text.
- The `openrung-client` executable is built from the separately maintained `openrung/openrung` upstream repository. Its licensing, copyright notices, and additional terms are governed by that exact upstream revision. The client APK and IPK carry the upstream `LICENSE`, project `COPYRIGHT.md`, and distributor-ready `THIRD_PARTY_NOTICES.md` in `/usr/share/openrung/`.
- Third-party dependencies retain their own licenses. No license in this repository overrides or re-licenses those components.

## Source corresponding to a released client

For every APK/IPK build, the build workflow records the exact packaging-repository commit and exact OpenRung upstream commit in the client package's `SOURCE-INFO.txt`.

Each successful build's `openrung-openwrt-ipk` Actions artifact contains:

1. `openwrt-openrung-source-<packaging-commit>.tar.gz` — exact packaging repository source, including the scripts used to assemble the IPKs.
2. `openrung-upstream-source-<upstream-commit>.tar.gz` — exact upstream source snapshot, including `go.mod`, `go.sum`, and upstream notices.

For APK builds, the APK workflow creates and publishes its own exact packaging-source snapshot and vendor-inclusive upstream corresponding-source archive, together with SHA256 files. The APK package metadata links to that exact release asset.

For future successful builds after `.github/workflows/future-source-distribution.yml` is merged, that workflow automatically downloads the exact build artifact, reads and checks the IPK's `SOURCE-INFO.txt`, generates a vendor-inclusive corresponding-source archive from the exact upstream source snapshot using `go mod vendor`, verifies the target-specific Go package graph, and uploads a separate 90-day source artifact. The artifact includes the packaging and upstream source snapshots, vendor-inclusive source, license texts, third-party notices, distributor addendum, build manifest, original IPK checksums, and source SHA256 manifests. See [FUTURE-SOURCE-DISTRIBUTION.md](FUTURE-SOURCE-DISTRIBUTION.md).

Build #24 is historical and remains covered by the separate `OpenRung #24 Corresponding Source` and read-only `OpenRung License Compliance` workflows. The future-source workflow explicitly excludes the historical Build #24 run ID `44885434847`; it does not rebuild or alter #24.

The existing IPK build workflow deliberately separates building from Release publication. The future-source workflow does not upload files to or overwrite the existing `openwrt-latest` Release. When publishing a future IPK build as a GitHub Release, attach the complete contents of the corresponding source artifact generated from that same build run to the same Release as the matching IPKs. Never substitute a newer source snapshot for an older binary.

## Limits of automated checks

The automated workflows verify the tested license files, notices, commit identity, source archives, and presence of vendored dependency source. The Go dependency audit separately screens the exact Linux amd64 client dependency graph after successful APK and IPK builds.

These automated checks are not legal advice and do not replace a human review of each dependency's license, attribution, patent, trademark, or additional-term requirements. A passing workflow means the tested files and source bundle were present and internally matched; it is not a blanket legal certification.

## Target-specific Go dependency audit

The OpenWrt Linux amd64 client dependency graph is audited separately by
`.github/workflows/go-license-audit.yml`. The workflow uses the exact
upstream commit recorded in a successful APK or IPK build artifact, or accepts
an explicit upstream ref for a manual historical audit. It applies the same
`./cmd/client` target, `linux/amd64` platform, `CGO_ENABLED=0`, and
`with_utls,with_external_windivert` build tags as the package build.

The report artifact includes the compiled Go package list, module graph,
`go-licenses` CSV, collected license files, and tool logs. The workflow
blocks forbidden and unknown classifications. It does not blanket-block the
scanner's Restricted category because GPL copyleft code is intentionally part
of this project; Restricted entries must be reviewed license-by-license and
must not be assumed compatible solely because the build passes. This is a
screening control, not a substitute for manual review of copyright, NOTICE,
patent, trademark, additional terms, or non-Go/native components. See
[DEPENDENCY-LICENSE-AUDIT.md](DEPENDENCY-LICENSE-AUDIT.md).
