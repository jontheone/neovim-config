local cmd  = [[rg -. -P -l -g"*.md" ]]

vim.g.wiki_root = "~/documents/wikis/wiki"
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
    local pattern = string.format([[^#\+%s:%s]], label, string.format(".*%s.*", dataPattern))
    return string.format('"%s" ', pattern)
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

M.GetDataByTopic = function(topic)
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
    if type(label) == "table" then
        label = "(" .. table.concat(label, "|") .. ")"
    end
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
local mt = {
    priority = 1, -- this field may be empty, if so its going to be considered 999, meaning its going to have the least amount of priority.
    label = "", -- Only one label per metadata
    data = {}
}
---@param data table
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
    local files = io.popen(cmd..[["#\+links:.*" ]]..vim.g.wiki_root) or {}
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
            local link = line:match("^#%+links:(.*)")
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
            local lineData = line:match("^#%+"..label..":(.*)")
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

return M

