local M = {}

M.readnewpath = function (buf) 
    local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
    if not line then
        return nil, "Buffer is empty"
    end
    if line:match("[^%a%d]") then
        return nil, "Não use caracteres especiais"
    end
    if vim.fn.isdirectory(vim.fs.joinpath(string.format(vim.g.wiki_root .. "%s", line))) == 0 then
        return nil, "diretorio ".. line .." não existe"
    end
    return string.format(vim.g.wiki_root .. "%s", line)
end

M.topicmove = function ()
    local height = 1
    local width = 100
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)
    local buf = vim.api.nvim_create_buf(false, true)
    local opts = {
        relative = "editor",
        style = "minimal",
        border = "rounded",
        title = " Mover .assuntos para: ",
        title_pos = "center",
        height = height,
        width = width,
        col = col,
        row = row
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.keymap.set({"i", "n"}, "<CR>", function()
        vim.api.nvim_win_close(win, true)
        local path = vim.g.wiki_root ..  ".assuntos/"
        local new_path, err = M.readnewpath(buf)
        if new_path then
            for name, node in vim.fs.dir(vim.fs.joinpath(path)) do
                if node == "file" then
                    os.rename(vim.fs.joinpath(path, name), vim.fs.joinpath(new_path, name))
                end
            end
        else
            print("Erro: ", err)
        end
    end, {buffer=buf} )
    vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(win, true) end, {buffer=buf} )
end

return M
