--[[-----------------------------------------------------------------------------------------------------------------
          __
     w  c(..)o   (
      \__(-)    __)   Fear the monkey.
          /\   (
         /(_)___)
         w /|
          | \
          m  m
--]]-----------------------------------------------------------------------------------------------------------------

AddCSLuaFile()

namjepsi = {}

for _, v in pairs(file.Find("namjepsi/shared/*", "LUA")) do
    include("namjepsi/shared/" .. v)
    AddCSLuaFile("namjepsi/shared/" .. v)
end

for _, v in pairs(file.Find("namjepsi/client/*", "LUA")) do
    AddCSLuaFile("namjepsi/client/" .. v)
    if CLIENT then
        include("namjepsi/client/" .. v)
    end
end

if SERVER then
    for _, v in pairs(file.Find("namjepsi/server/*", "LUA")) do
        include("namjepsi/server/" .. v)
    end
end