--[[
  Induction Matrix Manager V2 - Bootloader
  Revised by hoangbussines-commits (JuliHyro Studios)
  Original Author: WOLFE_BR
]]

print("=== Induction Matrix Manager V2 ===")
print("Downloading Manager...")
shell.run("wget", "https://raw.githubusercontent.com/hoangbussines-commits/Mekanism-Induction-Matrix-Manager-V2-Revised/main/manager.lua", "manager.lua")

if fs.exists("manager.lua") then
  print("Loading Manager...")
  shell.run("manager.lua")
else
  print("ERROR: Failed to download manager.lua")
end
