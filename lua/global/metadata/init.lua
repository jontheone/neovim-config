-- SUGESTãO levar o retrieve de informação para próxima etapa, assim que o usuario escolher um arquivo, ele vai poder navegar pelo arquivo e copiar, colar e modificar qualquer informação presente nele, assim você pode acessar qualquer informação de forma rápida colar informação de outros buffers ou simplesmente modificar informações de outros buffers rápidamente, se você precisar

local M = {}

M.pickers = require("global.metadata.pickers")
M.change = require("global.metadata.metachange")
M.push = require("global.metadata.push")
M.index = require("global.metadata.index")
M.data = require("global.metadata.datacollect")

return M
