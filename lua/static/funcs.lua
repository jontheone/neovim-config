local fmd = require("static.FMD")
local flt = require("static.floaterminal")
local dbm = require("static.dbm")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

--commands


vim.api.nvim_create_user_command("UpdateWiki", function() dbm.Update() end, { desc = "Run an update on the wiki"})
vim.api.nvim_create_user_command("UpdateWikiForce", function() dbm.Update(true) end, { desc = "Run a full update on all the wiki files"})
vim.api.nvim_create_user_command("Sync", function() dbm.sync() end, { desc = "Complete sync of the database, run in case of new pc or change in locations"})
vim.api.nvim_create_user_command("Expr", function(opts) dbm.QueryExpr(opts.args)  end, { desc = "Pass a sql expression to filter the paths", nargs="?"})
vim.api.nvim_create_user_command("Quer", function(opts) dbm.Querydb(opts.args)  end, { desc = "Pass a sql query and the system executes it", nargs="?"})
vim.api.nvim_create_user_command("Fields", function(opts)
    local _,i = opts.args:find("%s")
    local expr
    local data = opts.args
    if i then
        expr = opts.args:sub(i+1)
        data = opts.args:sub(0, i-1)
    end
    dbm.ShowData(data, expr)
end, { desc = "Pass a sql query and the system executes it", nargs="?"})
vim.api.nvim_create_user_command("Arg", function()
end, { desc="Summon the picker that manages the arglist" })

-- keymaps
vim.keymap.set("n", "<CR>", function() fmd.followMdLinks() end)
vim.keymap.set("n", "<leader>t", function() flt.floaterminal() end)
vim.keymap.set("n","<leader>j", function()
    local count = vim.v.count > 0 and vim.v.count or 1
    local ret, _ = pcall(vim.cmd.argument, count)
    if not ret then
        print("Not a valid index")
    end
    print(string.format("[%s]", vim.fn.expand("%")))
end, { desc = "change to the file in the arglist" })
vim.keymap.set("n","<leader>ga", function() vim.cmd.argadd(vim.fn.expand("%")) end, { desc = "Add the current file to the arglist" })
vim.keymap.set("n","<leader>gr", function() vim.cmd.argdel(vim.fn.expand("%")) end, { desc = "Remove the current file from the arglist" })
vim.keymap.set("n","<C-l>", function() pcall(vim.cmd.next) end, { desc = "Move left in the arglist(towards the end)" })
vim.keymap.set("n","<C-h>", function() pcall(vim.cmd.prev) end, { desc = "Move right in the arglist(towards the begining)" })
vim.keymap.set("n","<leader>b", function() vim.cmd("args") end, { desc = "Show args list" })


-- other modules

