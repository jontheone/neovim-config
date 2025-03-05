local dt = require("metadata.data")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local ARGS
local WINDOW_SIZE
local PATH = vim.g.wiki_root
local WIN_OPTS = {
    cursorline = true,
    scrolloff = math.floor(vim.o.lines / 2),
    number = false,
    signcolunm = "yes",
    height = nil,
    width = nil
}
local STATE = {
    open = {
        win = -1,
        buf = -1
    }
}

local create_input_buf = function(links)
    local insertbuf = {}
    local letter
    for _, link in ipairs(links) do
        if link == "NO_LINK" then
            local blank = string.rep(" ", ((WINDOW_SIZE-11)/2))
            table.insert(insertbuf, string.format("%s[%s]%s", blank, "NO_LINK", blank))
            --table.insert(insertbuf, " ")
        elseif letter ~= string.sub(link, 1, 1) then
            letter = string.sub(link, 1, 1)
            local blank = string.rep(" ", ((WINDOW_SIZE-5)/2))
            --table.insert(insertbuf, " ")
            table.insert(insertbuf, string.format("%s[%s]%s", blank, letter, blank))
            --table.insert(insertbuf, " ")
        end
        table.insert(insertbuf, link)
    end
    return insertbuf
end

local get_links = function(json)
    local links = {}
    for path, value in pairs(json) do
        local link = value["links"]
        if type(link) == "table" then
            if link[1] then
                for i=1, #link do
                    if not string.match(link[i], "%.+%g*") then
                        table.insert(links, link[i])
                    end
                end
            end
        else
            if not string.match(link, "%.+%g*") then
                table.insert(links, link)
            end
        end
    end
    links = dt.remove_duplicate(links)
    table.sort(links)
    if links[1] == "" then
        links[1] = "NO_LINK"
    end
    return links
end

local add_highlightBuf1 = function(buf)
    vim.api.nvim_set_hl(0, 'BracketContentHl', { fg = '#db873d'})
    vim.api.nvim_set_hl(0, 'WordChoiceHl', { fg = '#5ca5ed' })
    local patterns = {
        BracketContentHl="\\[.*\\]",
        WordChoiceHl=[[\w\+\%([^\[]*\]\)\@!]],
    }
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for key, pattern in pairs(patterns) do
        local re = vim.regex(pattern)
        for index, line in ipairs(lines) do
            local start = 0
            while true do
                local from, to = re:match_str(line:sub(start + 1))
                if not from then break end
                vim.api.nvim_buf_add_highlight(buf, -1, key, index - 1, start + from, start + to)
                start = start + to + 1
            end
        end
    end
end

local add_highlightBuf2 = function(buf)
    vim.api.nvim_set_hl(0, 'TitleFileHl', { fg = '#e8612c' })
    vim.api.nvim_set_hl(0, 'FileOptionHl', { fg = '#3ae06f' })
    vim.api.nvim_set_hl(0, 'TagHeader', { fg = '#e0bf3a' })
    vim.api.nvim_set_hl(0, 'MdHeader', { fg = '#3bd1c5' })
    local patterns = {
        TitleFileHl="^\\~[^ ]*",
        FileOptionHl="\\s\\+ \\_.\\+",
        TagHeader="\\[.*\\]",
        MdHeader=[[^\([^]*\)[a-zA-Z0-9]\+\.]]
    }
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for key, pattern in pairs(patterns) do
        local re = vim.regex(pattern)
        for index, line in ipairs(lines) do
            local start = 0
            while true do
                local from, to = re:match_str(line:sub(start + 1))
                if not from then break end
                vim.api.nvim_buf_add_highlight(buf, -1, key, index - 1, start + from, start + to)
                start = start + to + 1
            end
        end
    end
end

