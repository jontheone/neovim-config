-- colors/greenphosphor.lua
vim.cmd("highlight clear")
vim.o.background = "dark"
vim.cmd("syntax reset")
vim.g.colors_name = "greenphosphor"

local hl = vim.api.nvim_set_hl

-- Base colors
local green = "#00FF00"
local dim_green = "#00AA00"
local bg = "#000000"
local visual_bg = "#003300"
local comment_green = "#007700"

-- UI
hl(0, "Normal",       { fg = green, bg = bg })
hl(0, "Visual",       { bg = visual_bg })
hl(0, "CursorLine",   { bg = "#001100" })
hl(0, "Cursor",       { fg = bg, bg = green })
hl(0, "StatusLine",   { fg = green, bg = visual_bg })
hl(0, "StatusLineNC", { fg = dim_green, bg = visual_bg })
hl(0, "LineNr",       { fg = comment_green, bg = bg })
hl(0, "CursorLineNr", { fg = green, bg = bg })

-- Syntax
hl(0, "Comment",      { fg = comment_green, italic = true })
hl(0, "Constant",     { fg = green })
hl(0, "String",       { fg = green })
hl(0, "Identifier",   { fg = green })
hl(0, "Function",     { fg = green })
hl(0, "Statement",    { fg = green, bold = true })
hl(0, "Keyword",      { fg = green })
hl(0, "Type",         { fg = green })
hl(0, "Special",      { fg = green })
hl(0, "Error",        { fg = "#FF0000", bg = bg })

-- Diff (optional)
hl(0, "DiffAdd",      { bg = "#002200" })
hl(0, "DiffChange",   { bg = "#222200" })
hl(0, "DiffDelete",   { bg = "#220000" })

-- LSP
hl(0, "DiagnosticError", { fg = "#FF0000" })
hl(0, "DiagnosticWarn",  { fg = "#FFFF00" })
hl(0, "DiagnosticInfo",  { fg = green })
hl(0, "DiagnosticHint",  { fg = comment_green })

-- Completion menu
hl(0, "Pmenu",        { fg = green, bg = "#001100" })
hl(0, "PmenuSel",     { fg = bg, bg = green })

-- Search
hl(0, "Search",       { fg = bg, bg = green })
hl(0, "IncSearch",    { fg = bg, bg = "#00AA00" })
