--[[
  Main UI for Induction Matrix Manager
  Handles drawing menu, keyboard/mouse navigation, and selection
]]

local M = {}

-- Draw menu
function M.draw(selected, has_installed)
  term.clear()
  local w, h = term.getSize()
  local center_x = math.floor(w / 2) - 10
  
  -- Title
  term.setCursorPos(center_x, 1)
  print("INDUCTION MATRIX MANAGER V2 MANAGE")
  term.setCursorPos(center_x, 2)
  print("-----------------------------------")
  
  local y = 4
  
  if has_installed then
    term.setCursorPos(center_x, y)
    if selected == "run" then
      print("> [ [ Run the installed program ] ]")
    else
      print("  [ Run the installed program ]")
    end
    y = y + 2
  else
    term.setCursorPos(center_x, y)
    print("(no program installed)")
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
    term.setCursorPos(center_x, y + i - 1)
    if selected == key then
      print("> [ " .. text .. " ]")
    else
      print("  " .. text)
    end
  end
  
  y = y + #items + 2
  term.setCursorPos(center_x, y)
  print("Use UP/DOWN or Mouse Click to select, ENTER or Double Click to confirm.")
end

-- Get item at mouse click position
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
