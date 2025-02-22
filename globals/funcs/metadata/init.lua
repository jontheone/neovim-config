-- SUGESTãO levar o retrieve de informação para próxima etapa, assim que o usuario escolher um arquivo, ele vai poder navegar pelo arquivo e copiar, colar e modificar qualquer informação presente nele, assim você pode acessar qualquer informação de forma rápida colar informação de outros buffers ou simplesmente modificar informações de outros buffers rápidamente, se você precisar

--local JSON
--local METADADO = {}
--local METADADOS = {}
--local PICKER_PATH
--local GREEDY_SEARCH = true
--local BUFFERINPUT = {}
--local GREP = false
--local TOC = false

local M = {}

-- O json contendo uma lista com todos os caminhos dos metadados e os metadados
M.JSON = nil
-- Uma lista de chave-valor em que as chaves são os metadados e os valores são listas contendo pelo que eles vão ser filtrados
M.METADADO = {}
-- lista contendo os possiveis metadados que o usuarios pode escolher para filtrar
M.METADADOS = {}
-- caminho em que o picker vai ser aberto e que os arquivos serão procurados
M.PICKER_PATH = nil
-- wether to make a greedy search or not to
M.GREEDY_SEARCH = true
-- the input of the buffer in case the user uses the non verbose option of input 
M.BUFFERINPUT = {}
-- wether to make a grep search or a normal search in the files
M.GREP = false
-- whether to use the toc function
M.TOC = false

M.data = require("metadata.data")
M.filters = require("metadata.filters")
M.pickers = require("metadata.pickers")

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

M.HandleArgs = function(args) 
    PICKER_PATH = args["path"] or vim.g.initial_dir
    if args["search"] == "nongreedy" then
        M.GREEDY_SEARCH = false
    end
    if args["grep"] then
        M.GREP = true
    end
    if args["toc"] then
        M.TOC = true
    end
end

M.searchMetaVerbose = function(args)
    if args then
        M.HandleArgs(args)
    end
    M.JSON = M.metadata(PICKER_PATH)
    for _, value in pairs(M.JSON) do
        for key, _ in pairs(value) do
            table.insert(METADADOS, key)       
        end
    end
    METADADOS = M.remove_duplicate(METADADOS)
    table.sort(METADADOS)
    M.PickerPrompt1()
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

M.SearchMetadata = function(args)
    M.JSON = M.metadata(PICKER_PATH)
    for key, _ in pairs(M.METADADO) do
        M.METADADO[key] = nil
    end
    for k, v in pairs(M.BUFFERINPUT) do
        if string.sub(string.format("%s", k), 1, 1) ~= "_" then
            if type(v) == "table" then
                M.METADADO[string.format("%s", k)] = v
            else
                M.METADADO[string.format("%s", k)] = {}
                table.insert(M.METADADO[string.format("%s", k)], v)
            end
        end
    end
    if M.GREEDY_SEARCH and M.GREP then
        M.createGrepPicker({}, M.greedyFilter())
    elseif M.GREEDY_SEARCH then
        if M.TOC then
            M.insertToc(M.greedyFilter)
        else
            M.createPicker({}, M.greedyFilter())
        end
    elseif M.GREP then
        M.createGrepPicker({}, M.nonGreedyFilter())
    else
        if M.TOC then
            M.insertToc(M.nonGreedyFilter)
        else
            M.createPicker({}, M.nonGreedyFilter())
        end
    end
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
        M.JSON = M.metadata(PICKER_PATH)
        for key, _ in pairs(M.METADADO) do
            M.METADADO[key] = nil
        end
        vim.api.nvim_win_close(win, true)
        local links, err = M.inputLinksHandle(buf)
        if links then
            M.METADADO.links = links
            if M.GREEDY_SEARCH and M.GREP then
                M.createGrepPicker({}, M.greedyFilter())
            elseif M.GREEDY_SEARCH then
                M.createPicker({}, M.greedyFilter())
            elseif M.GREP then
                M.createGrepPicker({}, M.nonGreedyFilter())
            else
                M.createPicker({}, M.nonGreedyFilter())
            end
        end
    end, {buffer=buf} )
    vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(win, true) end, {buffer=buf} )
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
    vim.keymap.set({"i", "n"}, "<CR>", function() local input, error = get_lua_array_from_buffer(buf); M.BUFFERINPUT = input or {}; vim.api.nvim_win_close(win, true);M.SearchMetadata(args) end, {buffer=buf} )
    vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(win, true) end, {buffer=buf} )
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
    M.PICKER_PATH = args["path"] or vim.g.initial_dir
    if args["search"] == "nongreedy" then
        M.GREEDY_SEARCH = false
    else
        M.GREEDY_SEARCH = true
    end
    if args["grep"] then
        M.GREP = true
    else
        M.GREP = false
    end
    if args["toc"] then
        M.TOC = true
    else
        M.TOC = false
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
