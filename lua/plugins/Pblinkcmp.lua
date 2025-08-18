return {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    version = '1.*',
    dependencies = { 'rafamadriz/friendly-snippets' },
    opts = {
        enabled = function() return true end,
        keymap = {
            preset = 'default',
            ["<C-l>"] = { 'snippet_forward', 'fallback' },
            ["<C-h>"] = { 'snippet_backward', 'fallback' },
            -- ["<C-j>"] = { 'select_next', 'fallback' },
            -- ["<C-k>"] = { 'select_prev', 'fallback' },
        },
        appearance = { nerd_font_variant = 'mono' },
        completion = { documentation = { auto_show = false }, menu = {ghost_text = { enabled = true } } },
        sources = { default = { 'lsp', 'path', 'snippets', 'buffer' }, }
    }
}
