return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local hp = require("harpoon")
        local set = vim.keymap.set
        hp:setup({})
--        set("n", "<leader>a", function() hp:list():add() end)
--        set("n", "<leader>b", function() hp.ui:toggle_quick_menu(hp:list()) end)
--        set("n", "<leader>s", function()
--            local list = hp:list():display()
--            local path = vim.fn.expand("%:p")
--            for i=1, #list do
--                if path:match(list[i]) then
--                    hp:list():remove_at(i)
--                end
--            end
--        end)
--        vim.api.nvim_create_user_command("GG", function(opts) hp:list():select(tonumber(opts.args)) end, {nargs = "?"})
--        set("n", "<leader>ga", function() hp:list():select(1) end)
--        set("n", "<leader>gs", function() hp:list():select(2) end)
--        set("n", "<leader>gd", function() hp:list():select(3) end)
--        set("n", "<leader>gf", function() hp:list():select(4) end)
--        set("n", "<C-h>", function() hp:list():prev() end)
--        set("n", "<C-l>", function() hp:list():next() end)
    end
}
