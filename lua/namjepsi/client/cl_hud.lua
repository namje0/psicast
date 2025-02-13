local cd_alpha, stim_alpha, dose_alpha, bar_alpha, cast_alpha = 0, 0, 0, 0, 0

local psi_bar = {
    x = ScreenScale(14),
    y = ScrH() - ScreenScale(45),
    w = ScreenScale(76.5),
    h = ScreenScale(5)
}

local bar_length = psi_bar.w
local trail_length = psi_bar.w

local function namjepsi_hud()
    local ply = LocalPlayer()
    if !ply:GetNW2Bool("namjepsi_awakened") then return end

    local stim_amount = ply:GetAmmoCount( "namje_psychostim" )
    local energy = ply:GetNW2Float("namjepsi_energy")
    local max_energy = ply:GetNW2Int("namjepsi_max_energy")

    local cooldowns = ply.namjepsi_cooldowns
    if cooldowns then
        for slot, time in pairs(cooldowns) do
            if time < CurTime() then
                print("cooldown complete for " .. slot)
                cooldowns[slot] = nil
            end
        end
    end

    local psi_bar_bg_color = Color(78, 75, 66, bar_alpha)
    local psi_bar_color = Color(230, 221, 175, bar_alpha)
    local psi_trail_color = Color(153, 144, 120, bar_alpha)
    local psi_over_color = Color(186, 120, 174, bar_alpha)

    --energy bar
    if energy == max_energy then
        bar_alpha = math.Approach(bar_alpha, 0, 255 * FrameTime() * .7)
    else
        bar_alpha = math.Approach(bar_alpha, 255, 255 * FrameTime() * 2)
    end

    bar_length = psi_bar.w * math.Clamp(energy / max_energy, 0, 1)
    trail_length = math.Approach(trail_length, bar_length, FrameTime() * 70)
    if trail_length < bar_length then
        trail_length = bar_length
    end

    surface.SetDrawColor(psi_bar_bg_color)
    surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, psi_bar.w, psi_bar.h)

    surface.SetDrawColor(psi_trail_color)
    surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, trail_length, psi_bar.h)

    surface.SetDrawColor(psi_bar_color)
    surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, bar_length, psi_bar.h)

    local over_energy = energy - max_energy
    if over_energy > 0 then
        surface.SetDrawColor(psi_over_color)
        surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, psi_bar.w * (over_energy / max_energy), psi_bar.h)
    end

    --draw.SimpleText(math.floor(energy) .. "%", "GModToolHelp", ScreenScale(13), ScrH() - ScreenScale(45.2), psi_bar_bg_color, TEXT_ALIGN_BOTTOM, TEXT_ALIGN_RIGHT)

    --stim count
    surface.SetDrawColor(Color(255,255,255, stim_alpha))
    surface.SetMaterial(Material("vgui/stimlogo.png"))
    surface.DrawTexturedRect( ScreenScale(11), ScrH() - ScreenScale(63), ScreenScale(12), ScreenScale(12) )
    draw.SimpleText(stim_amount > 99 and "99+" or stim_amount, "GModToolSubtitle", ScreenScale(22), ScrH() - ScreenScale(62), Color(255, 255, 255, stim_alpha), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_RIGHT)

    if stim_amount > 0 then
        stim_alpha = math.Approach(stim_alpha, 255, 255 * FrameTime() / 0.5)
    else
        stim_alpha = math.Approach(stim_alpha, 0, 255 * FrameTime() / 1)
    end
end
hook.Add("HUDPaint", "namjepsi_hud", namjepsi_hud)

local function namjepsi_hand_ui(hands)
    local bone = hands:LookupBone("ValveBiped.Bip01_L_Hand") or hands:LookupBone("L Hand")
    if bone == nil then return end
    local hand = hands:GetBoneMatrix(bone)

    if hand then
        if namjepsi.casting then
            cast_alpha = math.Approach(cast_alpha, 255, 255 * FrameTime() / .5)
        else
            cast_alpha = math.Approach(cast_alpha, 0, 255 * FrameTime() / .5)
        end

        local ability
        if namjepsi.current_slot then
            ability = namjepsi.abilities[LocalPlayer().namjepsi_slots[namjepsi.current_slot]]
        end

        local pos, ang = ((hand:GetTranslation() + hand:GetAngles():Forward() * 2.8)  + hand:GetAngles():Right() * 2.1) + hand:GetAngles():Up() * 2.5, hand:GetAngles()
        ang:RotateAroundAxis(hand:GetAngles():Forward(),90)
        ang:RotateAroundAxis(hand:GetAngles():Right(), -28)

        cam.Start3D2D(pos, ang, 0.1)
        --draw.SimpleText("Energy: " .. math.floor(energy) .. "%", "GModToolHelp", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        --draw.SimpleText("Stim: " .. (stim_amount > 99 and "99+" or stim_amount), "GModToolHelp", 0, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(Color(78, 75, 66, math.Clamp(cast_alpha, 0, 155)))
        surface.DrawRect(0, 0, 30, 30)

        surface.SetDrawColor(ability and Color(ability.theme.r, ability.theme.g, ability.theme.b, cast_alpha) or Color(150,150,150, cast_alpha))
        surface.SetMaterial(Material("vgui/gradient.png"))
        surface.DrawTexturedRect( 0, 0, 30, 30 )

        surface.SetDrawColor(Color(255, 255 ,255, cast_alpha))
        surface.SetMaterial(ability and Material(ability.icon) or Material("vgui/noability.png"))
        surface.DrawTexturedRect( 0, 0, 30, 30 )

        cam.End3D2D()
    end
end
hook.Add("PostDrawPlayerHands", "namjepsi_hand_ui", function()
    namjepsi_hand_ui(LocalPlayer():GetHands())
end)