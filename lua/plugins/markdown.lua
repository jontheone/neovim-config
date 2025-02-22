return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons", 'echasnovski/mini.nvim' },
    opts = {
        code = {
            enabled = true,
            sign = true,
            style = 'full',
            position = 'left',
            language_pad = 0,
            language_name = true,
            disable_background = { 'diff' },
            width = 'full',
            left_margin = 0,
            left_pad = 0,
            right_pad = 0,
            min_width = 0,
            border = 'thin',
            above = '▄',
            below = '▀',
            highlight = 'RenderMarkdownCode',
            highlight_inline = 'RenderMarkdownCodeInline',
            highlight_language = nil,
        },
        dash = {
            enabled = true,
            icon = '─',
            width = 'full',
            highlight = 'RenderMarkdownH1',
        },
        quote = { repeat_linebreak = true },
        win_options = {
            showbreak = { default = '', rendered = '  ' },
            breakindent = { default = false, rendered = true },
            breakindentopt = { default = '', rendered = '' },
        },
        checkbox = {
            enabled = true,
            position = 'inline',
            unchecked = {
                icon = '󰄱 ',
                highlight = 'RenderMarkdownUnchecked',
                scope_highlight = nil,
            },
            checked = {
                icon = '󰱒 ',
                highlight = 'RenderMarkdownChecked',
                scope_highlight = nil,
            }
        }
    }
}
