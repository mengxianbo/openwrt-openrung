local sys = require "luci.sys"

local m = Map("openrung", translate("OpenRung"), translate("管理 OpenRung 本地代理。当前版本默认使用无 TUN 权限要求的代理模式。"))
local s = m:section(NamedSection, "main", "openrung", translate("连接设置"))
s.addremove = false

local e = s:option(Flag, "enabled", translate("启用服务"))
e.rmempty = false
e.default = "0"

local mode = s:option(ListValue, "mode", translate("运行模式"))
mode:value("proxy", "HTTP / SOCKS5 本地代理（推荐）")
mode:value("tun", "TUN（当前构建禁用）")
mode.default = "proxy"
mode.description = translate("当前设备未检测到 /dev/net/tun，TUN 模式不可用。")

local country = s:option(Value, "relay_country", translate("节点国家代码"))
country.placeholder = "DE"
country.description = translate("两位国家代码，例如 DE、US、SG。留空表示自动选择。")

local rid = s:option(Value, "relay_id", translate("指定 Relay ID"))
rid.placeholder = "relay_xxxxx"
rid.description = translate("填写后优先按精确 Relay ID 连接；留空则不限制 ID。")

local label = s:option(Value, "relay_label", translate("节点标签"))
label.placeholder = "Germany"
label.description = translate("可选筛选条件；建议 Relay ID、国家代码、标签三者只设置一个。")

local status = s:option(DummyValue, "_status", translate("服务状态"))
status.rawhtml = true
function status.cfgvalue(self, section)
    local running = (sys.call("pgrep -f '/usr/bin/openrung-client connect' >/dev/null 2>&1") == 0)
    return running and translate("运行中（请检查日志确认已成功连接）") or translate("未运行")
end

local log = s:option(DummyValue, "_log", translate("查看日志命令"))
log.rawhtml = false
function log.cfgvalue(self, section)
    return "logread -e openrung"
end

return m
