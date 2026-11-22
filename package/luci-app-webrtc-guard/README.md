# JianxianApp WebRTC Leak Guard

独立 LuCI 插件，用于对 LAN 转发流量中的常见 STUN/TURN UDP 端口进行选择性阻断。

## 智能模式

默认关闭。启用后，在 nftables 的独立 `inet webrtc_guard` 表中创建 forward 链，只匹配配置的 LAN 入接口和以下 UDP 目的端口：

- 3478、5349
- 19302–19309

其他 UDP 流量不受本插件规则影响。规则使用独立 nftables 表，不修改 `/etc/config/firewall`、firewall4 主配置或 OpenRung 服务。LuCI 点击“保存并应用”后会自动重新加载本插件规则。

## 重要限制

这是一层路由器侧缓解措施，不是完整的 WebRTC 隐私保证。WebRTC/STUN 可以使用其他端口、TCP、TURN 或应用自定义传输；浏览器还可能公开本地候选地址。请同时在浏览器启用 WebRTC 隐私/mDNS 设置，并确认代理客户端正确处理 IPv4、IPv6 和 UDP。启用后，依赖 STUN UDP 的语音/视频连接可能降级或失败。

## 安装

适用于 OpenWrt 23.05 / firewall4 / nftables，IPK 为架构无关包：

```sh
opkg update
opkg install nftables
opkg install luci-app-webrtc-guard_all.ipk
/etc/init.d/webrtc_guard enable
/etc/init.d/webrtc_guard start
```

进入 LuCI：网络 → WebRTC 防泄漏。默认关闭，确认 LAN 接口名称后再启用。

## 回滚

```sh
uci set webrtc_guard.main.enabled='0'
uci commit webrtc_guard
/etc/init.d/webrtc_guard restart
/etc/init.d/webrtc_guard disable
opkg remove luci-app-webrtc-guard
```

卸载/停用只删除本插件创建的 `inet webrtc_guard` 表，不触碰其他 nftables 表。

## 测试

CI 检查 shell/Lua 语法、规则策略关键项、IPK 控制信息及包内文件清单。CI 不会在 GitHub runner 上加载或修改真实防火墙规则。
