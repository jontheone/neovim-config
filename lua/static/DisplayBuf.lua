local M = {}

-- notify function
M.getBuffers = function()
    local listed_buffers = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.buflisted(buf) == 1 then
            table.insert(listed_buffers, string.format("%s: %s", tostring(buf), vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":.")))
        end
    end
    return listed_buffers
end

M.selfClose = function(win)
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
end

M.setCursorPosition = function(buf, ns_id, win)
    local lines = vim.api.nvim_buf_get_lines(buf , 0, -1, false)
    vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
    for i=1, #lines do
        local bufcheck = lines[i]:match("^(%d+):.*$")
        if bufcheck == tostring(vim.api.nvim_get_current_buf()) then
            vim.api.nvim_buf_add_highlight(buf, 0, "QuickFixLine", (i-1), 0, -1)
            vim.fn.sign_unplace("CursorSignGroup", { buffer = buf })
            vim.fn.sign_place(0, "CursorSignGroup", "CursorSign", buf, { lnum = i, priority = 100 })
        else
            vim.api.nvim_buf_add_highlight(buf, 0, "normal", (i-1), 0, -1)
        end
    end
end



M.buildBuf = function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, M.getBuffers())
    return buf
end

M.winRefresh = function(buf, win)
    local lines = M.getBuffers()
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    if #lines >= 8 then
        vim.api.nvim_win_set_height(win, 8)
    else
        vim.api.nvim_win_set_height(win, #lines)
    end
end

M.bufferConfig = function(currentBuf, mainWin, ns_id, win, buf)
    vim.bo[buf].modifiable = false
    vim.fn.sign_define("CursorSign", { text = ""})
    local timer = vim.loop.new_timer()
    local timeout = 700
    timer:start(timeout, 0, vim.schedule_wrap(function() M.selfClose(win) end))
    -- autocmds
    local group_id = vim.api.nvim_create_augroup("floatingBuf", { clear = true })
    
    vim.api.nvim_create_autocmd("BufEnter", {group=group_id, callback=function()
        M.winRefresh(buf, win)
        M.setCursorPosition(buf, ns_id, win)
        if vim.api.nvim_win_is_valid(win) then
            timer:stop()
            timer:start(timeout, 0, vim.schedule_wrap(function() M.selfClose(win) end))
        end
    end})

    vim.api.nvim_create_autocmd("WinClosed", {group=group_id, callback = function(ev)
        if tonumber(ev.match) == win then
            vim.api.nvim_del_augroup_by_id(group_id)    
            vim.api.nvim_buf_delete(buf, {force = true})
            vim.g.buffer_active = false
        end
    end})

    -- end of autocmds
end

M.buildWin = function(buf)
    local height = #(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
    local opts = {
        relative = "editor",
        style = "minimal",
        width = vim.o.columns,
        height = height,
        col = math.floor((vim.o.columns / 2)),
        row = 0,
    }
    local win = vim.api.nvim_open_win(buf, false, opts)
    vim.wo[win].signcolumn = "yes"

    return win
end

M.notify = function()
    local ns_id = vim.api.nvim_create_namespace("FloatHl")
    local currentBuf = vim.api.nvim_get_current_buf()
    local mainWin = vim.api.nvim_get_current_win()
    local buf = M.buildBuf()
    local win = M.buildWin(buf)
    vim.g.buffer_active = true
    vim.api.nvim_win_set_hl_ns(win, ns_id)
    M.bufferConfig(currentBuf, mainWin, ns_id, win, buf)
    M.setCursorPosition(buf, ns_id)
end
-- end of notify functin



return M
