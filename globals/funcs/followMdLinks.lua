local M = {}

M.seePath = function()
    local utils = require("nvim-treesitter.ts_utils")
    local ts = require("vim.treesitter")
    local node_at_cursor = utils.get_node_at_cursor()
    if not node_at_cursor then
        return false
    end
    if node_at_cursor:type() == "link_text" then
        local sibling = node_at_cursor:next_sibling():next_sibling():next_sibling()
        if not sibling then
            return false
        end
        if not sibling:type() == "link_destination" then
            return false
        end
        local path = ts.get_node_text(sibling, 0)
        return path
    elseif node_at_cursor:type() == "link_destination" then
        local path = ts.get_node_text(node_at_cursor, 0)
        return path
    else
        return false
    end
end

M.checkInput = function(path)
    if path:sub(-1) == "/" then
        return false
    end
    if path:find("%/") then
        File = vim.split(path, "/")
        File = File[#File]

    else
        File = path
    end
    if File:find("%.") then
        if (File:sub(-2) == "md" or File:sub(-8) == "markdown") then
            return true
        end
        return false
    end
end

M.makePath = function(path)
    if path:sub(1, 2) == "~/" then
        return vim.g.wiki_root .. path:sub(2)
    elseif path:sub(1,2) == "./" then
        return vim.fn.expand("%:p:h") .. path
    elseif path:sub(1, 1) == "/" then
        return path
    else
        return vim.fn.expand("%:p:h") .. "/" .. path
    end
end

M.followlinks = function()
    local unfinishedPath = M.seePath()
    if not unfinishedPath then
        return
    end

    if not M.checkInput(unfinishedPath) then
        print("Caminho invalido")
        return
    end
    local path = M.makePath(unfinishedPath)
    print(path)
    if vim.fn.filereadable(path) == 1 then
        vim.cmd(string.format("%s %s", "e", path))
    else
        local file = vim.split(path, "/")
        file = file[#file]
        local dir = path:gsub(file, "")
        if vim.fn.isdirectory(dir) == 1 then
            vim.cmd(string.format("%s %s", "e", path))
        else
            vim.cmd(string.format("%s %s", "!mkdir", dir))
            vim.cmd(string.format("%s %s", "e", path))
        end
    end
end

M.followHeader = function(path)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for i, line in ipairs(lines) do
        local header = string.gsub(string.sub(string.gsub(line, "#", ""), 2), "%s", "-")
        local Path = string.sub(path, 2)
        if header == Path then
            vim.api.nvim_win_set_cursor(0, {i, 1})
        end
    end
end

M.followMdLinks = function()
    local unfinishedPath = M.seePath()
    if unfinishedPath then
        if unfinishedPath:sub(1, 1) == "#" then
            M.followHeader(unfinishedPath)
        else
            M.followlinks()
        end
    end
end

return M
