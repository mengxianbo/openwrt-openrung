module("luci.controller.webrtc_guard", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/webrtc_guard") then
		return
	end

	entry({"admin", "network", "webrtc_guard"},
		cbi("webrtc_guard"),
		_("WebRTC 防泄漏"),
		90).dependent = false
end
