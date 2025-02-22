return {
  'saghen/blink.cmp',
  dependencies = { "rafamadriz/friendly-snippets"},
  version = '*',
  opts = {
      keymap = {
          preset = 'default',
          ["<Tab>"] = {"accept", "fallback"},
          ["<C-j>"] = {function(cmp) cmp.select_next() end},
          ["<C-k>"] = {function(cmp) cmp.select_prev() end}
      },
      appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono'
      },
      enabled = function()
          -- Retrieve the current buffer's 'buftype' and 'filetype'
          local buftype = vim.bo.buftype
          local filetype = vim.bo.filetype

          -- Define lists of 'buftype' and 'filetype' where completion should be disabled
          local disabled_buftypes = { 'nofile', 'prompt', 'quickfix' }
          local disabled_filetypes = { 'TelescopePrompt', 'NvimTree', 'dashboard' }

          -- Check if the current buffer's 'buftype' or 'filetype' is in the disabled list
          if vim.tbl_contains(disabled_buftypes, buftype) or vim.tbl_contains(disabled_filetypes, filetype) then
              return false  -- Disable completion for these buffers
          end

          return true  -- Enable completion for all other buffers
      end
  },
  opts_extend = { "sources.default" }
}

