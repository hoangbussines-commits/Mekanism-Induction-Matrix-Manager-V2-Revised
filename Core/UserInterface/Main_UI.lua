--[[
  Main UI for Induction Matrix Manager
  Handles drawing menu, keyboard/mouse navigation, and selection
]]

local M = {}

-- Draw menu
function M.draw(selected, has_installed)
  term.clear()
  local w, h = term.getSize()
  local title = "INDUCTION MATRIX MANAGER V2 MANAGE"
  local line = "-----------------------------------"
  
  local title_x = math.floor((w - #title) / 2) + 1
  local line_x = math.floor((w - #line) / 2) + 1
  
  term.setCursorPos(title_x, 1)
  print(title)
  term.setCursorPos(line_x, 2)
  print(line)
  
  local y = 4
  
  if has_installed then
    local text = "[ Run the installed program ]"
    if selected == "run" then
      text = "[ [ Run the installed program ] ]"
    end
    local x = math.floor((w - #text) / 2) + 1
    term.setCursorPos(x, y)
    print(text)
    y = y + 2
  else
    local text = "(no program installed)"
    local x = math.floor((w - #text) / 2) + 1
    term.setCursorPos(x, y)
    print(text)
    y = y + 2
  end
  
  local items = {
    "Install Transmitter Module",
    "Install Receiver Module",
    "Delete Receiver Module",
    "Delete Transmitter Module",
    "Uninstall Software",
    "Exit Manage",
  }
  
  for i, text in ipairs(items) do
    local key = "item" .. i
    local display_text = text
    if selected == key then
      display_text = "[ " .. text .. " ]"
    end
    local x = math.floor((w - #display_text) / 2) + 1
    term.setCursorPos(x, y + i - 1)
    print(display_text)
  end
  
  local help_text = "Use UP/DOWN or Mouse Click to select, ENTER or Double Click to confirm."
  local help_x = math.floor((w - #help_text) / 2) + 1
  local help_y = y + #items + 2
  if help_y <= h then
    term.setCursorPos(help_x, help_y)
    print(help_text)
  end
end

function M.get_item_at_position(y, current_list, has_installed)
  local start_row = 4
  if not has_installed then
    start_row = 6
  end
  local index = y - start_row + 1
  if index >= 1 and index <= #current_list then
    return current_list[index]
  end
  return nil
end

return M
