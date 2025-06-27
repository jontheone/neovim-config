local fmd = require("static.FMD")
local buffer_list = require("static.DisplayBuf")

--commands

-- keymaps
vim.keymap.set("n", "<CR>", function() fmd.followMdLinks() end)
--vim.keymap.set("n", "<leader>md", function() meta.FileSearcher.main() end)


-- other modules

require("static.filesystem") -- this is the module for functions related to my filesystem
