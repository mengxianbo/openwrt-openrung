# OpenRung for OpenWrt (x86_64)

![Open Source](https://img.shields.io/badge/Open%20Source-Public%20Repository-blue?logo=github)
![Platform](https://img.shields.io/badge/Platform-OpenWrt%20x86__64-blue)
![Build](https://img.shields.io/badge/Build-GitHub%20Actions-success)

面向 KWRT/OpenWrt x86_64 的 OpenRung CLI + LuCI 管理包。

> **统一下载入口：** [OpenRung APK + IPK 最新 Release](https://github.com/mengxianbo/openwrt-openrung/releases/tag/openwrt-packages)。该 Release 同时提供 OpenWrt 25.12 使用的 APK、旧版 opkg 系统使用的 IPK、对应 ZIP 合集及校验文件。请优先使用此入口，不要从历史 Release 下载旧包。
>
> **格式选择：** OpenWrt 25.12（APK 包管理器）请选择 APK；仍使用 opkg 的旧版 OpenWrt 请选择 IPK。两个格式不能混装。以下命令均使用 Release 中的稳定文件名，无需手动修改版本号。

> **许可证：** 本项目自编写的代码采用 **GNU GPL-3.0-or-later** 发布。项目集成的 OpenRung 客户端及其第三方组件仍须遵守各自上游许可证与版权声明；请同时查看 [LICENSE](./LICENSE) 和 [OpenRung 上游许可证](https://github.com/openrung/openrung/blob/main/LICENSE)。

## 当前实现

- `openrung-client`：从官方 OpenRung 源码编译的 Linux amd64 CLI。
- `luci-app-openrung`：中文 LuCI 配置页，可修改本地代理监听端口，并显示实际监听地址和端口。
- procd 后台服务：使用 `connect -headless`，开机启动并无限自动重启。
- **本地监听端口可配置**：默认 `127.0.0.1:44025`；在 LuCI 页面修改“本地监听端口”并保存后重启服务生效。
- procd 显式设置 `HOME=/root` 和 `XDG_CONFIG_HOME=/root/.config`，避免 Go 客户端因精简服务环境缺少 HOME 而初始化失败。
- LuCI 状态检查实际 TCP 监听地址/端口，并结合 procd 状态区分“正在监听”“进程启动但未监听”“服务未运行”。
- PassWall 联动：执行 `openrung-client check` 时，若 PassWall 原本正在运行则先暂停，检测结束后自动恢复；原本关闭则保持关闭。
- 默认使用无 TUN 的本地代理模式。TUN 当前禁用，因为目标设备没有 `/dev/net/tun`。

## LuCI 修改端口

进入 OpenRung 页面，修改“本地监听端口”（1–65535），保存并应用后重启 OpenRung。状态栏会显示实际监听地址和端口。默认端口为 44025。

## OpenWrt 25.12 APK 安装

OpenWrt 25.12 x86_64 使用 APK 包格式。下面命令会从统一 Release 下载两个 APK（稳定文件名），并安装、启用服务：

```sh
cd /tmp
wget -O openrung-client_x86_64.apk https://github.com/mengxianbo/openwrt-openrung/releases/download/openwrt-packages/openrung-client_x86_64.apk
wget -O luci-app-openrung_all.apk https://github.com/mengxianbo/openwrt-openrung/releases/download/openwrt-packages/luci-app-openrung_all.apk

apk add --allow-untrusted ./openrung-client_x86_64.apk ./luci-app-openrung_all.apk

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

也可以下载 [APK 合集 ZIP](https://github.com/mengxianbo/openwrt-openrung/releases/download/openwrt-packages/openrung-openwrt-25.12-x86_64-bundle.zip)，其中包含上述两个稳定命名的 APK。

APK 由 OpenWrt 25.12.6 x86/64 官方 SDK 原生构建；原有 IPK 工作流继续保留，适用于使用 opkg 的旧版 OpenWrt。

## 旧版 OpenWrt（opkg / IPK）命令行安装

适用于仍使用 `opkg` 的 OpenWrt 版本。下面命令从统一 Release 下载稳定文件名的两个 IPK，无需手动选择版本号：

```sh
cd /tmp
wget -O openrung-client_x86_64.ipk https://github.com/mengxianbo/openwrt-openrung/releases/download/openwrt-packages/openrung-client_x86_64.ipk
wget -O luci-app-openrung_all.ipk https://github.com/mengxianbo/openwrt-openrung/releases/download/openwrt-packages/luci-app-openrung_all.ipk

opkg install --force-reinstall ./openrung-client_x86_64.ipk
opkg install --force-reinstall ./luci-app-openrung_all.ipk

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

也可以下载 [IPK 合集 ZIP](https://github.com/mengxianbo/openwrt-openrung/releases/download/openwrt-packages/openrung-ipk.zip)，其中包含上述两个稳定命名的 IPK 文件（不是带版本号的文件名）。

## 许可证与源码对应关系

- 本仓库维护的 OpenWrt 打包脚本及 LuCI 管理代码采用 GPL-3.0-or-later。
- IPK 中的客户端来自 OpenRung 上游仓库；构建时会将上游 `LICENSE` 和 `THIRD_PARTY_NOTICES.md` 原样安装到 `/usr/share/openrung/`，保留第三方版权、许可证文本和适用的附加条款。
- 每次构建会记录打包仓库与 OpenRung 上游的精确 Git commit，并在 IPK 内提供 `SOURCE-INFO.txt`。
- 每次 IPK 构建的 Actions artifact `openrung-openwrt-ipk` 会包含该次构建对应的本仓库打包源码和 OpenRung 上游源码快照；该 artifact 保留 30 天，不是 Release 附件。另一个后置工作流会生成包含 vendored Go 依赖的对应源码 artifact，保留 90 天。请从对应 IPK 构建记录及其关联的源码工作流下载，务必核对 `SOURCE-INFO.txt` 中的精确 commit，不要用最新版源码替代旧版 IPK。
- 客户端上游及其依赖的完整许可范围，以随包提供的 `THIRD_PARTY_NOTICES.md` 和各组件原始许可为准。

**注意：** 本项目提供源码定位与版权声明，不代表对所有第三方依赖重新授权。分发 IPK 时请同时保留包内的许可证和第三方声明文件。

## 源码归档与历史版本说明\n\n- 当前稳定二进制下载入口只有 [统一 Release：openwrt-packages](https://github.com/mengxianbo/openwrt-openrung/releases/tag/openwrt-packages)。该 Release 发布 APK、IPK、ZIP 合集和校验文件；对应源码归档通过 GitHub Actions artifacts 单独提供，不要把源码 artifact 误认为 Release 附件。\n- 当前 IPK 对应源码说明见 [FUTURE-SOURCE-DISTRIBUTION.md](./FUTURE-SOURCE-DISTRIBUTION.md)。\n- [SOURCE-DISTRIBUTION.md](./SOURCE-DISTRIBUTION.md) 仅记录历史 Build #24 的源码归档与精确版本，不代表当前 Release 或当前构建。\n\n## 运行验收

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

---

<div align="center">

# ⚡ OPENRUNG

<a href="https://github.com/mengxianbo/openwrt-openrung">
  <img src="https://img.shields.io/badge/OPEN%20SOURCE-PUBLIC%20REPOSITORY-00C853?style=for-the-badge&logo=github&logoColor=white&labelColor=111111" alt="Public Repository" />
</a>
<a href="https://github.com/mengxianbo/openwrt-openrung">
  <img src="https://img.shields.io/badge/COMMUNITY-POWERED-7C3AED?style=for-the-badge&logo=opensourceinitiative&logoColor=white&labelColor=111111" alt="Community Powered" />
</a>
<a href="https://github.com/mengxianbo/openwrt-openrung">
  <img src="https://img.shields.io/badge/LICENSE-GPL--3.0--or--later-00C853?style=for-the-badge&logo=gnu&logoColor=white&labelColor=111111" alt="License Pending" />
</a>

**OPENWRT × OPENRUNG — BUILT FOR THE COMMUNITY**

[⭐ Star this project](https://github.com/mengxianbo/openwrt-openrung) · [View Repository](https://github.com/mengxianbo/openwrt-openrung)

</div>
