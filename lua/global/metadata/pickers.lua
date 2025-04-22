local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local dt = require("global.metadata.datacollect")
local picker_memory

local M = {}


M.search = function(opts)
    local args = {}
    for item in opts.args:gmatch("[^;]+") do
        if item == "" then
            break
        else
            table.insert(args, item)
        end
    end
    if not args[2] then
        return
    end
    local labels = {}
    for item in args[1]:gmatch("[^,]+") do
        table.insert(labels, item)
    end
    table.remove(args, 1)
    local data = {}
    for i = 1, #labels do
        local dataset = args[i]
        local label = labels[i]
        if not dataset then
            print("provide enough input for the amount of labels")
            return
        end
        local set = {}
        for item in dataset:gmatch("[^,]+") do
            table.insert(set, item)
        end
        data[label] = set
    end
    local files = dt.getFilesByLabelData(labels, data)
    M.createPicker(files)
end

M.createPicker = function(paths)
    local opts = {}
    local options = {}
    for i = 1, #paths do
        local arr = {}
        arr.path = paths[i]
        arr.name = paths[i]:gsub("/", "\\")
        table.insert(options, arr)
    end
    pickers.new(opts, {
        prompt_title = "Metadata search",
        finder = finders.new_table {
            results = options,
            entry_maker = function(entry)
                local path = string.gsub(entry.path, vim.g.wiki_root, "")
                return {
                    display = path,
                    ordinal = entry.name,
                    path = entry.path
                }
            end
        },
        sorter = conf.generic_sorter(opts),
        previewer = conf.file_previewer({}),
        layout_strategy = "bottom_pane",
        attach_mappings = function(buf, map)
            map("n", "<C-g>", function() M.createGrepPicker(paths) end)
            return true
        end
    }):find()
    picker_memory = { picker = M.createPicker, paths = paths }
end

M.createGrepPicker = function(paths)
    paths = paths or vim.g.wiki_root
    builtin.live_grep({
        prompt_title = "Custom live grep",
        search_dirs = paths,
        layout_strategy = "bottom_pane"
    })
    picker_memory = { picker = M.createGrepPicker, paths = paths }
end

M.accessMemory = function()
    if picker_memory then
        picker_memory["picker"](picker_memory["paths"])
    else
        print("No picker used yet")
    end
end

return M
