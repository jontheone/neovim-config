return {
    'bullets-vim/bullets.vim',
    config = function()
        vim.g.bullets_enabled_file_types = { 'markdown' }
        vim.g.bullets_enable_in_empty_buffers = 0
    end
}
