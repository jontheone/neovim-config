vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = { "*.html" },
    callback = function()
        local template = {
            '<!DOCTYPE html>',
            '<html lang="en">',
            '<head>',
            '  <meta charset="UTF-8">',
            '  <meta name="viewport" content="width=device-width, initial-scale=1.0">',
            '  <title>Document</title>',
            '</head>',
            '<body>',
            ' ',
            '</body>',
            '</html>'
        }
        vim.api.nvim_buf_set_lines(0, 0, #template, false, template)
        vim.api.nvim_command("normal! Go")
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.keymap.set("n", "yy", function()
            vim.fn.setreg('"', vim.fn.expand("%") .. vim.fn.getline("."))
        end, { buffer = true })
    end
})
