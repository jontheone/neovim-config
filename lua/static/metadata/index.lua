---@class window
---@field name string
---@field active boolean
---@field buf number
---@field id number
---@field opts table
---@field created boolean
local window = {}
local state = {
    menus = {
        ---@type window
        ["links"] = {
            name = "Links",
            active = false,
            buf = -1,
            win = -1,
            id = 1,
            opts = {},
            created = false
        },
        ---@type window
        ["topic"] = {
            name = "Topic",
            active = false,
            buf = -1,
            win = -1,
            id = 2,
            opts = {},
            created = false
        },
        ---@type window
        ["files"] = {
            name = "Files",
            active = false,
            buf = -1,
            win = -1,
            id = 3,
            opts = {},
            created = false
        },
        ---@type window
        ["preview"] = {
            name = "Preview",
            active = false,
            buf = -1,
            win = -1,
            id = 4,
            opts = {},
            created = false
        }
    },
    buffers = {},
    bufCreate = {
        ["links"] = function(line)
            local buf = vim.api.nvim_create_buf(false, false)

            return buf
        end,
        ["topic"] = function(line)
            local buf = vim.api.nvim_create_buf(false, false)
            return buf
        end,
        ["files"] = function(line)
            local buf = vim.api.nvim_create_buf(false, false)
            return buf
        end,
        ["preview"] =  function(line)
            local buf = vim.api.nvim_create_buf(false, false)
            return buf
        end
    }
}
vim.g.state_started = false
local M = {}

M.unsetFocusAll = function()
    for _, pair in pairs(state.menus) do
        pair.active = false
    end
end

M.createBuf = function(menu, line)
    local name = state.menus[menu].name
    local buf = state.bufCreate[menu](line or "")
    vim.api.nvim_buf_set_name(buf, name)
    vim.bo[buf].modifiable = false
    print("creating new buffer: "..buf.." for menu: "..name)

    vim.keymap.set("n", "l", function() M.moveRight(menu) end, { buffer = buf, silent = true })
    vim.keymap.set("n", "h", function() M.moveLeft(menu) end, { buffer = buf, silent = true })
    vim.keymap.set("n", "q", function() M.endSession() end, { buffer = buf, silent = true })
    vim.keymap.set("n", "qu", function() M.terminateSession() end, { buffer = buf, silent = true })
    vim.keymap.set("n", "a", function() print("current state of the menus: \n"..vim.inspect(state.menus)) end, { buffer = buf, silent = true })
    return buf
end

M.endSession = function()
    for _, pair in pairs(state.menus) do
        if vim.api.nvim_win_is_valid(pair.win) then
            vim.api.nvim_win_close(pair.win, true)
            pair.win = -1
        end
    end
    vim.api.nvim_del_augroup_by_name("index")
end

