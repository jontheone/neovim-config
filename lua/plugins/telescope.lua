return {
    "nvim-telescope/telescope.nvim",
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function()
        local builtin = require("telescope.builtin")
        require("telescope").setup({
            defaults = {
                mappings = {
                    i = {
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous"
                    }
                }
            }
        })
        --require("telescope").load_extension("fzf")
    end
}
