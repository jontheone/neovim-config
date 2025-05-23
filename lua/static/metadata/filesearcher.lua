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
        table.insert(entries, entry)
    end
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

M.refreshBuf = function(state)
    local buf = vim.api.nvim_get_current_buf()
    
end

-- buffer actions

M.accept = function(line, entries)
    line = line - 4 
    if not (line <= 0) then
        vim.cmd("e "..entries[line].path)
    end
end

M.delete = function(opts)
    local linenum = (vim.fn.line(".") - 4)
    local entry = opts.entries[linenum]
    vim.fn.delete(entry.path)
    table.remove(opts.entries, linenum)
    local bufEntries = buildBufEntries(opts.entries)
    local buf = M.buildBuf(bufEntries, opts)
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
end

M.newFile = function(entries)
    local input = vim.fn.input("name > ")
    if input and not (input == "") then
         vim.cmd("e "..vim.g.wiki_root..".assuntos/"..input)
    end  
end

-- End of buffer actions

M.buildBuf = function(bufEntries, opts)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0,  -1, false, {
        "\" ==========================================",
        "\" Search by "..opts.args,
        "\" Sorted by name",
        "\" ==========================================",
    } )
    vim.api.nvim_buf_set_lines(buf, 4, -1, false, bufEntries)
    local buf_state = {}

    -- buf options
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "vim"

    -- buf keymaps
    vim.keymap.set("n", "<CR>", function() M.accept(vim.fn.line("."), opts.entries) end, { buffer=buf })
    vim.keymap.set("n", "d", function() M.delete(opts) end, {buffer=buf})
    vim.keymap.set("n", "n", function() M.newFile(entries) end, {buffer=buf})
    return buf
end

M.main = function()
    local opts = {}
    opts.args = M.getLabel()
    local paths = data.GetDataByLabel(opts.args)
    local entries = M.buildEntries(paths)
    local BufEntries = M.buildBufEntries(entries)
    local buf = M.buildBuf(BufEntries, {args=opts.args, entries=entries})
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
end

return M
