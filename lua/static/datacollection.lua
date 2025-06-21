-- this file exists strictly to provide me with a way to collect data from my wiki of md files

local cmd  = [[rg -. -P -l -g"*.md" ]]
vim.g.wiki_root = "~/Documents/wikis/wiki"

local M = {}

M.GenPattern = function(label, data)
    local dataPattern = ""
    if type(data) == "table" then
        for i=1, #data do
            dataPattern = dataPattern .. string.format("(?=.*%s)", data[i])
        end
    elseif type(data) == "string" then
        dataPattern = dataPattern .. string.format("(?=.*%s)", data)
    end
    local pattern = string.format([[^_%s:%s]], label, string.format(".*%s.*", dataPattern)) return string.format('"%s" ', pattern)
end

M.GetFilesByLink = function(label)
    local files = io.popen(cmd..M.GenPattern("links", label)..vim.g.wiki_root)
    local entries = files:read("*a")
    files:close()
    local paths = {}
    for item in string.gmatch(entries, "[^\n]+") do
        table.insert(paths, item)
    end
    table.sort(paths)
    return paths
end

M.GetFilesByTopic = function(topic)
    local files = io.popen(cmd..M.GenPattern("topic", topic)..vim.g.wiki_root) or {}
    local entries = files:read("*a")
    files:close()
    local paths = {}
    for item in string.gmatch(entries, "[^\n]+") do
        table.insert(paths, item)
    end
    table.sort(paths)
    return paths
end

-- This function serves the purpose of finding files based one or many data that might be different labels, but are supposed to represent the same thing
M.GetFilesByOpenSearch = function(label, data)
    if type(label) == "table" then label = "(" .. table.concat(label, "|") .. ")" end
    local pattern = M.GenPattern(label, data)
    local files = io.popen(cmd..pattern..vim.g.wiki_root) or {}
    local entries = files:read("*a")
    files:close()
    local paths = {}
    for item in string.gmatch(entries, "[^\n]+") do
        table.insert(paths, item)
    end
    table.sort(paths)
    return paths
end

-- receives a table of tables with each table containing information the metadata denoted in the notations down below
-- the lower the priority the first the metadata is going to be searched
-- the data has to be a table even if you are going to be searching for 1 data
---@class metadata
---@field priority number
---@field label string
---@field data table
---@param data metadata
---@return table
M.GetFilesByMetadata = function(data) -- function takes only one parameter, a table, and returns a table
    assert(type(data) == "table", "Metadata needs to be a table of tables, read the notations and comments before this function to understand")
    assert(data[1], "You need to input at least one metadata for search")
    for i=1, #data do
        assert(data[i].label, "You must provide a label do the metadata")
        assert(data[i].data[1], "you must filter the label for at least one data")
        data[i].priority = data[i].priority or 999
    end
    table.sort(data, function(a, b) return a.priority < b.priority end)
    local pattern = ""
    for i=1, #data do
        if i == 1 then
            pattern = pattern..string.format("%s %s", M.GenPattern(data[i].label, data[i].data), vim.g.wiki_root)
        else
            pattern = pattern..string.format(" | xargs %s %s", cmd, M.GenPattern(data[i].label, data[i].data))
        end
    end
    local files = io.popen(cmd..pattern) or {}
    local entries = files:read("*a")
    files:close()
    local paths = {}
    for item in string.gmatch(entries, "[^\n]+") do
        table.insert(paths, item)
    end
    table.sort(paths)
    return paths
end

M.GetAllLinks = function()
    local files = io.popen(cmd..[["^_links:.*" ]]..vim.g.wiki_root) or {}
    local entries = files:read("*a")
    files:close()
    local paths = {}
    for item in string.gmatch(entries, "[^\n]+") do
        table.insert(paths, item)
    end
    local links = {}
    local seen = {}
    for _, path in  ipairs(paths) do
        local file = io.open(path, "r") or {}
        for line in file:lines() do
            local link = line:match("^_links:(.*)")
            if link then
                link = link:match("^%s*(.-)%s*$")
                link = link:match("^,*(.-),*$")
                if not seen[link] then
                    table.insert(links, link)
                    seen[link] = {}
                    break
                end
            end
        end
        file:close()
    end
    return links
