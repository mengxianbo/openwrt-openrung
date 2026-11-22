local m = Map("webrtc_guard", translate("JianxianApp WebRTC 防泄漏"),
	translate("智能模式仅拦截常见 STUN/TURN UDP 端口，尽量保留普通 UDP 通信。保存并应用后规则立即生效。"))

local s = m:section(NamedSection, "main", "webrtc_guard", translate("防护设置"))
s.addremove = false

local enabled = s:option(Flag, "enabled", translate("启用智能防泄漏"))
enabled.rmempty = false
enabled.default = "0"
enabled.description = translate("默认关闭。启用后，对所选 LAN 接口转发的常见 STUN/TURN UDP 端口执行阻断。")

local iface = s:option(Value, "lan_ifname", translate("LAN 接口"))
iface.rmempty = false
iface.default = "br-lan"
iface.description = translate("通常为 br-lan。只填写接口名称，不要填写 IP 地址；可用 ip -br link 确认。")

local note = s:option(DummyValue, "_limitations", translate("工作原理与限制"))
note.rawhtml = false
note.default = translate("本插件只处理常见 UDP 端口 3478、5349、19302–19309。WebRTC/STUN 可使用其他端口、TCP 或中继，因此路由器规则不能保证阻止所有 WebRTC 地址暴露。浏览器端仍应启用 mDNS/隐私保护，并在代理客户端中确保 IPv4、IPv6 与 UDP 路由策略一致。启用后部分语音/视频通话可能回退或失败。")

function m.on_after_commit(self)
	luci.sys.call("/etc/init.d/webrtc_guard reload >/dev/null 2>&1")
end

return m
