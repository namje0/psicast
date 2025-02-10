local cd_alpha = 255
local stim_alpha = 255
local dose_alpha = 255

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
    --PSI bar
    local psi_bar_bg_color = Color(0,0,0, 120)
    local psi_bar_color = Color(38,68,200, 255)
    local psi_over_color = Color(255,0,255, 255)

    bar_length = psi_bar.w * math.Clamp(ply:GetNW2Float("namjepsi_energy") / ply:GetNW2Int("namjepsi_max_energy"), 0, 1)
    trail_length = math.Approach(trail_length, bar_length, FrameTime() * 70)
    if trail_length < bar_length then
        trail_length = bar_length
    end

    surface.SetDrawColor(psi_bar_bg_color)
    surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, psi_bar.w, psi_bar.h)

    surface.SetDrawColor(Color(138,68,200, 255))
    surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, trail_length, psi_bar.h)

    surface.SetDrawColor(psi_bar_color)
    surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, bar_length, psi_bar.h)
    local overEnergy = ply:GetNW2Float("namjepsi_energy") - ply:GetNW2Int("namjepsi_max_energy")
    if overEnergy > 0 then
        surface.SetDrawColor(psi_over_color)
        surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, psi_bar.w * (overEnergy / ply:GetNW2Int("namjepsi_max_energy")), psi_bar.h)
    end

    draw.SimpleText(math.floor(ply:GetNW2Float("namjepsi_energy")) .. "%", "GModToolHelp", ScreenScale(13), ScrH() - ScreenScale(45.2), Color(255, 255, 255, 255), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_RIGHT)

end
hook.Add("HUDPaint", "namjepsi_hud", namjepsi_hud)