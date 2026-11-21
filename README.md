# OpenRung for OpenWrt

将 [OpenRung](https://github.com/openrung/openrung) 客户端封装为 OpenWrt IPK，并提供 LuCI 中文管理页面和 procd 服务管理。

本仓库当前构建目标为 **OpenWrt x86_64**。构建会生成两个安装包：

- `openrung-client_x86_64.ipk`：OpenRung 客户端、命令包装器、UCI 默认配置和 procd 服务脚本。
- `luci-app-openrung_all.ipk`：LuCI 中文管理页面。

## 功能

- LuCI 页面管理 OpenRung 服务开关、运行模式、节点筛选和本地代理端口。
- 以 OpenWrt procd 服务方式在后台运行，不依赖 SSH 会话。
- 支持开机启动及进程异常退出后自动拉起（procd respawn）。
- 默认使用 Proxy 模式，默认本地代理端口配置为 **44025**。
- 支持按国家代码、Relay ID 或节点标签筛选节点；全部留空时由客户端自动选择。
- 节点检测时可按配置暂时停止原本正在运行的 PassWall，检测结束后恢复；原本未运行的 PassWall 不会被主动启动。
- 修复 LuCI 中文页面源码/显示问题。

### 当前版本说明

- 当前 IPK 构建目标是 **x86_64**；LuCI 包为 all 架构。
- 当前构建只支持 Proxy 运行模式。虽然 LuCI 页面保留 TUN 选项用于说明，但服务脚本会拒绝启动 TUN 模式。
- 默认端口配置为 `44025`，服务通过 `OPENRUNG_PROXY_PORT` 环境变量将端口传给客户端。请在目标设备上核对客户端实际监听结果；配置值不等于监听成功。
- LuCI 状态项用于判断客户端进程是否存在，并不等同于验证远端节点已连接或代理请求可用。

## 安装

### 一键安装（OpenWrt x86_64）

在路由器 SSH 终端以 root 执行：

```sh
set -e

BASE_URL="https://github.com/mengxianbo/openwrt-openrung/releases/download/openwrt-latest"

cd /tmp
wget -O openrung-client_x86_64.ipk "${BASE_URL}/openrung-client_x86_64.ipk"
wget -O luci-app-openrung_all.ipk "${BASE_URL}/luci-app-openrung_all.ipk"

# 安装客户端和 LuCI 页面
opkg install --force-reinstall ./openrung-client_x86_64.ipk
opkg install --force-reinstall ./luci-app-openrung_all.ipk

# 设置默认配置：启用服务、Proxy 模式、本地端口 44025
uci set openrung.main.enabled='1'
uci set openrung.main.mode='proxy'
uci set openrung.main.proxy_port='44025'
uci commit openrung

# 注册开机启动并启动服务
/etc/init.d/openrung enable
/etc/init.d/openrung restart

echo "===== OpenRung 服务状态 ====="
/etc/init.d/openrung status

echo "===== 开机启动状态 ====="
/etc/init.d/openrung enabled

echo "===== 进程 ====="
ps w | grep -E '[o]penrung'

echo "===== 监听端口 ====="
(netstat -lnpt 2>/dev/null || ss -lntp 2>/dev/null) | grep -E '44025|openrung' || true

echo "===== 最近日志 ====="
logread -e openrung | tail -n 50
```

> 上述下载地址指向仓库的 `openwrt-latest` Release。只有在 GitHub Actions 构建成功并成功发布 Release 后才能下载。若 Release 尚未生成，请先在仓库 **Actions** 页面运行构建工作流，并从该次运行的 Artifacts 下载两个 IPK。

### 手动安装

把两个 IPK 上传到路由器后执行：

```sh
opkg install --force-reinstall ./openrung-client_x86_64.ipk
opkg install --force-reinstall ./luci-app-openrung_all.ipk
```

如果使用非 x86_64 设备，请不要安装本仓库当前的客户端 IPK。请先为对应目标架构重新构建客户端包。

## LuCI 配置

安装后进入：

**LuCI → 服务 → OpenRung**

主要配置项：

| 配置项 | 默认值 | 说明 |
|---|---:|---|
| 启用服务 | 0 | 是否由 procd 启动后台客户端；安装命令会设为 1 |
| 运行模式 | proxy | 当前构建只支持 Proxy |
| 节点国家代码 | 空 | 例如 DE、US、SG；留空不限制 |
| 指定 Relay ID | 空 | 可指定一个 Relay ID |
| 本地监听端口 | 44025 | 通过 `OPENRUNG_PROXY_PORT` 传递给客户端 |
| 节点标签 | 空 | 可选筛选条件 |
| 检测节点时暂时暂停 PassWall | 1 | 只在 PassWall 原本运行时暂停并在检测后恢复 |
| PassWall 服务名称 | passwall | 可选择 passwall 或 passwall2 |

节点国家代码、Relay ID、节点标签建议只设置一个筛选条件。全部留空时使用客户端默认选择逻辑。

## 常用命令

```sh
# 交互式节点菜单
/usr/bin/openrung-menu

# 启动、停止、重启
/etc/init.d/openrung start
/etc/init.d/openrung stop
/etc/init.d/openrung restart

# 查看状态、开机启动状态
/etc/init.d/openrung status
/etc/init.d/openrung enabled

# 设置/取消开机启动
/etc/init.d/openrung enable
/etc/init.d/openrung disable

# 查看 UCI 配置
uci show openrung

# 修改端口（示例：44025）
uci set openrung.main.proxy_port='44025'
uci commit openrung
/etc/init.d/openrung restart

# 查看进程、监听和日志
ps w | grep -E '[o]penrung'
netstat -lnpt 2>/dev/null | grep -E '44025|openrung'
logread -e openrung | tail -n 100
```

不要在 SSH 命令行直接执行 `procd_set_param`。它是 init 脚本中定义 procd 服务时使用的函数。

## 验证代理是否正常

至少检查以下项目：

1. `/etc/init.d/openrung status` 显示服务运行。
2. `ps` 能看到 OpenRung 后台客户端进程。
3. `netstat` 或 `ss` 能看到客户端实际监听的地址和端口。
4. 使用实际监听端口发起 HTTP/SOCKS5 代理请求，确认请求成功。

例如设备安装了 curl 时，可按客户端实际支持的代理协议测试：

```sh
curl -x http://127.0.0.1:44025 https://www.cloudflare.com/cdn-cgi/trace
```

若配置为 44025，但实际监听在其他端口，或没有监听端口，请先查看日志和客户端启动参数。不要仅凭 UCI 配置或 procd 显示 running 就判断代理已可用。

## 构建

本仓库使用 GitHub Actions 构建 IPK：

1. 打开仓库的 **Actions** 页面。
2. 运行 **Build OpenRung OpenWrt IPK** 工作流。
3. 可在 `openrung_ref` 输入上游 OpenRung 的 tag、branch 或 commit；默认值为 `main`。
4. 构建成功后，在 Artifacts 下载 `openrung-openwrt-ipk`，其中包含两个 IPK 和 `SHA256SUMS`。
5. 工作流也会更新 `openwrt-latest` Release 的稳定文件名安装包。

构建环境使用 Ubuntu 24.04、Go 1.25.5，编译 Linux amd64 客户端，并打包为 OpenWrt x86_64 IPK。

## 包含文件

```text
package/
├── openrung-client/
│   ├── openrung-client-wrapper   # 客户端命令包装器，处理 PassWall 检测联动
│   ├── openrung.config           # UCI 默认配置
│   └── openrung.init             # procd 服务定义
└── luci-app-openrung/
    ├── controller.lua            # LuCI 菜单入口
    └── openrung.lua               # LuCI 配置页面
.github/
└── workflows/
    └── build.yml                 # GitHub Actions 构建和发布
```

## 安全与注意事项

- 默认本地代理应仅供本机使用，不要未经访问控制就暴露到 WAN。
- 如需让 LAN 设备使用代理，需要另行配置监听地址、防火墙和访问控制。
- 不要把账号凭据、访问令牌或私有节点信息提交到公开仓库。
- OpenRung 上游节点服务的可用性、连接质量及第三方网络环境不由本项目保证。

## 项目地址

- 本项目：<https://github.com/mengxianbo/openwrt-openrung>
- OpenRung 上游：<https://github.com/openrung/openrung>
