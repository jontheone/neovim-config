return {
    'github/copilot.vim',
    config = function()
        vim.g.copilot_no_tab_map = true
        vim.keymap.set("i", "<C-J>", 'copilot#Accept("<CR>")', { expr = true, silent = true, noremap = true, replace_keycodes = false })
        vim.keymap.set("i", "<C-k>", 'copilot#Dismiss()', { expr = true, silent = true, noremap = true })
    end,
}
