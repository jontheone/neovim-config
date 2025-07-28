return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim"},
    config = function()
        local tl = require"telescope.builtin"
        require("telescope").setup{
            defaults = {
                mappings = {
                    i = {
                        ["C-j"] = "move_selection_next",
                        ["C-k"] = "move_selection_previous",
                        ["C-x"] = "delete_buffer",
                    }
                }
            }
        }
        vim.keymap.set("n", "<leader>ff", function() tl.find_files({hidden = true}) end)
        vim.keymap.set("n", "<leader>fg", function() tl.live_grep() end)
        vim.keymap.set("n", "<leader>fs", function() tl.grep_string({use_regex=true, search=vim.fn.input("grep for > ")}) end)
        vim.keymap.set("n", "<leader>fl", function() tl.current_buffer_fuzzy_find() end)
        vim.keymap.set("n", "<leader>fc", function() tl.find_files({ cwd="~/.config/nvim" }) end)
        vim.keymap.set("n", "<leader>fb", function() tl.buffers() end)
        vim.keymap.set("n", "<leader>fq", function() tl.quickfix() end)
    end
}
