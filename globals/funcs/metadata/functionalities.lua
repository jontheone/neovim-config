local M = {}

M.insertToc = function(filter, params)    
    local lines = {}
    table.insert(lines, "# Search result")
    local paths = filter(params)
    for i=1, #paths do
        local item = paths[i]
        local filename = item:match("([^/\\]+)$"):match("(.+)%..+$")
        if item:match(vim.g.wiki_root) then
            item = item:gsub(vim.g.wiki_root, "~/")
        end
        local template = string.format("- [%s](%s)", filename, item)
        table.insert(lines, template)
    end
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, lines)
end



return M
