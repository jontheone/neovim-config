local db = require("lib.psmanager")

local M = {}

M.CheckDatabase = function()
    local ret = db.CheckDatabase(vim.g.wiki_root)
    if ret == -1 then
        print("Failed to check the database, check ~/.local/share/nvim/postgreslogs")
    elseif ret == 0 then
        print("Database in order")
    elseif ret == 1 then
        print("database in order, bur with warnings, check ~/.local/share/nvim/postgreslogs")
    else
        print("seila")
    end
end

M.Update = function()
end


return M
