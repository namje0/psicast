local function ability_ui()
    local ply = LocalPlayer()
    if !IsValid(ply) then return end

    local inv = ply.namjepsi_inv
    if !inv then print("no inv") return end

    local w, h = ScrW(), ScrH()
    local size = 64
    local padding = 10
    local x = w - size - padding
    local y = h - size - padding

    for i = 1, 6 do
        local ability = inv["slot_" .. i]
        if ability then
            local ab = namjepsi.abilities[ability]
            if ab then
                surface.SetDrawColor(ab.theme)
                surface.SetMaterial(Material(ab.icon))
                surface.DrawTexturedRect(x, y, size, size)
            end
        end
        y = y - size - padding
    end
end

local function namjepsi_hud()
    if namjepsi.casting then
        ability_ui()
    end
end

hook.Add("HUDPaint", "namjepsi_hud", namjepsi_hud)