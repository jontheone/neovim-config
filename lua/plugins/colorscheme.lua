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
            vim.cmd("colorscheme rose-pine-main")
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
        require("vague").setup({

        })
      end
    }
}
