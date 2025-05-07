local fmd = require("static.FMD")

vim.keymap.set("n", "<CR>", function() fmd.followMdLinks() end)
