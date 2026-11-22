#!/usr/bin/env python3
import io
import pathlib
import tarfile
ROOT = pathlib.Path(__file__).resolve().parents[1]
IPK = pathlib.Path("dist/luci-app-webrtc-guard_1.1.0-r1_all.ipk")
required = ["root/etc/config/webrtc_guard", "root/etc/init.d/webrtc_guard", "root/usr/libexec/webrtc_guard", "root/usr/lib/lua/luci/controller/webrtc_guard.lua", "root/usr/lib/lua/luci/model/cbi/webrtc_guard.lua"]
for rel in required:
    p = ROOT / rel
    if not p.is_file() or not p.stat().st_size:
        raise SystemExit(f"FAIL: missing/empty source file: {rel}")
script = (ROOT / "root/usr/libexec/webrtc_guard").read_text()
for token in ("smart4", "smart6", "strict4", "strict6", "config_foreach add_device device", "19302-19309", "counter drop", "nft delete table inet webrtc_guard"):
    if token not in script:
        raise SystemExit(f"FAIL: missing firewall policy token: {token}")
if "/etc/config/firewall" in script:
    raise SystemExit("FAIL: plugin must not edit firewall config")
cbi = (ROOT / "root/usr/lib/lua/luci/model/cbi/webrtc_guard.lua").read_text()
for token in ('mode:value("smart"', 'mode:value("strict"', 'mode:value("device"', 'TypedSection, "device"', '设备 IPv4 地址', '设备 IPv6 地址'):
    if token not in cbi:
        raise SystemExit(f"FAIL: missing LuCI option: {token}")
with tarfile.open(IPK, "r:gz") as outer:
    names = set(outer.getnames())
    for name in ("./debian-binary", "./control.tar.gz", "./data.tar.gz"):
        if name not in names:
            raise SystemExit(f"FAIL: invalid IPK outer member: {name}")
    control_blob = outer.extractfile("./control.tar.gz").read()
    data_blob = outer.extractfile("./data.tar.gz").read()
with tarfile.open(fileobj=io.BytesIO(control_blob), mode="r:gz") as tar:
    control = tar.extractfile("./control").read().decode()
    for token in ("Package: luci-app-webrtc-guard", "Version: 1.1.0-r1", "Architecture: all", "License: GPL-3.0-or-later"):
        if token not in control:
            raise SystemExit(f"FAIL: control metadata missing: {token}")
with tarfile.open(fileobj=io.BytesIO(data_blob), mode="r:gz") as tar:
    names = set(tar.getnames())
    for rel in required:
        packaged = "./" + rel.removeprefix("root/")
        if packaged not in names:
            raise SystemExit(f"FAIL: package missing {packaged}")
    if "./usr/share/licenses/luci-app-webrtc-guard/LICENSE" not in names:
        raise SystemExit("FAIL: embedded LICENSE missing")
print("PASS: three WebRTC modes, per-device IP policy, IPK metadata and license checks")
