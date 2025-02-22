local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

-- SUGESTãO levar o retrieve de informação para próxima etapa, assim que o usuario escolher um arquivo, ele vai poder navegar pelo arquivo e copiar, colar e modificar qualquer informação presente nele, assim você pode acessar qualquer informação de forma rápida colar informação de outros buffers ou simplesmente modificar informações de outros buffers rápidamente, se você precisar

-- O json contendo uma lista com todos os caminhos dos metadados e os metadados
local JSON
-- Uma lista de chave-valor em que as chaves são os metadados e os valores são listas contendo pelo que eles vão ser filtrados
local METADADO = {}
-- lista contendo os possiveis metadados que o usuarios pode escolher para filtrar
local METADADOS = {}
-- caminho em que o picker vai ser aberto e que os arquivos serão procurados
local PICKER_PATH
-- wether to make a greedy search or not to
local GREEDY_SEARCH = true
-- the input of the buffer in case the user uses the non verbose option of input 
local BUFFERINPUT = {}
-- wether to make a grep search or a normal search in the files
local GREP = false
-- whether to use the toc function
local TOC = false



local M = {}


M.readData = function(Path)
    local METADATA = {}
    for name, node in vim.fs.dir(Path) do
        local NODE = node
        local NAME = Path.. "/"..  name 
        if NODE == "directory" then 
            local data1 = M.readData(NAME)
            METADATA[string.format("%s", "_" .. NAME)] = data1
            goto Skip
        end
        if string.sub(NAME, -3) == ".md" then
            local data2 = M.readFileData(vim.fs.joinpath(NAME))
            if not data2 then
                goto Skip
            end
            if string.sub(data2[1], 1, 1) == "{" then
                local String = ""
                for i=1, #data2 do
                    String = String .. data2[i]
                end
                METADATA[string.format("%s", NAME)] = String
            end
        end
        ::Skip::
    end
    return METADATA
end

M.readFileDataErrorHandling = function(path, message)
    ::InputAgain::
    print("Erro na estrutura das tags <!-- METADATA --> e <!-- /METADATA --> do arquivo: " .. path)
    print(message)
    input = vim.fn.inputlist({"O que fazer:", "(1) tentar novamente", "(2) ignorar arquivo", "(3) cancelar operação"})
    if input == 1 then
        return 1 
    elseif input == 2 then
        return nil              
    elseif input == 3 then
        error("Operação cancelada pelo usuário", 2)
    else
        print("\n###################\nSELECIONE UMA DAS OPÇõES CORRETAMENTE DIGITE 3 PáRA CANCELAR A OPERAÇãO\n\n")
        goto InputAgain
    end
end

M.readFileData = function(path)
    ::tryReadFileDataAgain::
    local file = vim.fn.readfile(path)
    local pos = {}
    for index, item in ipairs(file) do
        if string.match(item, "<!%-%- METADATA %-%->") then
            pos.a = index
        elseif string.match(item, "<!%-%- /METADATA %-%->") then
            pos.b = index
        end
    end
    if pos.a and pos.b then
        if pos.a > pos.b then
            local input = M.readFileDataErrorHandling(path, "A tag <!-- METADATA --> deve vir antes de <!-- /METADATA -->")
            if input == 1 then goto tryReadFileDataAgain end
            return input or nil
        end
        local datatotreat = {}
        for i=(pos.a+1), (pos.b-1) do
            table.insert(datatotreat, file[i])
        end
        return datatotreat
    elseif (pos.a and not pos.b) or (not pos.a and pos.b) then
        local input = M.readFileDataErrorHandling(path, "Feche a tag <!-- METADATA -->")
        if input == 1 then goto tryReadFileDataAgain end
        return input or nil
    end
end

