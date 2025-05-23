return {
    {
        "rose-pine/neovim",
        config = function()
            require("rose-pine").setup({
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
            vim.g.nord_disable_background = true
            require("nord").set()
        end
    }
}
