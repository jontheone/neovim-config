return {
    "nvim-treesitter/nvim-treesitter",
    config = function()
        --this line is important:
        require 'nvim-treesitter.install'.compilers = { "clang" }
        require 'nvim-treesitter.configs'.setup {
            ensure_installed = {"c", "markdown", "markdown_inline", "html", "python", "lua", "c_sharp"}
        }
        vim.api.nvim_create_autocmd("BufReadPost", {
            callback = function()
                vim.cmd("TSBufEnable highlight")
            end,
        })
        vim.api.nvim_create_autocmd("BufNewFile", {
            callback = function()
                vim.cmd("TSBufEnable highlight")
            end,
        })
    end
}
