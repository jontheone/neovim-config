return  {
    "stevearc/oil.nvim",
    config = function()
        require("oil").setup({
            columns = {
                "icon",
                "permissions",
                "size",
                "mtime"
            }
        })
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        vim.api.nvim_create_user_command("Ex", function(opts)
            vim.cmd("split")
            vim.cmd(string.format("Oil %s", opts.args))
        end, { desc = "Open the directory in a split with oil", nargs = "?"})
    end
}

