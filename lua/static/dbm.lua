local db = require("lib.psmanager")

local M = {}

M.CheckDatabase = function()
    local ret = db.CheckDatabase(vim.g.wiki_root)
    if ret == -1 then
        print("\nFailed to check the database, check ~/.local/share/nvim/postgreslogs")
    elseif ret == 0 then
        print("\nDatabase in order")
    elseif ret == 1 then
        print("\ndatabase in order, bur with warnings, check ~/.local/share/nvim/postgreslogs")
    end
end

M.CheckDatabase()

return M
