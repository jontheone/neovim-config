return {
    'uga-rosa/ccc.nvim',
    config = function()
        local mappings = require("ccc").mapping
        require("ccc").setup({
            lsp = false,
            highlighter = {
                auto_enable = false,
                lsp = false
            },
        })
        vim.keymap.set("n", "<leader>pc", "<cmd>CccPick<CR>", {desc="color picker"})
    end
}
