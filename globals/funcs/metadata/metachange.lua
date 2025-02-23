-- ao final do sistema o usuario será perguntado se ele acrescentar a lista de inputs existentes ou se ele deseja substituir os metadados já contidos naquele field, não será perguntado caso o field esteja em branco
local readFileData = require("metadata.data").readFileData
local M = {}

M.promptInput = function(path, metatag)     
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 100 
    local height = 1
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)
    local opts = {
        relative = "editor",
        style = "minimal",
        title = " Escolha o metadado para mudar ",
        title_pos = "center",
        col = col,
        row = row,
        width = width,
        height = height,
        border = "rounded"
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.cmd("startinsert")
    vim.keymap.set({"n", "i"}, "<CR>", function() 
        vim.api.nvim_win_close(win, true)
        local inputstring = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
        local input = {}
        for item in inputstring:gmatch("[^,]+") do
            if item:match("[^%a%d%s]") then
                error("only type alphanumerical characters")
            else
                table.insert(input, item:match("^%s*(.-)%s*$"))
            end
        end
        if #input == 1 then
            input = input[1]
        end
        local insert = ""
        local file = vim.fn.readfile(path)
        local pos = {}
        for index, i in ipairs(file) do
            if i:match("<!%-%- METADATA %-%->") then
                pos.a = index
            elseif i:match("<!%-%- /METADATA %-%->") then
                pos.b = index 
            end
        end
        if type(input) == "table" then
            for _, i in ipairs(input) do
                insert = insert .. string.format('"%s", ', i)
            end
            insert = "[ " .. insert:sub(1, -3) .. " ]"
            for i=(pos.a+1), (pos.b-1) do
                if string.match(file[i], '^"([^"]+)"') == metatag then
                    if string.sub(file[i], -1, -1) == "," then
                        file[i] = string.gsub(file[i], "(:%s*)(.*)", ": " .. insert .. ",")
                    else
                        file[i] = string.gsub(file[i], "(:%s*)(.*)", ": " .. insert)
                    end
                end
            end
            vim.fn.writefile(file , path)
            vim.cmd("e!")
        elseif type(input) == "string" then
            insert = string.format('"%s"', input)
            for i=(pos.a+1), (pos.b-1) do
                if string.match(file[i], '^"([^"]+)"') == metatag then
                    if string.sub(file[i], -1, -1) == "," then
                        file[i] = string.gsub(file[i], "(:%s*)(.*)", ": " .. insert .. ",")
                    else
                        file[i] = string.gsub(file[i], "(:%s*)(.*)", ": " .. insert)
                    end
                end
            end
            vim.fn.writefile(file , path)
            vim.cmd("e!")
        end
        
    end, {buffer = buf})
    vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(win, true) end, {buffer=buf} )
end

M.metachange = function()
    local path = vim.fn.expand("%:p")
    local metadata = readFileData(path)
    local String = ""
    if string.sub(metadata[1], 1, 1) == "{" then
        for i=1, #metadata do
            String = String .. metadata[i]
        end
    end
    local status, json = pcall(vim.json.decode, String)
    if not status then
        print("NA ESTRUTURA DOS METADADOS: " .. json)
        return
    end
    local keys = {}
    for key, _ in pairs(json) do
        table.insert(keys, key)
    end
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 100 
    local height = #keys
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)
    local opts = {
        relative = "editor",
        style = "minimal",
        title = " Escolha o metadado para mudar ",
        title_pos = "center",
        col = col,
        row = row,
        width = width,
        height = height,
        border = "rounded"
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    table.sort(keys)
    vim.api.nvim_buf_set_lines(buf, 0, (#keys-1), false, keys)
    vim.bo[buf].modifiable = false
    vim.keymap.set({"n", "i"}, "<CR>", function() 
        local metatag = vim.api.nvim_get_current_line()
        vim.api.nvim_win_close(win, true)
        M.promptInput(path, metatag)
    end, {buffer = buf})
    vim.keymap.set("n", "<esc>", function() vim.api.nvim_win_close(win, true) end, {buffer=buf} )
end

return M
