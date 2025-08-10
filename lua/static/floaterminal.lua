local M = {}


local buffer = -1
local win = -1

M.CreateSplit = function()
    local before = vim.api.nvim_list_wins()
    vim.cmd("split")
    local after = vim.api.nvim_list_wins()
    local new_win
    local seen = {}
    for _, win in ipairs(before) do
        seen[win] = true
    end
    for _, win in ipairs(after) do
        if not seen[win] then
            new_win = win
            break
        end
    end

    return new_win
end

M.EnterTerm = function()
    if not vim.api.nvim_win_is_valid(win) then
        if not vim.api.nvim_buf_is_valid(win) then
            win = M.CreateSplit()
            vim.api.nvim_win_set_height(win, math.floor(vim.o.lines * 0.15))
            vim.api.nvim_set_current_win(win)
            vim.cmd("term")
            buffer = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_win_set_buffer(buffer)
        else
            win = M.CreateSplit()
            vim.api.nvim_set_current_win(win)
            vim.api.nvim_win_set_buffer(buffer)
        end
    else
        vim.api.nvim_win_close(win, false)
    end
end

return M
