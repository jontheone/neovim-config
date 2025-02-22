local M = {}

M.newfile = function (path)
    if not path then
        Path = vim.fn.expand("%:p:h") 
    else
        Path = path
    end
    local buf1 = vim.api.nvim_create_buf(false, true)
    local width = 100
    local height = 1
    local title = " new file: " .. Path .. " "
    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = (vim.o.lines - height) / 2,
        col = (vim.o.columns - width) / 2,
        style = "minimal",
        title = title,
        title_pos = "center",
        border = "rounded",
    }
    local win = vim.api.nvim_open_win(buf1, true, opts)
    vim.api.nvim_set_hl(0, 'title', {bg = "none", fg = "#ffffff"})
    vim.api.nvim_set_hl(0, 'bgwin', {bg = "none"})
    vim.api.nvim_set_hl(0, 'borderwin', {bg = "none"})
    vim.api.nvim_buf_set_keymap(buf1, "i", "<CR>","<Cmd>lua handle_input()<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf1, "n", "<Esc>", "<Cmd>lua close_input()<CR>", { noremap = true, silent = true })

    _G.handle_input = function()
        local input = vim.fs.joinpath(Path, vim.api.nvim_buf_get_lines(buf1, 0, -1, false)[1])
        vim.api.nvim_win_close(win, true)
        vim.cmd(string.format("%s %s", "e", input))
    end
    _G.close_input = function ()
        vim.api.nvim_win_close(win, true)
    end
    vim.cmd("startinsert")
end

M.newfileInWikiDir = function()
    local buf1 = vim.api.nvim_create_buf(false, true)
    local width = 100
    local height = 1
    local title = " new file: " .. "D:\\wikis\\wiki "
    local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = (vim.o.lines - height) / 2,
    col = (vim.o.columns - width) / 2,
    style = "minimal",
    title = title,
    title_pos = "center",
    border = "single"
    }
    local win = vim.api.nvim_open_win(buf1, true, opts)
    vim.api.nvim_set_hl(0, 'title', {bg = "#e85143", fg = "#ffffff"})
    vim.api.nvim_set_hl(0, 'bgwin', {bg = "#232629"})
    vim.api.nvim_set_hl(0, 'border', {bg = "#232629"})
    vim.api.nvim_buf_set_keymap(buf1, "i", "<CR>","<Cmd>lua handle_input()<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf1, "n", "<Esc>", "<Cmd>lua close_input()<CR>", { noremap = true, silent = true })

    _G.handle_input = function()
        local input = "D:\\wikis\\wiki" .. '\\' .. string.gsub(vim.api.nvim_buf_get_lines(buf1, 0, -1, false)[1], "/", "\\")
        vim.api.nvim_win_close(win, true)
        vim.cmd(string.format("%s %s", "e", input))
    end
    _G.close_input = function ()
        vim.api.nvim_win_close(win, true)
    end
    vim.cmd("startinsert")
end

M.DeleteFile = function()
    path = vim.fn.expand("%:p")
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 100
    local height = 1
    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = (vim.o.lines - height) / 2,
        col = (vim.o.columns - width) / 2,
        style = "minimal",
        title = " Confirme a ação digitando 'del' ",
        title_pos = "center",
        border = "single"
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_buf_set_keymap(buf, "i", "<CR>","<Cmd>lua handle_input()<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<Cmd>lua close_input()<CR>", { noremap = true, silent = true })

    _G.handle_input = function()
        local input = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]
        if input == "del" then      
            vim.api.nvim_win_close(win, true)
            vim.cmd("bd!")
            vim.fn.delete(path)
        else            
            vim.api.nvim_win_close(win, true)
        end
    end
    _G.close_input = function ()
        vim.api.nvim_win_close(win, true)
    end
    vim.cmd("startinsert")
end


M.ChangeNode = function()
    local path = vim.fn.expand("%:p")
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 100
    local height = 1
    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = (vim.o.lines - height) / 2,
        col = (vim.o.columns - width) / 2,
        style = "minimal",
        title = " Mude o arquivo atual: ",
        title_pos = "center",
        border = "single"
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, {path})
    vim.api.nvim_buf_set_keymap(buf, "i", "<CR>","<Cmd>lua handle_input()<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>","<Cmd>lua handle_input()<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<Cmd>lua close_input()<CR>", { noremap = true, silent = true })

    _G.handle_input = function()
        local input = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]
        if input then
            vim.api.nvim_win_close(win, true)
            vim.cmd("w!")
            pcall(os.rename(path, input))
            vim.cmd("bd!")            
            vim.cmd(string.format("e %s", input))
            print(path)
        else
            vim.api.nvim_win_close(win, true)
        end
    end
    _G.close_input = function ()
        vim.api.nvim_win_close(win, true)
    end
    vim.api.nvim_win_set_cursor(win, {1, (#(vim.fn.getline("."))+1)})
end

return M
