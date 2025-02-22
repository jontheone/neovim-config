return {
    "nvim-telescope/telescope.nvim",
    dependencies = { 'nvim-lua/plenary.nvim', 'BurntSushi/ripgrep'},
    config = function(_, opts)
        local builtin = require("telescope.builtin")
        require("telescope").setup(opts)
        require("telescope").load_extension("todo-comments")
        vim.keymap.set("n", "<Leader>ff", builtin.find_files, { desc = "find files in curr dir" } )
        vim.keymap.set("n", "<Leader>fb", builtin.current_buffer_fuzzy_find, { desc = "fuzzy find buffer" })
        vim.keymap.set("n", "<Leader>fc", builtin.live_grep, { desc = "live grep in dir" })
        vim.keymap.set("n", "<Leader>fw", function() builtin.find_files({ cwd = vim.g.wiki_root}) end, { desc = "search D:/wikis/wiki" })
        vim.keymap.set("n", "<Leader>fv", function() builtin.find_files({ cwd = "/mnt/c/users/home/appdata/local/nvim"}) end, { desc = "search nvim local files" })
    end
}
