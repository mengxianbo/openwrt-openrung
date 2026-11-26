# Third-Party Notices

This repository packages or refers to software maintained by other projects. The copyright and license of each third-party component remain with their respective rightsholders. Nothing in this repository relicenses third-party software under the repository maintainer's copyright.

## Known upstream component

### OpenRung client

- Component: OpenRung client (`openrung-client`)
- Upstream project: https://github.com/openrung/openrung
- Source: built from the upstream project source at the exact commit recorded in each package's `SOURCE-INFO.txt`.
- License and copyright: see the upstream repository's `LICENSE`, `THIRD_PARTY_NOTICES.md`, and the license files shipped with the exact source snapshot used for the build.

The package build is intended to preserve the upstream license and third-party notices under `/usr/share/openrung/`. Check the actual package contents and the source snapshot for the authoritative notices applicable to a particular release.

## Other dependencies and platform components

The LuCI/OpenWrt environment, Go modules, vendored dependencies, build tools, and any other bundled or linked components may be governed by separate licenses. Their exact versions and applicable notices must be determined from the source snapshot, dependency manifests, vendor tree, package metadata, and files shipped with the relevant release.

For each release, maintainers and redistributors should:

1. Keep the original copyright and license files for every third-party component.
2. Include the complete third-party notices and license texts required by each component's license.
3. Record exact upstream commits, dependency versions, and source locations in the release's source archive and `SOURCE-INFO.txt`.
4. Avoid describing third-party components as original work of this repository's maintainer.
5. Check license compatibility before combining, modifying, or redistributing components.

## Release-specific accuracy

This file is a project-level index, not a complete bill of materials for every historical build. The package's own notice directory, `SOURCE-INFO.txt`, and exact corresponding source archive are authoritative for the components included in that particular build. If a release contains a component not listed here, its own license and notices still apply.
