vim.g.wiki_root = "~/documents/wikis/wiki"
local M = {}

M.DataCollection = require("static.metadata.datacollection")
M.FileSearcher = require("static.metadata.filesearcher")

return M
