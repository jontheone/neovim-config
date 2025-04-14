return {
    'stevearc/conform.nvim',
    event = { "BufReadPre", "BufNewFile"},
    config = function()
        local conform = require("conform")


        conform.setup({
            formatters_by_ft = {
                javascript = { "prettier", "prettierd" },
                lua = { "prettier", "prettierd" },
                python = { "prettier", "prettierd" },
                c = { "prettier", "prettierd" }
            }
        })

        vim.api.nvim_create_autocmd("BufWritePre", {
            callback = function()
                conform.format({
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 500
                })
            end
        })
    end
}
