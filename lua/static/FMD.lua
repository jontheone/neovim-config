local M = {}

local ts = require("nvim-treesitter.ts_utils")

local function getfulllink(text)
    if text:match(".+://") then
        local out = io.popen(string.format("google-chrome-stable %s 2> /dev/null", text)) or {}
        local entries = out:read("*a")
        print(entries:gsub("\n", ""))
        out:close()
        return
    elseif text:sub(1, 1) == "/" or text:sub(1, 2) == "~/" then
        return text
    elseif text:sub(1, 2) == "-/" then
        local path = text:sub(2)
        return vim.fs.joinpath(vim.g.wiki_root, path)
    elseif text:match(".+%.md") then
        local currpath = vim.fn.expand("%:p:h")
        return vim.fs.joinpath(currpath, text)
    else
        print("seila")
        return
    end
end


M.followMdLinks = function()
    local ok, _ = pcall(vim.treesitter.get_parser, 0)
    if not ok then
        return
    end
    local node = ts.get_node_at_cursor()
    local ntype = node:type()
    local next_sibling = node:next_named_sibling()
    if ntype == "link_destination" then
        local text = getfulllink(vim.treesitter.get_node_text(node, 0))
        if text then
            vim.cmd(string.format("e %s", text))
        end
    elseif ntype == "link_text" or ntype == "inline_link" then
        local text = getfulllink(vim.treesitter.get_node_text(next_sibling, 0))
        if text then
            vim.cmd(string.format("e %s", text))
        end
    else
        return
    end
end

return M
