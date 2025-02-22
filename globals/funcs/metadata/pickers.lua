local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local mt = require("metadata")
local M = {}

M.PickerPrompt2 = function (opts)
    -- função pega e organiza o input de metadado do usuarios como chaves e os valores como todos os valores que o input pode ser filtrado, ignorando espaços em branco essa função pode ser chamada de qualquer parte do programa sem ocorrer um erro, e vai devolver uma lista vazia, exceto se METADADO contém alguma chave com o valor de um array vazio
    local GetMetaChoice = function()
        local metainfo = {}
        for key, _ in pairs(mt.METADADO) do
            local arr = {}
            for _ , value in pairs(mt.JSON) do
                local data = value[key]
                if type(data) == "table" then
                    for i=1, #data do
                        if data[i] == "" then
                            goto skip1
                        else
                            table.insert(arr, data[i])
                        end
                    end
                    ::skip1::
                elseif type(data) == "string" then
                    if data == "" then
                        goto skip2
                    else
                        table.insert(arr, data)
                    end
                    ::skip2::
                end
            end
            arr = mt.remove_duplicate(arr)
            metainfo[key] = arr
        end
        return metainfo
    end
    -- função pega e organiza o input de metadado do usuarios como chaves e os valores todos os valores que o input pode ser filtrado por, ignorando espaços em branco 
    local metachoice = GetMetaChoice()
    -- for loop abaixo organiza a lista a cima em um formato que pode ser lido pelo picker
    local input = {}
    for key, value in pairs(metachoice) do
        table.sort(value)
        for i=1, #value do
            local arr = {}
            arr["metadado"] = key
            arr["dado"] = value[i]
            table.insert(input, arr)
        end
    end
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Select the metatag to search",
        finder = finders.new_table{
            results = input,
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
                        table.insert(mt.METADADO[value.meta], value.ordinal)
                    end
                elseif entry.ordinal then
                    table.insert(mt.METADADO[entry.meta], entry.ordinal)
                end
                actions.close(prompt_bufnr)
                if mt.GREEDY_SEARCH and mt.GREP then
                    M.createGrepPicker({}, mt.filters.greedyFilter())
                elseif mt.GREEDY_SEARCH then
                    if mt.TOC then
                        mt.insertToc(mt.filters.greedyFilter)
                    else
                        M.createPicker({}, mt.filters.greedyFilter())
                    end
                elseif mt.GREP then
                    M.createGrepPicker({}, mt.filters.nonGreedyFilter())
                else
                    if mt.TOC then
                        mt.insertToc(mt.filters.nonGreedyFilter)
                    else
                        M.createPicker({}, mt.filters.nonGreedyFilter())
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


M.PickerPrompt1 = function (opts)
    for key, _ in pairs(mt.METADADO) do
        mt.METADADO[key] = nil
    end
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Select the metatag to search",
        finder = finders.new_table{
            results = mt.METADADOS
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selected_entries = picker:get_multi_selection()
                local entry = action_state.get_selected_entry()
                if selected_entries[1] then
                    for _, value in ipairs(selected_entries) do
                        mt.METADADO[value[1]] = {}
                    end
                elseif entry[1] then
                    mt.METADADO[entry[1]] = {} 
                end
                actions.close(prompt_bufnr)
                M.PickerPrompt2()
            end)
            return true
        end,
        layout_config = {
            width = 0.4,
            height = 0.6
        }
    }):find()
end


M.createPicker = function(opts, metadados)
    opts = opts or {}
    local treatedjson = {}
    for i=1, #metadados do
        local arr = {}
        arr.name = string.gsub(metadados[i], mt.PICKER_PATH .. "/", "")
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

M.createGrepPicker = function(opts, paths)
    opts = opts or {}
    builtin.live_grep({
        prompt_title = "Custom live grep",
        search_dirs = paths,
    })
end

return M
