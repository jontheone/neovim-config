return { 
    "hrsh7th/nvim-cmp",
    dependencies = {
         "hrsh7th/cmp-nvim-lsp",
         "hrsh7th/cmp-buffer",
         "hrsh7th/cmp-path",
         "neovim/nvim-lspconfig"
    },
    config = function()
        local cmp = require("cmp")
        cmp.setup({
          mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<Tab>"] = cmp.mapping.confirm({ select = true }), -- Accept selected item
            ["<C-n>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<C-p>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end, { "i", "s" }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "path" },
          }, {
            { name = "buffer" },
          }),
        })

        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("UserLspConfig", {}),
          callback = function(ev)
            local opts = { buffer = ev.buf }
            
            -- Navigation & Editing
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            
            -- Diagnostics
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
          end,
        })

        vim.lsp.config("clangd", {
            capabilities = capabilities,
        })
        vim.lsp.enable("clangd")

        vim.diagnostic.config({
            virtual_text = { prefix = "■", spacing = 4},
            signs = true,
            update_in_insert = false

        })
    end
}
