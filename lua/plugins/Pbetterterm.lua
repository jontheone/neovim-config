return {
  "CRAG666/betterTerm.nvim",
  opts = {
    position = "bot",
    size = 15,
  },
  config = function()
      local betterTerm = require("betterTerm")
      betterTerm.setup({size = 15})
      vim.keymap.set({"n", "t"}, "<C-\\>", betterTerm.open, { desc = "Open terminal"})
      vim.keymap.set({"n", "t"}, "<C-b>", function()
          if vim.api.nvim_get_mode().mode == "t" then
              vim.cmd("wincmd k")
          elseif vim.api.nvim_get_mode().mode == "n" then
              vim.cmd("wincmd j")
              vim.cmd("startinsert")
          end
      end, { desc = "Flip through windows in terminal mode"})
  end
}
