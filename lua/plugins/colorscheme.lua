return {
    {
        "rose-pine/neovim",
        config = function()
            require("rose-pine").setup({
                dim_inactive_windows = true,
                styles = {
                    transparency = true
                },
                palette = {
                    main = {
                        base = "#000000",
                        surface = "#000000",
                        overlay = "#000000"
                    }
                }
            })
            --vim.cmd("colorscheme rose-pine-main")
        end
    },
    {
        "shaunsingh/nord.nvim",
        config = function()
            --vim.g.nord_disable_background = true
            --require("nord").set()
        end
    },
    {
        "vague2k/vague.nvim",
        config = function()
            -- NOTE: you do not need to call setup if you don't want to.
            --require("vague").setup({})
        end
    },
    {
        'projekt0n/github-nvim-theme',
        name = 'github-theme',
        config = function()
            --vim.cmd('colorscheme github_dark_dimmed')
        end,
    },
    {
        "ellisonleao/gruvbox.nvim",
        config = function()
            require("gruvbox").setup({
                tranparent_mode = true,
            })
        end
    },
    {
        "folke/tokyonight.nvim",
        config = function()
            require("tokyonight").setup({
                style = "storm",
                transparent = true
            })
            vim.cmd("colorscheme tokyonight")
        end
    }
}
