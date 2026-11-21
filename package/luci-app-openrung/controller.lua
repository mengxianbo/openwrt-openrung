module("luci.controller.openrung", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/openrung") then
        return
    end
    entry({"admin", "services", "openrung"}, cbi("openrung/main"), _("OpenRung"), 90).dependent = false
end
