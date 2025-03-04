vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.formatoptions:append("r") -- `<CR>` in insert mode
		vim.opt_local.formatoptions:append("o") -- `o` in normal mode
		vim.opt_local.comments = {"b:>"}
	end,
})
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = {"*.md", "*.markdown"},
    callback = function()
        local template = {
            '#+file name:',
            '#+links:',
            '#+tags:',
            '#+type:',
            ' '
        }
        vim.api.nvim_buf_set_lines(0, 0, #template, false, template)
        vim.api.nvim_command("normal! Go")
    end
})
