return {
    "CRAG666/code_runner.nvim",
    config = function()
        require("code_runner").setup({
            focus = false,
            filetype = {
                javascript = {
                    "node $file"
                }
            }
        })
    end
}
