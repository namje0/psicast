local psi_panel = {}
local menu_frame = {
    w = ScreenScale(320),
    h = ScreenScale(222)
}

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

local function namjepsi_menu()
    local ply = LocalPlayer()
    if !IsValid(ply) then return end
    if IsValid(psi_panel) then psi_panel:Remove() end

    psi_panel.menu = vgui.Create( "DFrame" )
    psi_panel.menu:SetPos( ScrW() / 2 - (menu_frame.w / 2), ScrH() / 2 - (menu_frame.h / 2) )
    psi_panel.menu:SetSize( menu_frame.w, menu_frame.h )
    psi_panel.menu:SetTitle( "" )

    psi_panel.menu:SetBackgroundBlur( true )
    psi_panel.menu:SetVisible( true )
    psi_panel.menu:SetDraggable( false )
    psi_panel.menu:ShowCloseButton( true )
    psi_panel.menu:SetDeleteOnClose( true )

    gui.EnableScreenClicker( true )

    psi_panel.menu.OnClose = function()
        gui.EnableScreenClicker( false )
    end

    psi_panel.menu.Think = function()
        if !IsValid(ply) or !ply:Alive() then
            psi_panel.menu:Close()
        end
    end
end

hook.Add("HUDPaint", "namjepsi_hud", namjepsi_hud)

list.Add( "DesktopWindows", {
    icon = "vgui/stimlogo.png",
    title = "PSI Menu",
    init = function() namjepsi_menu() end,
})