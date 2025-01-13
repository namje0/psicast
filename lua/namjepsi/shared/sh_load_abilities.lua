namjepsi.AbilityData = {}

local FILE_PATH = "namjepsi/abilities/data/"

local function load_ability_data()
    local id = 0
    for _, v in pairs(file.Find(FILE_PATH .. "*", "LUA")) do
        if v == "template.lua" then return end
        include(FILE_PATH .. v)
        AddCSLuaFile(FILE_PATH .. v)
        local psi_ability = v:gsub("%.lua","")
        namjepsi.AbilityData[psi_ability]["ID"] = id
        id = id + 1
        print("Registered PSI Ability Data: " .. psi_ability)
    end
end

load_ability_data()