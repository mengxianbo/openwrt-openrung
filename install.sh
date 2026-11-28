#!/bin/sh
# OpenRung universal installer (currently published binary packages: x86_64 only)
set -eu

REPO="mengxianbo/openwrt-openrung"
RELEASE="openwrt-packages"
BASE="https://github.com/${REPO}/releases/download/${RELEASE}"
WORK="/tmp/openrung-install"
PORT="44025"

say() { printf '%s\n' "[OpenRung] $*"; }
die() { printf '%s\n' "[OpenRung] ERROR: $*" >&2; exit 1; }

[ "$(id -u)" = "0" ] || die "请使用 root 用户运行安装器。"
[ -r /etc/openwrt_release ] || die "未检测到 /etc/openwrt_release；此安装器仅适用于 OpenWrt 衍生系统。"
command -v uname >/dev/null 2>&1 || die "缺少 uname。"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) ;;
  *) die "当前架构为 $ARCH。当前 Release 只有 x86_64 核心包，拒绝安装；ARM/MIPS/RISC-V 包尚未发布。" ;;
esac

if command -v apk >/dev/null 2>&1; then
  PM="apk"
elif command -v opkg >/dev/null 2>&1; then
  PM="opkg"
else
  die "未找到 apk 或 opkg。请检查固件包管理器，不能把 Android APK 当作 OpenWrt APK 安装。"
fi

if ! command -v wget >/dev/null 2>&1; then
  die "缺少 wget。请先在固件中安装 wget 或使用 LuCI 上传本地软件包。"
fi
command -v sha256sum >/dev/null 2>&1 || die "缺少 sha256sum，无法验证安装包完整性，已停止安装。"
command -v uci >/dev/null 2>&1 || die "缺少 uci。"
command -v df >/dev/null 2>&1 || die "缺少 df。"

say "系统信息："
grep -E '^(DISTRIB_ID|DISTRIB_RELEASE|DISTRIB_REVISION|DISTRIB_TARGET|DISTRIB_ARCH)=' /etc/openwrt_release || true
say "CPU=$ARCH；包管理器=$PM"

mkdir -p "$WORK"
cd "$WORK"

fetch() {
  url="$1"
  out="$2"
  say "下载 $out"
  wget -q -O "$out" "$url" || die "下载失败：$url"
  [ -s "$out" ] || die "下载文件为空：$out"
}

if [ "$PM" = "apk" ]; then
  CLIENT="openrung-client_x86_64.apk"
  LUCI="luci-app-openrung_all.apk"
  SUMS="APK-SHA256SUMS"
else
  CLIENT="openrung-client_x86_64.ipk"
  LUCI="luci-app-openrung_all.ipk"
  SUMS="IPK-SHA256SUMS"
fi

fetch "$BASE/$CLIENT" "$CLIENT"
fetch "$BASE/$LUCI" "$LUCI"
fetch "$BASE/$SUMS" "$SUMS"

say "验证 SHA256"
grep -E "[[:space:]]*?($CLIENT|$LUCI)$" "$SUMS" >/dev/null 2>&1 || die "校验文件中没有对应安装包条目，停止安装。"
sha256sum -c "$SUMS" 2>/dev/null | grep -E "^($CLIENT|$LUCI): OK$" >/dev/null || die "SHA256 校验失败，停止安装。"

say "检查临时目录空间"
df -k "$WORK" | tail -1

say "安装 OpenRung 核心与 LuCI"
if [ "$PM" = "apk" ]; then
  apk add --allow-untrusted "./$CLIENT" "./$LUCI" || die "APK 安装失败。请检查软件源、依赖和固件 ABI。"
else
  opkg install --force-reinstall "./$CLIENT" || die "核心 IPK 安装失败。"
  opkg install --force-reinstall "./$LUCI" || die "LuCI IPK 安装失败。"
fi

[ -x /etc/init.d/openrung ] || die "安装后未找到 /etc/init.d/openrung；请提供安装日志。"
uci set openrung.main.enabled='1'
uci set openrung.main.mode='proxy'
uci set openrung.main.proxy_port="$PORT"
uci set openrung.main.passwall_guard='1'
uci commit openrung

/etc/init.d/openrung enable
/etc/init.d/openrung restart
sleep 5

say "服务状态："
/etc/init.d/openrung status || true
ubus call service list '{"name":"openrung"}' 2>/dev/null || true

if command -v ss >/dev/null 2>&1; then
  LISTEN="$(ss -lntp 2>/dev/null | grep ":$PORT" || true)"
elif command -v netstat >/dev/null 2>&1; then
  LISTEN="$(netstat -lntp 2>/dev/null | grep ":$PORT" || true)"
else
  LISTEN=""
fi

if [ -n "$LISTEN" ]; then
  say "安装完成，检测到端口 $PORT 正在监听。"
  printf '%s\n' "$LISTEN"
else
  say "软件包已安装，但暂未检测到端口 $PORT 监听。请查看：logread -e openrung | tail -50"
  exit 2
fi

say "LuCI 页面请刷新浏览器后查看 OpenRung 菜单。"
