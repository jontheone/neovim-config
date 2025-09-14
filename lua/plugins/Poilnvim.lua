return  {
    "stevearc/oil.nvim",
    config = function()
        local oil = require("oil")
        local function PutOnArg()
            local start_pos = vim.fn.getpos("v")[2]
            local end_pos = vim.api.nvim_win_get_cursor(0)[1]
            local dir = oil.get_current_dir(0)
            for i = start_pos, end_pos do
                local entry = oil.get_entry_on_line(0, i)
                if entry.type == "file" then
                    local name = entry.parsed_name
                    local path = string.match(vim.fs.joinpath(dir, name), string.format("%s(%s)", dir, name))
                    vim.cmd.argadd(path)
                end
            end
        end
        oil.setup({
            keymaps = {
                ["<C-f>"] = PutOnArg
            },
            columns = {
                "permissions",
                "size",
                "mtime",
                "icon",
            },
            skip_confirm_for_simple_edits = true,
        })
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        vim.api.nvim_create_user_command("Ex", function(opts)
            vim.cmd("split")
            vim.cmd(string.format("Oil %s", opts.args))
        end, { desc = "Open the directory in a split with oil", nargs = "?"})
    end
}

