return {
    "folke/snacks.nvim",
    config = function()
        local Snacks = require("snacks")
        vim.keymap.set('n', '<S-d>', function() Snacks.bufdelete.delete() end, { noremap = true })
        --vim.keymap.set("n", "<Leader>ff", function() Snacks.picker.files({hidden=true}) end, { desc = "find files in curr dir" } )
--        vim.keymap.set("n", "<Leader>fw", function() Snacks.picker.files({hidden=true, cwd=vim.g.wiki_root}) end, { desc = "find files in curr dir" } )
--        vim.keymap.set("n", "<Leader>fc", function() Snacks.picker.files({ cwd="~/appdata/local/nvim" }) end, { desc = "find files in curr dir" } )
        vim.keymap.set("n", "<Leader>fl", function() Snacks.picker.lines() end ,{ desc = "fuzzy find buffer" })
--        vim.keymap.set("n", "<Leader>fb", function() Snacks.picker.buffers() end, {desc="search for list of buffers"})
--        vim.keymap.set("n", "<leader>fg", function() Snacks.picker.grep({hidden=true}) end)
--        vim.keymap.set("n", "<Leader>p", function() Snacks.picker.registers() end, { desc = "lists registers" })
    end,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = { enabled = false },
        dashboard = { enabled = false },
        explorer = { enabled = false },
        indent = { enabled = false },
        input = { enabled = true },
        picker = { enabled = true },
        notifier = { enabled = false },
        quickfile = { enabled = true },
        scope = { enabled = false },
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = false },
    },
}
