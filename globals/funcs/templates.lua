local M = {}

M.template_html = function()
    local C_position = vim.api.nvim_win_get_cursor(0)
    local template = {
        '<!DOCTYPE html>',
        '<html lang="en">',
        '<head>',
        '  <meta charset="UTF-8">',
        '  <meta name="viewport" content="width=device-width, initial-scale=1.0">',
        '  <title>Document</title>',
        '</head>',
        '<body>',
        ' ',
        '</body>',
        '</html>'
    }
    vim.api.nvim_buf_set_lines(0, C_position[1], C_position[1], false, template) 
end

M.template_new_file = function()
    local C_position = vim.api.nvim_win_get_cursor(0)
    local template = {
        '<!-- METADATA -->',
        '{',
        string.format('"file name" : "%s",', vim.fn.expand("%:t:r")),
        '"links" : "",',
        '"tags" : [ "" ],',
        '"type" : "normal"',
        '}',
        '<!-- /METADATA -->'
    }
    vim.api.nvim_buf_set_lines(0, (C_position[1]-1),(C_position[1]-1), true, template) 
end

M.template_date = function()
    local C_position = vim.api.nvim_win_get_cursor(0)
    local template = {
        os.date("%d-%m-%y - %H:%M:%S"),
        '---',
        ' '
    }
    local stringed_list = table.concat(template, "/")
    local formatStr = string.format( stringed_list, vim.fn.expand('%:t:r'))
    local formated_content = {}
    for line in formatStr:gmatch("[^/]+") do
        table.insert( formated_content , line )
    end
    vim.api.nvim_buf_set_lines(0, C_position[1], C_position[1], false, formated_content) 
end

return M
