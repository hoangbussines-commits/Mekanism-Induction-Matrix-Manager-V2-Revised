--[[
  Induction Matrix Manager V2 (GUI Edition)
  Revised by hoangbussines-commits (JuliHyro Studios)
  Original Author: WOLFE_BR
]]

local REPO_RAW = "https://raw.githubusercontent.com/hoangbussines-commits/Mekanism-Induction-Matrix-Manager-V2-Revised/main"

local MODULES = {
  transmitter = "Module/Transmitter.lua",
  receiver    = "Module/Receiver.lua",
}

local mode_file = ".mode"

-- Load cleanup utility
local clear = nil
if fs.exists("Core/Utils/ClearOldFile.lua") then
  clear = dofile("Core/Utils/ClearOldFile.lua")
end

-- Load UI
local ui = nil
if fs.exists("Core/UserInterface/Main_UI.lua") then
  ui = dofile("Core/UserInterface/Main_UI.lua")
  print("UI loaded.")
else
  print("WARNING: UI not found. Using fallback.")
end

-- Helper functions
function file_read(file)
  local f = fs.open(file, "r")
  if not f then return nil end
  local data = f.readAll()
  f.close()
  return data
end

function file_write(file, data)
  local f = fs.open(file, "w")
  f.write(data)
  f.close()
end

function is_module_installed(name)
  return fs.exists(MODULES[name])
end

function set_selected_module(name)
  file_write(mode_file, name)
end

function get_selected_module()
  local data = file_read(mode_file)
  return data and data:gsub("%s+", "") or nil
end

function ensure_module_folder()
  if fs.exists("Module") and not fs.isDir("Module") then
    fs.delete("Module")
    print("Removed file 'Module' to create folder.")
    sleep(0.5)
  end
  if not fs.exists("Module") then
    fs.makeDir("Module")
    print("Module folder created.")
    sleep(0.5)
  end
end

function download_file(url, dest)
  print("Downloading " .. dest .. "...")
  shell.run("wget", url, dest)
  if fs.exists(dest) then
    print("Done: " .. dest)
    return true
  else
    print("Failed: " .. dest)
    return false
  end
end

function clean_old_files()
  if clear then
    clear.clean_old_files()
  else
    -- Fallback
    print("Cleaning old files (fallback)...")
    local legacy_files = {
      "Transmitter.lua", "Receiver.lua",
      "transmitter.lua", "receiver.lua",
      "startupinstall.lua",
      "mouse.lua",
      "Core/Events/mouse.lua"
    }
    for _, file in ipairs(legacy_files) do
      if fs.exists(file) then
        fs.delete(file)
        print("Removed: " .. file)
        sleep(0.1)
      end
    end
    print("Cleanup done.")
    sleep(0.5)
  end
end

function handle_selection(sel, has_installed)
  if sel == "run" and has_installed then
    local mod = get_selected_module()
    if mod and fs.exists(MODULES[mod]) then
      term.clear()
      print("Running " .. mod .. "...")
      sleep(1)
      shell.run(MODULES[mod])
      return
    else
      print("No module selected or file missing.")
      sleep(1)
      return
    end
  end

  if sel == "item1" then
    term.clear()
    print("Downloading Transmitter Module...")
    ensure_module_folder()
    local url = REPO_RAW .. "/Module/Transmitter.lua"
    download_file(url, MODULES.transmitter)
    if fs.exists(MODULES.transmitter) then
      set_selected_module("transmitter")
      print("Done! Transmitter installed.")
    else
      print("Download failed! Check URL or connection.")
    end
    sleep(1)
  end

  if sel == "item2" then
    term.clear()
    print("Downloading Receiver Module...")
    ensure_module_folder()
    local url = REPO_RAW .. "/Module/Receiver.lua"
    download_file(url, MODULES.receiver)
    if fs.exists(MODULES.receiver) then
      set_selected_module("receiver")
      print("Done! Receiver installed.")
    else
      print("Download failed! Check URL or connection.")
    end
    sleep(1)
  end

  if sel == "item3" then
    term.clear()
    if fs.exists(MODULES.receiver) then
      fs.delete(MODULES.receiver)
      print("Receiver module deleted.")
    else
      print("Receiver module not found.")
    end
    sleep(1)
  end

  if sel == "item4" then
    term.clear()
    if fs.exists(MODULES.transmitter) then
      fs.delete(MODULES.transmitter)
      print("Transmitter module deleted.")
    else
      print("Transmitter module not found.")
    end
    sleep(1)
  end

