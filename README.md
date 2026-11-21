# OpenRung for OpenWrt (x86_64)

面向 KWRT/OpenWrt x86_64 的 OpenRung CLI + LuCI 管理包。

## 当前实现

- `openrung-client`：从官方 OpenRung 源码编译的 Linux amd64 CLI。
- `luci-app-openrung`：中文 LuCI 配置页，可修改本地代理监听端口，并显示实际监听地址和端口。
- procd 后台服务：使用 `connect -headless`，开机启动并无限自动重启。
- **本地监听端口可配置**：默认 `127.0.0.1:44025`；在 LuCI 页面修改“本地监听端口”并保存后重启服务生效。
- procd 显式设置 `HOME=/root` 和 `XDG_CONFIG_HOME=/root/.config`，避免 Go 客户端因精简服务环境缺少 HOME 而初始化失败。
- LuCI 状态检查实际 TCP 监听地址/端口，并结合 procd 状态区分“正在监听”“进程启动但未监听”“服务未运行”。
- PassWall 联动：执行 `openrung-client check` 时，若 PassWall 原本正在运行则先暂停，检测结束后自动恢复；原本关闭则保持关闭。
- 默认使用无 TUN 的本地代理模式。TUN 当前禁用，因为目标设备没有 `/dev/net/tun`。

## GitHub Actions 构建

1. Actions -> `Build OpenRung OpenWrt IPK` -> Run workflow。
2. 构建完成后在 Actions 的 Artifacts 下载 `openrung-openwrt-ipk`。
3. Workflow 也会发布到 Release：`openwrt-latest`。

## LuCI 修改端口

进入 OpenRung 页面，修改“本地监听端口”（1–65535），保存并应用后重启 OpenRung。状态栏会显示实际监听地址和端口。默认端口为 44025。

## 命令行安装与设置

```sh
cd /tmp
wget -O openrung-client.ipk https://github.com/mengxianbo/openwrt-openrung/releases/latest/download/openrung-client_x86_64.ipk
wget -O luci-app-openrung.ipk https://github.com/mengxianbo/openwrt-openrung/releases/latest/download/luci-app-openrung_all.ipk

opkg install --force-reinstall ./openrung-client.ipk
opkg install --force-reinstall ./luci-app-openrung.ipk

uci set openrung.main.enabled='1'
uci set openrung.main.mode='proxy'
uci set openrung.main.proxy_port='44025'
uci set openrung.main.passwall_guard='1'
uci commit openrung

/etc/init.d/openrung enable
/etc/init.d/openrung restart
sleep 5

/etc/init.d/openrung status
ubus call service list '{"name":"openrung"}'
ss -lntp 2>/dev/null | grep ':44025' || netstat -lntp 2>/dev/null | grep ':44025'
logread -e openrung | tail -50
```

## 运行验收

1. LuCI 状态栏显示实际监听地址及端口。
2. `ubus call service list '{"name":"openrung"}'` 中 OpenRung 实例为 `running: true`。
3. `ss -lntp` 或 `netstat -lnpt` 显示配置的端口正在监听。
4. 修改端口后，旧端口停止监听，新端口开始监听。
5. 重启路由器后服务自动启动并监听配置端口。

## 说明

- 代理仅绑定 IPv4 回环地址 `127.0.0.1`，不会向 LAN 暴露无认证代理。
- procd 使用 `respawn 3600 5 0`，无限自动重启。
- 若端口已被其他程序占用，客户端可能无法监听；请先释放该端口。
- 节点筛选支持国家代码、Relay ID、Relay Label；全部留空时由官方引擎自动选择。
