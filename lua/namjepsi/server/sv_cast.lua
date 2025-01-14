function namjepsi.cast(len, ply)
    if !IsValid(ply) or !ply:Alive() then return end

    local slot = net.ReadDouble()
    local ability = namjepsi.abilities[ply:GetNW2String("namjepsi_slot_" .. slot)]
    if !ability then error("Ability " .. ply:GetNW2String("namjepsi_slot_" .. slot) .. "not found!") return end

    print("casting " .. ply:GetNW2String("namjepsi_slot_" .. slot))

    --get target/pos
    local target_entities = istable(ability.targeting)
    local pos, target
    if target_entities then
        print("target ent")
    else
        local tr = util.TraceLine( {
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + ply:GetAimVector() * ability.range,
            filter = ply,
            mask = MASK_SHOT
        } )
        pos = tr.HitPos
        print(pos)
    end

    ability.effect(ply, pos)
end

net.Receive("namjepsi_cast", namjepsi.cast)