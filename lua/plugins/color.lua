return {
    {
        'zenbones-theme/zenbones.nvim',
        dependencies = {"rktjmp/lush.nvim"},
        lazy = false,
        priority = 1000,
        config = function()
            --vim.cmd("colorscheme tokyobones")
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
    },
    {

        "neanias/everforest-nvim",
        version = false,
        lazy = false,
        priority = 1000, -- make sure to load this before all the other start plugins
        -- Optional; default configuration will be used if setup isn't called.
        config = function()
--            require("everforest").setup({
--                background = "soft"
--                -- Your config here
--            })
--            vim.cmd("colorscheme everforest")
        end,

    },
    {
        'shaunsingh/nord.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme nord")
            vim.g.nord_contrast = true
            vim.g.nord_borders = false
            vim.g.nord_disable_background = true
            vim.g.nord_italic = false
            vim.g.nord_uniform_diff_background = true
            vim.g.nord_bold = false
        end
    },
}
