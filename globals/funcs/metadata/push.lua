--local metadata = require("metadata.data").metadata

local M = {}

M.push = function(opts)
    local link = string.match(opts.args, "%g+%s*") or false
    link = string.match(link, "^%s*(.-)%s*$")
    if not link then
        error("Utilize apenas caracteres alfanumericos", 2)
    end
    if string.match(link, "%c") or string.match(link, "%p") then
        error("Não utilize caracteres de controle ou pontuação", 2)
    end
    local topic_dir = ".assuntos"
    local receiver = vim.fs.joinpath(vim.g.wiki_root, link) 
    local sender = vim.fs.joinpath(vim.g.wiki_root, topic_dir)
    local json = metadata(sender)
    local paths_to_rename = {}
    local notes_to_rename = {}
    for key, value in pairs(json) do
        local dado = value.links
        local note; do if value.type == "note" then note = true else note = false end end
        if type(dado) == "table" then
            if dado[1] == link then
                if note then
                    table.insert(notes_to_rename, key)
                else
                    table.insert(paths_to_rename, key)
                end
            end
        else
            if dado == link then
                if note then
                    table.insert(notes_to_rename, key)
                else
                    table.insert(paths_to_rename, key)
                end
            end
        end
    end
    if not paths_to_rename[1] and not notes_to_rename[1] then
        print("Nenhum arquivo com esse link encontrado")
        return
    end
    if vim.fn.isdirectory(receiver) == 0 then
        local input = vim.fn.inputlist({"Create new directory: " .. receiver, "(1). yes", "(2). no"})
        if input == 1 then
            os.execute(string.format("mkdir %s", receiver))
            print("\ndiretorio " .. receiver .. " criado")
        else
            return
        end
    end
    local input = vim.fn.inputlist({"Push files from " .. sender .. " --> " .. receiver .. " ?", "(1). yes", "(2). no"})
    if input == 1 then
        for i=1, #paths_to_rename do
            local path = paths_to_rename[i]
            local new_path = string.gsub(path, topic_dir, link)
            os.rename(path, new_path)
        end
        for i=1, #notes_to_rename do
            local path = notes_to_rename[i]
            local new_path = string.gsub(path, topic_dir, ".notas")
            os.rename(path, new_path)
        end
    else
        return
    end
end

return M
