local fmd = require("static.FMD")
local flt = require("static.floaterminal")
local dbm = require("static.dbm")

--commands


vim.api.nvim_create_user_command("UpdateWiki", function() dbm.Update() end, { desc = "Run an update on the wiki"})
vim.api.nvim_create_user_command("UpdateWikiForce", function() dbm.Update(true) end, { desc = "Run a full update on all the wiki files"})
vim.api.nvim_create_user_command("Sync", function() dbm.sync() end, { desc = "Complete sync of the database, run in case of new pc or change in locations"})
vim.api.nvim_create_user_command("Expr", function(opts) dbm.QueryExpr(opts.args)  end, { desc = "Pass a sql expression to filter the paths", nargs="?"})

-- keymaps
vim.keymap.set("n", "<CR>", function() fmd.followMdLinks() end)
vim.keymap.set("n", "<leader>t", function() flt.floaterminal() end)
--vim.keymap.set("n", "<leader>md", function() meta.FileSearcher.main() end)


-- other modules

