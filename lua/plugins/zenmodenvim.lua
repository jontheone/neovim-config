return {
  "folke/zen-mode.nvim",
  opts = {
      window = {
          width = 1,
          height = 1,
          options = {
              signcolumn = "no",
              number = false,
              relativenumber = false,
              cursorline = false,
          }
      },
      on_open = function()
          print("Zen mode")
      end,
      on_close = function()
          print("Zen mode: disabled")
      end
  },
}
