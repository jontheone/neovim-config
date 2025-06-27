return {
    "CRAG666/code_runner.nvim",
    config = function()
        require("code_runner").setup({
            focus = false,
            filetype = {
                javascript = {
                    "node $file"
                },
                lua = {
                    "lua $file"
                }
            }
        })
        vim.keymap.set("n", "|", ":RunCode<CR>")
    end
}
