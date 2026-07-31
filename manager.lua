--[[
  Induction Matrix Manager V2 (GUI Edition)
  Revised by hoangbussines-commits (JuliHyro Studios)
  Original Author: WOLFE_BR
]]

-- Repository settings
local REPO_RAW = "https://raw.githubusercontent.com/hoangbussines-commits/Mekanism-Induction-Matrix-Manager-V2-Revised/main"

local MODULES = {
  transmitter = "Module/Transmitter.lua",
  receiver    = "Module/Receiver.lua",
}

local mode_file = ".mode"

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
  if not fs.exists("Module") then
    fs.makeDir("Module")
    print("Module folder created.")
    sleep(0.5)
  end
end

function draw_menu(selected, has_installed)
  term.clear()
  term.setCursorPos(1,1)
  print("  INDUCTION MATRIX MANAGER V2 MANAGE")
  print("  -----------------------------------")
  print("")
  
  if has_installed then
    if selected == "run" then
      print("  > [ Run the installed program ]")
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
    "Exit Manage",
  }
  
  for i, text in ipairs(items) do
    local key = "item" .. i
    if selected == key then
      print("  > " .. text)
    else
      print("    " .. text)
    end
  end
  print("")
  print("  Use UP/DOWN to select, ENTER to confirm.")
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
    shell.run("wget", url, MODULES.transmitter)
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
    shell.run("wget", url, MODULES.receiver)
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
    print("Exiting Manager...")
    sleep(0.5)
    os.shutdown()
  end
end

-- Main program
local menu_items = { "run", "item1", "item2", "item3", "item4", "item5" }
local selected_index = 2
local running = true

-- Ensure Module folder exists
ensure_module_folder()

while running do
  local has_installed = is_module_installed("transmitter") or is_module_installed("receiver")
  
  local current_list = {}
  if has_installed then
    current_list = { "run", "item1", "item2", "item3", "item4", "item5" }
  else
    current_list = { "item1", "item2", "item3", "item4", "item5" }
  end

  if selected_index > #current_list then
    selected_index = #current_list
  end
  if selected_index < 1 then
    selected_index = 1
  end

  local selected = current_list[selected_index]

  draw_menu(selected, has_installed)

  local event, key = os.pullEvent("key")

  if key == keys.up then
    selected_index = selected_index - 1
    if selected_index < 1 then
      selected_index = #current_list
    end
  elseif key == keys.down then
    selected_index = selected_index + 1
    if selected_index > #current_list then
      selected_index = 1
    end
  elseif key == keys.enter then
    handle_selection(selected, has_installed)
  end
end
