local dt = require("metadata.datacollect")
local path
local col
local row
local originbuf
local M = {}

M.createInputWin = function (opts)
    local buf = vim.api.nvim_create_buf(false, true)
    local width = opts.width or 40
    local height = opts.height or 1
    local col = opts.col or math.floor((vim.o.lines-height)/2)
    local row = opts.row or math.floor((vim.o.columns-width)/2)
    local opts = {
        relative="editor",
        style="minimal",
        title = "Pick metadata",
        title_pos = "left",
        border = "rounded",
        row = row,
        col = col,
        height = height,
        width = width
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    return win, buf
end

local changemetadata = function(input, index)
    local win, buf = M.createInputWin({height=1, col=col, row=row, width=25})
    vim.wo[win].wrap = false
    vim.cmd("startinsert")
    vim.keymap.set({"n", "i"}, "<CR>", function()
        local data = vim.api.nvim_get_current_line()
        print(vim.inspect(data))
        local line = input..":"..data
        local lines = vim.api.nvim_buf_get_lines(originbuf, 0, -1, false)
        lines[index] = string.format("#+%s", line)
        vim.api.nvim_buf_set_lines(originbuf, 0, -1, false, lines)
        vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
        vim.cmd("stopinsert")
    end, {buffer=buf})
    vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, {buffer=buf})
end

local handleCR = function()
    local input = vim.api.nvim_get_current_line()
    local line = dt.dataOf(path, input)[2]
    vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
    changemetadata(input, line)
end

M.metachange = function()
    path = vim.fn.expand("%:p")
    col = vim.fn.wincol()
    row = vim.fn.winline()
    originbuf = vim.api.nvim_get_current_buf()
    local metadata = dt.getMetadataByFileName(path)
    local keys = {}
    for key, _ in pairs(metadata) do
        table.insert(keys, key)
    end
    local metaWin, metaBuf = M.createInputWin({height=#keys, width=25, col=col, row=row})
    vim.api.nvim_buf_set_lines(metaBuf, 0, #keys-1, false, keys)
    vim.wo[metaWin].wrap = false
    vim.bo[metaBuf].modifiable = false

    vim.keymap.set("n", "<CR>", handleCR, {buffer=metabuf})
    vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(metaWin, true) end, {buffer=metaBuf})
end


return M
