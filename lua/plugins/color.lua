return {
    {
        'zenbones-theme/zenbones.nvim',
        dependencies = {"rktjmp/lush.nvim"},
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme tokyobones")
        end
    },
    {
        "alexxGmZ/e-ink.nvim",
        priority = 1000,
        lazy = false,
        config = function ()
--            require("e-ink").setup()
--            vim.cmd.colorscheme "e-ink"
--            vim.opt.background = "dark"
        end
    }
}
