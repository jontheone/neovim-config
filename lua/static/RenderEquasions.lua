local img = require"image"
local ts = require"nvim-treesitter.ts_utils"
-- local buf = vim.api.nvim_create_buf(false, true)
-- local opts = {
--     style = "minimal",
--     relative = "cursor",
--     width = 30,
--     height = 1,
--     row = 1;
--     col = 1;
--     border = "rounded"
-- }
-- local win = vim.api.nvim_open_win(buf, false, opts)
--
-- local image = img.from_file("/home/jonputer/.config/nvim/main1.png", {
--     id = "emc",
--     window = win,
--     buffer = buf,
--     x = 0,
--     y = 0,
--     width = 10,
--     height = 10
-- })
--
-- image:render()
--
--

local state = {
    floating = {
        win = -1,
        buf = -1
    }
}

---@ param height integer
---@ param width integer
---@ return table
local function Create_win(height, width)
    local buf
    local opts = {
        style = "minimal",
        width = width,
        height = height,
        relative = "cursor",
        row = 0,
        col = 0,
        border = "rounded"
    }
    local win = vim.api.nvim_open_win(buf, false, opts)

    return {win, buf}
end


local function Render(node)
    if vim.api.nvim_win_is_valid(state.floating.win) then
    else
        local width
        local height

        local image = img.from_file("")
        state.floating = Create_win(height, width)
        image:render(state.floating.buf, {y = 0, x = 0})
    end

end


---@return table|nil
local function GetNode()
    -- if vim.api.nvim_win_is_valid(state.floating.win) then
    -- end
    local node = ts.get_node_at_cursor()
    local ntype = node:type()
    if ntype == "latex_block" then
        return node
    elseif ntype == "latex_span_delimiter" then
        local parent = node:parent()
        if parent and parent:type() == "latex_block" then
            return parent
        end
    end
end

vim.keymap.set("n", "<leader>s", function() local node = GetNode(); if node then Render(node) else return end end, { desc = "render the equation under the curosr" })

--local augroup = vim.api.nvim_create_augroup("RenderEquations", {})

