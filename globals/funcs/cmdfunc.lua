local M = {}

local state = {
    floating = {
        buf = -1,
        win = -1
    }
}

M.newwin = function(opts)
    opts = opts or {}

    local width = opts.width or math.floor(vim.o.columns * 0.80)
    local height = opts.height or math.floor(vim.o.lines * 0.80)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    local buferforcmd
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buferforcmd = opts.buf
    else
        buferforcmd = vim.api.nvim_create_buf(false, true)
        vim.fn.bufload(buferforcmd)
    end

    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded"
    }

    local win = vim.api.nvim_open_win(buferforcmd, true, win_opts)

    return {buf = buferforcmd, win = win}
end

M.floaterminal = function()
    if not vim.api.nvim_win_is_valid(state.floating.win) then
        state.floating = M.newwin{ buf = state.floating.buf}
        if vim.bo[state.floating.buf].buftype ~= 'terminal' then
            vim.fn.termopen(vim.o.shell)
        end
    else
        vim.api.nvim_win_close(state.floating.win, true)
    end
end



return M
