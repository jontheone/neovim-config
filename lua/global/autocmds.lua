vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.formatoptions:append("r") -- `<CR>` in insert mode
        vim.opt_local.formatoptions:append("o") -- `o` in normal mode
        vim.opt_local.comments = {
            "b:>",
            "b:# TODO:"
        }
        vim.cmd("highlight CustomHighlight guifg=#3ae06f")
        vim.fn.matchadd("CustomHighlight", [[^#+.\+:]])
    end,
})
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = { "*.md", "*.markdown" },
    callback = function()
        local template = {
            '#+links:',
            '#+tags:',
            '#+topic:',
            '#+type:',
            ' '
        }
        vim.api.nvim_buf_set_lines(0, 0, #template, false, template)
        vim.api.nvim_command("normal! Go")
    end
})
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
            vim.fn.setreg('"', string.gsub(vim.fs.joinpath(vim.fn.expand("%"), vim.fn.getline(".")), [[^/*(.-)/*$]], "%1"))
        end, { buffer = vim.api.nvim_get_current_buf() })
    end
})
