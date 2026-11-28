#!/bin/sh
# OpenRung multi-architecture installer.
# Selects only an exact, published OpenWrt target + package-manager combination.
set -eu

REPO="mengxianbo/openwrt-openrung"
RELEASE_TAG="openwrt-packages-multiarch"
BASE="https://github.com/${REPO}/releases/download/${RELEASE_TAG}"
WORK="/tmp/openrung-install"
PORT="44025"

say() { printf '%s\n' "[OpenRung] $*"; }
die() { printf '%s\n' "[OpenRung] ERROR: $*" >&2; exit 1; }
read_release_value() {
  sed -n "s/^$1=//p" /etc/openwrt_release | head -n 1 | tr -d "'\""
}

[ "$(id -u)" = "0" ] || die "请使用 root 用户运行安装器。"
[ -r /etc/openwrt_release ] || die "未检测到 /etc/openwrt_release；此安装器仅适用于 OpenWrt 衍生系统。"

DIST_RELEASE="$(read_release_value DISTRIB_RELEASE)"
TARGET="$(read_release_value DISTRIB_TARGET)"
ARCH="$(read_release_value DISTRIB_ARCH)"
[ -n "$DIST_RELEASE" ] || die "无法识别 DISTRIB_RELEASE。"
[ -n "$TARGET" ] || die "无法识别 DISTRIB_TARGET。"
[ -n "$ARCH" ] || die "无法识别 DISTRIB_ARCH；为避免装错 ABI，已停止。"

if command -v apk >/dev/null 2>&1; then
  PM="apk"
elif command -v opkg >/dev/null 2>&1; then
  PM="opkg"
else
  die "未找到 apk 或 opkg。请检查固件包管理器。"
fi

# This mapping is intentionally target-specific. Do not infer compatibility
# from uname -m alone: MIPS endian/word-size/float ABI variants are distinct.
case "$DIST_RELEASE:$PM:$TARGET" in
  25.12.*:apk:x86/64)       SLUG="x86_64"; CLIENT="openrung-client_x86_64.apk"; LUCI="luci-app-openrung_all.apk" ;;
  25.12.*:apk:armsr/armv8)  SLUG="arm64-armsr-armv8" ;;
  25.12.*:apk:armsr/armv7)  SLUG="armv7-armsr-armv7" ;;
  25.12.*:apk:ramips/mt7621) SLUG="mipsel-ramips-mt7621" ;;
  25.12.*:apk:malta/be)    SLUG="mips-malta-be" ;;
  25.12.*:apk:ath79/generic) SLUG="mips-ath79-generic" ;;
  25.12.*:apk:malta/le)    SLUG="mipsel-malta-le" ;;
  25.12.*:apk:malta/le64)  SLUG="mips64el-malta-le64" ;;
  25.12.*:apk:octeon/generic) SLUG="mips64-octeon" ;;
  25.12.*:apk:sifiveu/generic) SLUG="riscv64-sifiveu" ;;
  25.12.*:apk:starfive/generic) SLUG="riscv64-starfive" ;;

  24.10.*:opkg:x86/64)       SLUG="x86_64"; CLIENT="openrung-client_x86_64.ipk"; LUCI="luci-app-openrung_all.ipk" ;;
  24.10.*:opkg:armsr/armv8)  SLUG="arm64-armsr-armv8" ;;
  24.10.*:opkg:armsr/armv7)  SLUG="armv7-armsr-armv7" ;;
  24.10.*:opkg:ramips/mt7621) SLUG="mipsel-ramips-mt7621" ;;
  24.10.*:opkg:malta/be)    SLUG="mips-malta-be" ;;
  24.10.*:opkg:ath79/generic) SLUG="mips-ath79-generic" ;;
  24.10.*:opkg:malta/le)    SLUG="mipsel-malta-le" ;;
  24.10.*:opkg:malta/le64)  SLUG="mips64el-malta-le64" ;;
  24.10.*:opkg:octeon/generic) SLUG="mips64-octeon" ;;
  24.10.*:opkg:sifiveu/generic) SLUG="riscv64-sifiveu" ;;
  24.10.*:opkg:starfive/generic) SLUG="riscv64-starfive" ;;
  *)
    die "未发布或未验证的系统组合：版本=$DIST_RELEASE，目标=$TARGET，架构=$ARCH，包管理器=$PM。已安全停止；不会尝试安装近似架构的软件包。"
    ;;
esac

if [ -z "${CLIENT:-}" ]; then
  if [ "$PM" = "apk" ]; then
    CLIENT="openrung-client-$SLUG.apk"
    LUCI="luci-app-openrung-$SLUG.apk"
  else
    CLIENT="openrung-client-$SLUG.ipk"
    LUCI="luci-app-openrung-$SLUG.ipk"
  fi
fi

for cmd in wget sha256sum uci df; do
  command -v "$cmd" >/dev/null 2>&1 || die "缺少必要命令：$cmd"
done

say "系统版本：$DIST_RELEASE"
say "目标平台：$TARGET"
say "发行架构：$ARCH"
say "包管理器：$PM"
say "选择核心包：$CLIENT"
say "选择 LuCI 包：$LUCI"

mkdir -p "$WORK"
cd "$WORK"

fetch() {
  url="$1"
  out="$2"
  say "下载 $out"
  wget -q -O "$out" "$url" || die "下载失败：$url"
  [ -s "$out" ] || die "下载文件为空：$out"
}

fetch "$BASE/$CLIENT" "$CLIENT"
fetch "$BASE/$LUCI" "$LUCI"
fetch "$BASE/$CLIENT.sha256" "$CLIENT.sha256"
fetch "$BASE/$LUCI.sha256" "$LUCI.sha256"

say "验证 SHA256"
sha256sum -c "$CLIENT.sha256" >/dev/null 2>&1 || die "$CLIENT SHA256 校验失败。"
sha256sum -c "$LUCI.sha256" >/dev/null 2>&1 || die "$LUCI SHA256 校验失败。"

# opkg checks the IPK Architecture field against its configured architecture list.\n# Do not use force-depends or force-architecture; ABI mismatches must fail closed.\n
say "检查临时目录空间"
df -k "$WORK" | tail -1

say "安装 OpenRung 核心与 LuCI"
if [ "$PM" = "apk" ]; then
  apk add --allow-untrusted "./$CLIENT" "./$LUCI" || die "APK 安装失败。请检查固件源、依赖及 ABI。"
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
