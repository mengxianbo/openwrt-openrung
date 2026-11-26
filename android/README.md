# OpenRung Android

Android companion client developed in this repository. It shares this repository with the OpenWrt package, while keeping its Gradle build and workflow separate.

## Scope: local proxy only

The Android client will expose a local HTTP and SOCKS5 proxy backed by the Android-compatible OpenRung data plane.

- No Android VPN permission or `VpnService`.
- No TUN interface and no device-wide traffic interception.
- Apps that support manual proxy configuration can connect to the local listener.
- The app will provide node import/management, node selection, start/stop, listener address and port, connection status, and logs.

## Core integration requirement

The OpenWrt package's Linux amd64 executable cannot run on Android ARM devices. The Android app must bundle or build a compatible Android engine for `arm64-v8a` and `armeabi-v7a`, and configure a local HTTP/SOCKS5 inbound that forwards through the OpenRung relay transport.

The current scaffold is not yet a functional proxy client. A successful Gradle build alone does not prove that proxy traffic works. Do not publish it as a usable release until the Android engine is integrated and both local proxy protocols are tested on real devices.

## Build

The Android workflow builds a debug APK for early UI/CI validation. A signed release requires repository Actions secrets for the Android signing keystore and credentials; never commit signing material.
