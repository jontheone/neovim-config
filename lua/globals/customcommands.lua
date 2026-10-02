
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


vim.api.nvim_create_user_command("Tabls", function()
  local tabs = get_tabs_info()
  print("\nActive Tabs:")
  print("--------------------------------------------------")
  for _, tab in ipairs(tabs) do
    local active_marker = tab.is_current and " % " or "   "
    print(string.format("%sTab #%d (ID: %d) -> %s", active_marker, tab.tab_num, tab.tab_id, tab.path))
  end
  print("--------------------------------------------------")
end, { desc = "List open tabs with ID and filename" })
