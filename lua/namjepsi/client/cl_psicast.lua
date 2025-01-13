namjepsi.casting = false
namjepsi.self_target = false
namjepsi.current_slot = 1

local function send_slow(time)
    if game.SinglePlayer() then
        net.Start("namje_slow_time")
        net.WriteBool(time)
        net.SendToServer()
    end
end

local function psicast_cycle(slot)
    if namjepsi.selfTarget then namjepsi.selfTarget = false end
    namjepsi.current_slot = namjepsi.current_slot + slot
    if namjepsi.current_slot < 1 then
    namjepsi.current_slot = 3
    elseif namjepsi.current_slot > 3 then
    namjepsi.current_slot = 1
    end
    local currentPSI = LocalPlayer():GetNWString("namjepsi_slot_" .. namjepsi.current_slot)
    if currentPSI == "none" then
        psicast_cycle(slot)
    end
    print(namjepsi.current_slot)
end

local function psicast_start()
    if !IsValid(LocalPlayer()) or !LocalPlayer():Alive() then return end
    if namjepsi.casting then return end

    namjepsi.casting = true
    VManip:PlayAnim("cast")

    --singleplayer time slowdown
    send_slow(true)
end

local function psicast_release()
    if !namjepsi.casting then return end
    VManip:QuitHolding("cast")
    namjepsi.casting = false

    --singleplayer time slowdown
    send_slow(false)
end

local function psicast_cancel()
    LocalPlayer():EmitSound( "player/suit_denydevice.wav")
    namjepsi.casting = false
    namjepsi.selfTarget = false
    VManip:Remove()
    --singleplayer time slowdown
    send_slow(false)
end

local function psicast_disable_keys(_, cmd)
    if (namjepsi.casting) then
        cmd:RemoveKey(8192) --reload
        cmd:RemoveKey(1) --attack
        cmd:RemoveKey(2048) --alt attack
        cmd:RemoveKey(32) --use
    end
end

local function psicast_binds(ply, bind, pressed)
    if !IsValid(LocalPlayer()) or !LocalPlayer():Alive() then return end
    if namjepsi.casting then
        --TODO: Target Self bind
        --impulse 100 = flashlight
        if (bind == "impulse 100") then
            psicast_cancel()
            return true
        elseif (bind == "invprev") then
            psicast_cycle(-1)
            return true
        elseif (bind == "invnext") then
            psicast_cycle(1)
            return true
        end
    end
end

concommand.Add("+psicast", psicast_start)
concommand.Add("-psicast", psicast_release)

hook.Add("PlayerBindPress", "psicast_binds", psicast_binds)
hook.Add("StartCommand", "psicast_disable_keys", psicast_disable_keys)