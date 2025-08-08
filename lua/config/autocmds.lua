--vim.api.nvim_create_autocmd("BufNewFile", {
--    pattern = {"*.md"},
--    callback = function()
--        vim.api.nvim_buf_set_lines(0, 0, -1, false, {string.format("Date: %s", os.date())})
--    end
--})
--

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.keymap.set("n", "yy", function()
            vim.fn.setreg('"', vim.fs.joinpath(vim.fn.expand("%"), vim.fn.getline(".")))
        end, { buffer = vim.api.nvim_get_current_buf() })
    end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
      vim.wo[vim.api.nvim_get_current_win()].relativenumber = false
--    if vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].loclist == 0 then
--    end
  end,
})
