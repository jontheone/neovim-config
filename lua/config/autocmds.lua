vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = {"*.md"},
    callback = function()
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {
            '#+links:',
            '#+tags:',
            '#+topic:',
            '#+type:',
        })
    end
})
