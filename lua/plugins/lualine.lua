return {
    "nvim-lualine/lualine.nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require("lualine").setup{
            options = {
                theme = "auto",
                icons_enable = true,
                section_separators = { left = "", right = "" },
                component_separators = { left = '/', right = '/' }
            },
            sections = {
                lualine_a = {"mode"},
                lualine_b = {"filename", "filetype"},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {"progress", "location"},
                lualine_z = {"os.date('%d-%m-%y')"}
            },
            tabline = {
                lualine_a = {
                    {
                        'buffers',
                        mode = 2
                    }
                },
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {"tabs"}
            }
        }
    end
}
