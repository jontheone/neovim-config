local fmd = require("static.FMD")
local meta = require("static.metadata")
local buffer_list = require("static.DisplayBuf")

-- keymaps

vim.keymap.set("n", "<CR>", function() fmd.followMdLinks() end)
vim.keymap.set("n", "<leader>md", function() meta.FileSearcher.main() end)

-- autocmds

--vim.api.nvim_create_autocmd("BufEnter", {callback=function()
--    if not (vim.g.buffer_active) then
--        buffer_list.notify()
--    end
--end})
