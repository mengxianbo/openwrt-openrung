# OpenRung for OpenWrt

面向 OpenWrt / KWRT（当前以 x86_64 环境为主要目标）的 OpenRung 客户端与 LuCI 管理插件。项目将 OpenRung CLI、LuCI 配置页面和 OpenWrt 的 procd 服务管理整合在一起，便于在路由器上选择节点并运行本地代理。

> **版本说明**：本文档对应 2026-11-21 这一轮重新编译、修复 Lua 页面中文显示并调整服务管理的版本。不同设备上的 OpenRung 上游节点连接情况、实际监听端口和内核能力可能不同。请以设备上的服务日志、进程和监听结果为准，不要仅凭配置值判断代理已成功启动。

## 功能概览

- **OpenRung CLI**：在 OpenWrt 上运行 OpenRung 客户端，支持交互式菜单和 headless 后台连接。
- **LuCI 管理页面**：中文配置页面，用于启用/停用服务、选择运行模式、设置本地代理端口及 PassWall 联动选项。
- **procd 服务管理**：通过 `/etc/init.d/openrung` 注册为系统服务，支持开机启动、手动启动/停止和异常退出后自动拉起。
- **后台保活**：服务使用 procd respawn 机制管理 headless 客户端，避免仅依赖 SSH 会话维持进程。
- **本地代理端口设置**：默认目标端口为 `44025`，配置项为 `proxy_port`。页面提供端口显示/修改入口；实际监听端口仍须在运行后核对。
- **节点选择**：通过 OpenRung 菜单交互选择节点；后台 headless 模式可使用客户端支持的筛选参数（例如国家代码、Relay ID 或 Relay Label，具体以当前 CLI 的 `--help` 输出为准）。
- **PassWall 联动选项**：提供检测代理时暂停 PassWall 的配置入口，避免检测请求被现有代理链路干扰。是否成功暂停/恢复，取决于设备上实际安装的服务名称及当前脚本版本；请查看日志验证。
- **Lua 中文显示修复**：修正 LuCI 页面源码编码/显示问题，避免中文说明乱码。

## 运行模式与限制

- 当前构建以 **本地 Proxy 模式** 为主要运行方式。
- **TUN 模式不作为此构建的可用功能**；不要在未确认设备具备 `/dev/net/tun`、内核支持及相应配置前启用 TUN。
- 本地代理默认绑定回环地址（通常为 `127.0.0.1`），供路由器本机程序使用。若要供 LAN 设备使用，需要单独设计监听地址、防火墙和访问控制；不要直接将代理端口暴露到公网。
- 配置中的 `proxy_port=44025` 表示期望端口，不代表上游连接引擎必然已在该端口监听。历史调试中出现过配置端口与实际端口不一致（例如实际进程监听 `127.0.0.1:46289`）的情况。若客户端没有读取端口配置或上游自动分配端口，必须先修复该映射再宣称端口锁定成功。
- OpenRung 节点 API/远端连接可能失败或被重置；服务进程存在不等于节点已连接，也不等于代理可用。

## 安装

### 方式一：安装编译好的 IPK

将构建产物上传到路由器后执行（文件名按实际产物替换）：

```sh
opkg install ./openrung-client_*.ipk
opkg install ./luci-app-openrung_*.ipk
```

如果系统使用 apk 包管理器，请使用设备对应的软件包安装命令，不要直接照搬 `opkg` 命令。

安装后刷新 LuCI 页面；如菜单未出现，可重启 uhttpd 或重新登录 LuCI。

### 方式二：通过 GitHub Actions 构建

1. 打开仓库的 **Actions** 页面。
2. 选择 OpenRung 的 OpenWrt 构建工作流并运行。
3. 等待构建完成，在该次运行的 Artifacts 中下载 IPK。
4. 将客户端包和 LuCI 包上传到路由器，再按上面的方式安装。

> 构建工作流使用的上游源码版本、Go 版本和目标架构应以仓库当前 workflow 文件为准。正式发布建议将上游源码固定到经过测试的 tag 或 commit，避免直接跟随上游 main 分支导致构建结果变化。

