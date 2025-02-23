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

M.data = require("metadata.data")
M.filters = require("metadata.filters")
M.pickers = require("metadata.pickers")

M.searchMetaVerbose = function(args)
    local path = args["path"] or vim.g.initial_dir
    local json = M.data.metadata(path)
    M.pickers.PickerPrompt1({}, {args=args, json=json})
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
        M.searchMetaVerbose(args)
    elseif args["links"] then
        M.searchLinks()
    else
        M.promptMetaData() 
    end
end


return M
