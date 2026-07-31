--[[
  Mouse Event Handler for Induction Matrix Manager
  Handles single click, double click, and coordinate mapping
]]

local M = {}

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

function M.handle(event, p1, p2, p3, p4, current_list, has_installed, selected_index, last_click_time, last_click_item)
  if event == "mouse_click" then
    local button, x, y = p1, p2, p3
    if button == 1 then
      local clicked_item = M.get_item_at_position(y, current_list, has_installed)
      if clicked_item then
        local current_time = os.clock()
        if clicked_item == last_click_item and (current_time - last_click_time) < 0.5 then
          return selected_index, 0, nil, clicked_item
        else
          for i, item in ipairs(current_list) do
            if item == clicked_item then
              return i, current_time, clicked_item, nil
            end
          end
        end
      end
    end
  end
  return selected_index, last_click_time, last_click_item, nil
end

return M
