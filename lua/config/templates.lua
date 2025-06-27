-- Templates for files
local setlines = vim.api.nvim_buf_set_lines

vim.keymap.set("n", "<leader>ta", function()
    local cursor = vim.api.nvim_win_get_cursor(0)[1]
    local template = {
        "---",
        string.format("date: %s", os.date("%m-%d-%Y")),
        string.format("title: %s", vim.fn.expand"%:t:r"),
        string.format("author: %s", "Jonh"),
        "---"
    }
    setlines(0, (cursor-1), cursor, false, template)
    vim.api.nvim_win_set_cursor(0, {(cursor+2), 0})
    vim.cmd("normal A")
end)

vim.keymap.set("n", "<leader>ts", function()
    local cursor = vim.api.nvim_win_get_cursor(0)[1]
    local template = {
        "---",
        string.format("date: %s", os.date("%m-%d-%Y")),
        string.format("title: %s", vim.fn.expand"%:t:r"),
        string.format("author: %s", "Jonh"),
        "_links: ",
        "---"
    }
    setlines(0, (cursor-1), cursor, false, template)
    vim.api.nvim_win_set_cursor(0, {(cursor+4), 0})
    vim.cmd("normal A")
end)

vim.keymap.set("n", "<leader>td", function()
    local cursor = vim.api.nvim_win_get_cursor(0)[1]
    local template = {
        "---",
        string.format("date: %s", os.date("%m-%d-%Y")),
        string.format("title: %s", vim.fn.expand"%:t:r"),
        string.format("author: %s", "Jonh"),
        "_links: ",
        "_topic: ",
        "---"
    }
    setlines(0, (cursor-1), cursor, false, template)
    vim.api.nvim_win_set_cursor(0, {(cursor+4), 0})
    vim.cmd("normal A")
end)

vim.keymap.set("n", "<leader>tf", function()
    local cursor = vim.api.nvim_win_get_cursor(0)[1]
    local template = {
        "---",
        string.format("date: %s", os.date("%m-%d-%Y")),
        string.format("title: %s", vim.fn.expand"%:t:r"),
        string.format("author: %s", "Jonh"),
        "_links: ",
        "_topic: ",
        "_tags: ",
        "---"
    }
    setlines(0, (cursor-1), cursor, false, template)
    vim.api.nvim_win_set_cursor(0, {(cursor+4), 0})
    vim.cmd("normal A")
end)
