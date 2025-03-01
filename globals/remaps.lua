-- leader key remap 
vim.g.mapleader = "ç"
vim.g.maplocalleader = "ç"
-- commands remaps
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
--vim.keymap.set('n', '<S-e>', ':tabe<CR>', { noremap = true })
--vim.keymap.set('n', '<S-b>', ':enew<CR>', { noremap = true })
vim.keymap.set('n', '<S-k>', ':bn<CR>', { noremap = true })
vim.keymap.set('n', '<S-j>', ':bp<CR>', { noremap = true })
vim.keymap.set('n', '<S-d>', ':bd!<CR>', { noremap = true })
vim.keymap.set('n', '<S-h>', ':split<CR>', { noremap = true })
vim.keymap.set('n', '<S-l>', ':vsplit<CR>', { noremap = true })
vim.keymap.set('n', 'ww', ':w<CR>', { noremap = true })
vim.keymap.set('n', 'wwe', ':wa<CR>', { noremap = true })
vim.keymap.set('n', 'qu', ':qa!<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>l', 'g_', { noremap = true })
vim.keymap.set('n', '<Leader>h', '^', { noremap = true })
vim.keymap.set('v', '<Leader>l', 'g_', { noremap = true })
vim.keymap.set('v', '<Leader>h', '^', { noremap = true })
vim.keymap.set('n', '<Leader>i', '=%', { noremap = true })
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true, silent = true })
vim.keymap.set('t', '<esc><esc>', "<c-\\><c-n>", {})
-- TODO verificar se o plugin todo está funcionando
