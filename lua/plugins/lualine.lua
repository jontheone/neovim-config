return {
    "nvim-lualine/lualine.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local function get_file_icon()
                local devicons = require('nvim-web-devicons')
                local filename = vim.fn.expand('%:t')   -- Nome do arquivo (ex: main.lua)
                local extension = vim.fn.expand('%:e')  -- Extensão (lua)
                local icon, _ = devicons.get_icon(filename, extension, { default = true })
                icon = icon .. " " .. extension
                return icon or ''  -- Fallback de segurança
        end
        require("lualine").setup{
            sections = {
                lualine_a = {'mode'},
                lualine_b = {'filename'},
                lualine_c = {'diff'},
                lualine_x = {'searchcount', 'selectioncount'},
                lualine_y = { get_file_icon },
                lualine_z = {'progress', 'location'}
            }
        }
    end
}
