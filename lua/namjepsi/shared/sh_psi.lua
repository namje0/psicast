AddCSLuaFile()

function namjepsi.give_psi(ply, psi, initial)
    if !IsValid(ply) then return end
    if !namjepsi.abilities[psi] then print(psi .. " is not a valid ability!") return end

    if !ply.namjepsi_inv then
        ply.namjepsi_inv = {}
    end

    ply.namjepsi_inv[psi] = true

    if !initial then
        namjepsi.update_inventory(ply)
    end

    print(ply:Name() .. " was given " .. namjepsi.abilities[psi]["name"])
end

function namjepsi.has_psi(ply, psi)
    if !IsValid(ply) then return end
    if ply.namjepsi_inv[psi] then return true end
    return false
end

function namjepsi.update_inventory(ply)
    if !IsValid(ply) then return end
    if !ply.namjepsi_inv then return end

    net.Start("namjepsi_update_inventory")

    net.WriteUInt(table.Count(ply.namjepsi_inv),32)
    for i, _ in pairs(ply.namjepsi_inv) do
        net.WriteString(i)
    end
    net.Send(ply)
end

local function ply_spawn(ply, transition)
    if transition then return end
    if !ply.init then
        ply.init = true
    end

    ply:SetNW2Bool("namjepsi_awakened", true)
    ply:SetNW2Int("namjepsi_max_energy", 100)
    ply:SetNW2Int("namjepsi_energy",ply:GetNW2Int("namjepsi_max_energy"))

    local slot_count = GetConVar("namjepsi_slot_amount"):GetInt()

    if !ply.init and !GetConVar("namjepsi_save_inv_on_death"):GetBool() then
        print("wipe inv for " .. ply.Name)

        ply.namjepsi_inv = {}
        ply.namjepsi_slots = {}
        for i = 1, slot_count do
            ply.namjepsi_slots[i] = "none"
        end
        if !GetConVar("namjepsi_spawn_with_all_abilities"):GetBool() then namjepsi.update_inventory(ply) end

        net.Start("namjepsi_update_slots")
        net.WriteUInt(table.Count(ply.namjepsi_inv),32)
        net.Send(ply)
    end

    if GetConVar("namjepsi_spawn_with_all_abilities"):GetBool() then
        for i,_ in pairs(namjepsi.abilities) do
            namjepsi.give_psi(ply, i, true)
        end
        namjepsi.give_psi(ply, "deeznuts")
        namjepsi.update_inventory(ply)
    end
end
hook.Add("PlayerSpawn", "namjepsi_ply_spawn", ply_spawn)
