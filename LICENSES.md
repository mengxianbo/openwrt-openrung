# License declarations

This repository packages the OpenRung client and provides OpenWrt integration files.

## Upstream OpenRung client

The upstream source pinned for stable build #24 is:

- Repository: https://github.com/openrung/openrung
- Commit: `5cba4f0b9da642dcc9cc1904f861eb1d59c23a04`
- License text: the upstream `LICENSE` file at that exact commit.
- Third-party attribution: upstream `THIRD_PARTY_NOTICES.md` at that exact commit.

The exact upstream license text and third-party notices are distributed as separate source attachments and are also included in the OpenRung client IPK under `/usr/share/openrung/`.

## OpenWrt integration and packaging files

The packaging source pinned for stable build #24 is:

- Repository: https://github.com/mengxianbo/openwrt-openrung
- Commit: `ea2385243c93440fcede94923a7f83477d27af70`

The repository's integration and packaging files are separately identifiable from the upstream OpenRung client. This notice does not assert that every file in this repository has the same license as the upstream client. Any license for independently authored integration files must be confirmed by their respective copyright holder before a blanket license is declared.

## Distribution integrity

The #24 IPK files, their published SHA256 values, release assets, and historical workflow run are preserved. The corresponding-source workflow creates separate source archives and separate checksum files; it does not rebuild, replace, upload over, or otherwise modify the stable IPK assets.
