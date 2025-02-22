return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = false },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    picker = { enabled = false },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
    image = {
        enabled = true,
        formats = {
            "png",
            "jpg",
            "jpeg",
            "gif",
            "bmp",
            "webp",
            "tiff",
            "heic",
            "avif",
            "mp4",
            "mov",
            "avi",
            "mkv",
            "webm",
            "pdf",
        },
        doc = {
            -- enable image viewer for documents
            -- a treesitter parser must be available for the enabled languages.
            -- supported language injections: markdown, html
            enabled = true,
            -- render the image inline in the buffer
            -- if your env doesn't support unicode placeholders, this will be disabled
            -- takes precedence over `opts.float` on supported terminals
            inline = true,
            -- render the image in a floating window
            -- only used if `opts.inline` is disabled
            float = true,
            max_width = 160,
            max_height = 100,
        },
    }
  },
}
