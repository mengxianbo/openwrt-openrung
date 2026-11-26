#!/usr/bin/env bash
set -euo pipefail

APP="$PWD/upstream/android/app/src/main"
RES="$APP/res"
mkdir -p "$RES/drawable" "$RES/values" "$RES/mipmap-anydpi" "$RES/mipmap-anydpi-v26"

# Rename the Android launcher label and VPN notification branding in every
# locale that carries these strings. Keep resource identifiers stable.
python3 - "$RES" <<'PY'
from pathlib import Path
import re, sys
root = Path(sys.argv[1])
replacements = {
    "app_name": "邪剑仙",
    "vpn_notification_channel": "邪剑仙 VPN",
    "vpn_notification_title": "邪剑仙 VPN",
    "vpn_notification_preparing": "正在启动邪剑仙 VPN",
}
for path in root.glob("values*/strings.xml"):
    text = path.read_text(encoding="utf-8")
    for key, value in replacements.items():
        pattern = rf'(<string\s+name="{re.escape(key)}"[^>]*>).*?(</string>)'
        text, count = re.subn(pattern, lambda m: m.group(1) + value + m.group(2), text, flags=re.S)
    path.write_text(text, encoding="utf-8")
PY

cat > "$RES/drawable/xiejianxian_launcher_foreground.xml" <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <!-- Outer hellfire silhouette -->
    <path android:fillColor="#8B0000"
        android:pathData="M54,4 C49,17 35,19 31,33 C27,43 33,50 24,59 C16,68 20,80 31,84 C26,72 36,66 39,57 C42,48 37,40 45,32 C48,27 52,23 54,16 C57,25 65,29 68,38 C72,48 64,54 70,65 C74,73 82,76 77,87 C92,78 91,64 81,55 C74,49 78,39 72,29 C67,18 59,15 54,4 Z" />
    <path android:fillColor="#E21B16"
        android:pathData="M54,17 C49,29 41,31 40,43 C39,51 32,56 34,65 C36,73 44,77 43,87 C49,81 51,74 48,66 C45,57 52,52 54,43 C57,52 64,57 61,66 C59,74 63,82 69,88 C68,77 78,73 76,63 C74,54 67,49 68,40 C67,30 60,24 54,17 Z" />
    <path android:fillColor="#FF5A24"
        android:pathData="M54,30 C50,39 47,44 48,52 C49,59 44,64 47,71 C50,67 52,62 54,57 C56,63 59,68 62,72 C65,64 59,58 60,51 C61,43 58,36 54,30 Z" />
    <!-- Sword blade -->
    <path android:fillColor="#FFF0E6"
        android:pathData="M51,25 L57,25 L62,70 L54,96 L46,70 Z" />
    <path android:fillColor="#FF3A20"
        android:pathData="M54,30 L57,69 L54,87 L51,69 Z" />
    <path android:fillColor="#F6B18B"
        android:pathData="M51,27 L54,27 L49,69 L46,70 Z" />
    <!-- Crossguard and grip -->
    <path android:fillColor="#250707"
        android:pathData="M27,42 L45,46 L49,40 L59,40 L63,46 L81,42 L77,51 L61,50 L58,55 L50,55 L47,50 L31,51 Z" />
    <path android:fillColor="#FF4A24"
        android:pathData="M30,44 L46,48 L49,44 L59,44 L62,48 L78,44 L75,48 L60,48 L57,52 L51,52 L48,48 L33,48 Z" />
    <path android:fillColor="#1B0505"
        android:pathData="M49,12 L59,12 L59,37 L49,37 Z" />
    <path android:fillColor="#B80E12"
        android:pathData="M51,14 L57,14 L57,35 L51,35 Z" />
    <path android:fillColor="#FF9A45"
        android:pathData="M54,7 L61,14 L54,20 L47,14 Z" />
    <path android:fillColor="#5C0808"
        android:pathData="M54,9 L58,14 L54,17 L50,14 Z" />
    <!-- Pommel -->
    <path android:fillColor="#FF4A24"
        android:pathData="M49,55 L59,55 L57,61 L54,64 L51,61 Z" />
</vector>
XML

cat > "$RES/values/xiejianxian_colors.xml" <<'XML'
<resources>
    <color name="xiejianxian_icon_background">#160202</color>
</resources>
XML

cat > "$RES/mipmap-anydpi-v26/ic_launcher.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/xiejianxian_icon_background" />
    <foreground android:drawable="@drawable/xiejianxian_launcher_foreground" />
</adaptive-icon>
XML
cp "$RES/mipmap-anydpi-v26/ic_launcher.xml" "$RES/mipmap-anydpi-v26/ic_launcher_round.xml"

# Pre-adaptive-icon fallback: use the same vector art as a regular launcher icon.
cat > "$RES/mipmap-anydpi/ic_launcher.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<inset xmlns:android="http://schemas.android.com/apk/res/android"
    android:drawable="@drawable/xiejianxian_launcher_foreground"
    android:inset="0dp" />
XML
cp "$RES/mipmap-anydpi/ic_launcher.xml" "$RES/mipmap-anydpi/ic_launcher_round.xml"

echo "Applied 邪剑仙 app label, VPN notification branding, and red hellfire sword launcher icon."
