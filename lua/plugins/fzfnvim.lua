return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local fzf = require("fzf-lua")
        fzf.setup({
            files = {
                hidden = true
            },
            grep = {
                hidden = true
            }
        })
        vim.keymap.set("n", "<Leader>ff", function() fzf.files() end, { desc = "find files in curr dir" } )
        vim.keymap.set("n", "<Leader>fw", function() fzf.files({ cwd=[[D:\documents\wikis\wiki]]}) end, { desc = "find files in curr dir" } )
        vim.keymap.set("n", "<Leader>fc", function() fzf.files({ cwd=[[~/AppData/Local/nvim/]]}) end, { desc = "find files in curr dir" } )
        vim.keymap.set("n", "<Leader>fb", function() fzf.buffers() end, {desc="search for list of buffers"})
        vim.keymap.set("n", "<Leader>fg", function() fzf.live_grep() end, {desc="search for list of buffers"})
        vim.keymap.set("n", "<Leader>p", function() fzf.registers() end, {desc="search for list of buffers"})
        vim.keymap.set("n", "<Leader>c", function() fzf.command_history() end, {desc="search for list of buffers"})
    end
}
