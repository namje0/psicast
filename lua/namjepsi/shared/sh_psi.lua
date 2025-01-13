function namjepsi.give_psi(ply, psi)
    if !IsValid(ply) then return end
    if !namjepsi.abilities[psi] then print(psi .. " is not a valid ability!") return end

    if !ply.namjepsi_inv then
        ply.namjepsi_inv = {}
    end

    ply.namjepsi_inv[psi] = true

    print(ply:Name() .. " was given " .. namjepsi.abilities[psi]["name"])
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

local function ply_init(ply, transition)
    if transition then return end

    ply:SetNW2Bool("namjepsi_awakened", true)
    ply:SetNW2Int("namjepsi_max_energy", 100)
    ply:SetNW2Int("namjepsi_energy",ply:GetNW2Int("namjepsi_max_energy"))

    ply:SetNW2String("namjepsi_slot_1", "test")
    ply:SetNW2String("namjepsi_slot_2", "test2")
    ply:SetNW2String("namjepsi_slot_3", "none")

    --TODO: if lose on death enabled/disabled
    ply.namjepsi_inv = {}
    --TODO: give all psi on spawn option
    if SERVER then
        for i,_ in pairs(namjepsi.abilities) do
            namjepsi.give_psi(ply, i)
        end
        namjepsi.give_psi(ply, "deeznuts")
        namjepsi.update_inventory(ply)
    end
end
hook.Add("PlayerSpawn", "namjepsi_ply_init", ply_init)
