local sys = require "luci.sys"
local jsonc = require "luci.jsonc"

local function load_directory()
    local p = io.popen("/usr/bin/openrung-relays 2>/dev/null", "r")
    if not p then
        return nil, translate("无法启动节点目录程序")
    end

    local raw = p:read("*a") or ""
    local ok = p:close()
    if not ok or raw == "" then
        return nil, translate("获取节点目录失败，请检查路由器网络及日志")
    end

    local data = jsonc.parse(raw)
    if type(data) ~= "table" or type(data.relays) ~= "table" then
        return nil, translate("节点目录格式错误")
    end

    return data
end

local directory, directory_error = load_directory()
local relays = directory and directory.relays or {}
table.sort(relays, function(a, b)
    local ak = table.concat({a.country or "", a.city or "", a.label or "", a.id or ""}, " ")
    local bk = table.concat({b.country or "", b.city or "", b.label or "", b.id or ""}, " ")
    return ak:lower() < bk:lower()
end)

local m = Map("openrung", translate("OpenRung"), translate("管理 OpenRung 本地代理。支持从在线节点目录按国家筛选并手动选择具体节点。"))
local s = m:section(NamedSection, "main", "openrung", translate("连接设置"))
s.addremove = false

local e = s:option(Flag, "enabled", translate("启用服务"))
e.rmempty = false
e.default = "0"

local mode = s:option(ListValue, "mode", translate("运行模式"))
mode:value("proxy", "HTTP / SOCKS5 本地代理（推荐）")
mode:value("tun", "TUN（当前构建禁用）")
mode.default = "proxy"
mode.description = translate("当前构建只支持 Proxy 模式。")

local country = s:option(ListValue, "relay_country", translate("筛选国家"))
country:value("", translate("全部国家"))
local country_names = {}
for _, relay in ipairs(relays) do
    local code = (relay.country_code or ""):upper()
    if code ~= "" and not country_names[code] then
        local name = relay.country or code
        country_names[code] = name .. " (" .. code .. ")"
    end
end
local country_codes = {}
for code in pairs(country_names) do
    country_codes[#country_codes + 1] = code
end
table.sort(country_codes)
for _, code in ipairs(country_codes) do
    country:value(code, country_names[code])
end
country.default = ""
country.description = translate("从在线目录筛选国家；选择国家后保存/刷新页面，再选择该国家的具体节点。")

local selected_country = m.uci:get("openrung", "main", "relay_country") or ""
local rid = s:option(ListValue, "relay_id", translate("手动选择节点"))
rid:value("", translate("自动选择节点"))
rid.rmempty = true
rid.default = ""

local found_current = false
local current_id = m.uci:get("openrung", "main", "relay_id") or ""
local visible_count = 0

for _, relay in ipairs(relays) do
    local code = (relay.country_code or ""):upper()
    if selected_country == "" or selected_country == code then
        local parts = {}
        local country_name = relay.country or code
        if country_name ~= "" then parts[#parts + 1] = country_name end
        if relay.city and relay.city ~= "" then parts[#parts + 1] = relay.city end
        if relay.label and relay.label ~= "" then parts[#parts + 1] = relay.label end
        if relay.node_class == "foundation" then
            parts[#parts + 1] = "[官方]"
        elseif relay.node_class == "volunteer" then
            parts[#parts + 1] = "[社区]"
        end
        parts[#parts + 1] = relay.id
        rid:value(relay.id, table.concat(parts, " · "))
        visible_count = visible_count + 1
        if relay.id == current_id then found_current = true end
    end
end

if current_id ~= "" and not found_current then
    rid:value(current_id, current_id .. " (" .. translate("当前保存的节点，目录中暂不可见") .. ")")
end

rid.description = translate("节点来自 OpenRung 官方签名验证目录。选择具体节点后，后台将按 Relay ID 连接；留空则由客户端自动选择。") ..
    " " .. translate("当前筛选结果：") .. tostring(visible_count)

local directory_status = s:option(DummyValue, "_directory_status", translate("节点目录状态"))
directory_status.rawhtml = false
function directory_status.cfgvalue(self, section)
    if directory then
        return translate("获取成功") .. "：" .. tostring(directory.count or #relays) .. translate(" 个节点") ..
            "；" .. translate("更新时间") .. "：" .. tostring(directory.fetched_at or "unknown")
    end
    return translate("获取失败") .. "：" .. tostring(directory_error or translate("未知错误"))
end

local proxy_port = s:option(Value, "proxy_port", translate("本地监听端口"))
proxy_port.datatype = "port"
proxy_port.default = "44025"
proxy_port.placeholder = "44025"
proxy_port.rmempty = false
proxy_port.description = translate("OpenRung 本地 HTTP / SOCKS5 混合代理监听端口，仅绑定本机回环地址。默认 44025。")

local label = s:option(Value, "relay_label", translate("节点标签（高级筛选）"))
label.placeholder = "Germany"
label.description = translate("通常留空；使用手动选择节点时无需填写。")

local status = s:option(DummyValue, "_status", translate("服务状态"))
status.rawhtml = false
function status.cfgvalue(self, section)
    local running = (sys.call("pgrep -f '/usr/bin/openrung-client connect' >/dev/null 2>&1") == 0)
    return running and translate("客户端进程运行中（请检查日志确认节点已连接）") or translate("未运行")
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
