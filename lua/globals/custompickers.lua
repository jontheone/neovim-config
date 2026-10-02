# this is a telescope module, dont require it outside of the telescope configuration
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local make_entry = require("telescope.make_entry")


local function get_tabs_info()
  local tabs = {}
  local current_tab = vim.api.nvim_get_current_tabpage()

  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    local tab_num = vim.api.nvim_tabpage_get_number(tabpage)
    local tab_id = tabpage -- Tabpage internal ID handle
    local win = vim.api.nvim_tabpage_get_win(tabpage)
    local bufnr = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(bufnr)

    local name = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":t") or "[No Name]"
    local rel_path = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":~:.") or "[No Name]"
    local is_current = (tabpage == current_tab)

    table.insert(tabs, {
      tabpage = tabpage,
      tab_num = tab_num,
      tab_id = tab_id,
      bufnr = bufnr,
      name = name,
      path = rel_path,
      is_current = is_current,
    })
  end

  return tabs
end

local boilerplates = {
    {
        name = "CmakeList.txt",
        ft = "Cmake",
        code = [[
# ------------------------------------------------------------------------------
# Poject settings
# ------------------------------------------------------------------------------
 
cmake_minimum_required(VERSION 3.16)
  
# Project metadata
project(
        app
        VERSION 1.0.0
        LANGUAGES C CXX
)
  
# Force C++17 standard strictly
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
  
# Automatically generate compile_commands.json
# set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
 
# Set Automoc for libraries like QT
# set(CMAKE_AUTOMOC ON)
# set(CMAKE_AUTOUIC ON)
  
  
# ------------------------------------------------------------------------------
# General Settings
# ------------------------------------------------------------------------------
 
# Force Out-of-Source builds to keep the source tree clean
if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
    message(FATAL_ERROR "In-source builds are disabled. Please build in a separate directory (e.g., 'mkdir build && cd build && cmake ..').")
endif()
  
# Set default build configuration to Release if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build (Debug, Release, RelWithDebInfo, MinSizeRel)." FORCE)
endif()
  
# Output directories for binaries and libraries
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
  
# Define source files manually or discover via globbing
file(GLOB_RECURSE SOURCES 
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/c/*.c"
)
 
  
# Executable target
add_executable(${PROJECT_NAME} ${SOURCES})
 
 
# Target-specific include directories (Modern CMake practice)
target_include_directories(${PROJECT_NAME} PRIVATE 
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

# Define path to runtime dependencies folder (relative to project root)
set(DEPENDENCIES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/dependencies")

# Copy all contents from dependencies/ into the target binary directory during CMake Configure stage
file(COPY "${DEPENDENCIES_DIR}/" DESTINATION "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")


# Define Executable output 
# set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "../${CMAKE_SOURCE_DIR}")
 
# ------------------------------------------------------------------------------
# Linking Libraries (-l flags)
# ------------------------------------------------------------------------------

# Define Linking Directory
# link_directories()

 
# Find packages requires for linking
# find_package(Qt6 REQUIRED COMPONENTS Widgets Core Gui)
# find_package(OpenCV REQUIRED)


target_link_libraries(${PROJECT_NAME} PRIVATE

)
 
 
 
# ------------------------------------------------------------------------------
# Compilation flags with mingw
# ------------------------------------------------------------------------------
 
# MinGW Compiler Flags & Warnings
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    target_compile_options(${PROJECT_NAME} PRIVATE
        -Wall
        $<$<CONFIG:Debug>:-g -O0>
        $<$<CONFIG:Release>:-O3>
    )
  
    # Static linking options for standalone Windows binaries (MinGW specific)
    if(MINGW)
        target_link_options(${PROJECT_NAME} PRIVATE
            -static
            -static-libgcc
            -static-libstdc++
        )
    endif()
endif()
 
 
]]
    },
}

local function string_to_lines(str)
  local lines = {}
  for line in str:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  return lines
end

local M = {}

M.function_picker = function(opts)
  opts = opts or {}

  -- Fetch document symbols using Neovim's native LSP client
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(err, result, ctx, config)
    if err or not result or vim.tbl_isempty(result) then
      vim.notify("No LSP symbols found for current buffer", vim.log.levels.WARN)
      return
    end

    -- Flatten nested symbols (e.g., functions/methods inside classes or modules)
    local items = {}
    local function flatten_symbols(symbols)
      for _, symbol in ipairs(symbols) do
        -- LSP SymbolKinds: 12 = Function, 6 = Method
        -- Adjust kinds if you also want Constructors (9) or Macros (15)
        if symbol.kind == vim.lsp.protocol.SymbolKind.Function or symbol.kind == vim.lsp.protocol.SymbolKind.Method then
          table.insert(items, symbol)
        end
        if symbol.children then
          flatten_symbols(symbol.children)
        end
      end
    end

    -- Handle both SymbolInformation[] and DocumentSymbol[] LSP responses
    if result[1] and result[1].location then
      for _, symbol in ipairs(result) do
        if symbol.kind == vim.lsp.protocol.SymbolKind.Function or symbol.kind == vim.lsp.protocol.SymbolKind.Method then
          table.insert(items, symbol)
        end
      end
    else
      flatten_symbols(result)
    end

    if vim.tbl_isempty(items) then
      vim.notify("No function definitions found", vim.log.levels.INFO)
      return
    end

    -- Convert LSP items to Telescope entries
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)

    pickers.new(opts, {
      prompt_title = "Function Definitions",
      finder = finders.new_table({
        results = items,
        entry_maker = function(entry)
          local range = entry.location and entry.location.range or entry.range
          local line = range["start"].line + 1
          local col = range["start"].character + 1

          return {
            value = entry,
            display = string.format("%s (Line %d)", entry.name, line),
            ordinal = entry.name,
            filename = filename,
            lnum = line,
            col = col,
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),
      previewer = conf.qflist_previewer(opts),
    }):find()
  end)
end

M.BoilerplatePicker = function()
    opts = opts or {}

  pickers.new(opts, {
    prompt_title = "Select Boilerplate",

    finder = finders.new_table({
      results = boilerplates,
      entry_maker = function(entry)
        -- Convert string to table of lines once for both preview and insertion
        local lines = string_to_lines(entry.code)
        return {
          value = entry,
          lines = lines,
          display = entry.name,
          ordinal = entry.name .. " " .. entry.ft,
        }
      end,
    }),

    sorter = conf.generic_sorter(opts),

    previewer = previewers.new_buffer_previewer({
      title = "Boilerplate Preview",
      define_preview = function(self, entry)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, entry.lines)
        if entry.value.ft then
          vim.bo[self.state.bufnr].filetype = entry.value.ft
        end
      end,
    }),

    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        if selection and selection.lines then
          local current_win = vim.api.nvim_get_current_win()
          local cursor_pos = vim.api.nvim_win_get_cursor(current_win)
          local row = cursor_pos[1] - 1 -- Convert 1-based index to 0-based

          -- Paste lines at current cursor position
          vim.api.nvim_buf_set_text(
            0,
            row,
            cursor_pos[2],
            row,
            cursor_pos[2],
            selection.lines
          )
        end
      end)
      return true
    end,
  }):find()
end

M.TabePicker = function()
    opts = opts or {}
  local tabs = get_tabs_info()

  pickers.new(opts, {
    prompt_title = "Select Tab",

    finder = finders.new_table({
      results = tabs,
      entry_maker = function(entry)
        local marker = entry.is_current and " (current)" or ""
        local display_str = string.format("Tab #%d [ID: %d]: %s%s", entry.tab_num, entry.tab_id, entry.name, marker)
        return {
          value = entry,
          display = display_str,
          ordinal = string.format("%d %d %s", entry.tab_num, entry.tab_id, entry.name),
        }
      end,
    }),

    sorter = conf.generic_sorter(opts),

    previewer = previewers.new_buffer_previewer({
      title = "Tab Preview",
      define_preview = function(self, entry)
        local target_buf = entry.value.bufnr
        if vim.api.nvim_buf_is_valid(target_buf) then
          local lines = vim.api.nvim_buf_get_lines(target_buf, 0, -1, false)
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

          local ft = vim.bo[target_buf].filetype
          if ft and ft ~= "" then
            vim.bo[self.state.bufnr].filetype = ft
          end
        end
      end,
    }),

    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        if selection and selection.value.tabpage then
          vim.api.nvim_set_current_tabpage(selection.value.tabpage)
        end
      end)
      return true
    end,
  }):find()
  end


return M
