namjepsi.casting = false
namjepsi.self_target = false
namjepsi.current_slot = 1
namjepsi.range = 0
namjepsi.invalid_pos = false

local function send_slow(time)
    if game.SinglePlayer() and GetConVar("namjepsi_cast_slow"):GetBool() then
        net.Start("namje_slow_time")
        net.WriteBool(time)
        net.SendToServer()
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

    psicast_zoom(0)
end

local function psicast_start()
    if !IsValid(LocalPlayer()) or !LocalPlayer():Alive() then return end
    if namjepsi.casting then return end

    if is_slots_empty() then
        LocalPlayer():PrintMessage(HUD_PRINTTALK, "You have no abilities to cast. Add some in the inventory menu.")
        return
    end

    if LocalPlayer().namjepsi_slots[namjepsi.current_slot] == "none" then
        psicast_cycle(1)
    end

    namjepsi.casting = true
    VManip:PlayAnim("cast")

    --singleplayer time slowdown
    send_slow(true)

    psicast_zoom(0)
end

local function psicast_cancel()
    LocalPlayer():EmitSound( "player/suit_denydevice.wav")
    namjepsi.casting = false
    namjepsi.selfTarget = false
    VManip:Remove()
    --singleplayer time slowdown
    send_slow(false)
end

local function psicast_release()
    if !namjepsi.casting then return end
    VManip:QuitHolding("cast")
    namjepsi.casting = false

    --singleplayer time slowdown
    send_slow(false)

    local ability = namjepsi.abilities[LocalPlayer().namjepsi_slots[namjepsi.current_slot]]
    if !ability or LocalPlayer().namjepsi_cooldowns[ability.intName] or LocalPlayer():GetNW2Float("namjepsi_energy") < ability.cost() or namjepsi.invalid_pos then
        psicast_cancel()
        return
    end

    net.Start("namjepsi_cast")
    net.WriteInt(namjepsi.current_slot, 4)
    net.WriteInt(namjepsi.range, 16)
    net.SendToServer()
    LocalPlayer().namjepsi_cooldowns[ability.intName] = CurTime() + ability.cooldown
    ability.effect(LocalPlayer())
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
        --TODO: Target Self bind
        --impulse 100 = flashlight
        if (bind == "impulse 100") then
            psicast_cancel()
            return true
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