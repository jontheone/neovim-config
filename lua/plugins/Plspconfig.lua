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
    config = function()
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
            ensure_installed = {
                "pyright",
                "clangd",
                "html",
                "cssls",
                "jsonls",
                "lua_ls",
                "biome",
            }
        })
        lsp["clangd"].setup({})
        lsp["pyright"].setup({})
        lsp["biome"].setup({})
        lsp["lua_ls"].setup({
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim' }
                    }
                }
            }
        })
        lsp["cssls"].setup({})
        lsp["html"].setup({})
        vim.diagnostic.config({virtual_text = true})

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