## 首次配置

1. 安装客户端和 LuCI 插件。
2. 在 LuCI 中打开 OpenRung 页面。
3. 选择 Proxy 模式并启用服务。
4. 将本地代理端口设置为 `44025`（如果页面已有默认值，可先保持默认）。
5. 根据实际安装情况设置 PassWall 服务名称；未使用 PassWall 时关闭联动。
6. 保存并应用配置。
7. 启动服务后，检查服务状态、进程、监听端口和连接日志。

节点交互选择可在路由器终端执行：

```sh
/usr/bin/openrung-menu
```

后台服务使用 headless 方式运行，不应依赖 SSH 登录后手动打开交互菜单。交互菜单与后台服务是不同的运行入口；不要在未确认进程管理逻辑前同时启动多个实例，以免产生多个代理进程或不同端口。

## 服务管理

```sh
# 启动
/etc/init.d/openrung start

# 停止
/etc/init.d/openrung stop

# 重启
/etc/init.d/openrung restart

# 查看状态
/etc/init.d/openrung status

# 设置开机自启动
/etc/init.d/openrung enable

# 取消开机自启动
/etc/init.d/openrung disable

# 查看是否已启用
/etc/init.d/openrung enabled
```

服务由 OpenWrt 的 **procd** 管理。不要在 SSH 命令行直接执行 `procd_set_param`；该函数只在 init 脚本的 procd 服务定义上下文中使用。

## 查看端口与排错

### 查看配置

```sh
uci show openrung
```

确认配置中包含启用状态、运行模式、代理端口和 PassWall 联动选项。常见配置字段：

| 字段 | 说明 |
|---|---|
| `enabled` | 是否启用 OpenRung 服务 |
| `mode` | 运行模式，当前使用 `proxy` |
| `proxy_port` | 期望的本地代理端口，默认目标为 `44025` |
| `passwall_guard` | 是否启用 PassWall 检测联动 |
| `passwall_service` | PassWall init 服务名称，例如 `passwall` |

### 查看实际监听端口

```sh
# 查看目标端口
netstat -lnpt 2>/dev/null | grep -E '44025|openrung'

# 如果系统安装了 ss
ss -lntp | grep -E '44025|openrung'

# 查看 OpenRung 相关进程
ps w | grep -E '[o]penrung'

# 查看服务日志
logread -e openrung
```

判断代理是否真正可用，至少要确认：

1. `/etc/init.d/openrung status` 显示服务运行；
2. headless 客户端和代理引擎进程存在；
3. 实际监听地址、端口与 LuCI 配置一致；
4. 使用该代理发起请求能够成功访问目标网站。

如果服务显示运行但没有监听端口，或端口与配置不一致，请先查看 `logread -e openrung` 和进程启动参数。不要通过重复启动菜单或服务来掩盖端口映射问题。

## 安全建议

- 默认优先使用 `127.0.0.1` 回环监听。
- 不要把本地代理端口直接映射到 WAN。
- 若确实需要 LAN 设备访问，应限制来源网段，并配置防火墙规则。
- 不要在公开日志、截图或仓库中提交账号凭据、访问令牌或私有节点信息。

## 兼容性提示

本项目面向 OpenWrt/KWRT 环境。客户端作为用户态程序运行，不代表所有设备都具备 TUN 所需的内核模块。不同固件的包管理器、LuCI 版本、init 服务名称和防火墙实现可能不同，安装前请确认目标架构及依赖。

## 项目

- GitHub：<https://github.com/mengxianbo/openwrt-openrung>
- OpenWrt 服务入口：`/etc/init.d/openrung`
- 客户端菜单：`/usr/bin/openrung-menu`
- LuCI 页面源码（如安装包布局未变）：`/usr/lib/lua/luci/model/cbi/openrung/main.lua`

## 免责声明

本项目用于在 OpenWrt 路由器上管理 OpenRung 客户端。上游服务可用性、节点连接质量及第三方网络环境不由本项目保证。请遵守 OpenRung 服务条款及所在地法律法规。
