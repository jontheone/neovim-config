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
M.funcs = require("metadata.functionalities")

M.searchMetadataVerbose = function(args)
    args = args or {}
    local path = args["path"] or vim.g.initial_dir
    local json = M.data.metadata(path)
    M.pickers.PickerPrompt1({}, {args=args, json=json})
end

M.SearchMetadata = function(args)
    args = args or {}
    local get_lua_array_from_buffer = function(bufnr)
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
    local processInput = function(params)
        params = params or {}
        local args = params.args
        local input = params.input
        local options = {}
        for k, v in pairs(input) do
            if string.sub(string.format("%s", k), 1, 1) ~= "_" then
                if type(v) == "table" then
                    options[string.format("%s", k)] = v
                else
                    options[string.format("%s", k)] = {}
                    table.insert(options[string.format("%s", k)], v)
                end
            end
        end
        params.input = options
        if (not args.greedy) and (args.grep) then
            M.pickers.createGrepPicker({}, M.filters.greedyFilter(params))
        elseif not args.greedy then
            if args.toc then
                M.funcs.insertToc(greedyFilter, params)
            else
                M.pickers.createPicker({}, M.filters.greedyFilter(params), args.path or vim.g.initial_dir)
            end
        elseif args.grep then
            M.pickers.createGrepPicker({}, M.filters.nonGreedyFilter(params))
        else
            if args.toc then
                M.funcs.insertToc(M.filters.nonGreedyFilter, params)
            else
                M.pickers.createPicker({}, M.filters.nonGreedyFilter(params), args.path or vim.g.initial_dir)
            end
        end
    end
    local win, buf = M.funcs.promptWindow({title=" digite os seus metadados "})
    vim.keymap.set({"i", "n"}, "<CR>", function()
        local input, err = get_lua_array_from_buffer(buf)
        if not input then
            error(err, 2)
        end
        vim.api.nvim_win_close(win, true)
        processInput({args=args, input=input, json=M.data.metadata(args.path or vim.g.initial_dir)}) 
    end, {buffer=buf})

    vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(win, true) end, {buffer=buf} )

end

M.searchLinks = function(args)    
    args = args or {}
    local inputLinksHandle = function(bufnr)
        local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
        local links = {}
        links.links = {}
        for item in line:gmatch("[^%s]+") do
            if item:match("[^%a%d]") then
            else
                table.insert(links.links, item)
            end
        end
        return links
    end
    local win, buf = M.funcs.promptWindow({title=" pesquisa por links "})
    vim.keymap.set({"i", "n"}, "<CR>", function()
        local params = {}
        params.args = args
        params.json = M.data.metadata(args.path or vim.g.initial_dir)
        params.input = inputLinksHandle(buf)
        vim.api.nvim_win_close(win, true)
        if (not args.greedy) and (args.grep) then
            M.pickers.createGrepPicker({}, M.filters.greedyFilter(params))
        elseif not args.greedy then
            if args.toc then
                M.funcs.insertToc(greedyFilter, params)
            else
                M.pickers.createPicker({}, M.filters.greedyFilter(params), args.path or vim.g.initial_dir)
            end
        elseif args.grep then
            M.pickers.createGrepPicker({}, M.filters.nonGreedyFilter(params))
        else
            if args.toc then
                M.funcs.insertToc(M.filters.nonGreedyFilter, params)
            else
                M.pickers.createPicker({}, M.filters.nonGreedyFilter(params), args.path or vim.g.initial_dir)
            end
        end
    end, {buffer=buf} )
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
    -- espaço reservado para args que mudam a funcionalidade do programa
    if args.verbose then
        M.searchMetadataVerbose(args)
    elseif args.links then
        M.searchLinks(args)
    else
        M.SearchMetadata(args)
    end
end


return M
