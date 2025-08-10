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
    local pattern = string.format([[^%s: %s]], label, string.format(".*%s.*", dataPattern))
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
---@param data metadata[]
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

M.GetYaml = function(filepath)
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
    return yaml
end


M.TableIn = function(tbl1, tbl2)
    if #tbl1 > #tbl2 then
        return false
    end

    for _, item in ipairs(tbl1) do
        local continue = false
        for  _, comp in ipairs(tbl2) do
            if comp == item then
                continue = true
                break
            end
        end
        if not continue then
            return false
        end
    end
    return true
end

M.TableEquals = function(tbl1, tbl2)
    if not (#tbl1 == #tbl2) then
        return false
    end
    table.sort(tbl1)
    table.sort(tbl2)
    for i=1, #tbl1 do
        if not (tbl1[i] == tbl2[i]) then
            return false
        end
    end
    return true
end

M.TypeOfPath = function(path)
    assert(path, "Path cant be nil")
    path = vim.fs.abspath(path)
    assert(vim.uv.fs_stat(path), "path is invalid: "..path)
    if os.execute(string.format(' [ -d "%s" ] ', path)) == 0 then
        return "directory"
    elseif os.execute(string.format(' [ -f "%s" ] ', path)) then
        return "file"
    end
end

M.IterDir = function(dirpath)
    assert(dirpath, "The paths directory cant be nil")
    dirpath = vim.fs.abspath(dirpath)
    assert(vim.uv.fs_stat(dirpath), "Invalid directory")
    local dir = {}
    local count = 0
    local out = io.popen(string.format("ls %s", dirpath)) or {}
    for item in out:lines() do
        table.insert(dir, vim.fs.joinpath(dirpath, item))
    end
    out:close()
    return function()
        count = count + 1
        if count > #dir then
            return nil
        end
        local type = M.TypeOfPath(dir[count])
        return dir[count], type
    end
end

-- works like a cursor for the yaml
-- Basically whenever you call the iterator with a yaml it moves the "cursor" to the next \n character and then parses and gives you the metadata  from the line that was just deleted
-- If it encounters an entry with indentation it will call the iterator until the indentation stops and will put every line in a list and return it
-- If you pass in an empty yaml string the cursor wont move to the next \n character and will return nil which will give the signal for the iterator to stop and no iteration will occur
-- This function works with other functions in this file if you wanna ship it, you have to ship the whole file, and it requires an unix like system to work, why:
    -- The function to test if a filepath is a directory or not
    -- How i open and read the line of a file, in unix system the lines are \n, but in windows the lines are \n\r
M.YamlIter = function(filepath)
    local function iterfunc()
        local yaml = M.GetYaml(filepath)
        return function(redo)
            if redo then
                yaml = redo..yaml
            else
                local pos = yaml:find("\n")
                if not pos then
                    return nil
                end
                local line = yaml:sub(1, pos)
                yaml = yaml:sub(pos+1)
                return line
            end
        end
    end
    local iter = iterfunc()
    return function()
        local line = iter()
        if not line then
            return nil
        end
        if line:match("^.+:%s.+") then
            local label = line:match("^(.+):%s.+")
            local data = line:match("^.+:%s(.+)\n")
            return label, data
        elseif line:match("^.+:%s*.*") then
            local label = line:match("^(.+):%s*.*")
            local data = {}
            while true do
                local nextLine = iter()
                if not nextLine then
                    return nil
                end
                if not nextLine:match("^%s+-%s.*") then
                    iter(nextLine)
                    break
                end
                local listItem = nextLine:match("^%s+-%s(.+)\n")
                if listItem then
                    table.insert(data, listItem)
                end
            end
            return label, data
        end
    end
end

M.GetSingleLabelData = function(filepath, label)
    filepath = vim.fs.abspath(filepath) or ""
    assert(label, "You need to specify a label  to do a search")
    assert(type(label) == "string", "The label must be a string")
    assert(filepath, "You need to pass a filepath in order to do the search")
    assert(vim.uv.fs_stat(filepath), "Filepath does not exist")
    assert(not (M.TypeOfPath(filepath) == "directory"), "You need to pass in a readable file not a directory")
    for key, pair in M.YamlIter(filepath) do
        if key == label then
            return {key, pair}
        end
    end
end

---@param filepath string
---@return table
M.GetMetadata = function(filepath)
    filepath = filepath or ""
    filepath = vim.fs.abspath(filepath)
    assert(vim.uv.fs_stat(filepath), "Invalid file path")
    local yaml = {}
    for key, pair in M.YamlIter(filepath) do
        yaml[key] = pair
    end
    return yaml
end

M.LabelExists = function(filepath, label)
    filepath = vim.fs.abspath(filepath) or ""
    assert(label, "You need to specify a label to do a search")
    assert(type(label) == "string", "The label must be a string")
    assert(filepath, "You need to pass a filepath in order to verify its metadata")
    assert(vim.uv.fs_stat(filepath), "Filepath does not exist")
    assert(not (M.TypeOfPath(filepath) == "directory"), "You need to pass in a readable file not a directory")
    for key, pair in M.YamlIter(filepath) do
        if key == label then
            return true
        end
    end
end


-- The implementation of this function is different from the GetFileByMetadata() function in this file
-- Since there is no more hierachy, the arguments are now back at key-value pair, beign the keys the metadata you wanna search and the value a string or table with the metadata you wanna filter
-- This function is recursive and currently it only searches for .md files
-- The implementation through ripgrep is much faster
M.GetFilesByYaml = function(metainfo, path)
    assert(metainfo, "You must to specify the Info you wanna search")
    assert(type(metainfo) == "table", "The info must be a key-value table")

    path = path or vim.g.wiki_root
    local paths = {}
    for filepath, filetype in M.IterDir(path) do
        if filetype == "directory" and not (filepath:match("%.git")) then
            local files = M.GetFilesByYaml(metainfo, filepath)
            for i=1, #files do
                table.insert(paths, files[i])
            end
        elseif filepath:sub(-3) == ".md" then
            local metadata = M.GetMetadata(filepath)
            for label, data in pairs(metainfo) do
                assert(label, "You must use a key-value pair table to search through the metadata")
                if not metadata[label] then
                    break
                end
                local fileData = metadata[label]

                if type(fileData) == "table" and type(data) == "table" then
                    if #data > #fileData then
                        break
                    elseif #fileData > #data then
                        if M.TableIn(data, fileData) then table.insert(paths, filepath) else break end
                    else
                        if M.TableEquals(data, fileData) then table.insert(paths, filepath) else break end
                    end
                elseif type(fileData) == "table" and type(data) == "string" then
                    if M.TableIn({data}, fileData) then table.insert(paths, filepath) else break end
                elseif type(fileData) == "string" and type(data) == "string" then
                    fileData = fileData:match("^%s*(.-)%s*$")
                    if fileData == data then table.insert(paths, filepath) else break end
                else
                    break
                end
            end
        end
    end
    return paths
end

return M
