return {
    'hedyhli/markdown-toc.nvim',
    ft = "markdown",
    cmd = {'Mtoc'},
    config = function()
        require("mtoc").setup({
            fences = false
        })
        vim.keymap.set('n', '<Leader>mt', ':Mtoc<CR>', { desc = "Toc markdown"})
    end
}
