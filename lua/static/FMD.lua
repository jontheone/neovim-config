local M = {}

local ts = require("nvim-treesitter.ts_utils")

M.getfulllink = function(text)
    
end

M.followMdLinks = function()
    local node = ts.get_node_at_cursor()
    local ntype = node:type()
    local next_sibling = node:next_named_sibling()
    if ntype == "link_destination" then
        vim.cmd(string.format("e %s", M.getfulllink(vim.treesitter.get_node_text(node))))
    elseif ntype == "link_text" or ntype == "inline_link" then
        vim.cmd(string.format("e %s", M.getfulllink(vim.treesitter.get_node_text(next_sibling))))
    else
        return
    end
end

return M
