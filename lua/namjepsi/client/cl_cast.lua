namjepsi.casting = false
namjepsi.channeling = false
namjepsi.self_target = false
namjepsi.current_slot = 1
namjepsi.invalid_pos = false

namjepsi.range = 0
namjepsi.channel_args = nil
namjepsi.target = nil
namjepsi.pos = nil

--[[local vmanip_anims = {
    "cast2",
    "castself",
    "caststart",
    "castcancel2",
    "channelstart",
    "channelidle",
    "channelend"
}]]

local function namjepsi_channel_idle(name,cursegment,islastsegment,segmentcount)
    if namjepsi.channeling then
        VManip:PlaySegment("channelidle")
    end
end

local function psicast_end_channel()
    local ability = namjepsi.abilities[LocalPlayer().namjepsi_slots[namjepsi.current_slot]]
    if !ability then return end

    namjepsi.channeling = false
    hook.Remove("VManipSegmentFinish","namjepsi_channel_idle")
    VManip:Remove()
    VManip:PlayAnim("channelend")

    ability.channelEnd(LocalPlayer(), namjepsi.channel_args)

    net.Start("namjepsi_end_channel")
    net.WriteInt(namjepsi.current_slot, 4)
    net.SendToServer()

    namjepsi.channel_args = nil
    LocalPlayer().namjepsi_cooldowns[ability.intName] = CurTime() + ability.cooldown
end

local function send_slow(time)
    if game.SinglePlayer() and GetConVar("namjepsi_cast_slow"):GetBool() then
        net.Start("namje_slow_time")
        net.WriteBool(time)
        net.SendToServer()
    end
end

local function psicast_cancel()
    LocalPlayer():EmitSound( "player/suit_denydevice.wav")

    local vmanip_anim = VManip:GetCurrentAnim()
    --if table.HasValue(vmanip_anims, vmanip_anim) then
    if vmanip_anim then
        VManip:Remove()
    end
    --end
    VManip:PlayAnim("castcancel2")

    namjepsi.casting = false
    namjepsi.self_target = false
    --VManip:Remove()
    --singleplayer time slowdown
    send_slow(false)
end

local function client_cast()
    local ability = namjepsi.abilities[LocalPlayer().namjepsi_slots[namjepsi.current_slot]]
    local is_targeting = istable(ability.targeting)

    local cost = ability and is_targeting and ability.cost(ply, namjepsi.target) or ability and ability.cost(ply)
    if !ability or !cost or LocalPlayer().namjepsi_cooldowns[ability.intName] or LocalPlayer():GetNW2Float("namjepsi_energy") < cost or namjepsi.invalid_pos then
        psicast_cancel()
        return
    end

    net.Start("namjepsi_cast")
    net.WriteInt(namjepsi.current_slot, 4)
    net.WriteInt(namjepsi.range, 16)

    if namjepsi.target then
        net.WriteEntity(namjepsi.target)
    end

    net.SendToServer()
    print("client cast")

    local args = namjepsi.pos != nil and namjepsi.pos or namjepsi.target != nil and namjepsi.target or nil

    VManip:Remove()
    if ability.castType == 1 then
        VManip:PlayAnim(ability.castAnim or "cast2")
        ability.effect(LocalPlayer(), args)
        LocalPlayer().namjepsi_cooldowns[ability.intName] = CurTime() + ability.cooldown
    elseif ability.castType == 2 then
        --VManip:PlayAnim(ability.channelStartAnim or "channelstart")
        --TODO: ability effect timer on client
        namjepsi.channeling = true
        namjepsi.channel_args = args
        if VManip:PlayAnim(ability.channelStartAnim or "channelstart") then
            hook.Add("VManipSegmentFinish", "namjepsi_channel_idle", namjepsi_channel_idle)
        end
        ability.channelStart(LocalPlayer(), args)
    end
end

local function is_slots_empty()
    for k, v in pairs(LocalPlayer().namjepsi_slots) do
        if v != "none" then
            return false
        end
    end
    return true
end

local function psicast_zoom(increment)
    local ability = namjepsi.abilities[LocalPlayer().namjepsi_slots[namjepsi.current_slot]]
    if !ability then return end

    if increment == 0 then namjepsi.range = ability.range return end
    namjepsi.range = math.floor(math.Clamp(namjepsi.range + ((ability.range / 10) * increment), 50, ability.range))
end

local function psicast_cycle(slot)
    --if is_slots_empty() then return end
    local num_slots = LocalPlayer().namjepsi_slots
    namjepsi.current_slot = namjepsi.current_slot + slot

    if namjepsi.current_slot > #num_slots then
        namjepsi.current_slot = 1
    elseif namjepsi.current_slot < 1 then
        namjepsi.current_slot = #num_slots
    end

    if LocalPlayer().namjepsi_slots[namjepsi.current_slot] == "none" then
        psicast_cycle(slot)
    end

    namjepsi.self_target = false
    psicast_zoom(0)
end

local function psicast_start()
    if !IsValid(LocalPlayer()) or !LocalPlayer():Alive() then return end
    if namjepsi.casting or namjepsi.stimming then return end

    if namjepsi.channeling then
        psicast_end_channel()
        return
    end

    if is_slots_empty() then
        LocalPlayer():PrintMessage(HUD_PRINTTALK, "You have no abilities to cast. Add some in the inventory menu.")
        return
    end

    if LocalPlayer().namjepsi_slots[namjepsi.current_slot] == "none" then
        psicast_cycle(1)
    end

    local vmanip_anim = VManip:GetCurrentAnim()
    if vmanip_anim then
        VManip:Remove()
    end
    VManip:PlayAnim("caststart")
    namjepsi.casting = true

    --singleplayer time slowdown
    send_slow(true)
    namjepsi.self_target = false
    psicast_zoom(0)
end

local function psicast_release()
    if !namjepsi.casting then return end
    namjepsi.casting = false

    --singleplayer time slowdown
    send_slow(false)

    local ability = namjepsi.abilities[LocalPlayer().namjepsi_slots[namjepsi.current_slot]]

    if !ability or LocalPlayer().namjepsi_cooldowns[ability.intName] or namjepsi.invalid_pos then
        print("blah")
        PrintTable(ability)
        print(namjepsi.invalid_pos)
        psicast_cancel()
        return
    end

    client_cast()
end

local function psicast_disable_keys(_, cmd)
    if (namjepsi.casting or namjepsi.stimming) then
        cmd:RemoveKey(8192) --reload
        cmd:RemoveKey(1) --attack
        cmd:RemoveKey(2048) --alt attack
        cmd:RemoveKey(32) --use
    end
end

local function psicast_binds(ply, bind, pressed)
    if !IsValid(LocalPlayer()) or !LocalPlayer():Alive() then return end
    if !pressed then return end

    if namjepsi.casting then
        --impulse 100 = flashlight
        if (bind == "impulse 100") then
            psicast_cancel()
            return true
        elseif input.IsKeyDown(15) then
            namjepsi.self_target = !namjepsi.self_target
        elseif input.IsMouseDown(107) then
            psicast_cycle(1)
            return true
        elseif input.IsMouseDown(108) then
            psicast_cycle(-1)
            return true
        elseif (bind == "invnext") then
            psicast_zoom(-1)
            return true
        elseif (bind == "invprev") then
            psicast_zoom(1)
            return true
        end

    end
end

concommand.Add("+psicast", psicast_start)
concommand.Add("-psicast", psicast_release)

hook.Add("PlayerBindPress", "psicast_binds", psicast_binds)
hook.Add("StartCommand", "psicast_disable_keys", psicast_disable_keys)