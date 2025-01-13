namjepsi.ability_data = {}
namjepsi.ability_effects = {}

local FILE_PATH = "namjepsi/abilities/"

function namjepsi.load_ability_data()
    local id = 0
    for _, v in pairs(file.Find(FILE_PATH .. "data/*", "LUA")) do
        if v == "template.lua" then return end
        include(FILE_PATH .. "data/" .. v)
        AddCSLuaFile(FILE_PATH .. "data/" .. v)
        local psi_ability = v:gsub("%.lua","")

        print("Loading PSI Ability Data for " .. psi_ability)
        print(namjepsi.ability_data[psi_ability])
        namjepsi.ability_data[psi_ability]["id"] = id
        id = id + 1
    end
    print("Finished loading PSI Ability Data")
    PrintTable(namjepsi.ability_data)
end

function namjepsi.load_ability_effects()
    for _, v in pairs(file.Find(FILE_PATH .. "effects/*", "LUA")) do
        if v == "template.lua" then return end
        include(FILE_PATH .. "effects/" .. v)
        AddCSLuaFile(FILE_PATH .. "effects/" .. v)
        local psi_ability = v:gsub("%.lua","")
        print("Loading PSI Ability Effect for " .. psi_ability)
    end
    print("Finished loading PSI Ability Effects")
    PrintTable(namjepsi.ability_effects)
end

namjepsi.load_ability_data()
namjepsi.load_ability_effects()