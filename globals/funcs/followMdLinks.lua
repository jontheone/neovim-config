local M = {}

M.followMdLinks = function()
    if not (string.sub(vim.fn.expand("%:t"), -3) == ".md") then
        return
    end
    local link = vim.fn.expand("<cWORD>")
    local path = link:match("^%[.+%]%((.+)%)$")
    if not path then
        return
    end
    if not path:match("^%~/.+$") then
        path = path:gsub("%./", "/")
        path = vim.fs.joinpath(vim.fn.expand("%:p:h") , path)
    end
    if not (path:sub(-3) == ".md") then
        print("caminho inválido")
        return
    end
    if path:sub(1, 1) == "#" then
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for i, line in ipairs(lines) do
            local header =  string.gsub(string.gsub(path, "-", " "), "^(#+)(.+)$", "%1 %2")
            if header == line then
                vim.api.nvim_win_set_cursor(0, {i, 1})
                break
            end
        end
    else
        vim.cmd.edit(path)
    end
end

return M
