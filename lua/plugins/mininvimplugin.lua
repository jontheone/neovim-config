return {
    'echasnovski/mini.files',
    version = false,
    config = function()
        require('mini.files').setup({
            options = {
                use_as_default_explorer = true
            }
        })
        vim.keymap.set('n', '<Leader>d', ":lua MiniFiles.open()<CR>", { desc = "search w/ mini"})

    end
}
