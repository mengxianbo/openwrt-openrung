local sys = require "luci.sys"

local m = Map("openrung", translate("OpenRung"), translate("管理 OpenRung 本地代理。固定监听 127.0.0.1:44025，由 procd 在后台持续守护。"))
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

local fixed_port = s:option(DummyValue, "_fixed_proxy_port", translate("固定本地监听端口"))
function fixed_port.cfgvalue(self, section)
    return "127.0.0.1:44025（固定，不允许随机分配）"
end

local label = s:option(Value, "relay_label", translate("节点标签"))
label.placeholder = "Germany"
label.description = translate("可选筛选条件；建议 Relay ID、国家代码、标签三者只设置一个。")

local status = s:option(DummyValue, "_status", translate("服务状态"))
status.rawhtml = false
function status.cfgvalue(self, section)
    local service_running = (sys.call("ubus call service list '{\"name\":\"openrung\"}' 2>/dev/null | grep -q '\"running\"[[:space:]]*:[[:space:]]*true'") == 0)
    local listening = (sys.call("(ss -lnt 2>/dev/null || netstat -lnt 2>/dev/null) | grep -Eq '127\\.0\\.0\\.1:44025([[:space:]]|$)'") == 0)

    if listening then
        return translate("运行正常：127.0.0.1:44025 正在监听")
    elseif service_running then
        return translate("进程运行中，但 44025 尚未监听；请检查连接日志")
    end
    return translate("未运行：请检查启用开关和系统日志")
end

local log = s:option(DummyValue, "_log", translate("查看日志命令"))
log.rawhtml = false
function log.cfgvalue(self, section)
    return "logread -e openrung"
end

local pw_guard = s:option(Flag, "passwall_guard", translate("检测节点时暂时暂停 PassWall"))
pw_guard.default = "1"
pw_guard.rmempty = false
pw_guard.description = translate("执行 openrung-client check 时暂停原本正在运行的 PassWall，检测结束后恢复；原本关闭则保持关闭。")

local pw_service = s:option(Value, "passwall_service", translate("PassWall 服务名称"))
pw_service.default = "passwall"
pw_service:value("passwall", "PassWall")
pw_service:value("passwall2", "PassWall 2")
pw_service.description = translate("通常保持默认 passwall；使用 PassWall 2 时选择 passwall2。")

return m
