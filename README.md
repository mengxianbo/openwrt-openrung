# OpenRung for OpenWrt (初版)

面向 KWRT/OpenWrt x86_64 的 OpenRung CLI + LuCI 管理包。

## 当前实现边界
- `openrung-client`：从官方 OpenRung 源码编译的 Linux amd64 CLI。
- `luci-app-openrung`：中文 LuCI CBI 配置页。
- procd 服务：以 `connect -headless` 运行，支持开机启动、停止、崩溃重启。
- PassWall 联动：执行 `/usr/bin/openrung-client check` 时，若 PassWall 原本正在运行则先暂停，检测结束后自动恢复；原本关闭则保持关闭。可在 LuCI 中关闭此功能或选择 PassWall / PassWall 2。
- 节点选择：自动（不设置筛选）、国家代码、Relay ID、Relay Label。
- 默认只启用无 TUN 的本地代理模式。TUN 当前不启用，因为目标设备没有 `/dev/net/tun`，且运行内核与软件源内核不匹配。

## 重要说明
OpenRung 当前 CLI 的 headless 模式使用 `connect -headless`，可传入 `-relay-id`、`-relay-label`、`-relay-country`。
CLI 的代理监听地址/端口由官方连接引擎管理；此包不伪造端口设置，也不将其硬编码为 40333。连接后请以 `logread -e openrung`、`ps` 和 `ss -lntp` 核实实际监听端口。
此初版未实现从官方目录读取完整节点列表并在 LuCI 中展示测速排名；网页端通过 Relay ID / 国家 / 标签进行筛选。后续要做实时节点表，需要官方目录 API 的数据结构及 UI 接口适配。

## GitHub Actions 构建
1. 将整个目录内容上传到自己的 GitHub 仓库。
2. Actions -> `Build OpenRung OpenWrt IPK` -> Run workflow。
3. 构建完成后在 Actions 的 Artifacts 下载 `openrung-openwrt-ipk`。
4. 包含：
   - `openrung-client_*_x86_64.ipk`
   - `luci-app-openrung_*_all.ipk`

Workflow 从官方 `openrung/openrung` main 分支拉取源码，使用 Go 1.25.5 编译；建议正式部署前将 `OPENRUNG_REF` 固定到经过验证的 tag 或 commit。

## 安装
1. 下载 OpenRung 客户端
 
cd /tmp
wget -O openrung-client.ipk \
https://github.com/mengxianbo/openwrt-openrung/releases/latest/download/openrung-client_x86_64.ipk

2. 下载 LuCI 管理界面
   
wget -O luci-app-openrung.ipk \
https://github.com/mengxianbo/openwrt-openrung/releases/latest/download/luci-app-openrung_all.ipk

3. 安装

opkg install ./openrung-client.ipk
opkg install ./luci-app-openrung.ipk

4. 设置本地监听端口为 44025，并开启开机自启

uci set openrung.main.enabled='1'
uci set openrung.main.proxy_port='44025'
uci set openrung.main.passwall_guard='1'
uci commit openrung

/etc/init.d/openrung enable
/etc/init.d/openrung restart

5. 检查运行状态

/etc/init.d/openrung status
logread | grep -i openrung | tail -30
netstat -lnpt 2>/dev/null | grep 44025


## 使用
在 LuCI 设置国家代码（例如 `DE`）或 Relay ID；留空则交给官方引擎自动选择。PassWall 联动默认开启，需确认服务名与实际安装的 init 服务一致。
注意：本初版的 country/id 是筛选目标，不是完整可视化节点目录。

## 兼容性
目标设备显示 x86_64，但运行内核 `6.2.16-3-pve`，软件源指向 KWRT 25.12 内核目录 `6.12.94`。因此客户端作为 Go 静态用户态程序编译，不包含内核模块；TUN 默认关闭。该 IPK 尚未在你的实际路由器上安装验证。
