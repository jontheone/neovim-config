return {
  'stevearc/oil.nvim',
  opts = {},
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  lazy = false,
  config = function()
      require("oil").setup{
          default_file_explorer = true
      }
  end
}
