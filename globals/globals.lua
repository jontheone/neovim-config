vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.ruler = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.cmd('syntax on')
vim.opt.laststatus = 2
vim.opt.showmatch = true
vim.opt.timeoutlen = 500
vim.opt.hidden = true
vim.opt.scrolloff = 8
vim.opt.cmdheight = 2
vim.opt.encoding = 'utf-8'
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.shadafile = "NONE"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.api.nvim_set_hl(0, 'bgwin', {bg = "none"})
vim.cmd("set winhighlight=Normal:bgwin")
vim.g.initial_dir = vim.fn.getcwd()
vim.g.wiki_root = "/mnt/d/wikis/wiki/"