M.newSession = function()
    print("creating a new session")
    local buf = M.createBuf("links")
    state.menus.links.buf = buf
    local opts = {
        title = "links",
        relative = "editor",
        width = math.floor(vim.o.columns * 0.17),
        height = vim.o.lines-3,
        row = 1,
        col = 1,
        style = "minimal",
        border = {"╔", "═" ,"╗", "║", "╝", "═", "╚", "║"}
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    table.insert(state.buffers, buf)
    state.menus.links.buf = buf
    state.menus.links.opts = opts
    state.menus.links.win = win
    state.menus.links.active = true
    state.menus.links.created = true
end

M.getPrevMenuName = function(id)
    for key, menu in pairs(state.menus) do
        if menu.id == (id - 1) then
            return key
        end
    end
end

M.getNextMenuName = function(id)
    for key, menu in pairs(state.menus) do
        if menu.id == (id + 1) then
            return key
        end
    end
end

M.getMenuPos = function(menu)
    local prevMenu = M.getPrevMenuName(state.menus[menu].id)
    print(vim.inspect(prevMenu))
    if not prevMenu then
        return 1
    end
    local col = state.menus[prevMenu].opts.col
    local width = state.menus[prevMenu].opts.width
    return (col + width) + 2
end

M.aureaProportion = function()
    local expandSize = {
        ['links'] = math.floor(vim.o.columns * 0.17),
        ['topic'] = math.floor(vim.o.columns * 0.17),
        ['files'] = math.floor(vim.o.columns * 0.25),
        ['preview'] = math.floor(vim.o.columns * 0.50) - 2
    }
    local minimalSize = math.floor(vim.o.columns * 0.05)
    local focusedMenu
    for key, menu in pairs(state.menus) do
        if menu.active then
            focusedMenu = key
            break
        end
    end
    assert(focusedMenu, "how da fuck are you not focusing in any menu at the moment")
    for key, menu in pairs(state.menus) do
        if key == focusedMenu and vim.api.nvim_win_is_valid(menu.win) then
            vim.api.nvim_win_set_config(menu.win, {
                width = expandSize[key]
            })
            menu.opts.width = expandSize[key]
        elseif vim.api.nvim_win_is_valid(menu.win) then
            vim.api.nvim_win_set_config(menu.win, {
                width = minimalSize })
            menu.opts.width = minimalSize
        end
    end
    for i=1, 4 do
        local currmenu
        local win
        for key, menu in pairs(state.menus) do
            if menu.id == i then
                currmenu = key
                win = menu.win
            end
        end
        local prevMenu = M.getPrevMenuName(i)
        local valid = vim.api.nvim_win_is_valid
        if (prevMenu and (valid(state.menus[prevMenu].win) and valid(win))) then
            local colPos = (state.menus[prevMenu].opts.col + state.menus[prevMenu].opts.width) + 3
            vim.api.nvim_win_set_config(win, {
                col = colPos,
                row = 1,
                relative = "editor"
            })
            state.menus[currmenu].opts.col = colPos
        end
    end
end

M.moveLeft = function(menu)
    local prevMenu = M.getPrevMenuName(state.menus[menu].id)
    if prevMenu then
        assert(vim.api.nvim_win_is_valid(state.menus[prevMenu].win), "Something went deeply wrong in the window creation, because its trying to move left to the previous window, but the previous window doesnt exist.")
        vim.api.nvim_set_current_win(state.menus[prevMenu].win)
        M.unsetFocusAll()
        state.menus[prevMenu].active = true
        M.aureaProportion()
        return
    end
    print("Cannot move left from links window")
end

M.moveRight = function(menu)
    local nextMenu = M.getNextMenuName(state.menus[menu].id)
    if nextMenu then
        if vim.api.nvim_win_is_valid(state.menus[nextMenu].win) then
            vim.api.nvim_set_current_win(state.menus[nextMenu].win)
            M.unsetFocusAll()
            state.menus[nextMenu].active = true
            M.aureaProportion()
            return
        else
            M.createWindow(nextMenu, true)
            M.aureaProportion()
            return
        end
    end
    print("youre already in the preview window")
end

M.createWindow = function(menu, focus)
    local buf
    if not (vim.api.nvim_buf_is_valid(state.menus[menu].buf)) then
        buf = M.createBuf(menu, vim.fn.getline(vim.fn.line(".")))
        state.menus[menu].buf = buf
    else
        buf = state.menus[menu].buf
    end
    local opts
    if not state.menus[menu].opts.row then
        opts = {
            title = state.menus[menu].name,
            relative = "editor",
            width = 40,
            height = vim.o.lines-3,
            row = 1,
            col = M.getMenuPos(menu),
            style = "minimal",
            border = {"╔", "═" ,"╗", "║", "╝", "═", "╚", "║"}
        }
        state.menus[menu].opts = opts
    else
        opts = state.menus[menu].opts
    end
    if not (vim.api.nvim_win_is_valid(state.menus[menu].win)) then
        focus = focus or menu.active
        if focus then
            M.unsetFocusAll()
            state.menus[menu].active = focus
        end
        local win = vim.api.nvim_open_win(buf, focus, opts)
        state.menus[menu].win = win
        state.menus[menu].created = true
        print("Window created for " .. menu)
    else
        print("Window already exists for " .. menu) end
end

M.reatachSession = function()
    print("reataching from previous session")
    for key, menu in pairs(state.menus) do
        if menu.created then
            print("Attaching menu: "..menu.name)
            M.createWindow(key, menu.active or nil)
        end
    end
end

M.index = function()
    if vim.g.state_started then
        -- reatach to  previous session
        M.reatachSession()
    else
        -- create new session
        vim.g.state_started = true
        M.newSession()
    end
    vim.api.nvim_create_augroup("index", { clear = true })
end

M.terminateSession = function()
    for _, menu in pairs(state.menus) do
        vim.api.nvim_win_close(menu.win, true)
        vim.api.nvim_buf_delete(menu.buf, { force = true })
        menu.active = false
        menu.created = false
        menu.buf = -1
        menu.win = -1
        menu.opts = {}
    end
    state.buffers = {}
    vim.g.state_started = false
    vim.api.nvim_del_augroup_by_name("index")
end

return M
