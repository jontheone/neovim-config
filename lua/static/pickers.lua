local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")

local M = {}

---@param entries table
M.NormalPicker = function(entries)
    pickers.new({}, {
        finder = finders.new_table(entries),
        sorter = conf.generic_sorter({}),
        layout_config = {
            width = 0.4
        }
    }):find()
end

---@param entries table
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
