net.Receive("namjepsi_update_inventory", function()
    if !IsValid(LocalPlayer()) then return end
    LocalPlayer().namjepsi_inv = {}

    local count = net.ReadUInt(32)

    for i = 1, count do
        local ability = net.ReadString()
        print("give ability on client: " .. ability)
        LocalPlayer().namjepsi_inv[ability] = true
    end
    print("updated inventory:")
    PrintTable(LocalPlayer().namjepsi_inv)
end)

net.Receive("namjepsi_init_slots", function()
    if !IsValid(LocalPlayer()) then return end
    --also init slot cooldowns here
    LocalPlayer().namjepsi_cooldowns = {}
    LocalPlayer().namjepsi_slots = {}

    local count = net.ReadUInt(32)
    for i = 1, count do
        LocalPlayer().namjepsi_slots[i] = "none"
    end
    print("updated slots:")
    PrintTable(LocalPlayer().namjepsi_slots)
end)

net.Receive("namjepsi_complete_cd", function()
    if !IsValid(LocalPlayer()) then return end
    local ability = net.ReadString()
    LocalPlayer().namjepsi_cooldowns[ability] = nil
end)

--TODO: handle invalid cast for channel abilities
net.Receive("namjepsi_invalid_cast", function()
    if !IsValid(LocalPlayer()) then return end
    local ability = net.ReadString()
    print("Invalid cast for ability " .. ability)
    LocalPlayer().namjepsi_cooldowns[ability] = nil

    local ability_data = namjepsi.abilities[ability]
    if !ability_data then return end

    if ability_data.castType == 2 then
        print("handling channel invalid")
        namjepsi.channeling = false
        hook.Remove("VManipSegmentFinish","namjepsi_channel_idle")

        ability_data.channelEnd(LocalPlayer(), namjepsi.channel_args)

        namjepsi.channel_args = nil
    end

    local vmanip_anim = VManip:GetCurrentAnim()
    --if table.HasValue(vmanip_anims, vmanip_anim) then
    if vmanip_anim then
        VManip:Remove()
    end
    --end
    VManip:PlayAnim("castcancel2")
end)

net.Receive("namjepsi_end_channel", function()
    if !IsValid(LocalPlayer()) then return end

    local ability = namjepsi.abilities[LocalPlayer().namjepsi_slots[namjepsi.current_slot]]
    if !ability then return end

    namjepsi.channeling = false
    hook.Remove("VManipSegmentFinish","namjepsi_channel_idle")
    VManip:Remove()
    VManip:PlayAnim("channelend")

    ability.channelEnd(LocalPlayer(), namjepsi.channel_args)

    namjepsi.channel_args = nil
    LocalPlayer().namjepsi_cooldowns[ability.intName] = CurTime() + ability.cooldown
end)