M.readJson = function(data)
    ::tryReadJsonAgain::
    local jsondata = {}
    for key, value in pairs(data) do
        if type(value) == "table" then
            local json = M.readJson(value)
            jsondata[string.format("%s", key)] = json
        else
            local status, json = pcall(vim.json.decode, value)
            if status then     
                jsondata[string.format("%s", key)] = json
            else
                ::InputAgain::
                print("Erro na estrutura dos metadados no arquivo: " .. key)
                print("ERRO: " .. json)
                input = vim.fn.inputlist({"O que fazer:", "(1) tentar novamente", "(2) ignorar arquivo", "(3) cancelar operação"})
                if input == 1 then
                    goto tryReadJsonAgain 
                elseif input == 2 then
                                  
                elseif input == 3 then
                    error("Operação cancelada pelo usuário", 2)
                else
                    print("\n###################\nSELECIONE UMA DAS OPÇõES CORRETAMENTE DIGITE 3 PáRA CANCELAR A OPERAÇãO\n\n")
                    goto InputAgain
                end
            end
        end 
    end
    return jsondata
end

M.Files = function (jsondata)
    local metadata = {}
    for key, value in pairs(jsondata) do
        if string.sub(key, 1, 1) == "_" then
            local j = M.Files(value)
            for k, v in pairs(j) do
                metadata[k] = v
            end
        else
            metadata[key] = value
        end
    end
    return metadata
end

M.checkData = function (json)
    M.recurse = function(data)
        local directories = {}
        local markdown_files = {}

        for key, value in pairs(data) do
            if key:sub(-3) == ".md" then
                table.insert(markdown_files, key)
            elseif key:sub(1, 1) == "_" and type(value) == "table" then
                table.insert(directories, value)
            end
        end

        for _, dir in ipairs(directories) do
            local files_in_dir = M.recurse(dir)
            if files_in_dir then
                for _, file in ipairs(files_in_dir) do
                    table.insert(markdown_files, file)
                end
            end
        end

        return #markdown_files > 0 and markdown_files or nil
    end
    if M.recurse(json) then
        return true
    else
        return false
    end
end

M.metadata = function(path)
    if not vim.fn.isdirectory(path) then
        error(path .. " is not a directory", 2)
        return
    end
    local metadata = M.readData(path)
    local json = M.readJson(metadata)
    if not M.checkData(json) then
        error("No .md files in directory", 2)
        return
    end
    json = M.Files(json)
    return json
end

M.createGrepPicker = function(opts, paths)
    opts = opts or {}
    builtin.live_grep({
        prompt_title = "Custom live grep",
        search_dirs = paths,
    })
end

M.createPicker = function(opts, metadados)
    opts = opts or {}
    local treatedjson = {}
    for i=1, #metadados do
        local arr = {}
        arr.name = string.gsub(metadados[i], PICKER_PATH .. "/", "")
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

M.insertToc = function(filter)    
    local lines = {}
    table.insert(lines, "# Search result")
    local paths = filter()
    for i=1, #paths do
        local item = paths[i]
        local filename = item:match("([^/\\]+)$"):match("(.+)%..+$")
        if item:match(vim.g.wiki_root) then
            item = item:gsub(vim.g.wiki_root, "~/")
        end
        local template = string.format("- [%s](%s)", filename, item)
        table.insert(lines, template)
    end
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(bufnr, row - 1, col, row - 1, col, lines)
end

-- função pega e organiza o input de metadado do usuarios como chaves e os valores como todos os valores que o input pode ser filtrado, ignorando espaços em branco essa função pode ser chamada de qualquer parte do programa sem ocorrer um erro, e vai devolver uma lista vazia, exceto se METADADO contém alguma chave com o valor de um array vazio
M.GetMetaChoice = function()
    local metainfo = {}
    for key, _ in pairs(METADADO) do
        local arr = {}
        for _ , value in pairs(JSON) do
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
        arr = M.remove_duplicate(arr)
        metainfo[key] = arr
    end
    return metainfo
end

