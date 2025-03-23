local M = {}

local cmd = [[powershell -NoProfile -Command]]
local search_command = [[rg --hidden --pcre2 -l -g '*.md']]

M.remove_duplicate = function(arr)
    local unique = {}
    local seen = {}
    for _, value in ipairs(arr) do
        if not seen[value] then
            table.insert(unique, value)
            seen[value] = true
        end
    end
    return unique
end

M.getLabelsList = function()
    local output = io.popen(cmd..[[ rg --hidden --vimgrep "^#\+.+" ]]..vim.g.wiki_root) or {}
    local entries = output:read("*a")
    output:close()
    local labels = {}
    local seen = {}
    for line in string.gmatch(entries, "[^\n]+") do
        for item in string.gmatch(line, '#%+([%d%a%s%ç%õ%ã_]+):') do
            if not seen[item] then
                table.insert(labels, item)
                seen[item] = true
            end
        end
    end
    return labels
end

M.getLabelDataList = function(label, path)
    path = path or vim.g.wiki_root
    if type(path) == "table" then
        path = table.concat(path, " ")
    end
    local output = io.popen(string.format(cmd..[[ rg --hidden '^#\+%s:(.*)' --no-line-number --no-heading --no-filename -P --stop-on-nonmatch --replace '$1' %s]], label, path)) or {}
    local datalist = {}
    local seen = {}
    for line in output:lines() do
        if line == "" then
            if not seen[line] then
                table.insert(datalist, line)
                seen[line] = true
            end
        else
            local data = line:match("^%s*(.-)%s*$")
            for item in data:gmatch("[^,]+") do
                item = item:match("^%s*(.-)%s*$")
                if not seen[item] then
                    table.insert(datalist, item)
                    seen[item] = true
                end
            end
        end
    end
    output:close()
    table.sort(datalist)
    return datalist
end

M.getFilesByLabel = function(label, path)
    label = label or {}
    path = path or vim.g.wiki_root
    if type(label) == 'table' then
        label =  "(".. table.concat(label, "|") ..")"
    end
    local output = io.popen(string.format(cmd..search_command..[[ '^#\+%s:' %s]], label, path)) or {}
    local entries = output:read("*a")
    output:close()
    local files = {}
    for line in entries:gmatch("[^\n]+") do
        for item in line:gmatch("([/%a%d%s%p%ç%ã%õ_]+/[%d%a%p%s%ç%õ%ã_]+%.md)") do
            table.insert(files, item)
        end
    end
    table.sort(files)
    return files
end

local function genPattern(label, data)
    local pattern = [[ '^#\+%s:%s' ]]
    local labelPattern = label
    local dataPattern = ".*%s.*"
    if type(data) == "table" then
        local str = ""
        for i=1, #data do
            str = str..string.format("(?=.*%s)", data[i])
        end
        dataPattern = string.format(dataPattern, str)
    elseif type(data) == "string" then
        dataPattern = string.format(dataPattern, data)
    end
    return string.format(pattern, labelPattern, dataPattern)
end


M.getFilesByLabelData = function(label, data, path)
    label = label or ""
    data = data or ""
    path = path or vim.g.wiki_root
    if type(path) == "table" then
        path = table.concat(path, " ")
    end
    local command = ""
    if type(label) == "table" and type(data) == "table" then
        for i=1, #label do
            local info = data[label[i]]
            if not info then
                print("provide enough input for the amount of labels")
                return
            end
            if i == 1 then
                command = command.. " $(".. search_command .. genPattern(label[i], info) .. path .. ")"
            else
                command = " $(".. search_command .. genPattern(label[i], info) .. command .. ")"
            end
        end
    elseif type(data) == "table" then
        command = command.." ".. search_command .. genPattern(label, data) .. path
    elseif type(label) == "table" then
        for i=1, #label do
            if i == 1 then
                command = command .. " $(" .. search_command .. genPattern(label[i], {data}) .. path .. ")"
            else
                command = " $(".. search_command .. genPattern(label[i], {data}) .. command .. ")"
            end
        end
    else
        command = command.. " " .. search_command .. genPattern(label, {data}) .. path
    end
    local output = io.popen(cmd..command) or {}
    local entries = output:read("*a")
    output:close()
    local files = {}
    for line in entries:gmatch("[^\n]+") do
        for item in line:gmatch("([/%a%d%s%p%ç%ã%õ_]+/[%d%a%p%s%ç%õ%ã_]+%.md)") do
            table.insert(files, item)
        end
    end
    table.sort(files)
    return files
end

M.notSearchByLabelData = function(label, path)
    if type(label) == 'table' then
        label =  "(".. table.concat(label, "|") ..")"
    end
    local output = io.popen(string.format(cmd..search_command..[['^#\+%s:$', %s]], label, path)) or {}
    local entries = output:read("*a")
    output:close()
    local files = {}
    for line in entries:gmatch("[^\n]+") do
        for item in line:gmatch("([/%a%d%s%p%ç%ã%õ_]+/[%d%a%p%s%ç%õ%ã_]+%.md)") do
            table.insert(files, item)
        end
    end
    table.sort(files)
    return files
end

local parseFileData = function(filename)
    local file = io.open(filename, "r") or {}
    local metadata = {}
    for line in file:lines() do
        local key, pair = line:match("^#%+(.+):(.*)")
        if key then
            if pair:match(",") then
                pair = pair:match("^%s*(.-)%s*$")
                local values = {}
                for item in pair:gmatch("[^,]+") do
                    item = string.gsub(item, "%\r", "")
                    table.insert(values, item)
                end
                metadata[key] = values
            else
                pair = string.gsub(pair, "%\r", "")
                metadata[key] = pair
            end
        end
    end
    file:close()
    return metadata
end

M.getMetadataByFileName = function(filename)
    if type(filename) == "table" then
        local metadata = {}
        for _, item in ipairs(filename) do
            metadata[item] = parseFileData(item)
        end
        return metadata
    else
        return parseFileData(filename)
    end
end

M.dataOf = function(filepath, tag)
    local file = io.open(filepath, "r") or {}
    local data
    local index = 0
    for item in file:lines() do
        index = index + 1
        if item:match("^#%+"..tag..":(.*)") then
            data = string.gsub(item:match("^#%+"..tag..":(.*)"), "%\r", "")
            break
        end
    end
    file:close()
    return {data, index}
end

M.dataExists = function(filepath, label, value)
    local file = io.open(filepath, "r") or {}
    for item in file:lines() do
        local line = item:match("^#%+"..label..":(.*)")
        if line then
            if line:match("%f[%a],?" .. value .. ",?%f[%A]") or (line == value) then
                return true
            end
        end
    end
    return false
end

return M
