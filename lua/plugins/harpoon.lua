return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()
        vim.keymap.set("n", "<leader>gg", function() harpoon:list():add() end, { desc = "add harpoon"})
        vim.keymap.set("n", "<Leader>gh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "view harpoon menu"})
        vim.keymap.set("n", "<Leader>gk", function() harpoon:list():prev() end, { desc = "go to prev file in list"})
        vim.keymap.set("n", "<Leader>gj", function() harpoon:list():next() end, { desc = "go to next file in list"})
    end
}

