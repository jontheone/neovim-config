return {
    {
        'neovim/nvim-lspconfig',
    },
    {
        "williamboman/mason.nvim",
        dependencies = {'williamboman/mason-lspconfig.nvim'},
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "lua_ls", "vimls", "ts_ls", "cssls", "superhtml"}, -- Adicione os servidores que deseja instalar
                automatic_installation = true
            })

            -- Configuração automática para servidores instalados
            local lspconfig = require("lspconfig")
            local capabilities = require("blink.cmp").get_lsp_capabilities()
            lspconfig.lua_ls.setup { capabilities = capabilities }
            lspconfig.pyright.setup { capabilities = capabilities }
            lspconfig.vimls.setup { capabilities = capabilities }
            lspconfig.ts_ls.setup{ capabilities = capabilities}
            lspconfig.cssls.setup{ capabilities = capabilities}
            lspconfig.superhtml.setup{ capabilities = capabilities}
--            require("mason-lspconfig").setup_handlers({
--                function(server_name)
--                    lspconfig[server_name].setup({})
--                end,
--            })
        end,
    }
}
