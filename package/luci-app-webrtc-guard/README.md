# JianxianApp WebRTC Leak Guard

独立 LuCI IPK，提供三种可选防护模式。默认关闭，默认策略为智能模式。

## 1. 智能防泄漏（推荐）
仅对所选 LAN 接口的转发流量阻断常见 STUN/TURN UDP 目的端口：3478、5349、19302–19309，尽量避免影响普通 UDP。透明代理若已在更早的 prerouting 阶段接管流量，相关流量通常不会进入本插件 forward 链；实际行为取决于代理架构和 nftables hook 优先级。

## 2. 严格阻断模式
阻断所选 LAN 接口转发的 UDP 流量，仅保留 UDP DNS 53 和 NTP 123；同时阻断 TCP 3478/5349。它不只是阻断 WebRTC：QUIC/HTTP3、游戏、语音、视频会议及其他 UDP 应用都可能受影响。

## 3. 按设备防护
在 LuCI 中添加设备的固定 IPv4 和/或 IPv6 地址，并为每台设备选择智能或严格策略。建议设置 DHCP 静态租约，并填写设备实际使用的 IPv6 地址。地址变化后必须同步更新配置。

## 安全边界与限制
本插件是路由器侧流量缓解工具，不是完整 WebRTC 防泄漏保证。STUN/TURN 可使用非标准端口、TCP/TLS 或应用自定义传输；浏览器也可能在本机页面中展示 host candidates。智能模式不负责自动把流量送入代理，也不能修复代理本身的 UDP/IPv6 路由。需要结合浏览器 WebRTC 隐私设置、代理 UDP 支持、IPv4/IPv6 出口检查和真实客户端测试。

## 安装与启用
    opkg update
    opkg install nftables
    opkg install ./luci-app-webrtc-guard_1.1.0-r1_all.ipk
    /etc/init.d/webrtc_guard enable
    /etc/init.d/webrtc_guard start

进入 LuCI：网络 → WebRTC 防泄漏。默认关闭，确认 LAN 接口后再启用。

## 检查规则与计数器
    /etc/init.d/webrtc_guard status
    nft list table inet webrtc_guard

## 回滚
    uci set webrtc_guard.main.enabled='0'
    uci commit webrtc_guard
    /etc/init.d/webrtc_guard restart
    /etc/init.d/webrtc_guard disable
    opkg remove luci-app-webrtc-guard

插件只删除自己的 inet webrtc_guard 表，不修改 /etc/config/firewall 或其他 nftables 表。

## CI
GitHub Actions 检查 shell/Lua 语法、三种模式关键规则、IPK 内容、元数据及许可证文件。CI 不会加载真实防火墙规则；仍需在隔离测试路由器上进行语音、视频、QUIC、DNS、IPv4/IPv6 回归。
