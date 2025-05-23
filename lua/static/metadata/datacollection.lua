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

M.GetDataByLabel = function(label)
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


return M

