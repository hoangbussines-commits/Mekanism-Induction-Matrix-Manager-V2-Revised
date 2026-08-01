--[[
  Induction Matrix Manager V2 - Bootloader
  Revised by hoangbussines-commits (JuliHyro Studios)
  Original Author: WOLFE_BR
]]

print("=== Induction Matrix Manager V2 ===")

-- Ensure Core/Utils folder exists
if not fs.exists("Core/Utils") then
  fs.makeDir("Core/Utils")
  print("Created Core/Utils folder.")
end

-- Download cleanup utility if not exists
if not fs.exists("Core/Utils/ClearOldFile.lua") then
  print("Downloading cleanup utility...")
  shell.run("wget", "https://raw.githubusercontent.com/hoangbussines-commits/Mekanism-Induction-Matrix-Manager-V2-Revised/main/Core/Utils/ClearOldFile.lua", "Core/Utils/ClearOldFile.lua")
end

-- Load cleanup utility
local clear = nil
if fs.exists("Core/Utils/ClearOldFile.lua") then
  clear = dofile("Core/Utils/ClearOldFile.lua")
  print("Cleanup utility loaded.")
else
  print("ERROR: Cannot load cleanup utility.")
end

-- Check if software already installed
if clear and clear.is_installed() then
  print("")
  print("You have installed software on this computer!")
  print("Are you sure you want to reinstall/update it? (Y/N)")
  while true do
    local event, key = os.pullEvent("key")
    if key == keys.y or key == keys.Y then
      clear.clean_all()
      break
    elseif key == keys.n or key == keys.N then
      print("Installation cancelled.")
      sleep(1)
      return
    end
  end
end

-- Save bootloader to disk (if not already saved)
if not fs.exists("startup.lua") then
  print("Saving bootloader to disk...")
  shell.run("wget", "https://raw.githubusercontent.com/hoangbussines-commits/Mekanism-Induction-Matrix-Manager-V2-Revised/main/startup.lua", "startup.lua")
  print("Bootloader saved!")
  sleep(1)
end

-- Download manager.lua
print("Downloading Manager...")
shell.run("wget", "https://raw.githubusercontent.com/hoangbussines-commits/Mekanism-Induction-Matrix-Manager-V2-Revised/main/manager.lua", "manager.lua")

if fs.exists("manager.lua") then
  print("Loading Manager...")
  shell.run("manager.lua")
else
  print("ERROR: Cannot load manager.lua")
end
