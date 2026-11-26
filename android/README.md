# OpenRung Android

Android companion client developed in this repository. This project is separate from the OpenWrt package build but shares the repository and release location.

## Planned modes

- Local proxy: expose configurable loopback HTTP and SOCKS5 listeners; no Android VPN interface.
- VPN: Android `VpnService` routes device traffic into the OpenRung Android data plane.
- Shared node management and connection status.

## Important implementation boundary

The current OpenWrt package builds a Linux amd64 CLI. That executable is not an Android ARM binary and must not be bundled into the Android app. The Android data plane must be built for Android ABIs and integrated through a supported library/API or a dedicated Android build of the upstream core.

The initial Android scaffold is not yet a functional proxy/VPN client. VPN permission/service scaffolding does not itself provide packet forwarding. Do not publish it as a usable release until both data paths, node configuration, lifecycle handling, and device tests pass.

## Build

The Android workflow builds a debug APK for early CI validation. A signed release requires repository Actions secrets for the Android signing keystore and credentials; never commit signing material.
