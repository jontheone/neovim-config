return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons"},
    config = function()
        local tl = require"telescope.builtin"
        local action = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        require("telescope").setup{
            defaults = {
                mappings = {
                    i = {
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",
                        ["<C-x>"] = "delete_buffer",
                        ["<C-g>"] = function(buf)
                            local picker = action_state.get_current_picker(buf)
                            local selection = picker:get_multi_selection()
                            for _, item in ipairs(selection) do
                                vim.cmd.argadd(item[1])
                            end
                            action.close(buf)
                        end,
                    }
                }
            }
        }
        vim.keymap.set("n", "<leader>ff", function() tl.find_files({hidden = false}) end)
        vim.keymap.set("n", "<leader>fg", function() tl.live_grep() end)
        vim.keymap.set("n", "<leader>fs", function() tl.grep_string({use_regex=true, search=vim.fn.input("grep for > ")}) end)
        vim.keymap.set("n", "<leader>fl", function() tl.current_buffer_fuzzy_find() end)
        vim.keymap.set("n", "<leader>fc", function() tl.find_files({ cwd="~/.config/nvim" }) end)
        vim.keymap.set("n", "<leader>fb", function() tl.buffers() end)
        vim.keymap.set("n", "<leader>fq", function() tl.quickfix() end)
    end
}
