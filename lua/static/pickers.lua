local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")

local M = {}

M.FilePicker = function(entries)
    pickers.new({}, {
        finder = finders.new_table({
            results = entries,
            entry_maker = function(entry)
                return {
                    ordinal = entry.ordinal,
                    display = entry.display,
                    path = entry.path
                }
            end
        }),
        sorter = conf.generic_sorter({}),
        previewer = conf.file_previewer({})
    }):find()
end

return M
