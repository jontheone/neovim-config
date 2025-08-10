local db = require("lib.psmanager")

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

--M.Update()


return M
