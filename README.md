# OpenRung for OpenWrt (x86_64 / ARM64)

面向 OpenWrt x86_64 与 ARM64 设备的 OpenRung CLI + LuCI 管理包。支持 Proxmox LXC、PVE/ESXi 虚拟机、x86_64 物理机及兼容的 ARM64 软路由；是否为 LXC 不影响软件包选择，关键是 CPU 架构与 OpenWrt ABI。

## 软件包架构

- `openrung-client_x86_64.ipk`：Linux amd64 客户端，OpenWrt 架构标记为 `x86_64`。
- `openrung-client_aarch64_generic.ipk`：Linux arm64 客户端，OpenWrt 架构标记为 `aarch64_generic`。
- `luci-app-openrung_all.ipk`：架构无关的中文 LuCI 管理界面。

ARM64 包面向 OpenWrt 的 `aarch64_generic` 软件包架构。若设备的 opkg 架构列表不包含该兼容架构，不要强制安装；应使用与设备 OpenWrt target/subtarget 匹配的构建包。

## 当前功能

- 从官方 OpenRung 源码编译 Linux x86_64 和 ARM64 客户端。
- 中文 LuCI 配置页，可修改本地代理监听端口，并显示实际监听地址和端口。
- procd 后台服务：使用 `connect -headless` 自动选择节点，开机启动并自动重启。
- 本地监听端口可配置：默认 `127.0.0.1:44025`。
- procd 显式设置 `HOME=/root` 和 `XDG_CONFIG_HOME=/root/.config`。
- LuCI 状态检查实际 TCP 监听地址/端口，并区分进程已运行但尚未监听、服务未运行等状态。
- PassWall 联动：执行节点检测时，若 PassWall 原本正在运行则先暂停，检测结束后自动恢复；原本关闭则保持关闭。
- 默认使用无 TUN 的本地代理模式，不修改系统默认路由或防火墙转发规则。

## GitHub Actions 构建

1. Actions -> `Build OpenRung OpenWrt IPK` -> Run workflow。
2. 构建完成后在 Artifacts 下载 `openrung-openwrt-ipk-universal`。
3. Workflow 也会更新 Release：`openwrt-latest`。

## 安装

先在路由器上确认架构：

```sh
opkg print-architecture
uname -m
```

x86_64：

```sh
cd /tmp
wget -O openrung-client.ipk https://github.com/mengxianbo/openwrt-openrung/releases/latest/download/openrung-client_x86_64.ipk
wget -O luci-app-openrung.ipk https://github.com/mengxianbo/openwrt-openrung/releases/latest/download/luci-app-openrung_all.ipk
opkg install --force-reinstall ./openrung-client.ipk
opkg install --force-reinstall ./luci-app-openrung.ipk
```

ARM64（OpenWrt `aarch64_generic`）：

```sh
cd /tmp
wget -O openrung-client.ipk https://github.com/mengxianbo/openwrt-openrung/releases/latest/download/openrung-client_aarch64_generic.ipk
wget -O luci-app-openrung.ipk https://github.com/mengxianbo/openwrt-openrung/releases/latest/download/luci-app-openrung_all.ipk
opkg install --force-reinstall ./openrung-client.ipk
opkg install --force-reinstall ./luci-app-openrung.ipk
```

安装后启用服务并设置默认端口：

```sh
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

## LuCI 修改端口

进入 OpenRung 页面，修改“本地监听端口”（1–65535），保存并应用后重启 OpenRung。状态栏会显示实际监听地址和端口。默认端口为 44025。

## 运行验收

1. LuCI 状态栏显示实际监听地址及端口。
2. `ubus call service list '{"name":"openrung"}'` 中 OpenRung 实例为 `running: true`。
3. `ss -lntp` 或 `netstat -lnpt` 显示配置的端口正在监听。
4. 修改端口后，旧端口停止监听，新端口开始监听。
5. 重启路由器后服务自动启动并监听配置端口。

## 安全与兼容性说明

- 代理仅绑定 IPv4 回环地址 `127.0.0.1`，不会向 LAN 暴露无认证代理。
- procd 使用 `respawn 3600 5 0` 自动重启。
- 若端口已被其他程序占用，客户端可能无法监听。
- 节点筛选支持国家代码、Relay ID、Relay Label；全部留空时由官方引擎自动选择。
- 本项目不把 LXC 特有接口或权限作为运行前提；但容器自身的 CPU 架构、内核能力和 OpenWrt 软件包 ABI 仍须兼容。
