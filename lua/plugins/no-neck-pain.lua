return {
    'shortcuts/no-neck-pain.nvim',
    config = function()
        vim.keymap.set('n', '<Leader>y', ':NoNeckPain<CR>', { noremap = true })
    end
}
