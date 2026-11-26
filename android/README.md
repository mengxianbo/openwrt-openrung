# OpenRung Android

Android companion client developed in this repository. It shares this repository with the OpenWrt package, while keeping its Gradle build and workflow separate.

## Selected capture mode: no TUN, local proxy

This Android variant deliberately does not use Android `VpnService`, a TUN interface, root privileges, or device-wide packet interception.

The intended traffic path is:

```text
Apps configured to use the local proxy
  -> 127.0.0.1:44025 (HTTP or SOCKS5)
  -> Android-compatible sing-box/libbox engine
  -> OpenRung relay (VLESS + REALITY + Vision)
  -> Internet
```

The Android app must provide:
- OpenRung broker relay discovery and relay selection.
- An Android ARM64 / ARMv7 compatible sing-box engine.
- A loopback-only HTTP/SOCKS5 inbound on port `44025`.
- A VLESS + REALITY + Vision outbound matching the selected signed relay descriptor.
- Start/stop lifecycle, connection state, traffic counters, and diagnostic logs.
- Node/relay refresh and automatic failover without claiming success until an end-to-end probe passes.

## Important Android limitation

Without TUN/VpnService or root-level transparent routing, an ordinary Android app cannot force every other app's traffic through itself.

The local proxy can be used by:
- Apps with their own HTTP/SOCKS proxy settings.
- A Wi-Fi network's Android system proxy setting, for apps that honor that setting.

The Wi-Fi proxy is configured per network and is not a guaranteed all-app solution. It does not cover mobile data, and some apps ignore system proxy settings. The UI and documentation must not call this mode "全局代理" or claim all applications are intercepted. If true all-app routing becomes mandatory later, it requires relaxing the no-TUN constraint or using a rooted-device transparent-proxy design.

## Core integration requirement

The OpenWrt package's Linux executable cannot be run directly on Android ARM devices. Do not bundle the OpenWrt Linux binary as the Android engine.

The Android build must package a compatible native engine for `arm64-v8a` and `armeabi-v7a`, with its matching Go/native dependencies and license notices. Reuse OpenRung's relay-discovery and VLESS/REALITY configuration contracts where compatible, but do not import the upstream mobile VPN service or TUN lifecycle into this no-TUN variant.

The current scaffold is not yet a functional proxy client. A successful Gradle build alone does not prove that proxy traffic works. Do not publish it as a usable release until:
1. The native engine loads on both target ABIs.
2. The local HTTP and SOCKS5 listeners accept connections only on loopback.
3. A real relay is discovered and selected.
4. HTTP and SOCKS5 requests pass through VLESS + REALITY + Vision to an external test endpoint.
5. DNS behavior, stop/restart, relay failure, and app-background behavior are tested on real Android devices.

## Build

The Android workflow builds a debug APK for early UI/CI validation. A signed release requires repository Actions secrets for the Android signing keystore and credentials; never commit signing material.
