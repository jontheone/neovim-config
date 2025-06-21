local pastelinks = require("static.pastelinks")

-- commands
vim.api.nvim_create_user_command("Plinks", function(opts) pastelinks.clicommand(opts.args) end, {})
vim.api.nvim_create_user_command("Pastelinks", function() pastelinks.main() end, {})


-- keymaps
