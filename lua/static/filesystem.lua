local pastelinks = require("static.pastelinks")
local mdrenderer = require('static.NoteRenderer')
local filesearcher = require("static.filesearcher")

print(vim.inspect(dbm))

-- commands
vim.api.nvim_create_user_command("Plinks", function(opts) pastelinks.clicommand(opts.args) end, {})
vim.api.nvim_create_user_command("Pastelinks", function() pastelinks.main() end, {})


-- keymaps

vim.keymap.set("n", "<leader>vm", function() mdrenderer.render() end)
