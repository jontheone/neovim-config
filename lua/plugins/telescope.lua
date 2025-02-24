return {
    "nvim-telescope/telescope.nvim",
    dependencies = { 'nvim-lua/plenary.nvim', 'BurntSushi/ripgrep'},
    config = function(_, opts)
        local builtin = require("telescope.builtin")
        require("telescope").setup(opts)
        require("telescope").load_extension("todo-comments")
        vim.keymap.set("n", "<Leader>ff", function() builtin.find_files({hidden=true}) end, { desc = "find files in curr dir" } )
        vim.keymap.set("n", "<Leader>fb", builtin.current_buffer_fuzzy_find, { desc = "fuzzy find buffer" })
        vim.keymap.set("n", "<Leader>fc", function() builtin.live_grep({additional_args=function() return {"--hidden"} end}) end, { desc = "live grep in dir" })
        vim.keymap.set("n", "<Leader>fg", function() builtin.buffers() end, {desc="search for list of buffers"})
        vim.keymap.set("n", "<Leader>fw", function() builtin.find_files({ cwd = vim.g.wiki_root, hidden=true}) end, { desc = "search D:/wikis/wiki" })
    end
}
