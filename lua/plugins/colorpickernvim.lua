return {
    'uga-rosa/ccc.nvim',
    config = function()
        require("ccc").setup()
        vim.keymap.set("n", "<leader>pc", ":CccPick")
    end
}
