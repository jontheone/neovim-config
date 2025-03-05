local M = {}

-- essa função organiza os inputs do usuario em uma estrutura de dados ideial para ser filtrado por um filtro greedy or non greedy
-- { *metadado inputado* : {
    -- *tags inputadas* : {*caminhos que contém essa tag*},
    -- *tags inputadas* : {*caminhos que contém essa tag*}
    -- }
-- }
M.getFilteringStructure = function(args)
    local input = args.input
    local json = args.json
    local caminhos = {}
    for metadado, tags in pairs(input) do
        local arr = {}
        for i=1, #tags do
            arr[tags[i]] = {}
        end
        caminhos[metadado] = arr
    end
    for key, value in pairs(caminhos) do
        local tags = {}
        for k, _ in pairs(value) do
            table.insert(tags, k)
        end
        for i=1, #tags do
            local tag = tags[i]
            for path, meta in pairs(json) do
                local dado = meta[key]
                if type(dado) == "table" then
                    for j=1, #dado do
                        if dado[j] == tag then
                            table.insert(caminhos[key][tag], path)
                        end
                    end
                else
                    if dado == tag then
                        table.insert(caminhos[key][tag], path)
                    end
                end
            end
        end
    end
    return caminhos
end
-- Função que vai finalmente passar os caminhos do metadados pelo filtro que o usuários escolheu e vai devolver uma lista com todos os caminhos para o picker de caminhos
M.greedyFilter = function(args)
    args = args or {}
    local files = {}
    local filteringStructure = M.getFilteringStructure(args)
    for _, value in pairs(filteringStructure) do
        for _, paths in pairs(value) do
            vim.list_extend(files, paths)
        end
    end
    local files = require("metadata.datacollect").remove_duplicate(files)
    table.sort(files)
    return files
end

M.nonGreedyFilter = function(args)
    args = args or {}
    local metadata = M.getFilteringStructure(args)
    local common_paths = nil

    for _, info in pairs(metadata) do
        for _, paths in pairs(info) do
            if common_paths == nil then
                common_paths = vim.deepcopy(paths)
            else
                local path_set = {}
                for _, path in ipairs(paths) do
                    path_set[path] = true
                end
                local new_common = {}
                for _, path in ipairs(common_paths) do
                    if path_set[path] then
                        table.insert(new_common, path)
                    end
                end

                common_paths = new_common
            end
        end
    end
    table.sort(common_paths)
    return common_paths or {}
end



return M
