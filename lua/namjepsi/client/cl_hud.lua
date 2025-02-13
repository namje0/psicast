local cd_alpha = 255
local stim_alpha = 255
local dose_alpha = 255
local bar_alpha = 255

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
    surface.SetDrawColor(Color(255,255,255, stim_alpha)) -- Set the drawing color
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