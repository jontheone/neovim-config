local M = {}

local generatePermutationPattern = function(words)
    table.sort(words) -- Sort to ensure consistent order (optional)  
    local patterns = {}
    local function permute(arr, n)
        n = n or #arr
        if n == 1 then
            table.insert(patterns, table.concat(arr, ".*"))
        else
            for i = 1, n do
                arr[i], arr[n] = arr[n], arr[i]
                permute(arr, n - 1)
                arr[i], arr[n] = arr[n], arr[i] -- Restore order
            end
        end
    end

    permute(words) -- Generate all possible orderings
    return "(" .. table.concat(patterns, "|") .. ")"
end

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
    local output = io.popen([[rg --only-matching --hidden '^#\+.+' /mnt/d/wikis/wiki]])
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
    local output = io.popen(string.format([[rg --only-matching --hidden '^#\+%s:.*' %s]], label, path))
    local entries = output:read("*a")
    output:close()
    local datalist = {}
    local seen = {}
    for line in entries:gmatch("[^\n]+") do
        for data in string.gmatch(line, '#%+.+:(.+)') do
            if data:match(",") then
                data = data:match("^%s*(.-)%s*$")
                for item in data:gmatch("[^,]+") do
                    item = item:match("^%s*(.-)%s*$")
                    if not seen[item] then
                        table.insert(datalist, item)
                        seen[item] = true 
                    end
                end
            else
                if not seen[data] then
                    table.insert(datalist, data)
                    seen[data] = true 
                end
            end
        end
    end
    return datalist
end

M.getFilesByLabel = function(label, path)
    if type(label) == 'table' then
        label =  "(".. table.concat(label, "|") ..")"
    end
    local output = io.popen(string.format([[rg --only-matching --hidden '^#\+%s:.*' -g '*.md' %s]], label, path))
    local entries = output:read("*a")
    output:close()
    local files = {}
    for line in entries:gmatch("[^\n]+") do
        for item in line:gmatch("([/%a%d%s%p%ç%ã%õ_]+/[%d%a%p%s%ç%õ%ã_]+%.md):") do
            table.insert(files, item)
        end
    end
    return files
end

M.getFilesByLabelData = function(label, data, path, greedy)
    if #data > 10 then
        print("CANNOT FILTER MORE THAN 10 DATA AT A TIME")
        return 
    end
    greedy = greedy or false
    if type(label) == 'table' then
        label =  "(".. table.concat(label, "|") ..")"
    end
    local cmd
    if greedy == true then
        if type(data) == "table" then
            data = "(".. table.concat(data, "|") ..")"
            cmd = string.format([[rg --only-matching --hidden '^#\+%s:.*%s.*' -g '*.md' %s]], label, data, path)
        else
            cmd = string.format([[rg --only-matching --hidden '^#\+%s:.*%s.*' -g '*.md' %s]], label, data, path)
        end
    else
        if type(data) == "table" then
            cmd = string.format([[rg --only-matching --hidden '^#\+%s:.*%s.*' -g '*.md' %s]], label, generatePermutationPattern(data), path) 
        else
            cmd = string.format([[rg --only-matching --hidden '^#\+%s:.*%s.*' -g '*.md' %s]], label, data, path)
        end
    end
    local output = io.popen(string.format(cmd))
    local entries = output:read("*a")
    output:close()
    local files = {}
    for line in entries:gmatch("[^\n]+") do
        for item in line:gmatch("([/%a%d%s%p%ç%ã%õ_]+/[%d%a%p%s%ç%õ%ã_]+%.md):") do
            table.insert(files, item)
        end
    end
    return files
end

M.getMetadataByFileName = function(filename)
    local output = io.popen(string.format([[rg --only-matching --hidden '^#\+.+:.*' %s]], filename))
    local entries = output:read("*a")
    output:close()
    local metadata = {}
    for line in entries:gmatch("[^\n]+") do
        for key, pair in line:gmatch("#%+(.+):(.*)") do
            if pair:match(",") then
                pair = pair:match("^%s*(.-)%s*$")
                local values = {}
                for item in pair:gmatch("[^,]+") do
                    table.insert(values, item)
                end
                metadata[key] = values
            else
                metadata[key] = pair
            end
        end
    end
    return metadata
end

return M
