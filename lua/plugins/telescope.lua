return {
    "nvim-telescope/telescope.nvim",
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function()
        local builtin = require("telescope.builtin")
        -- local res, custom = pcall(require,"globals.custompickers.lua")
        local custom = require("globals.custompickers")
        require("telescope").setup({
            defaults = {
                sorting_strategy = "ascending",
                layout_strategy = "bottom_pane",
                layour_config = {

                },
                -- borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
            },
            mappings = {
                i = {
                    ["<C-j>"] = "move_selection_next",
                    ["<C-k>"] = "move_selection_previous"
                }
            },
        })
        vim.keymap.set("n", "<Leader>ff", function() builtin.find_files() end, { desc = "find files in curr dir" } )
        vim.keymap.set("n", "<Leader>fc", function() builtin.find_files({ cwd=[[~/AppData/Local/nvim/]]}) end, { desc = "find files in curr dir" } )
        vim.keymap.set("n", "<Leader>fb", function() builtin.buffers() end, {desc="search for list of buffers"})
        vim.keymap.set("n", "<Leader>fg", function() builtin.live_grep() end, {desc="search for list of buffers"})
        vim.keymap.set("n", "<Leader>fd", function() builtin.grep_string({search = vim.fn.input("grep > "), use_regex = true}) end, {desc="search for list of buffers"})
        vim.keymap.set("n", "<Leader>fs", function() builtin.lsp_documentn_symbols() end, {desc="Search document symbols"})
        vim.keymap.set("n", "<Leader>fsv", function() builtin.lsp_documentn_symbols({
            symbols = {"variable"}
        }) end, {desc="Search document symbols"})
        vim.keymap.set("n", "<Leader>fsf", function() builtin.lsp_documentn_symbols({
            symbols = { 'Class', 'Function', 'Method'}
        }) end, {desc="Search document symbols"})
        vim.keymap.set("n", "<Leader>fp", function() builtin.registers() end, {desc="search for list of buffers"})
        vim.keymap.set("n", "<Leader>fh", function() builtin.command_history() end, {desc="search for list of buffers"})
        vim.keymap.set("n", "<Leader>fl", function() builtin.current_buffer_fuzzy_find() end, {desc="fuzzy find lines"})

    end
}