end

-- this function will take a n amount of paths and a label and will return a list of all the available data in of that specific label only for those paths
---@param paths table
---@param label string
---@return table
M.GetLabelDataBasedOnFiles = function(paths, label)
    assert(type(paths) == "table", "Paths must be a table")
    assert(paths[1], "Must contain at least one path")
    assert(type(label) == "string", "label must be one string")
    local data = {}
    local seen = {}
    -- youre never compreheending this code, dont even try it
    for _, path in  ipairs(paths) do
        local file = io.open(path, "r") or {}
        for line in file:lines() do
            local lineData = line:match("^_"..label..":(.*)")
            if lineData then
                lineData = lineData:match("^%s*(.-)%s*$")
                lineData = lineData:match("^,*(.-),*$")
                if lineData:find(",") then
                    local dataTable = {}
                    for item in string.gmatch(lineData, "[^,]+") do
                        item = item:match("^%s*(.-)%s*$")
                        table.insert(dataTable, item)
                    end
                    for i=1, #dataTable do
                        if not seen[dataTable[i]] then
                            table.insert(data, dataTable[i])
                            seen[dataTable[i]] = {}
                        end
                    end
                    break
                else
                    if not seen[lineData] then
                        table.insert(data, lineData)
                        seen[lineData] = {}
                        break
                    end
                end
            end
        end
        file:close()
    end
    return data
end

-- getting data by yaml metadata

-- Get metadata from a certain file path

M.ParseYaml = function(str)
    local metadata = {}
    local nest
    for line in str:gmatch("[^\n]+") do
        if line:match("^.+:%s.+") then
            nest = nil
            line = line:match("^%s*(.-)%s*$")
            local label = line:match("^(.+):%s.+")
            local data  = line:match("^.+:%s(.+)")
            if label and data then
                metadata[label] = data
            end
        elseif line:match("^.+:") then
            line = line:match("^%s*(.-)%s*$")
            local key = line:match("^(.+):")
            if key then metadata[key] = {}
                nest = key
            end
        elseif line:match("^%s+-%s.*") then
            line = line:match("^%s+-%s(.*)")
            line = line:match("^%s*(.-)%s*$")
            local label
            local data
            if line:find(":") then
                label = line:match("^(.+):") data = line:match("^.+:%s(.*)")
            else
                data = line
            end
            if nest then
                if label and data then
                    metadata[nest][label] = data
                elseif data then
                    table.insert(metadata[nest], data)
                end
            end
        end
    end
    return metadata
end

---@param filepath string
---@return table
M.GetMetadata = function(filepath)
    assert(vim.uv.fs_stat(filepath), "Invalid file path")
    filepath = vim.fs.abspath(filepath)
    local insideYaml = false
    local yaml = ""
    local i = 0
    for line in io.lines(filepath) do
        if line:match("%s*%-%-%-%s*") then
            insideYaml = not (insideYaml)
            goto skip
        end
        if (not insideYaml) and (i >= 5) then
            break
        end
        if insideYaml then
            yaml = yaml..line.."\n"
        end
        ::skip::
        i = i + 1
    end
    local metadados = M.ParseYaml(yaml)
    return metadados
end

M.LabelExists = function(filepath, label)
    local metadata = M.GetMetadata(filepath)
    if metadata[label] then
        return metadata[label]
    else
        return
    end
end

-- make it recursive
M.GetFilesByYaml = function(label, data, path)
    assert(type(label) == "string", "label must be a string")
    path = path or vim.g.wiki_root
    local out = io.popen(string.format("ls %s", path)) or {}
    local dir = out:read("a*")
    out:close()
    local paths = {}
    for file in dir:gmatch("[^\n]+") do
        local filepath = vim.fs.joinpath(path, file)
        filepath = vim.fs.abspath(filepath)
        if os.execute(string.format(' [ -d "%s" ] ', filepath)) == 0 then
            local files = M.GetFilesByYaml(label, data, filepath) or {}
            for i=1, #files do
                table.insert(paths, files[i])
            end
        else
            local metadata = M.GetMetadata(filepath)
            local key = metadata[label]
        end
    end
    return paths
end

print(vim.inspect(M.GetFilesByYaml("_links", {"pessoal"})))

return M

