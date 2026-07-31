--[[
  Induction Matrix Manager V2 - Bootloader (Self-saving)
  Revised by hoangbussines-commits (JuliHyro Studios)
  Original Author: WOLFE_BR
]]

print("=== Induction Matrix Manager V2 ===")

-- Check if this file is already saved locally
if not fs.exists("startup.lua") or fs.getSize("startup.lua") == 0 then
  print("Saving bootloader to disk...")
  shell.run("wget", "https://raw.githubusercontent.com/hoangbussines-commits/Mekanism-Induction-Matrix-Manager-V2-Revised/main/startup.lua", "startup.lua")
  print("Bootloader saved!")
  sleep(1)
end

-- Download or update manager.lua
print("Checking for Manager...")
shell.run("wget", "https://raw.githubusercontent.com/hoangbussines-commits/Mekanism-Induction-Matrix-Manager-V2-Revised/main/manager.lua", "manager.lua")

if fs.exists("manager.lua") then
  print("Loading Manager...")
  shell.run("manager.lua")
else
  print("ERROR: Cannot load manager.lua")
end
