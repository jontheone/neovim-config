return {
    {
        "rose-pine/neovim",
        config = function()
            require("rose-pine").setup({
                dim_inactive_windows = true,
                styles = {
                    transparency = false
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
            require("vague").setup({})
            -- vim.cmd("colorscheme vague")
        end
    },
    {
        'projekt0n/github-nvim-theme',
        name = 'github-theme',
        config = function()
            --vim.cmd('colorscheme github_dark_tritanopia')
        end,
    },
    {
        "ellisonleao/gruvbox.nvim",
        config = function()
            require("gruvbox").setup({
                transparent_mode = true,
            })
            --vim.cmd("colorscheme gruvbox")
        end
    },
    {
        "folke/tokyonight.nvim",
        config = function()
            require("tokyonight").setup({
                style = "storm",
                transparent = false
            })
           vim.cmd("colorscheme tokyonight")
           vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
           vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
           vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
           vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
           vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
           vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
           vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "none" })
           vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none" })
        end
    },
    {
        "nyoom-engineering/oxocarbon.nvim",
        config = function()
--            vim.cmd("colorscheme oxocarbon")
--            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--            vim.api.nvim_set_hl(0, "FloatTitle", { bg = "none" })
--            vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
--            vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
--            vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
--            vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
--            vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
--            vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
--            vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
--            vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
--            vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
--            vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "none" })
--            vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none" })
        end
    },
}
