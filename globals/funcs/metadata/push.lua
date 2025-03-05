local dt = require("metadata.datacollect")

local M = {}

M.Push = function(opts)
    local link = string.match(opts.args, "[%g%s%p%ç%ã%õ]+")
    local topic_dir = ".assuntos"
    local receiver = vim.fs.joinpath(vim.g.wiki_root, link)
    local sender = vim.fs.joinpath(vim.g.wiki_root, topic_dir)
    local paths = dt.getFilesByLabelData("links", link, sender, true)
    if not paths[1] then
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
        for i=1, #paths do
            local path = paths[i]
            if dt.dataOf(path, "type")[1] == "" then
                local new_path = string.gsub(path, topic_dir, link)
                os.rename(path, new_path)
            else                
                local new_path = string.gsub(path, topic_dir, ".notas")
                os.rename(path, new_path)
            end
        end
    else
        return
    end
end


return M
