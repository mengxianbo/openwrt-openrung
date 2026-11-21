# OpenRung for OpenWrt (x86_64)

面向 KWRT/OpenWrt x86_64 的 OpenRung CLI + LuCI 管理包。

## 当前实现

- `openrung-client`：从官方 OpenRung 源码编译的 Linux amd64 CLI。
- `luci-app-openrung`：中文 LuCI CBI 配置页。
- procd 后台服务：使用 `connect -headless`，开机启动并无限自动重启。
- **本地代理端口固定为 `127.0.0.1:44025`**：由官方客户端支持的 `OPENRUNG_PROXY_PORT` 环境变量在服务启动时强制指定，不读取随机端口。
- procd 服务显式设置 `HOME=/root` 和 `XDG_CONFIG_HOME=/root/.config`，避免精简 OpenWrt 服务环境缺少 HOME，导致 Go 客户端无法初始化用户配置目录并立即退出。
- LuCI 状态同时检查 procd 实例和 44025 TCP 监听，不再用错误的进程命令行匹配来判断运行状态。
- PassWall 联动：执行 `openrung-client check` 时，若 PassWall 原本正在运行则先暂停，检测结束后自动恢复；原本关闭则保持关闭。
- 默认只启用无 TUN 的本地代理模式。TUN 当前不启用，因为目标设备没有 `/dev/net/tun`，且运行内核与软件源内核不匹配。

## GitHub Actions 构建

1. Actions -> `Build OpenRung OpenWrt IPK` -> Run workflow。
2. 构建完成后在 Actions 的 Artifacts 下载 `openrung-openwrt-ipk`。
3. 也会发布到 Release：`openwrt-latest`。

Workflow 从官方 `openrung/openrung` main 分支拉取源码，使用 Go 1.25.5 编译；正式部署前建议将 `OPENRUNG_REF` 固定到经过验证的 tag 或 commit。

## 安装

```sh
cd /tmp
wget -O openrung-client.ipk https://github.com/mengxianbo/openwrt-openrung/releases/latest/download/openrung-client_x86_64.ipk
wget -O luci-app-openrung.ipk https://github.com/mengxianbo/openwrt-openrung/releases/latest/download/luci-app-openrung_all.ipk

opkg install ./openrung-client.ipk
opkg install ./luci-app-openrung.ipk

# 启用服务并固定代理端口
uci set openrung.main.enabled='1'
uci set openrung.main.mode='proxy'
uci set openrung.main.proxy_port='44025'
uci set openrung.main.passwall_guard='1'
uci commit openrung

/etc/init.d/openrung enable
/etc/init.d/openrung restart
sleep 3

/etc/init.d/openrung status
ubus call service list '{"name":"openrung"}'
ss -lntp 2>/dev/null | grep ':44025' || netstat -lnpt 2>/dev/null | grep ':44025'
logread -e openrung | tail -50
```

## 运行验收

必须同时满足：

1. `ubus call service list '{"name":"openrung"}'` 中 OpenRung 实例为 `running: true`。
2. `ss -lntp` 或 `netstat -lnpt` 显示 `127.0.0.1:44025` 正在监听。
3. `/etc/init.d/openrung enabled` 返回成功。
4. 重启路由器后仍自动启动并监听 44025。

## 说明

- 端口只绑定 IPv4 回环地址 `127.0.0.1`，不会向 LAN 暴露无认证代理。
- procd 使用 `respawn 3600 5 0`：短时间反复崩溃也会每隔 5 秒持续重启，不会因默认 5 次重试后永久停止。
- 如果 44025 已被其他程序占用，OpenRung 会报告端口冲突；请先释放该端口，不会自动换端口。
- 节点筛选支持国家代码、Relay ID、Relay Label；全部留空时由官方引擎自动选择。