if sel == "item5" then
  term.clear()
  print("Are you sure you want to uninstall everything? (Y/N)")
  while true do
    local event, key = os.pullEvent("key")
    if key == keys.y or key == keys.Y then
      print("Creating uninstall script...")
      local f = fs.open("uninstall.lua", "w")
      f.write([[
print("Uninstalling...")
local files = {
  "startup.lua", "manager.lua",
  "Transmitter.lua", "Receiver.lua",
  "transmitter.lua", "receiver.lua",
  "startupinstall.lua", "mouse.lua",
  "Core/Events/mouse.lua",
  "Core/UserInterface/Main_UI.lua",
  "Core/Utils/ClearOldFile.lua",
  "uninstall.lua"
}
for _, f in ipairs(files) do
  if fs.exists(f) then
    fs.delete(f)
    print("Deleted: " .. f)
  end
end
if fs.exists("Module") then
  local items = fs.list("Module")
  for _, item in ipairs(items) do
    fs.delete(fs.combine("Module", item))
  end
  fs.delete("Module")
end
print("Uninstall complete. Rebooting...")
sleep(1)
os.reboot()
]])
      f.close()
      print("Running uninstall script...")
      sleep(1)
      shell.run("uninstall.lua")
      return
    elseif key == keys.n or key == keys.N then
      print("Uninstall cancelled.")
      sleep(1)
      return
    end
  end
end

  if sel == "item6" then
    term.clear()
    print("Exiting Manager...")
    sleep(0.5)
    os.shutdown()
  end
end

-- Main
clean_old_files()
ensure_module_folder()

-- Ensure Core/UserInterface folder and Main_UI.lua exist
if not fs.exists("Core/UserInterface") then
  fs.makeDir("Core/UserInterface")
  print("Created Core/UserInterface folder.")
end

if not fs.exists("Core/UserInterface/Main_UI.lua") then
  download_file(REPO_RAW .. "/Core/UserInterface/Main_UI.lua", "Core/UserInterface/Main_UI.lua")
end

-- Ensure Core/Events folder and mouse.lua exist
if not fs.exists("Core/Events") then
  fs.makeDir("Core/Events")
  print("Created Core/Events folder.")
end

if not fs.exists("Core/Events/mouse.lua") then
  download_file(REPO_RAW .. "/Core/Events/mouse.lua", "Core/Events/mouse.lua")
end

-- Reload UI if just downloaded
if fs.exists("Core/UserInterface/Main_UI.lua") then
  ui = dofile("Core/UserInterface/Main_UI.lua")
end

-- Load mouse support
local mouse = nil
if fs.exists("Core/Events/mouse.lua") then
  mouse = dofile("Core/Events/mouse.lua")
  print("Mouse support loaded.")
else
  print("Mouse support not found. Keyboard only.")
end

local menu_items = { "run", "item1", "item2", "item3", "item4", "item5", "item6" }
local selected_index = 2
local running = true
local last_click_time = 0
local last_click_item = nil

while running do
  local has_installed = is_module_installed("transmitter") or is_module_installed("receiver")
  
  local current_list = {}
  if has_installed then
    current_list = { "run", "item1", "item2", "item3", "item4", "item5", "item6" }
  else
    current_list = { "item1", "item2", "item3", "item4", "item5", "item6" }
  end

  if selected_index > #current_list then
    selected_index = #current_list
  end
  if selected_index < 1 then
    selected_index = 1
  end

  local selected = current_list[selected_index]
  
  -- Tạo window ở giữa màn hình
  local w, h = term.getSize()
  local win_width = 50
  local win_height = 12
  local win_x = math.floor((w - win_width) / 2) + 1
  local win_y = math.floor((h - win_height) / 2) + 1
  local main_window = window.create(term.current(), win_x, win_y, win_width, win_height, true)
  
  term.redirect(main_window)
  
  if ui then
    ui.draw(selected, has_installed)
  else
    term.clear()
    term.setCursorPos(1,1)
    print("ERROR: UI missing, please reinstall.")
    sleep(2)
    os.reboot()
  end
  
  term.redirect(term.current())
  
  local event, p1, p2, p3, p4 = os.pullEvent()

  if event == "key" then
    local key = p1
    if key == keys.up then
      selected_index = selected_index - 1
      if selected_index < 1 then selected_index = #current_list end
    elseif key == keys.down then
      selected_index = selected_index + 1
      if selected_index > #current_list then selected_index = 1 end
    elseif key == keys.enter then
      handle_selection(selected, has_installed)
    end

  elseif event == "mouse_click" and mouse then
    local new_index, new_time, new_item, action = mouse.handle(
      event, p1, p2, p3, p4,
      current_list, has_installed,
      selected_index, last_click_time, last_click_item
    )
    if action then
      handle_selection(action, has_installed)
    else
      selected_index = new_index
      last_click_time = new_time
      last_click_item = new_item
    end
  end
end

  local event, p1, p2, p3, p4 = os.pullEvent()

  if event == "key" then
    local key = p1
    if key == keys.up then
      selected_index = selected_index - 1
      if selected_index < 1 then selected_index = #current_list end
    elseif key == keys.down then
      selected_index = selected_index + 1
      if selected_index > #current_list then selected_index = 1 end
    elseif key == keys.enter then
      handle_selection(selected, has_installed)
    end

  elseif event == "mouse_click" and mouse then
    local new_index, new_time, new_item, action = mouse.handle(
      event, p1, p2, p3, p4,
      current_list, has_installed,
      selected_index, last_click_time, last_click_item
    )
    if action then
      handle_selection(action, has_installed)
    else
      selected_index = new_index
      last_click_time = new_time
      last_click_item = new_item
    end
  end
end
