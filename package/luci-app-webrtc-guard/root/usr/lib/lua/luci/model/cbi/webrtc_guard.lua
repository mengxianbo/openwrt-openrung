local m = Map("webrtc_guard", translate("JianxianApp WebRTC 防泄漏"),
	translate("选择全局智能防泄漏、严格阻断，或仅保护指定设备。保存后立即应用。"))
local s = m:section(NamedSection, "main", "webrtc_guard", translate("全局防护"))
s.addremove = false
local enabled = s:option(Flag, "enabled", translate("启用防护"))
enabled.rmempty = false
enabled.default = "0"
local mode = s:option(ListValue, "mode", translate("防护模式"))
mode:value("smart", translate("智能防泄漏（推荐）"))
mode:value("strict", translate("严格阻断模式"))
mode:value("device", translate("按设备防护"))
mode.default = "smart"
mode.rmempty = false
mode.description = translate("智能模式阻断常见 STUN/TURN UDP 端口；严格模式阻断转发 UDP（保留 DNS 53 和 NTP 123）并阻断 TCP 3478/5349；按设备模式只匹配下方设备清单。")
local iface = s:option(Value, "lan_ifname", translate("LAN 接口"))
iface.rmempty = false
iface.default = "br-lan"
local d = m:section(TypedSection, "device", translate("设备防护清单"))
d.addremove = true
d.anonymous = false
d.template = "cbi/tblsection"
d.description = translate("仅在按设备防护模式时生效。请填写设备固定 IPv4 和/或 IPv6 地址，建议设置 DHCP 静态租约。")
local name = d:option(Value, "name", translate("设备名称"))
name.rmempty = true
local ipv4 = d:option(Value, "ipv4", translate("设备 IPv4 地址"))
ipv4.rmempty = true
ipv4.placeholder = "10.10.10.20"
local ipv6 = d:option(Value, "ipv6", translate("设备 IPv6 地址"))
ipv6.rmempty = true
ipv6.placeholder = "fd00::20"
local policy = d:option(ListValue, "policy", translate("该设备策略"))
policy:value("smart", translate("智能防泄漏"))
policy:value("strict", translate("严格阻断"))
policy.default = "smart"
policy.rmempty = false
local note = m:section(SimpleSection)
local warning = note:option(DummyValue, "_limitations", translate("重要说明"))
warning.rawhtml = false
warning.default = translate("智能模式只是常见 STUN UDP 直连缓解，不保证拦截所有 WebRTC。严格模式会明显影响 QUIC、游戏、语音和视频。按设备模式按 IP 地址匹配，地址变化后必须同步更新。路由器无法阻止浏览器在本机页面显示本地候选地址，也不能替代浏览器隐私设置及正确的代理 UDP/IPv6 路由。")
function m.on_after_commit(self)
	luci.sys.call("/etc/init.d/webrtc_guard reload >/dev/null 2>&1")
end
return m
