--[[
  Centralized cleanup utility
  Used by startup.lua and manager.lua to remove old files
]]

local M = {}

-- List of known legacy files to remove
function M.get_legacy_files()
  return {
    "Transmitter.lua",
    "Receiver.lua",
    "transmitter.lua",
    "receiver.lua",
    "startupinstall.lua",
    "mouse.lua",
    "Core/Events/mouse.lua",
  }
end

-- Clean all legacy files
function M.clean_all()
  print("Cleaning old files...")
  local files = M.get_legacy_files()
  for _, file in ipairs(files) do
    if fs.exists(file) then
      fs.delete(file)
      print("Removed: " .. file)
      sleep(0.1)
    end
  end

  -- Remove old Module folder if exists
  if fs.exists("Module") and fs.isDir("Module") then
    local items = fs.list("Module")
    for _, item in ipairs(items) do
      fs.delete(fs.combine("Module", item))
    end
    fs.delete("Module")
    print("Removed old Module folder.")
  end

  print("Cleanup done.")
  sleep(0.5)
end

-- Check if software is installed (for startup guard)
function M.is_installed()
  return fs.exists("startup.lua") and fs.exists("manager.lua")
end

return M
