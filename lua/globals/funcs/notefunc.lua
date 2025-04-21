local PATH_NOTE = "/home/jonhson/.config/nvim/note.md"
local NOTE_DIR = vim.g.wiki_root .. ".notas/"
local state = {
    floating = {
        buf = -1,
        win = -1
    }
}
local template = {
    '<!-- METADATA -->',
    '{',
    '"file name" : "note",',
    '"links" : [ "" ],',
    '"tags" : [ "" ],',
    '"type" : "note"',
    '}',
    '<!-- /METADATA -->'
}

local M = {}

M.makewin = function(args)
    local width = args.width or 120
    local height = args.height or 1
    local col = args.col or math.floor((vim.o.columns - width) / 2)
    local row = args.row or math.floor((vim.o.lines - height) / 2)
    local buf = args.buf or vim.api.nvim_create_buf(false, true)
    local title = args.title or ""
    local opts = {
        width = width,
        height = height,
        col = col,
        row = row,
        title = title,
        title_pos = "left",
        relative = "editor",
        style = "minimal",
        border = "rounded"
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    return {win=win, buf=buf}
end

M.main = function()
    if not vim.api.nvim_win_is_valid(state.floating.win) then
        local bufNote = vim.fn.bufadd(PATH_NOTE)
        vim.fn.bufload(bufNote)
        state.floating.buf = bufNote
        local winNote = M.makewin({title=" note ", width=math.floor(vim.o.columns * 0.8), height=math.floor(vim.o.lines * 0.8), buf=bufNote})
        state.floating.win = winNote.win
        vim.api.nvim_buf_set_lines(bufNote , -1, -1, false, {string.format("# %s", os.date("%d/%m/%Y - %H:%M:%S")), "---"})
        vim.cmd("normal! Go")
        vim.api.nvim_buf_create_user_command(bufNote, "Save", function() 
            vim.cmd("w")
            local winSave = M.makewin({title=" save as ", width=120, height=1})
            local buf = winSave.buf
            local win = winSave.win
            vim.cmd("startinsert")
            vim.keymap.set({"n", "i"}, "<CR>", function() 
                local line = vim.api.nvim_get_current_line()
                if line:match("[^%a%d]") then
                    error("Não escreva caracteres especiais", 2)       
                end
                local file = vim.fn.readfile(PATH_NOTE)
                local noteName = string.format("%s_%s", os.date("%d-%m-%Y"), line .. ".md")
                local path = vim.fs.joinpath(NOTE_DIR, noteName)
                if vim.fn.filereadable(path) == 1 then
                    local prompt = M.makewin({title=" override file ", width=30, height=2})
                    local promptBuf = prompt.buf
                    local promptWin = prompt.win
                    vim.api.nvim_buf_set_lines(prompt.buf, 0, 1, false, {"yes", "no"})
                    vim.cmd("stopinsert")  -- Exits Insert mode
                    vim.bo[promptBuf].modifiable = false
                    vim.keymap.set("n", "<CR>", function()
                        local input = vim.api.nvim_get_current_line()
                        if input == "yes" then
                            file[3] = string.gsub(file[3], "(:%s*)(.*)", ": " .. string.format('"%s"', noteName) .. ",")
                            vim.fn.writefile(file, path)
                            print(string.format("Note %s saved at: %s", noteName, NOTE_DIR))
                            vim.fn.writefile(template, PATH_NOTE)
                            vim.api.nvim_win_close(promptWin, true)
                            vim.api.nvim_win_close(win, true)
                            vim.api.nvim_win_close(state.floating.win, true)
                        else
                            vim.api.nvim_win_close(promptWin, true)
                            vim.api.nvim_set_current_win(win)
                        end
                    end, {buffer=prompt.buf})
                    vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(promptWin, true); vim.api.nvim_set_current_win(win) end)
                else
                    file[3] = string.gsub(file[3], "(:%s*)(.*)", ": " .. string.format('"%s"', noteName) .. ",")
                    vim.fn.writefile(file, path)
                    vim.fn.writefile(template, PATH_NOTE)
                    print(string.format("Note %s saved at: %s", noteName, NOTE_DIR))
                    vim.api.nvim_win_close(win, true)
                    vim.api.nvim_win_close(state.floating.win, true)
                end
            end, {buffer=buf})
            vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(win, true); vim.api.nvim_set_current_win(state.floating.win) end, {buffer=buf})

        end, {})
        vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(state.floating.win, true); vim.api.nvim_buf_delete(state.floating.buf, { force = true}) end, {buffer=bufNote})
    else
        vim.api.nvim_win_close(state.floating.win, true)
        vim.api.nvim_buf_delete(state.floating.buf, {force=true})
    end
end


return M

