local M = {}

M.change = function(opts)
    local args = {}
    for item in opts.args:gmatch("[^%;]+") do
        if item == "" then
            break
        else
            table.insert(args, item)
        end
    end
    if not args[2] then
        return
    end
    local labels = {}
    for item in args[1]:gmatch("[^,]+") do
        table.insert(labels, item)
    end
    table.remove(args, 1)
    local data = {}
    for i=1, #labels do
        local dataset = args[i]
        local label = labels[i]
        if not dataset then
            print("provide enough input for the amount of labels")
            return
        end
        local set = {}
        for item in dataset:gmatch("[^,]+") do
            table.insert(set, item)
        end
        data[label] = set
    end
    local buf = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for i=1, #labels do
        for j=1, #buf do
            if buf[j]:match("^#%+"..labels[i]..":.*") then
                if data[labels[i]][1] == "*reset" then
                    buf[j] = string.format("#+%s:%s", labels[i], "")
                    vim.api.nvim_buf_set_lines(0, 0, -1, false, buf)
                    break
                else
                    buf[j] = string.format("#+%s:%s", labels[i], table.concat(data[labels[i]], ", "))
                    vim.api.nvim_buf_set_lines(0, 0, -1, false, buf)
                    break
                end
            end
        end
    end
end

return M
