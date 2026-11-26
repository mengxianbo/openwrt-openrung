OpenWrt OpenRung distribution notice addendum

This addendum supplies the distributor-specific contact and source-location details requested by the upstream THIRD_PARTY_NOTICES.md. The exact upstream source archive retains the upstream file unchanged; the notice copy shipped in the OpenWrt distribution fills only those two distribution-specific placeholder values.

Distributor / corresponding-source requests:
https://github.com/mengxianbo/openwrt-openrung/issues

Upstream project:
https://github.com/openrung/openrung

The exact upstream commit used for a particular client binary is recorded in SOURCE-INFO.txt in the installed package. Use that commit, not the current default branch, when obtaining corresponding source.

## Scope of this OpenWrt package

The OpenWrt packages in this repository contain the OpenRung Linux amd64
client built for the OpenWrt x86_64 target, the repository's LuCI integration,
and the service/configuration scripts listed in the matching package source
snapshot. The upstream third-party notice file is retained in full because
it is the upstream attribution record and may describe components used by
other upstream distribution targets as well.

A component mentioned in the upstream notice is not, by that mention alone,
asserted to be embedded in this OpenWrt package. Determine inclusion and
license obligations for a particular release from its exact upstream commit,
target-specific compiled Go package report, vendor source, package contents,
and corresponding-source archive. OpenWrt/LuCI platform packages are system
dependencies and are not represented as original project code.
