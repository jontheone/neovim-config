local fmd = require("static.FMD")
local flt = require("static.floaterminal")

--commands

-- keymaps
vim.keymap.set("n", "<CR>", function() fmd.followMdLinks() end)
vim.keymap.set("n", "<leader>t", function() flt.floaterminal() end)
--vim.keymap.set("n", "<leader>md", function() meta.FileSearcher.main() end)


-- other modules

