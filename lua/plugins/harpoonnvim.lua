return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local hp = require("harpoon")
        local set = vim.keymap.set
        hp:setup({})
        set("n", "<leader>a", function() hp:list():add() end)
        set("n", "<leader>b", function() hp.ui:toggle_quick_menu(hp:list()) end)
        set("n", "<leader>s", function()
            local list = hp:list():display()
            local path = vim.fn.expand("%:p")
            for i=1, #list do
                if path:match(list[i]) then
                    hp:list():remove_at(i)
                end
            end
        end)
        -- set("n", "<S-j>", function() hp:list():prev() end)
        -- set("n", "<S-k>", function() hp:list():next() end)
    end
}
