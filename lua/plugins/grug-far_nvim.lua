return {
    'MagicDuck/grug-far.nvim',
    config = function()
        local grug = require("grug-far")
        require('grug-far').setup()
        vim.keymap.set("n", "<Leader>g", function() grug.open() end, {})
    end
}
