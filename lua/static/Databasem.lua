package.path = package.path..";/usr/local/share/lua/5.4/?.lua"
local status, DBI = pcall(function() return require("DBI") end)


local M = {}

if not status then
    print("Could not load LuaDBI module. Any database functionality will not work until you install it on you enviroment. Consult luarocks for details on installation.")
    return {}
else
    return M
end
