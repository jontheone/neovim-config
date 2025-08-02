local M = {}


local state = {
    term = {
        win = -1,
        buf = -1
    }
}

M.createwindow = function(buffer)
    local buf = buffer or vim.api.nvim_create_buf(false, true)
    local height = math.floor(vim.o.lines * 0.3)
    local width = math.floor(vim.o.columns * 0.97)
    local col = math.floor(vim.o.columns * 0.5) - math.floor(width / 2)
    local row = math.floor(vim.o.lines * 0.65)
    local opts = {
        relative = "editor",
        col = col,
        row = row,
        height = height,
        width = width,
        style = "minimal",
        border = "rounded"
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    return { win = win, buf = buf }
end

M.floaterminal = function()
    if vim.api.nvim_win_is_valid(state.term.win) then
        vim.api.nvim_win_close(state.term.win, true)
    else
        if vim.api.nvim_buf_is_valid(state.term.buf) then
            state.term = M.createwindow(state.term.buf)
        else
            state.term = M.createwindow()
            vim.cmd.term()
        end
    end
end

return M
