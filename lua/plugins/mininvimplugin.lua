return {
    'echasnovski/mini.files',
    version = false,
    config = function()
        require('mini.files').setup({})
        vim.keymap.set('n', '<Leader>d', ":lua MiniFiles.open()<CR>", { desc = "search w/ mini"})

    end
}
