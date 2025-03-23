-- SUGESTãO levar o retrieve de informação para próxima etapa, assim que o usuario escolher um arquivo, ele vai poder navegar pelo arquivo e copiar, colar e modificar qualquer informação presente nele, assim você pode acessar qualquer informação de forma rápida colar informação de outros buffers ou simplesmente modificar informações de outros buffers rápidamente, se você precisar

local M = {}

M.pickers = require("metadata.pickers")
M.change = require("metadata.metachange")
M.push = require("metadata.push")
M.index = require("metadata.index")
M.data = require("metadata.datacollect")

return M
