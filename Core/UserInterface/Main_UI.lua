--[[
  Main UI for Induction Matrix Manager
  Handles drawing menu, keyboard/mouse navigation, and selection
]]

local M = {}

-- Draw menu
function M.draw(selected, has_installed)
  term.clear()
  term.setCursorPos(1,1)
  print("  INDUCTION MATRIX MANAGER V2 MANAGE")
  print("  -----------------------------------")
  print("")
  
  if has_installed then
    if selected == "run" then
      print("  > [ [ Run the installed program ] ]")
    else
      print("    [ Run the installed program ]")
    end
  else
    print("    (no program installed)")
  end
  print("")
  
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
    if selected == key then
      print("  > [ " .. text .. " ]")
    else
      print("    " .. text)
    end
  end
  print("")
  print("  Use UP/DOWN or Mouse Click to select, ENTER or Double Click to confirm.")
end

-- Get item at mouse click position
function M.get_item_at_position(y, current_list, has_installed)
  local start_row = 5
  if not has_installed then
    start_row = 7
  end
  local index = y - start_row + 1
  if index >= 1 and index <= #current_list then
    return current_list[index]
  end
  return nil
end

return M
