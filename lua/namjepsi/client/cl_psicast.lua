namjepsi.casting = false
namjepsi.self_target = false
namjepsi.current_slot = 1

local function psicast_start()
    if !IsValid(LocalPlayer()) or !LocalPlayer():Alive() then return end
    if namjepsi.casting then return end

    namjepsi.casting = true
    VManip:PlayAnim("cast")

    --singleplayer time slowdown
    if game.SinglePlayer() then
        net.Start("namje_slow_time")
        net.WriteBool(true)
        net.SendToServer()
    end
end

local function psicast_release()
    if !namjepsi.casting then return end
    VManip:QuitHolding("cast")
    namjepsi.casting = false

    --singleplayer time slowdown
    if game.SinglePlayer() then
        net.Start("namje_slow_time")
        net.WriteBool(false)
        net.SendToServer()
    end
end

concommand.Add("+psicast", psicast_start)
concommand.Add("-psicast", psicast_release)