-- essa função organiza os inputs do usuario em uma estrutura de dados ideial para ser filtrado por um filtro greedy or non greedy
-- { *metadado inputado* : {
    -- *tags inputadas* : {*caminhos que contém essa tag*},
    -- *tags inputadas* : {*caminhos que contém essa tag*}
    -- }
-- }
M.getFilteringStructure = function()
    local caminhos = {}
    for metadado, tags in pairs(METADADO) do
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
            for path, meta in pairs(JSON) do
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
M.greedyFilter = function()
    local files = {}
    local filteringStructure = M.getFilteringStructure()
    for _, value in pairs(filteringStructure) do
        for _, paths in pairs(value) do
            vim.list_extend(files, paths)
        end
    end
    local files = M.remove_duplicate(files)
    table.sort(files)
    return files
end

M.nonGreedyFilter = function()
    local metadata = M.getFilteringStructure()
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

M.PickerPrompt1 = function (opts)
    for key, _ in pairs(METADADO) do
        METADADO[key] = nil
    end
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Select the metatag to search",
        finder = finders.new_table{
            results = METADADOS
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selected_entries = picker:get_multi_selection()
                local entry = action_state.get_selected_entry()
                if selected_entries[1] then
                    for _, value in ipairs(selected_entries) do
                        METADADO[value[1]] = {}
                    end
                elseif entry[1] then
                    METADADO[entry[1]] = {} 
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

M.PickerPrompt2 = function (opts)
    -- função pega e organiza o input de metadado do usuarios como chaves e os valores todos os valores que o input pode ser filtrado por, ignorando espaços em branco 
    local metachoice = M.GetMetaChoice()
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
                        table.insert(METADADO[value.meta], value.ordinal)
                    end
                elseif entry.ordinal then
                    table.insert(METADADO[entry.meta], entry.ordinal)
                end
                actions.close(prompt_bufnr)
                if GREEDY_SEARCH and GREP then
                    M.createGrepPicker({}, M.greedyFilter())
                elseif GREEDY_SEARCH then
                    if TOC then
                        M.insertToc(M.greedyFilter)
                    else
                        M.createPicker({}, M.greedyFilter())
                    end
                elseif GREP then
                    M.createGrepPicker({}, M.nonGreedyFilter())
                else
                    if TOC then
                        M.insertToc(M.nonGreedyFilter)
                    else
                        M.createPicker({}, M.nonGreedyFilter())
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

M.searchMetaVerbose = function(args)
    if args then
        M.HandleArgs(args)
    end
    JSON = M.metadata(PICKER_PATH)
    for _, value in pairs(JSON) do
        for key, _ in pairs(value) do
            table.insert(METADADOS, key)       
        end
    end
    METADADOS = M.remove_duplicate(METADADOS)
    table.sort(METADADOS)
    M.PickerPrompt1()
end


M.SearchMetadata = function(args)
    JSON = M.metadata(PICKER_PATH)
    for key, _ in pairs(METADADO) do
        METADADO[key] = nil
    end
    for k, v in pairs(BUFFERINPUT) do
        if string.sub(string.format("%s", k), 1, 1) ~= "_" then
            if type(v) == "table" then
                METADADO[string.format("%s", k)] = v
            else
                METADADO[string.format("%s", k)] = {}
                table.insert(METADADO[string.format("%s", k)], v)
            end
        end
    end
    if GREEDY_SEARCH and GREP then
        M.createGrepPicker({}, M.greedyFilter())
    elseif GREEDY_SEARCH then
        if TOC then
            M.insertToc(M.greedyFilter)
        else
            M.createPicker({}, M.greedyFilter())
        end
    elseif GREP then
        M.createGrepPicker({}, M.nonGreedyFilter())
    else
        if TOC then
            M.insertToc(M.nonGreedyFilter)
        else
            M.createPicker({}, M.nonGreedyFilter())
        end
    end
end

function get_lua_array_from_buffer(bufnr)
    bufnr = bufnr
    local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
    if not line then
        return nil, "Buffer is empty"
    end
    line = "{" .. line .. "}"
    local success, result = pcall(load("return " .. line))
    if not success then
        return nil, "Error parsing Lua array"
    end
 
    local function convert_keys_to_strings(tbl)
        if type(tbl) ~= "table" then return tbl end
        local new_tbl = {}
        for k, v in pairs(tbl) do
            if k then
                if type(k) ~= "string" then
                    k = tostring(k) -- Convert keys to strings if they aren't already
                end
                new_tbl[k] = v -- Recursively process nested tables
            end
        end
        return new_tbl
    end

    return convert_keys_to_strings(result)
end

M.promptMetaData = function(args)
    if args then
        M.HandleArgs(args)
    end
    local height = 1
    local width = 100
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)
    local buf = vim.api.nvim_create_buf(false, true)
    local opts = {
        relative = "editor",
        style = "minimal",
        border = "rounded",
        title = " Escreva os metadados ",
        title_pos = "center",
        height = height,
        width = width,
        col = col,
        row = row
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.cmd("startinsert")
    vim.keymap.set({"i", "n"}, "<CR>", function() local input, error = get_lua_array_from_buffer(buf); BUFFERINPUT = input or {}; vim.api.nvim_win_close(win, true);M.SearchMetadata(args) end, {buffer=buf} )
    vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(win, true) end, {buffer=buf} )
