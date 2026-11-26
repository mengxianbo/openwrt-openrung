local sys = require "luci.sys"
local json = require "luci.jsonc"

local function directory()
    local raw = sys.exec("/usr/bin/openrung-client list 2>/dev/null")
    if not raw or raw == "" then return nil, translate("目录接口尚未安装或查询失败") end
    local ok, data = pcall(json.parse, raw)
    if not ok or type(data) ~= "table" or type(data.relays) ~= "table" then
        return nil, translate("节点目录响应无效")
    end
    return data
end

local data, directory_error = directory()
local relays = data and data.relays or {}

local m = Map("openrung", translate("OpenRung"),
    translate("管理 OpenRung 本地代理和真实 Relay 节点。节点来自客户端验证过签名的目录，并按 TCP 探测延迟排序。"))
local s = m:section(NamedSection, "main", "openrung", translate("连接设置"))
s.addremove = false

local e = s:option(Flag, "enabled", translate("启用服务"))
e.rmempty = false
e.default = "1"

local mode = s:option(ListValue, "mode", translate("运行模式"))
mode:value("proxy", "HTTP / SOCKS5 本地代理")
mode.default = "proxy"
mode.description = translate("当前版本使用本地代理模式，监听地址固定为 127.0.0.1。")

local port = s:option(Value, "proxy_port", translate("本地监听端口"))
port.datatype = "port"
port.default = "44025"
port.rmempty = false

local selection = s:option(ListValue, "selection_mode", translate("节点选择模式"))
selection:value("auto", translate("自动选择（按国家筛选）"))
selection:value("manual", translate("手动选择指定节点"))
selection.default = "auto"
selection.rmempty = false
selection.description = translate("自动模式不固定 Relay ID；手动模式按所选 Relay ID 连接。")

local country = s:option(ListValue, "relay_country", translate("国家筛选"))
country:value("", translate("全部国家 / 自动"))
local countries = {}
for _, r in ipairs(relays) do
    local code = (r.country_code or ""):upper()
    if code:match("^[A-Z][A-Z]$") then countries[code] = r.country or code end
end
local codes = {}
for code in pairs(countries) do codes[#codes + 1] = code end
table.sort(codes)
for _, code in ipairs(codes) do country:value(code, code .. " - " .. countries[code]) end
country.description = translate("选择国家并保存后，节点列表会按该国家筛选。")

local node = s:option(ListValue, "relay_id", translate("可用 Relay 节点"))
node:value("", translate("自动选择 / 不固定节点"))
node.rmempty = true
local filter_country = (m.uci:get("openrung", "main", "relay_country") or ""):upper()
local count = 0
for _, r in ipairs(relays) do
    local code = (r.country_code or ""):upper()
    if filter_country == "" or code == filter_country then
        local label = r.label or r.city or r.country or code or "Relay"
        local latency = r.probe_ms and (tostring(r.probe_ms) .. " ms") or translate("未测得")
        local expires = r.expires_at and r.expires_at:sub(1, 10) or translate("未知")
        local display = string.format("%s | %s | %s:%s | %s | %s",
            label, code, r.host or "?", tostring(r.port or "?"), latency, expires)
        node:value(r.id, display)
        count = count + 1
    end
end
node.description = translate("显示真实可用节点、Relay ID、IP、端口、探测延迟和到期日期。筛选结果：") .. tostring(count)

local label = s:option(Value, "relay_label", translate("节点标签（可选）"))
label.placeholder = "Germany"

local status = s:option(DummyValue, "_status", translate("实际监听状态"))
function status.cfgvalue(self, section)
    local p = self.map:get(section, "proxy_port") or "44025"
    if not p:match("^%d+$") then p = "44025" end
    local n = tonumber(p)
    if not n or n < 1 or n > 65535 then p = "44025" end
    local out = sys.exec("ss -H -lnt 2>/dev/null | awk '$4 ~ /:" .. p .. "$/ {print $4}'")
    if out and out ~= "" then return translate("正在监听：") .. out:gsub("%s+$", "") end
    return translate("未检测到监听端口：") .. p .. "；请检查 logread -e openrung"
end

local directory_status = s:option(DummyValue, "_directory", translate("真实节点目录状态"))
function directory_status.cfgvalue()
    if not data then return directory_error end
    return string.format("已加载 %d 个可用节点（候选上限 %d）；更新时间：%s",
        tonumber(data.count) or #relays, tonumber(data.limit) or 0, data.fetched_at or translate("未知"))
end

local refresh = s:option(Button, "_refresh", translate("刷新节点目录"))
refresh.inputtitle = translate("查询最新可用节点")
refresh.inputstyle = "apply"
function refresh.write()
    sys.call("/usr/bin/openrung-client list >/tmp/openrung-directory-refresh.json 2>/tmp/openrung-directory-refresh.err")
end

local log = s:option(DummyValue, "_log", translate("日志查看命令"))
function log.cfgvalue() return "logread -e openrung" end

local pw_guard = s:option(Flag, "passwall_guard", translate("检测节点时暂时暂停 PassWall"))
pw_guard.default = "1"
pw_guard.rmempty = false

local pw_service = s:option(Value, "passwall_service", translate("PassWall 服务名称"))
pw_service.default = "passwall"
pw_service:value("passwall", "PassWall")
pw_service:value("passwall2", "PassWall 2")

return m
