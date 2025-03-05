local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local dt = require("metadata.datacollect")
local greedyFilter = require("metadata.filters").greedyFilter
local nonGreedyFilter = require("metadata.filters").nonGreedyFilter
local insertToc = require("metadata.functionalities").insertToc

local M = {}

M.PickerPrompt2 = function (opts, params)
    opts = opts or {}
    params = params or {}
    local args = params.args or {}
    local input = params.input or {}
    local json = params.json or {}
    -- função pega e organiza o input de metadado do usuarios como chaves e os valores como todos os valores que o input pode ser filtrado, ignorando espaços em branco essa função pode ser chamada de qualquer parte do programa sem ocorrer um erro, e vai devolver uma lista vazia, exceto se METADADO contém alguma chave com o valor de um array vazio
    local GetMetaChoice = function()
        local metainfo = {}
        for key, _ in pairs(input) do
            local arr = dt.getLabelDataList(key, vim.g.wiki_root)
            metainfo[key] = arr
        end
        return metainfo
    end
    -- função pega e organiza o input de metadado do usuarios como chaves e os valores todos os valores que o input pode ser filtrado por, ignorando espaços em branco 
    local metachoice = GetMetaChoice()
    -- for loop abaixo organiza a lista a cima em um formato que pode ser lido pelo picker
    local results = {}
    for key, value in pairs(metachoice) do
        for i=1, #value do
            local arr = {}
            arr["metadado"] = key
            arr["dado"] = value[i]
            table.insert(results, arr)
        end
    end
    pickers.new(opts, {
        prompt_title = "Select the metatag to search",
        finder = finders.new_table{
            results = results,
            entry_maker = function(entry)
                return {
                    display = entry.metadado .. ":" .. entry.dado,
                    ordinal = entry.dado, 
                    meta = entry.metadado
                }
            end
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selected_entries = picker:get_multi_selection()
                local entry = action_state.get_selected_entry()
                if selected_entries[1] then
                    for _, value in pairs(selected_entries) do 
                        table.insert(input[value.meta], value.ordinal)
                    end
                elseif entry.ordinal then
                    table.insert(input[entry.meta], entry.ordinal)
                end
                actions.close(prompt_bufnr)
                local function getfiles()
                    local files = {}
                    for label, datalist in pairs(input) do
                        if datalist[1] then
                            local arr = dt.getFilesByLabelData(label, datalist, vim.g.wiki_root, true) 
                            for i=1, #arr do
                                table.insert(files, arr[i])
                            end
                        end
                    end
                    return files
                end
                params.json = dt.getMetadataByFileName(getfiles())
                if args.greedy and args.grep then
                    M.createGrepPicker({}, greedyFilter(params), args.path)
                elseif args.greedy then
                    if args.toc then
                        insertToc(greedyFilter, params)
                    else
                        M.createPicker({}, greedyFilter(params), args.path)
                    end
                elseif args.grep then
                    M.createGrepPicker({}, nonGreedyFilter(params), args.path)
                else
                    if args.toc then
                        insertToc(nonGreedyFilter, params)
                    else
                        M.createPicker({}, nonGreedyFilter(params), args.path)
                    end
                end
            end)
            return true
        end,
        layout_config = {
            width = 0.4,
            height = 0.6
        }
    }):find()
end


M.PickerPrompt1 = function (opts, params)
    params = params or {}
    opts = opts or {}
    local args = params.args or {}
    local input = {}
    local options = dt.getLabelsList()
    pickers.new(opts, {
        prompt_title = "Select the metatag to search",
        finder = finders.new_table{
            results = options
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selected_entries = picker:get_multi_selection()
                local entry = action_state.get_selected_entry()
                if selected_entries[1] then
                    for _, value in ipairs(selected_entries) do
                        input[value[1]] = {}
                    end
                elseif entry[1] then
                    input[entry[1]] = {} 
                end
                actions.close(prompt_bufnr)
                M.PickerPrompt2({}, {args=args, input=input, json=json})
            end)
            return true
        end,
        layout_config = {
            width = 0.4,
            height = 0.6
        }
    }):find()
end


M.createPicker = function(opts, metadados, path)
    opts = opts or {}
    path = path or vim.g.initial_dir
    local treatedjson = {}
    for i=1, #metadados do
        local arr = {}
        arr.name = string.gsub(metadados[i], path .. "/", "")
        arr.path = metadados[i]
        table.insert(treatedjson, arr)
    end
    pickers.new(opts, {
        prompt_title = "Metadata search",
        finder = finders.new_table{
            results = treatedjson,
            entry_maker = function(entry) 
                return {
                    display = entry.name,
                    ordinal = entry.name,
                    path = entry.path
                }
            end
        },
        sorter = conf.generic_sorter(opts),
        previewer = conf.file_previewer({})
    }):find()
end

M.createGrepPicker = function(opts, paths, path)
    path = path or vim.g.wiki_root
    opts = opts or {}
    builtin.live_grep({
        prompt_title = "Custom live grep",
        search_dirs = paths,
        cwd = path
    })
end

return M
