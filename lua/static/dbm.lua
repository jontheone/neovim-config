local data = require("static.datacollection")
local status = true
if not (os.execute("psql --version") == 0) then
    status = not status
end

local DB = "wiki"
local TABLE = "wiki"

local M = {}

M.cmd = function(command)
    local out = io.popen(command) or {}
    local entries = out:read"a*"
    out:close()
    if not (entries == "") then return entries else return end
end

-- this one is a query in expecting stdout
---@param query string
M.SQuery = function(query, args)
    if args then assert(type(args) == "table", "The second parameter must be a table containing extra arguments  for the command") end
    local ExtraArgs = table.concat(args, " ")
    local command = string.format([[psql -d%s -c"%s"]], DB, query) .. " " .. ExtraArgs
    print(command)
    local out = M.cmd(command)
    if out then
        return out
    else
        return false
    end
end

-- this one is a query not expecting any stdout
---@param query string
M.Query = function(query, ...)
    local command = string.format([[psql -d%s -c"%s"]], DB, query) .. ...
    local out = os.execute(command)
    if out == 0 then
        return true
    else
        return false
    end
end

-- this is an iterator function that returs a list of key-value pairs in which the keys are the column and the values are the values on that row
---@param query string
M.IterRows = function(query)

end


M.GetInodes = function()
end

-- An iterator to iterate through the whole wiki table
M.IterTable = function()
    local out = M.SQuery(string.format("SELECT * FROM %s", TABLE))
    if not out then print("failed"); return end
    local entries = {}
    local columns = {}
    for item in out:gmatch("[^\n]+") do
        table.insert(entries, item)
    end
    for col in entries[1]:gmatch("[^|]+") do
        table.insert(columns, col:match("^%s*(.-)%s*$"))
    end
    table.remove(entries, 1)
    table.remove(entries, 1)
    table.remove(entries, #entries)
    print(vim.inspect(entries))
    return function()
        local fields = {}
        local line = table.remove(entries, 1)
        if not line then return nil end
        local i = 0
        for item in line:gmatch("[^|]+") do
            i = i + 1
            item = item:match("^%s*(.-)%s*$")
            fields[columns[i]] = item
        end
        return fields
    end
end

M.CheckDatabase = function()
    print("Verificando databases presentes no cluster... ")
    local databases = M.cmd("psql -l | grep "..DB)
    if not databases then
        print("Database wiki não está presente. criando database wiki... ")
        local out = os.execute(string.format([[psql postgres -c"%s"]], "CREATE DATABASE "..DB))
        if not (out == 0) then
            print("Erro ao criar a database Wiki, Operação sync cancelada.")
            return false
        end
    end
    print("Databse wiki presente no cluster.")
    return true
end
M.CheckTable = function()
    print("Verificando a existência da tabela wiki...")
    local wikis = M.cmd(string.format([[psql -d%s -c"\d"]], DB)) or ""
    local tbl = wikis:match(TABLE)
    if tbl then
        print("Tabela wiki encontrada com sucesso.")
        return true
    else
        print("Tabela wiki não está presente. Criando uma...")
        print("Checando por backup da tabela wiki no seu diretório...")
        local backup = vim.fs.joinpath(vim.g.wiki_root, ".wiki.sql")
        if not (os.execute(string.format("[ -f %s ]", backup)) == 0) then
            local input = vim.fn.input("(não recomendado)Backup da tabela wiki não encontrado, você gostaria de criar uma nova do zero (y/n): ")
            if input == "y" then
                print("\nCriando nova tabela wiki...")
                local out = M.Query([[
                    CREATE TABLE wiki (
                        inode integer PRIMARY KEY,
                        path varchar(120) NOT NULL,
                        author varchar(20),
                        title varchar(50),
                        date DATE,
                        links varchar(30),
                        topic varchar(30),
                        tags TEXT[]
                    );
                ]])
                if out then print("tabela wiki criada com sucesso"); return true else print("Falha ao criar tabela wiki. Operação sync cancelada"); return false end
            else
                print("\nOperação sync cancelada.")
                return false
            end
        else
            print("Backup da tabela wiki encontrado. Atualizando database...")
            if not (os.execute(string.format([[psql -d %s -f %s]], DB, vim.fs.abspath(backup))) == 0) then
                print("Backup falhou por algum motivo. Operação sync cancelada.")
                return false
            else
                print("Backup feito com sucesso.")
                return  true
            end
        end
    end
end

M.Sync = function()
    if not M.CheckDatabase() then
        return
    elseif not M.CheckTable() then
        return
    end
    print("verificando integridade da tabela...")    
end


M.Sync()


if not status then
    print("Psql is not installed in your enviroment. All database related functionality will not be available. install and configura postgres cli in order to and set up a user with the current user that your in neovim")
    return {}
else
    return M
end
