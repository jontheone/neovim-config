local M = {}

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


M.readData = function(Path)
    local metadata = {}
    for name, node in vim.fs.dir(Path) do
        local NODE = node
        local NAME = vim.fs.joinpath(Path, name)
        if NODE == "directory" then 
            local data1 = M.readData(NAME)
            metadata[string.format("%s", "_" .. NAME)] = data1
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
                metadata[string.format("%s", NAME)] = String
            end
        end
        ::Skip::
    end
    return metadata
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

return M
