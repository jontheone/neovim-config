return {
    "3rd/image.nvim",
    build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
    opts = {
        processor = "magick_cli",
    },
    config = function()
        require("image").setup({
            backend = "kitty",
            processor = "magick_cli",
            inetgrations = {
                markdown = {
                    enabled = true
                }
            },
            scale_factor = 2.0
        })
    end
}
