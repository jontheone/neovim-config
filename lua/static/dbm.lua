local db = require("lib.psmanager")
local pick = require("static.pickers")

local M = {}

M.CheckDatabase = function()
    local ret = db.CheckDatabase(vim.g.wiki_root)
    if ret == -1 then
        print("Failed to check the database, check ~/.local/share/nvim/postgreslogs")
    elseif ret == 0 then
        print("Database in order")
    elseif ret == 1 then
        print("database in order, but with warnings, check ~/.local/share/nvim/postgreslogs")
    else
        print("seila")
    end
end

---@param force boolean|nil
M.Update = function(force)
    local ret
    if force then
        ret = db.UpdateForce(vim.g.wiki_root)
    else
        ret = db.Update(vim.g.wiki_root)
    end
    if ret == -1 then
        print("Failed to update the database, check ~/.local/share/nvim/postgreslogs")
    elseif ret == 0 then
        print("Database in order")
    elseif ret == 1 then
        print("database in order, but with warnings, check ~/.local/share/nvim/postgreslogs")
    end
end

M.sync = function()
    local ret = M.CheckDatabase()
    if not ret > -1 then
        return
    end
    ret = M.Update()
    if not ret > -1 then
        return
    end
    print("Runned check and update and everything seems fine")
end

---@param query string
M.Querydb = function(query)
    assert(type(query) == "string", "Could not process the query, its type is not string")
    local res = db.Querydb(query);
    print(vim.inspect(res));
end

---@param expr string
M.QueryExpr = function(expr)
    local res = db.Expr(expr)
    local entries = {}
    for _, item in ipairs(res) do
        local tbl = {}
        tbl.path = vim.fs.joinpath(vim.g.wiki_root, item)
        tbl.ordinal = item
        tbl.display = item
        table.insert(entries, tbl)
    end
    pick.FilePicker(entries)
end


--M.Update()


return M
