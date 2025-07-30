local fmd = require("static.FMD")

--commands

-- keymaps
vim.keymap.set("n", "<CR>", function() fmd.followMdLinks() end)
--vim.keymap.set("n", "<leader>md", function() meta.FileSearcher.main() end)


-- other modules

