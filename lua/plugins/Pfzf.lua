return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local fzf = require("fzf-lua")
        fzf.setup{
            files = {
                hidden = true,
            },
            grep = {
                hidden = true
            }
        }
        vim.keymap.set("n", "<leader>ff", function() fzf.files() end)
        vim.keymap.set("n", "<leader>fg", function() fzf.live_grep() end)
        vim.keymap.set("n", "<leader>fc", function() fzf.files({ cwd="~/.config/nvim" }) end)
    end
}
