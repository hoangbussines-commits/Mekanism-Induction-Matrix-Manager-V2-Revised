--[[
  Centralized cleanup utility
  - clean_old_files(): only removes temporary/legacy junk
  - clean_all(): removes EVERYTHING (including modules) for uninstall
]]

local M = {}

-- Files that are always safe to delete
function M.get_temp_files()
  return {
    "startupinstall.lua",
    "mouse.lua",
    "Core/Events/mouse.lua",
    "Core/Utils/ClearOldFile.lua", -- optional, may be removed if you want to update
  }
end

-- Full uninstall: delete everything
function M.get_all_files()
  return {
    "startup.lua",
    "manager.lua",
    "Transmitter.lua",
    "Receiver.lua",
    "transmitter.lua",
    "receiver.lua",
    "startupinstall.lua",
    "mouse.lua",
    "Core/Events/mouse.lua",
    "Core/UserInterface/Main_UI.lua",
    "Core/Utils/ClearOldFile.lua",
  }
end

-- Light cleanup (daily use)
function M.clean_old_files()
  print("Cleaning temp files...")
  local files = M.get_temp_files()
  for _, file in ipairs(files) do
    if fs.exists(file) then
      fs.delete(file)
      print("Removed: " .. file)
      sleep(0.1)
    end
  end
  print("Temp cleanup done.")
  sleep(0.5)
end

-- Full uninstall (nuclear)
function M.clean_all()
  print("Uninstalling everything...")
  local files = M.get_all_files()
  for _, file in ipairs(files) do
    if fs.exists(file) then
      fs.delete(file)
      print("Removed: " .. file)
      sleep(0.1)
    end
  end
  if fs.exists("Module") and fs.isDir("Module") then
    local items = fs.list("Module")
    for _, item in ipairs(items) do
      fs.delete(fs.combine("Module", item))
    end
    fs.delete("Module")
    print("Removed Module folder.")
  end
  print("Full uninstall complete.")
  sleep(0.5)
end

function M.is_installed()
  return fs.exists("startup.lua") and fs.exists("manager.lua")
end

return M
