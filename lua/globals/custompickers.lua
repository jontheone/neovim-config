# this is a telescope module, dont require it outside of the telescope configuration
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local make_entry = require("telescope.make_entry")
local vim = vim

local M = {}

M.function_picker = function(opts)
  opts = opts or {}

  -- Fetch document symbols using Neovim's native LSP client
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(err, result, ctx, config)
    if err or not result or vim.tbl_isempty(result) then
      vim.notify("No LSP symbols found for current buffer", vim.log.levels.WARN)
      return
    end

    -- Flatten nested symbols (e.g., functions/methods inside classes or modules)
    local items = {}
    local function flatten_symbols(symbols)
      for _, symbol in ipairs(symbols) do
        -- LSP SymbolKinds: 12 = Function, 6 = Method
        -- Adjust kinds if you also want Constructors (9) or Macros (15)
        if symbol.kind == vim.lsp.protocol.SymbolKind.Function or symbol.kind == vim.lsp.protocol.SymbolKind.Method then
          table.insert(items, symbol)
        end
        if symbol.children then
          flatten_symbols(symbol.children)
        end
      end
    end

    -- Handle both SymbolInformation[] and DocumentSymbol[] LSP responses
    if result[1] and result[1].location then
      for _, symbol in ipairs(result) do
        if symbol.kind == vim.lsp.protocol.SymbolKind.Function or symbol.kind == vim.lsp.protocol.SymbolKind.Method then
          table.insert(items, symbol)
        end
      end
    else
      flatten_symbols(result)
    end

    if vim.tbl_isempty(items) then
      vim.notify("No function definitions found", vim.log.levels.INFO)
      return
    end

    -- Convert LSP items to Telescope entries
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)

    pickers.new(opts, {
      prompt_title = "Function Definitions",
      finder = finders.new_table({
        results = items,
        entry_maker = function(entry)
          local range = entry.location and entry.location.range or entry.range
          local line = range["start"].line + 1
          local col = range["start"].character + 1

          return {
            value = entry,
            display = string.format("%s (Line %d)", entry.name, line),
            ordinal = entry.name,
            filename = filename,
            lnum = line,
            col = col,
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      previewer = conf.qflist_previewer(opts),
    }):find()
  end)
end

return M
