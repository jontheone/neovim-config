vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = {"*.md"},
    callback = function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '#+links:',
            '#+tags:',
            '#+topic:',
            '#+type:',
        })
        -- vim.keymap.set("n", "j", "gj", {buffer=vim.api.nvim_get_current_buf()})
        -- vim.keymap.set("n", "k", "gk", {buffer=vim.api.nvim_get_current_buf()})
    end
})
