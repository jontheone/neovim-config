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

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.keymap.set("n", "yy", function()
            vim.fn.setreg('"', vim.fs.joinpath(vim.fn.expand("%"), vim.fn.getline(".")))
        end, { buffer = vim.api.nvim_get_current_buf() })
    end
})
