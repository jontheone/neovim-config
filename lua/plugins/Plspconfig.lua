return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "jay-babu/mason-nvim-dap.nvim",
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "mfussenegger/nvim-dap"
    },
    config = function(_, opts)
        local dap = require("dap")
        local dapui = require("dapui")
        local lsp = require("lspconfig")
        require("mason").setup()
        require("mason-nvim-dap").setup({
            ensure_installed = {
                "codelldb",
            }
        })
        require("mason-lspconfig").setup({
            automatic_enable = false,
            ensure_installed = {
                "pyright",
                "clangd",
                "html",
                "cssls",
                "jsonls",
                "lua_ls",
                "biome",
                "texlab"
            }
        })

        local capabilities = require('blink.cmp').get_lsp_capabilities()
        lsp["pyright"].setup({capabilities = capabilities})
        lsp["clangd"].setup({capabilities = capabilities})
        lsp["cssls"].setup({capabilities = capabilities})
        lsp["jsonls"].setup({capabilities = capabilities})
        lsp["lua_ls"].setup({capabilities = capabilities})
        lsp["biome"].setup({capabilities = capabilities})
        lsp["texlab"].setup({capabilities = capabilities})


        vim.diagnostic.config({virtual_text = false, underline = false, signs = false, virtual_lines = false, update_in_insert = true})

        dapui.setup()
        dap.listeners.before.attach.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
          dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
          dapui.close()
        end
--        dap.adapters.codelldb = {
--          type = "executable",
--          command = "/home/jonputer/debuggers/extension/adapter/codelldb", -- or if not in $PATH: "/absolute/path/to/codelldb"
--        }
--        dap.configurations.cpp = {
--          {
--            name = "Launch file",
--            type = "codelldb",
--            request = "launch",
--            program = function()
--              return vim.fn.input('File: ', vim.fn.getcwd() .. '/', 'file')
--            end,
--            cwd = '${workspaceFolder}',
--          },
--        }
--        vim.keymap.set("n", "|", function() dap.continue() end, { desc = "DAP: Continue" })
--        vim.keymap.set("n", "<leader>et", function() dap.toggle_breakpoint() end, { desc = "DAP: Step Over" })

    end
}
