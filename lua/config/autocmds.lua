--vim.api.nvim_create_autocmd("BufNewFile", {
--    pattern = {"*.md"},
--    callback = function()
--        vim.api.nvim_buf_set_lines(0, 0, -1, false, {string.format("Date: %s", os.date())})
--    end
--})
--
local ps = require("lib.psmanager")
local data = require("static.datacollection")
vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.keymap.set("n", "yy", function()
            vim.fn.setreg('"', vim.fs.joinpath(vim.fn.expand("%"), vim.fn.getline(".")))
        end, { buffer = vim.api.nvim_get_current_buf() })
    end
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.md",
    callback = function()
        local file = vim.fn.expand("%:p")
        print(file)
        if file:match("wiki") then
            local ret = ps.UpdateNoWrite(file, data.GetYaml(file))
            if ret == 0 then
                print("Updated file successfully")
            elseif ret == 1 then
                print("Updated successfully with warnings, read ~/.local/share/nvim/postgreslogs")
            elseif ret == -1 then
                print("Failed updating the file, read ~/.local/share/nvim/postgreslogs")
            end
        end
    end
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.md",
    callback = function()
        local file = vim.fn.expand("%:p")
        if file:match("wiki") then
            ps.UpdateInodeTime(file)
        end
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