end

M.inputLinksHandle = function(bufnr)
    local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
    if not line then
        return nil, "Linha não existe"
    end
    local links = {}
    for item in line:gmatch("[^%s]+") do
        if item:match("[^%a%d]") then
        else
            table.insert(links, item)
        end
    end
    return links
end

M.searchLinks = function(args)    
    if args then
        M.HandleArgs(args)
    end
    local height = 1
    local width = 100
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)
    local buf = vim.api.nvim_create_buf(false, true)
    local opts = {
        relative = "editor",
        style = "minimal",
        border = "rounded",
        title = " Pesquisa por links ",
        title_pos = "center",
        height = height,
        width = width,
        col = col,
        row = row
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.cmd("startinsert")
    vim.keymap.set({"i", "n"}, "<CR>", function()
        JSON = M.metadata(PICKER_PATH)
        for key, _ in pairs(METADADO) do
            METADADO[key] = nil
        end
        vim.api.nvim_win_close(win, true)
        local links, err = M.inputLinksHandle(buf)
        if links then
            METADADO.links = links
            if GREEDY_SEARCH and GREP then
                M.createGrepPicker({}, M.greedyFilter())
            elseif GREEDY_SEARCH then
                M.createPicker({}, M.greedyFilter())
            elseif GREP then
                M.createGrepPicker({}, M.nonGreedyFilter())
            else
                M.createPicker({}, M.nonGreedyFilter())
            end
        end
        
    end, {buffer=buf} )
    vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(win, true) end, {buffer=buf} )
end

M.HandleArgs = function(args) 
    PICKER_PATH = args["path"] or vim.g.initial_dir
    if args["search"] == "nongreedy" then
        GREEDY_SEARCH = false
    end
    if args["grep"] then
        GREP = true
    end
    if args["toc"] then
        TOC = true
    end
end

M.Main = function(opts)
    local args = {}
    for option, config in opts.args:gmatch("(%S+)=(%S+)") do
        local num = tonumber(config)
        if num then
            args[option] = num ~= 0 -- Convert to true/false
        else
            args[option] = config -- Keep as string if not a number
        end
        args[option] = config
    end

    -- args que mudam certas coisas dentro do programa
    PICKER_PATH = args["path"] or vim.g.initial_dir
    if args["search"] == "nongreedy" then
        GREEDY_SEARCH = false
    else
        GREEDY_SEARCH = true
    end
    if args["grep"] then
        GREP = true
    else
        GREP = false
    end
    if args["toc"] then
        TOC = true
    else
        TOC = false
    end

    -- espaço reservado para args que mudam a funcionalidade do programa
    if args["verbose"] then
        M.searchMetaVerbose()
    elseif args["links"] then
        M.searchLinks()
    else
        M.promptMetaData() 
    end
end

return M
