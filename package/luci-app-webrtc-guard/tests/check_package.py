#!/usr/bin/env python3
import io
import pathlib
import tarfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
IPK = pathlib.Path("dist/luci-app-webrtc-guard_1.0.0-r1_all.ipk")

required = [
    "root/etc/config/webrtc_guard",
    "root/etc/init.d/webrtc_guard",
    "root/usr/libexec/webrtc_guard",
    "root/usr/lib/lua/luci/controller/webrtc_guard.lua",
    "root/usr/lib/lua/luci/model/cbi/webrtc_guard.lua",
]

for rel in required:
    path = ROOT / rel
    if not path.is_file() or path.stat().st_size == 0:
        raise SystemExit(f"FAIL: missing/empty source file: {rel}")

script = (ROOT / "root/usr/libexec/webrtc_guard").read_text()
for token in ('3478', '5349', '19302-19309', 'table inet webrtc_guard',
              'iifname "$LAN_IFACE"', 'udp dport', 'counter drop'):
    if token not in script:
        raise SystemExit(f"FAIL: expected policy token missing: {token}")

if 'nft delete table inet webrtc_guard' not in script:
    raise SystemExit("FAIL: private table cleanup missing")
if '/etc/config/firewall' in script:
    raise SystemExit("FAIL: plugin must not edit firewall config")

with tarfile.open(IPK, "r:gz") as outer:
    names = set(outer.getnames())
    for name in ("./debian-binary", "./control.tar.gz", "./data.tar.gz"):
        if name not in names:
            raise SystemExit(f"FAIL: invalid IPK outer member: {name}")
    control_blob = outer.extractfile("./control.tar.gz").read()
    data_blob = outer.extractfile("./data.tar.gz").read()

with tarfile.open(fileobj=io.BytesIO(control_blob), mode="r:gz") as control_tar:
    control = control_tar.extractfile("./control").read().decode()
    if "Package: luci-app-webrtc-guard" not in control:
        raise SystemExit("FAIL: package name mismatch")
    if "Architecture: all" not in control:
        raise SystemExit("FAIL: package architecture mismatch")
    if "License: GPL-3.0-or-later" not in control:
        raise SystemExit("FAIL: package license metadata missing")

with tarfile.open(fileobj=io.BytesIO(data_blob), mode="r:gz") as data_tar:
    data_names = set(data_tar.getnames())
    for rel in required:
        packaged = "./" + rel.removeprefix("root/")
        if packaged not in data_names:
            raise SystemExit(f"FAIL: package missing {packaged}")
    if "./usr/share/licenses/luci-app-webrtc-guard/LICENSE" not in data_names:
        raise SystemExit("FAIL: embedded LICENSE missing")

print("PASS: WebRTC Guard package structure, metadata and policy checks")
