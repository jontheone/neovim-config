local data = require("static.metadata.datacollection")
local M = {}

M.getMetadata = function(path)
    local metadata = {} 
    for line in io.lines(path) do
        if string.match(line, [[^#%+.+:.*]]) then
            local label, data = string.match(line, [[^#%+(.+):(.*)]])
            metadata[label] = data
        end
        if metadata["topic"] and metadata["tags"] then -- break the loop once it finds theses two 
            break
        end
    end
    return metadata
end
M.buildEntries = function(paths)
    local entries = {}
    for i=1, #paths do
        local entry = {}
        entry.id = i
        entry.path = paths[i]
        entry.name = string.match(paths[i], "([^/\\]+%.md)$")
        entry.metadata = M.getMetadata(paths[i])
        entry.heat = 1
        entry.hl = {}
        table.insert(entries, entry)
    end
    table.sort(entries, function(a, b) return a.name < b.name end)
    return entries
end

M.buildBufEntries = function(entries)
    local bufEntries = {}
    for i=1, #entries do
        table.insert(bufEntries, entries[i].name) 
    end
    return bufEntries
end

M.getLabel = function()
    local file = vim.fn.expand("%:p")
    local ext = vim.fn.expand("%:e")
    if not (ext == "md") then
        error("no md file", 2)  
    end
    for line in io.lines(file) do
        local data = line:match"^#%+links:(.*)"
        if data and not (data == "") then
            return data:match"^%s*(.-)%s*$"
        end
    end
    error("No links header found", 2)
end

M.refreshBuf = function(buf, entry_state)
    print(vim.inspect(entry_state))
    local lines = {}
    for i=1, #entry_state do
        if not (entry_state[i].heat == 0) then
            table.insert(lines, entry_state[i].name)
        end
    end
    print(vim.inspect(lines))
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
end


-- buffer actions

M.accept = function(entries)
    local line = vim.fn.line('.')
    if not (line <= 0) then
        vim.cmd("e "..entries[line].path)
    end
end

M.delete = function(entries, buf)
    local linenum = vim.fn.line(".")
    local entry = entries[linenum]
    vim.fn.delete(entry.path)
    table.remove(entries, linenum)
    M.refreshBuf(buf, entries)
    return entries
end

M.newFile = function()
    local input = vim.fn.input("name > ")
    
    if input and not (input == "") then
         vim.cmd("e "..vim.g.wiki_root..".assuntos/"..input)
    end  
end
-- End of buffer actions

M.buildBuf = function(bufEntries, opts)
    local buf = vim.api.nvim_create_buf(true, true)
    local buf_state = {}
    local entries = opts.entries
    local entry_state = entries
    local data = opts.args
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, bufEntries)
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)

    -- buf options
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "vim"

    -- buf keymaps
    vim.keymap.set("n", "<CR>", function() M.accept(entry_state) end, { buffer=buf })
    vim.keymap.set("n", "d", function() entries = M.delete(entry_state, buf) end, {buffer=buf})
    vim.keymap.set("n", "n", function() M.newFile() end, {buffer=buf})

    --autocmds
    local buf_gp = vim.api.nvim_create_augroup("finder_buffer", {clear=true})
    
    vim.api.nvim_create_autocmd("BufEnter", {
        group=buf_gp,
        callback = function(ev)
            if vim.api.nvim_buf_is_valid(buf) then
                local newBuf = vim.api.nvim_get_current_buf()
                if not (newBuf == buf) then
                    vim.api.nvim_buf_delete(buf, {force=true})
                    vim.api.nvim_del_augroup_by_id(buf_gp)
                end
            end
        end
    })

    return buf
end

M.main = function()
    local opts = {}
    opts.args = M.getLabel()
    local paths = data.GetFileByLink(opts.args)
    local entries = M.buildEntries(paths)
    local BufEntries = M.buildBufEntries(entries)
    local buf = M.buildBuf(BufEntries, {args=opts.args, entries=entries})
end

return M