local promptWin = function()
    local winstart = vim.o.columns - (WINDOW_SIZE-1)
    local winend = winstart + WINDOW_SIZE
    local buf = vim.api.nvim_create_buf(false, true)
    local height = 1
    local width = 15
    local row = 1
    local col = winstart + math.floor((WINDOW_SIZE - 1 - width)/2)
    local opts = {
        relative = "editor",
        title = "search letter",
        title_pos = "center",
        border = "rounded",
        col = col,
        row = row,
        width = width,
        height = height
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.cmd("startinsert")
    return win, buf
end

local handleEsc = function(win, buf)
    vim.api.nvim_win_close(win, true)
end

local handleCR = function(win, buf)
    vim.api.nvim_win_set_cursor(STATE.open.win, {2, 0})
    vim.api.nvim_set_current_win(STATE.open.win)
    handleEsc(win, buf)
    vim.api.nvim_input("<Esc>")
end

local getBiggestWin = function()
    local largest_win = nil
    local max_area = 0

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local width = vim.api.nvim_win_get_width(win)
        local height = vim.api.nvim_win_get_height(win)
        local area = width * height

        if area > max_area then
            max_area = area
            largest_win = win
        end
    end

    return largest_win
end

local to_roman = function(num)
    if num <= 0 or num > 3999 then
        return "Number out of range (1-3999)"
    end

    local roman_numerals = {
        {1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"},
        {100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
        {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"},
        {1, "I"}
    }

    local result = ""

    for _, pair in ipairs(roman_numerals) do
        local value, symbol = pair[1], pair[2]
        while num >= value do
            result = result .. symbol
            num = num - value
        end
    end

    return result.."."
end

local to_alphabet_index = function(num)
    if num <= 0 or num > 5000 then
        return "Number out of range (1-5000)"
    end

    local result = ""
    local base = 26
    local ascii_offset = 96 -- 'a' in ASCII is 97

    while num > 0 do
        local remainder = (num - 1) % base
        result = string.char(ascii_offset + 1 + remainder) .. result
        num = math.floor((num - 1) / base)
    end

    return result.."."
end

local collapseMdHeaders = function(json, filename, insertbuf, indent)
    local path
    for key, _ in pairs(json) do
        if key:match("([^/\\]+%.md)$") == filename then
            path = key
            break
        end
    end
    local file = vim.fn.readfile(path)
    local titleIndent = indent
    local num = 0
    local roman = 0
    local alphabet = 0
    local pos
    for i, line in ipairs(insertbuf) do
        if line:match("%s+%s(.+)") == filename then
            pos = i +1
            break
        end
    end
    for i, line in ipairs(file) do
        if line:match("#%s.*") and not (line:match("[#+]%s+(.*)") == "") then
            local title = line:match("(#+)%s+.*")
            line = line:match("[#+]%s+(.*)")
            if string.sub(title, 1, 3) == "###" then
                roman = 0 
                alphabet = alphabet + 1
                table.insert(insertbuf, pos, string.format("%s%s", titleIndent .. string.rep(" ", 4), to_alphabet_index(alphabet)..string.format(" %s (%s)", line, tostring(i))))
                pos = pos + 1
            elseif string.sub(title, 1, 2) == "##" then
                alphabet= 0
                roman = roman + 1
                table.insert(insertbuf, pos, string.format("%s%s", titleIndent .. string.rep(" ", 2), to_roman(roman)..string.format(" %s (%s)", line, tostring(i))))
                pos = pos + 1
            elseif string.sub(title, 1, 1) == "#" then
                roman, alphabet= 0, 0
                num = num + 1
                table.insert(insertbuf, pos, string.format("%s%s", titleIndent, tostring(num)..string.format(". %s (%s)", line, tostring(i))))
                pos = pos + 1
            end
        end
    end
    return insertbuf
end

local unpackPackage = function(pack, insertbuf, args)
    for tag, tagpaths in pairs(pack) do
        local tag_indent = string.rep(" ", 2)
        local file_indent = string.rep(" ", 5)
        if tagpaths[1] then
            table.insert(insertbuf, string.format("%s[%s]", tag_indent, tag))
            for i=1, #tagpaths do
                local path = tagpaths[i]
                local name = string.match(path, "([^/\\]+%.md)$")
                table.insert(insertbuf, string.format("%s%s", file_indent, " "..name))
            end
        end
    end
    return insertbuf
end

local nofilterPackage = function(files, insertbuf, args)
    for key, item in pairs(files) do
        local indent = string.rep(" ", 2)
        local name = string.match(key, "([^/\\]+%.md)$")
        local line = string.format("%s%s", indent, " "..name)
        table.insert(insertbuf, line)
    end
    return insertbuf
end

local createPackage = function(files, tags)
    local pack = {}
    for _, tag in ipairs(tags) do
        local list = {}
        if tag == "[no tag]" then
            tag = ""
        end
        for key, value in pairs(files) do
            local metatag = value.tags
            if type(metatag) == "table" then
                for i=1, #metatag do
                    if metatag[i] == tag then
                        table.insert(list, key)
                    end
                end
            else
                if metatag == tag then
                    table.insert(list, key)
                end
            end
        end
        if tag == "" then
            pack["no tag"] = list
        else
            pack[tag] = list
        end
    end
    return pack
end

local separateByType = function(json, filter)
    local paths = {}
    for key, value in pairs(json) do
        if not value.type or value.type == "" then
            if filter == "normal" then
                paths[key] = value
            end
        else
            if value.type == filter then
                paths[key] = value
            end
        end
    end
    return paths
end

local filterJsonByLink = function(json, link)
    local jsonLinks = {}
    for key, value in pairs(json) do
        local dado = value.links
        if type(dado) == "table" then
            for i=1, #dado do
                if dado[i] == link then
                    jsonLinks[key] = value
                    goto skip
                end
            end
            ::skip::
        else
            if dado == link then
                jsonLinks[key] = value
            end
        end
    end
    return jsonLinks
end


local handleCursorMovedEvent = function()
    local bufnr = vim.api.nvim_get_current_buf() -- Get current buffer
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1] -- Get cursor line
    vim.fn.sign_unplace("CursorSignGroup", { buffer = bufnr })
    vim.fn.sign_place(0, "CursorSignGroup", "CursorSign", bufnr, { lnum = cursor_line, priority = 100 })
end

local handleTextChangedEvent = function(win, buf)
    local char = vim.api.nvim_get_current_line()
    local lines = vim.api.nvim_buf_get_lines(STATE.open.buf, 0, -1, false)
    for i, line in ipairs(lines) do
        if line:match("%s*%["..char.."%]%s*") then
            vim.api.nvim_win_set_cursor(STATE.open.win, {(i+1), 0})
            vim.api.nvim_set_current_win(STATE.open.win)
            handleEsc(win, buf)
            vim.api.nvim_input("<Esc>")
            return
        end
    end
    print("No matches")
    vim.api.nvim_win_set_cursor(STATE.open.win, {1, 0})
    vim.api.nvim_set_current_win(STATE.open.win)
    handleEsc(win, buf)
    vim.api.nvim_input("<Esc>")
end

local getTypeChoice = function(input)
    if input:match("") then
        return "FileOption"
    elseif input:match("%[") then
        return "TagHeader"
    elseif input:match("~/") then
        return "LinkHeader"
    elseif input:match("[^%[]+%w%.") then
        return "MdHeader"
    end
    return input
end

local handleFileOptionInput = function(json, input)
    for key, _ in pairs(json) do
        if key:match(input:match("%s+%s(.+)")) then
            local filebuffer = vim.fn.bufadd(key) 
            vim.fn.bufload(filebuffer)
            vim.bo[filebuffer].buflisted = true
            local fwin = getBiggestWin()
            vim.api.nvim_win_set_buf(fwin, filebuffer)
        end
    end
end

local handleMdHeaderInput= function(json, input, buf)
    local pos = vim.api.nvim_win_get_cursor(0)[1]
    local filename
    local i = tonumber(input:match("%((%d+)%)"))
    while true do
        pos = pos-1
        local line = buf[pos]
        if line:match("") then
            filename = line:match("%s(.+)")
            break
        end
    end
    if filename then
        for key, _ in pairs(json) do
            if key:match(filename) then
                local filebuffer = vim.fn.bufadd(key) 
                vim.fn.bufload(filebuffer)
                vim.bo[filebuffer].buflisted = true
                local fwin = getBiggestWin()
                vim.api.nvim_win_set_buf(fwin, filebuffer)
                vim.api.nvim_win_set_cursor(fwin, {i, 0})
            end
        end
    end
end

local alphabeticalSearch = function()
    local win, buf = promptWin()
    vim.keymap.set({"n", "i"}, "<CR>", function() handleCR(win, buf) end, {buffer=buf}) 
    vim.keymap.set("n", "<esc>", function() handleEsc(win, buf) end, {buffer=buf})
    vim.api.nvim_create_autocmd("TextChangedI", {buffer = buf, callback = function() handleTextChangedEvent(win, buf) end})
end

local getTagOptions = function(json) 
    local tags = {}
    for path, value in pairs(json) do
        local tag = value["tags"]
        if type(tag) == "table" then
            if tag[1] then
                for i=1, #tag do
                    table.insert(tags, tag[i])
                end
            end
        else
            table.insert(tags, tag)
        end
    end
    tags = dt.remove_duplicate(tags)
    table.sort(tags)
    if tags[1] == "" then
        tags[1] = "[no tag]"
    end
    return tags
end

local adjustSize = function(int)
    local buf = STATE.open.buf
    local win = STATE.open.win
    if win > 0 and vim.api.nvim_win_is_valid(win) then
        local config = vim.api.nvim_win_get_config(win)
        config.height, WIN_OPTS.height = int, int
        vim.api.nvim_win_set_config(0, config)
    end
end

local resizeLeft = function()
    local resize = 10
    local win = STATE.open.win
    local config = vim.api.nvim_win_get_config(win)
    config.width = config.width + resize
    WIN_OPTS.width = config.width + resize
    vim.api.nvim_win_set_config(win, config)
end

local resizeRight = function()
    local resize = -10
    local win = STATE.open.win
    local config = vim.api.nvim_win_get_config(win)
    config.width = config.width + resize
    WIN_OPTS.width = config.width + resize
    vim.api.nvim_win_set_config(win, config)
end

local resizeDefault = function()
    local win = STATE.open.win
    if win > 0 and vim.api.nvim_win_is_valid(win) then
        local resize = 45
        local config = vim.api.nvim_win_get_config(win)
        config.width = resize
        WIN_OPTS.width = resize
        vim.api.nvim_win_set_config(win, config)
    end
end

local tables_are_equal = function(tbl1, tbl2)
    if type(tbl1) ~= "table" or type(tbl2) ~= "table" then
        return false -- Both must be tables
    end

    for k, v in pairs(tbl1) do
        if tbl2[k] ~= v then
            return false -- Mismatched key or value
        end
    end

    for k, v in pairs(tbl2) do
        if tbl1[k] ~= v then
            return false -- Check the reverse direction
        end
    end

    return true
end

local handlebufferEsc = function()
    vim.api.nvim_win_hide(STATE.open.win)
end

local handleExpandHeaderFile = function(json, filename, insertbuf, line)
        local file_indent = line:match("^(%s+)[^.-]")
        local cursorline = vim.api.nvim_win_get_cursor(STATE.open.win)[1]
        local check = string.match(insertbuf[cursorline+1], "^%s*(.-)%s*$")
        if check:match("[%[~/]") then
            insertbuf = collapseMdHeaders(json, filename, insertbuf, file_indent..string.rep(" ", 3))
            vim.bo[STATE.open.buf].modifiable = true
            vim.api.nvim_buf_set_lines(STATE.open.buf, 0, #insertbuf, false, insertbuf)
            vim.bo[STATE.open.buf].modifiable = false
            add_highlightBuf2(STATE.open.buf)
        end
end

local handleExpandHeaderTitle = function(json, insertbuf)
    local pos_start = vim.api.nvim_win_get_cursor(STATE.open.win)[1]
    local pos_end = -1
    for i=pos_start+1, #insertbuf do
        if insertbuf[i]:match("~/") then
            pos_end = i
            break
        end
    end
    local fileLines = vim.api.nvim_buf_get_lines(STATE.open.buf, pos_start, pos_end, false)
    for i, item in ipairs(fileLines) do
        local file_indent = item:match("^(%s+)[^.-]")
        local filename = item:match("%s+%s(.+)")
        if filename then
            local check = string.match(fileLines[i+1] or "", "^%s*(.-)%s*$")
            if check:match("[%[~/]") then
                insertbuf = collapseMdHeaders(json, filename, insertbuf, file_indent..string.rep(" ", 3))
            end
        end
    end
    vim.bo[STATE.open.buf].modifiable = true
    vim.api.nvim_buf_set_lines(STATE.open.buf, 0, #insertbuf, false, insertbuf)
    vim.bo[STATE.open.buf].modifiable = false
    add_highlightBuf2(STATE.open.buf)
end

local expandHeader = function(json)
    local line = vim.api.nvim_get_current_line()
    local insertbuf = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false)
    local filename = line:match("%s+%s(.+)")
    if line:match("") then
        handleExpandHeaderFile(json, filename, insertbuf, line)
    elseif line:match("~/") then
        handleExpandHeaderTitle(json, insertbuf)
    end 
end

local M = {}

M.tagsInput = function(params)
    local opts = {}
    local options = getTagOptions(params.json)  
    pickers.new(opts, {
        prompt_title = "Select the metatag to search",
        finder = finders.new_table{
            results = options
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local picker = action_state.get_current_picker(prompt_bufnr)
                local selected_entries = picker:get_multi_selection()
                local entry = action_state.get_selected_entry()
                local input = {}
                if selected_entries[1] then
                    for _, value in ipairs(selected_entries) do
                        table.insert(input, value[1])
                    end
                elseif entry[1] then
                    table.insert(input, entry[1])
                end
                actions.close(prompt_bufnr)
                params.tags = input
                local insertbuf = M.buildBuf2(params)
                vim.api.nvim_buf_set_lines(STATE.open.buf, 0, #insertbuf, false, insertbuf)
                vim.bo[STATE.open.buf].modifiable = false
                add_highlightBuf2(STATE.open.buf)
            end)
            return true
        end,
        layout_config = {
            width = 0.4,
            height = 0.6
        }
    }):find()
end

M.buildBuf2 = function(params)
    params = params or {}
    local args = params.args
    local json = params.json
    local tags = params.tags
    local link = params.link
    local packages = {}
    if not tags then -- função sem filtro de tags
        local insertbuf = {}
        table.insert(insertbuf, string.format("~/%s", link))
        insertbuf = nofilterPackage(separateByType(json, "normal"), insertbuf, args)
        table.insert(insertbuf, string.format("~/%s", link .. ":notes"))
        insertbuf = nofilterPackage(separateByType(json, "note"), insertbuf, args)
        return insertbuf
    else -- função com filtro de tags
        local insertbuf = {}
        packages.files = createPackage(separateByType(json, "normal"), tags)
        packages.notes = createPackage(separateByType(json, "note"), tags)
        table.insert(insertbuf, string.format("~/%s", link))
        insertbuf = unpackPackage(packages.files, insertbuf, args)
        table.insert(insertbuf, string.format("~/%s", link..":notes"))
        insertbuf = unpackPackage(packages.notes, insertbuf, args)
        return insertbuf
    end
end

M.fileIndex = function(params)
    params = params or {}
    local args = params.args
    local link = params.link
    local json = params.json
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(STATE.open.win, buf)
    STATE.open.buf = buf
    vim.wo.signcolumn = WIN_OPTS.signcolumn
    vim.fn.sign_define("CursorSign", { text = ">"})
    params.json = filterJsonByLink(json, link)
    if ARGS.filter then
        M.tagsInput(params)
    else
        local insertbuf = M.buildBuf2(params)
        vim.api.nvim_buf_set_lines(STATE.open.buf, 0, #insertbuf, false, insertbuf)
        vim.bo[STATE.open.buf].modifiable = false
        add_highlightBuf2(STATE.open.buf)
    end
    adjustSize(math.floor(vim.o.lines*0.76))

    vim.keymap.set("n", "<CR>", function() M.handleBuf2CR(params.json) end, {buffer=buf})
    vim.keymap.set("n", "h", function() M.handleBuf2BS(args) end, {buffer=buf})
    vim.keymap.set("n", "l", function() expandHeader(params.json) end, {buffer=buf})
    vim.keymap.set("n", "<C-j>", "zH", {buffer=buf})
    vim.keymap.set("n", "<C-k>", "zL", {buffer=buf})
    vim.keymap.set("n", "<C-h>", function() resizeLeft() end, {buffer=buf})
    vim.keymap.set("n", "<C-l>", function() resizeRight() end, {buffer=buf})
    vim.keymap.set("n", "q", handlebufferEsc, {buffer=buf})
    vim.api.nvim_create_autocmd("CursorMoved", {buffer = buf, callback = handleCursorMovedEvent})
end

M.buildBuf1 = function(args)
    adjustSize((vim.o.lines/2))
    resizeDefault()
    -- buffer config
    local buf = vim.api.nvim_create_buf(false, true)
    local json = dt.metadata("/mnt/d/wikis/wiki - Copia/")
    local links = get_links(json)
    local insertbuf = create_input_buf(links)
    vim.api.nvim_buf_set_lines(buf, 0, (#insertbuf-1), false, insertbuf)
    add_highlightBuf1(buf)
    vim.bo[buf].modifiable = false

    vim.keymap.set("n", "l", function()    
        local line = vim.api.nvim_get_current_line()
        if not line:match("%[") and not line:match("%s") then
            M.fileIndex({args=args, link=line, json=json})
        end
    end, {buffer=buf})

    vim.keymap.set("n", "a", alphabeticalSearch, {buffer=buf})
    vim.keymap.set("n", "q", handlebufferEsc, {buffer=buf})
    vim.api.nvim_create_autocmd("CursorMoved", {buffer = buf, callback = handleCursorMovedEvent})

    return buf
end


M.linksIndex = function(args)
    args = args or {}
    if ARGS and args then
        if tables_are_equal(ARGS, args) then
            args = ARGS
        else
            ARGS = args or {}
            STATE.open.buf = -1
        end
    else
        ARGS = args or {}
        STATE.open.buf = -1
    end
    -- create window or close it if its already open
    if not vim.api.nvim_win_is_valid(STATE.open.win) then
        WINDOW_SIZE = WINDOW_SIZE or 45
        local width = WIN_OPTS.width or WINDOW_SIZE
        local height = WIN_OPTS.height or math.floor((vim.o.lines/2))
        local col = vim.o.columns
        local row = 1
        local opts = {
            relative = "editor",
            title = "Index",
            title_pos = "center",
            border = "rounded",
            row = row,
            col = col,
            width = width,
            height = height,
        }
        if not vim.api.nvim_buf_is_valid(STATE.open.buf) then
            STATE.open.buf = M.buildBuf1(args)
        end
        STATE.open.win = vim.api.nvim_open_win(STATE.open.buf, true, opts)

        -- win config
        vim.wo[STATE.open.win].cursorline = WIN_OPTS.cursorline
        vim.wo[STATE.open.win].scrolloff = WIN_OPTS.scrolloff
        vim.wo[STATE.open.win].number = WIN_OPTS.number
        vim.wo[STATE.open.win].relativenumber = WIN_OPTS.number
        vim.wo[STATE.open.win].signcolumn = WIN_OPTS.signcolumn
        vim.wo[STATE.open.win].wrap = false
        vim.fn.sign_define("CursorSign", { text = ">"})

    else
        vim.api.nvim_win_hide(STATE.open.win)
        return
    end
end

M.handleBuf2CR = function(json)
    local input = vim.api.nvim_get_current_line()
    local option = getTypeChoice(input)
    local buf = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false)
    if option == "FileOption" then
        handleFileOptionInput(json, input)
    elseif option == "MdHeader" then
        handleMdHeaderInput(json, input, buf)
    end
end

M.handleBuf2BS = function(args)
    STATE.open.buf = M.buildBuf1(args)
    vim.api.nvim_win_set_buf(STATE.open.win, STATE.open.buf)
end

M.CliIndex = function(opts)
    local args = {}
    for option, config in opts.args:gmatch("(%S+)=(%S+)") do
        local num = tonumber(config)
        if num then
            args[option] = num ~= 0 -- Convert to true/false
        else
            args[option] = config -- Keep as string if not a number
        end
        --args[option] = config
    end
    M.linksIndex(args)
end

return M
