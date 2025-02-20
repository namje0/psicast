namjepsi.abilities = {}
local FILE_PATH = "namjepsi/abilities/"

local function create_entity(ability)
    local ent = {}
    ent.Base = "namjepsi_ability_base"
    ent.Category = ability.entCategory or "PSIcast - Abilities"
    ent.Spawnable = true
    ent.AdminOnly = ability.adminOnly or false
    ent.PrintName = ability.name
    ent.Ability = ability.intName
    ent.IconOverride = ability.icon or "vgui/stimlogo.png"
    ent.Model = ability.model or "models/Items/battery.mdl"

    scripted_ents.Register(ent, ability.intName)
end

--TODO: fix case
function namjepsi.load_ability()
    local id = 0
    for _, v in pairs(file.Find(FILE_PATH .. "/*", "LUA")) do
        if v == "template.lua" then continue end
        include(FILE_PATH .. v)
        AddCSLuaFile(FILE_PATH .. v)
        local psi_ability = v:gsub("%.lua","")

        print("Loading PSI Ability for " .. psi_ability)
        print(namjepsi.abilities[psi_ability])
        namjepsi.abilities[psi_ability]["id"] = id
        create_entity(namjepsi.abilities[psi_ability])
        id = id + 1
    end
    print("Finished loading PSI Abilities")
    PrintTable(namjepsi.abilities)
end

namjepsi.load_ability()