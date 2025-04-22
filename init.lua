require("global.globals")
require("global.remaps")
require("global.autocmds")
require("global.termhighlights")
require("config.lazy")

-------------------------
--- funções nvim e comandos
-------------------------

local follow = require("global.followMdLinks")
local fs = require("global.managefile")
local mt = require("global.metadata")

-- Configurando as funções como comandos do vim
vim.api.nvim_create_user_command('FollowMdLinks', follow.followMdLinks, {})
vim.api.nvim_create_user_command('Teste', function() end, {})
vim.api.nvim_create_user_command('Touch', function(opts) vim.cmd([[e expand('%:p:h')."/]] .. opts.args .. '"') end,
    { nargs = 1 })
vim.api.nvim_create_user_command('Push', mt.push.Push,
    { desc = "Push files in the topic dir to the link dir", nargs = 1 })
vim.api.nvim_create_user_command('Index', mt.index.linksIndex, { desc = "Wiki Index", nargs = "*" })
vim.api.nvim_create_user_command('Mt', mt.pickers.search, { desc = "Metadata search", nargs = 1 })
vim.api.nvim_create_user_command('Mtc', mt.change.change, { desc = "Change metadata in the current buffer", nargs = 1 })
vim.api.nvim_create_user_command("Qf",
    function() vim.cmd([[caddexpr expand("%") . ":" . line(".") . ":" . col(".") . ":" . getline(".")]]) end,
    { desc = "add line to qf list" })
vim.api.nvim_create_user_command("File",
    function(opts) vim.cmd([[e ]] .. vim.fs.joinpath(vim.g.wiki_root, ".assuntos", opts.args)) end,
    { desc = "new Md file", nargs = 1 })
vim.api.nvim_create_user_command("Qfile",
    function(opts) vim.cmd([[vsplit | e ]] .. vim.fs.joinpath(vim.g.wiki_root, ".assuntos", opts.args)) end,
    { desc = "new Md file with split", nargs = 1 })
vim.api.nvim_create_user_command("Exlink", mt.data.linkExists, { desc = "new Md file with split", nargs = 1 })
vim.api.nvim_create_user_command("Extag", mt.data.tagExists, { desc = "new Md file with split", nargs = 1 })

-- remaps
vim.keymap.set('n', '<CR>', follow.followMdLinks, { noremap = true })
vim.keymap.set('n', '<Leader>fn', function() fs.newfile() end, { desc = 'novo arquivo' })
vim.keymap.set('n', '<Leader>fd', fs.DeleteFile, { desc = 'deleta o arquivo atual' })
vim.keymap.set('n', '<Leader>fr', fs.ChangeNode, { desc = 'Muda o nome do arquivo atual' })
vim.keymap.set('n', '<Leader>e', function() mt.index.linksIndex() end, { desc = 'Wiki Index' })
vim.keymap.set('n', '<Leader>pl', function() mt.pickers.accessMemory() end, { desc = 'Wiki Index' })
vim.keymap.set("n", "<Leader>q", ":Qf<CR>", { desc = "add line to qf list" })
