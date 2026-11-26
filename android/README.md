# 邪剑仙 Android 客户端

本分支构建真正具备代理连接能力的 Android VPN 客户端，应用显示名称为 **邪剑仙**，图标采用红色地狱火与长剑主题。客户端复用 OpenRung 移动端原生 Go/libbox 引擎及 Android VPN 宿主实现。此工作与 OpenWrt 软件包和 LuCI 页面分离。

## Actual traffic path

```text
Android applications
  -> Android VpnService permission
  -> Android TUN interface
  -> sing-box libbox + OpenRung connectcore/punchbridge
  -> discovered and verified OpenRung relay
  -> Internet
```

- No root is required.
- The app requests Android's VPN permission and establishes a real TUN interface.
- The native engine is built into the same libbox AAR as the OpenRung Go bindings; a separate punchbridge AAR is deliberately not used because it would duplicate the gomobile runtime.
- The native AAR is checked for `arm64-v8a` and `armeabi-v7a` libraries before the APK build.
- The upstream Android application source is pinned to commit `3a68a6fc15ddd4a13873f0196abbc1b49db87354` for reproducible builds.

## Build

运行 **Actions → Build 邪剑仙 Android VPN client → Run workflow**，分支选择 `feature/android-client`。

The workflow:
1. Checks out the pinned OpenRung mobile application source.
2. Builds the combined sing-box/libbox + OpenRung native engine.
3. Verifies ARM64 and ARMv7 native libraries.
4. Compiles the Android application and runs its JVM unit tests.
5. Uploads `xiejianxian-android-debug.apk`, source licenses, build provenance, and SHA-256.

The uploaded APK is a debug build for installation and functional testing. It is not a production-signed release.

## Honest release gate

A successful compile proves that the Android client and native engine were packaged; it does not by itself prove that a relay is reachable from a particular network. Before calling this a verified production release, test on a real Android device:

- VPN permission and TUN creation.
- Real relay discovery, connection and end-to-end internet access.
- Public egress IP and DNS behavior while connected.
- Network changes, disconnect/reconnect and relay failover.

The current upstream VPN client provides device-wide VPN/TUN routing. The older scaffold's local HTTP/SOCKS5 listener on port `44025` is not represented as implemented by this build; it must be integrated and tested separately before claiming that local proxy endpoint is available.

## Scope protection

Only `feature/android-client` is used for Android client work. Do not merge these Android changes into the OpenWrt main branch as part of this build. Existing OpenWrt IPK/APK packaging and LuCI functionality remain untouched.
