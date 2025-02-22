return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    config = function()
        require("todo-comments").setup()
        --vim.keymap.set("n", "<Leader>a", ":TodoTelescope keywords=TODO cwd=/mnt/d/wikis/wiki<CR>", {desc="Todo List"})
    end
}
