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

M.promptWindow = function(args)
    args = args or {}
    local height = args.height or 1
    local width = args.width or 100
    local col = args.col or math.floor((vim.o.columns - width) / 2)
    local row = args.row or math.floor((vim.o.lines - height) / 2)
    local buf = args.buf or vim.api.nvim_create_buf(false, true)
    local title = args.title or ""
    local opts = {
        relative = "editor",
        style = "minimal",
        border = "rounded",
        title = title,
        title_pos = "center",
        height = height,
        width = width,
        col = col,
        row = row
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.cmd("startinsert")
    return win, buf
end

return M
