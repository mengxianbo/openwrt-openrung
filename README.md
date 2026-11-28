# OpenRung for OpenWrt（多架构构建中）

![Open Source](https://img.shields.io/badge/Open%20Source-Public%20Repository-blue?logo=github)
![Platform](https://img.shields.io/badge/Platform-OpenWrt%20x86__64-blue)
![Build](https://img.shields.io/badge/Build-GitHub%20Actions-success)

面向 KWRT/OpenWrt x86_64 的 OpenRung CLI + LuCI 管理包。

> **统一下载入口：** [OpenRung APK + IPK 最新 Release](https://github.com/mengxianbo/openwrt-openrung/releases/tag/openwrt-packages)。该 Release 同时提供 OpenWrt 25.12 使用的 APK、旧版 opkg 系统使用的 IPK、对应 ZIP 合集及校验文件。请优先使用此入口，不要从历史 Release 下载旧包。
>
> **格式选择：** OpenWrt 25.12（APK 包管理器）请选择 APK；仍使用 opkg 的旧版 OpenWrt 请选择 IPK。两个格式不能混装。以下命令均使用 Release 中的稳定文件名，无需手动修改版本号。

> **许可证与版权：** 本仓库由项目维护者编写并拥有版权的代码采用 **GNU GPL-3.0-or-later**。允许免费使用、修改、分享，也允许合规收费分发；收费分发不免除 GPL 对应源码、版权声明、许可证文本和修改说明等要求。OpenRung 上游客户端及第三方组件仍按各自许可证执行。详见 [LICENSE](./LICENSE)、[COPYRIGHT.md](./COPYRIGHT.md) 和 [THIRD_PARTY_NOTICES.md](./THIRD_PARTY_NOTICES.md)。

> **安装包版权文件：** 客户端和 LuCI 包均会附带 GPL 许可证及项目版权说明；客户端包还附带经发行方信息填充的上游第三方声明。每次构建会检查必要文件是否进入最终 APK/IPK。Go 依赖许可证审计会针对 APK/IPK 构建所使用的精确上游提交运行；自动审计不替代对非 Go 资源、专利、商标和额外许可条款的人工复核。

## 许可证专项审计

许可证审计针对每次 APK/IPK 构建所使用的精确 OpenRung 上游提交运行。自动检查阻断禁止及未知许可证；GPL 等 copyleft/Restricted 分类不会被一概视为不兼容，而是需要结合具体许可证、上游声明和对应源码人工复核。客户端和 LuCI 安装包会携带项目版权说明及适用的许可证/第三方声明。审计范围和限制见 [DEPENDENCY-LICENSE-AUDIT.md](./DEPENDENCY-LICENSE-AUDIT.md) 与 [LICENSES.md](./LICENSES.md)。

## 多架构构建进度（构建验证阶段）

仓库维护两类多架构工作流：

- [Linux 多架构核心编译](./.github/workflows/build-architecture-matrix.yml)：尝试构建 amd64、arm64、armv7、mips、mipsel、mips64、mips64el、riscv64 核心二进制。
- [OpenWrt 25.12 SDK 安装包矩阵](./.github/workflows/build-sdk-matrix.yml)：使用 OpenWrt 官方 SDK，为 armsr/armv8、armsr/armv7、ramips/mt7621、malta/be、malta/le、malta/le64、sifiveu/generic、starfive/generic 构建原生 APK，并检查包内容及核心 ELF 文件头。

SDK 工作流会从 OpenWrt 官方目标目录动态发现 SDK，并依据该目录的官方 sha256sums 校验下载文件。构建产物先保存为 GitHub Actions artifacts，**不会自动覆盖现有正式 Release，也不会让安装器提前下载未经验证的架构包**。

**当前正式 Release 和一键安装器仍只支持 x86_64。** 上述新增目标属于构建验证阶段；只有对应 Actions 成功、安装包元数据和 ELF ABI 检查通过，并完成目标设备/模拟环境的安装、procd 启动、LuCI 和代理监听测试后，才会加入正式 Release 和自动安装映射。不同 MIPS 大小端、32/64 位及浮点 ABI 不得混用。

## 当前实现

- `openrung-client`：从官方 OpenRung 源码编译的 Linux amd64 CLI。
- `luci-app-openrung`：中文 LuCI 配置页，可修改本地代理监听端口，并显示实际监听地址和端口。
- procd 后台服务：使用 `connect -headless`，开机启动并无限自动重启。
- **本地监听端口可配置**：默认 `127.0.0.1:44025`；在 LuCI 页面修改“本地监听端口”并保存后重启服务生效。
- procd 显式设置 `HOME=/root` 和 `XDG_CONFIG_HOME=/root/.config`，避免 Go 客户端因精简服务环境缺少 HOME 而初始化失败。
- LuCI 状态检查实际 TCP 监听地址/端口，并结合 procd 状态区分“正在监听”“进程启动但未监听”“服务未运行”。
- PassWall 联动：执行 `openrung-client check` 时，若 PassWall 原本正在运行则先暂停，检测结束后自动恢复；原本关闭则保持关闭。
- 默认使用无 TUN 的本地代理模式。TUN 当前禁用，因为目标设备没有 `/dev/net/tun`。

## 一键自动安装（推荐）

**以下命令与仓库根目录的 [install.sh](./install.sh) 保持同步。** 命令会下载 `main` 分支当前最新版安装脚本，因此脚本更新后无需修改路由器上的命令。需要使用 root 用户，并确保路由器能够访问 GitHub。

```sh
wget -O /tmp/openrung-install.sh https://raw.githubusercontent.com/mengxianbo/openwrt-openrung/main/install.sh
sh /tmp/openrung-install.sh
```

安装器会自动识别包管理器：检测到 `apk` 时选择 APK，检测到 `opkg` 时选择 IPK；下载后验证 SHA256，再安装、启用服务并检查默认代理端口 `44025`。

**当前正式安装包支持范围：仍为 x86_64 核心包。** ARM、MIPS 和 RISC-V 的 SDK 构建正在验证，尚未进入正式 Release；安装器会对未发布的架构安全停止，不会下载或安装错误架构的软件包。

脚本和说明同步维护：修改安装脚本时应同时更新本节；若架构安装包尚未进入统一 Release，不得在说明中标记为已支持。

**当前正式二进制支持边界（请注意）：** 目前统一 Release 中的 OpenRung 核心二进制仍仅为 `x86_64`。安装器现阶段支持 x86_64 设备上的 APK 或 IPK 包管理器自动选择；其他架构在 SDK 构建、ABI 检查和运行验收全部完成前，均不标记为正式支持。ImmortalWrt、iStoreOS、Lean、KWR​​T 等衍生固件只有在其架构、包管理器、依赖和 ABI 与现有包兼容时才可能安装；需要逐版本构建和实机验证，不能仅凭发行版名称保证兼容。

安装成功后会启用 OpenRung 服务并检查默认本地代理端口 `44025`。若软件包安装成功但端口未监听，安装器会返回非零状态并提示查看 `logread -e openrung | tail -50`；这不等于节点连接已成功。

## LuCI 修改端口

进入 OpenRung 页面，修改“本地监听端口”（1–65535），保存并应用后重启 OpenRung。状态栏会显示实际监听地址和端口。默认端口为 44025。

## 节点连接与切换

首次连接或修改节点筛选条件后，请让 OpenRung 持续运行较长时间，给节点连接和线路建立留出时间。运行中需要切换节点时，修改并保存节点筛选条件后，**重启整个 OpenWrt 路由器**；系统启动后 OpenRung 会随服务自动启动，并根据保存的配置自动切换节点。

详细操作步骤和检查命令见 [节点连接与切换说明](./NODE-CONNECTION.md)。请注意：服务进程运行或本地端口监听，不单独代表远端节点连接已经成功。

## OpenWrt 25.12 APK 安装

OpenWrt 25.12 x86_64 使用 APK 包格式。请确认设备为 x86_64，并且系统中存在 `apk` 命令。下面命令会从统一 Release 下载两个 OpenWrt APK（不是 Android 应用 APK，稳定文件名），并安装、启用服务：

```sh
# 安装前检查：确认架构和 APK 包管理器
uname -m
command -v apk || { echo '错误：当前系统找不到 apk；请先确认固件确实为 OpenWrt 25.12 APK 版本，不要继续安装'; exit 1; }
apk --version

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

**故障排查：** 如果执行 `command -v apk` 没有输出，或安装时提示 `apk: not found`，说明当前运行环境没有可用的 APK 包管理器。此时不要尝试用 `opkg` 安装这两个 APK，也不要继续执行后续 UCI/服务命令；请先核对 `cat /etc/openwrt_release`、`uname -m` 和 `command -v apk` 的输出，确认实际固件版本及架构。

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

## 许可证、版权与商业分发

- 本仓库中由项目维护者原创并有权授权的代码，采用 **GNU General Public License v3.0 or later（GPL-3.0-or-later）**。完整许可证文本见 [LICENSE](./LICENSE)。
- 允许任何人免费使用、复制、修改、分享和再分发；也允许收费出售软件副本、固件、安装服务、技术支持或保修服务。不得以收费为由取消接收者在 GPL 下的权利，也不得向下游收取其行使 GPL 权利的额外许可费。
- 分发原版或修改版时，必须遵守 GPL：保留适用的版权、许可证及无担保声明；向接收者提供 GPL 文本；修改版须显著说明修改内容和日期；分发目标代码时须按 GPL 提供与该二进制相对应的完整源代码及必要构建/安装脚本。
- 不得将本项目 GPL 覆盖的衍生作品以更严格的闭源条款再分发，不得删除或篡改原有版权/许可证声明，也不得虚假声称本项目或其上游代码由再分发者原创。
- GPL 不自动授予使用项目名称、标识、徽标或作者身份进行背书/宣传的商标或宣传权利。未经许可，不得暗示某个分支、收费版本或服务是作者官方发布或获得作者认可。
- 上述 GPL 授权只覆盖本项目维护者有权授权的原创部分。OpenRung 客户端及第三方依赖按其各自许可证和版权声明执行；不得把它们误标为本项目作者所有。具体边界见 [COPYRIGHT.md](./COPYRIGHT.md) 与 [THIRD_PARTY_NOTICES.md](./THIRD_PARTY_NOTICES.md)。

### 二进制包与对应源码

- IPK 中的客户端来自 OpenRung 上游仓库；构建时会将上游 `LICENSE` 和 `THIRD_PARTY_NOTICES.md` 安装到 `/usr/share/openrung/`，保留第三方版权、许可证文本和适用的附加条款。
- 每次构建会记录打包仓库与 OpenRung 上游的精确 Git commit，并在包内提供 `SOURCE-INFO.txt`。
- Actions 源码 artifact 仍作为构建过程副本保留 30/90 天。APK 构建工作流会把该次 APK 对应的完整源码包及 SHA256 文件直接上传到统一 Release；IPK 构建成功后，后置源码工作流会校验并上传对应源码包及 SHA256 文件。源码包均包含精确打包源码、上游源码快照、vendor 依赖、许可证/第三方声明、构建元数据和校验清单。APK/IPK 发布工作流的清理步骤均配置为保留这些源码附件。
- 用户或再分发者应核对包内 `SOURCE-INFO.txt` 的精确 commit。不能用最新版源码或不匹配的构建快照代替对应源码。

**注意：** 本仓库的版权声明不代表对所有第三方依赖重新授权。分发 APK/IPK 时，请保留包内许可证和第三方声明文件，并确保每个组件的许可证义务均已满足。

## 源码归档与历史版本说明

- 当前稳定二进制下载入口只有 [统一 Release：openwrt-packages](https://github.com/mengxianbo/openwrt-openrung/releases/tag/openwrt-packages)。该 Release 发布 APK、IPK、ZIP 合集和校验文件；对应源码归档通过 GitHub Actions artifacts 单独提供，不要把源码 artifact 误认为 Release 附件。
- 当前 IPK 对应源码说明见 [FUTURE-SOURCE-DISTRIBUTION.md](./FUTURE-SOURCE-DISTRIBUTION.md)。
- [SOURCE-DISTRIBUTION.md](./SOURCE-DISTRIBUTION.md) 仅记录历史 Build #24 的源码归档与精确版本，不代表当前 Release 或当前构建。

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

[⭐ Star this project](https://github.com/mengxianbo/openwrt-openrung) · [View Repository](https://github.com/mengxianbo/openwrt-openrung) · [Contact](mailto:mengxianbo556677@gmail.com)

**联系邮箱：** [mengxianbo556677@gmail.com](mailto:mengxianbo556677@gmail.com)

</div>
