local menu_frame = {
    w = ScreenScale(220),
    h = ScreenScale(150)
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
    local psi_panel = {}
    local ply = LocalPlayer()
    local slot_count = GetConVar("namjepsi_slot_amount"):GetInt()

    if !IsValid(ply) then return end
    if IsValid(psi_panel) then psi_panel:Remove() end

    --primary frame
    psi_panel.menu = vgui.Create( "DFrame" )
    psi_panel.menu:SetPos( ScrW() / 2 - (menu_frame.w / 2), ScrH() / 2 - (menu_frame.h / 2) )
    psi_panel.menu:SetSize( menu_frame.w, menu_frame.h )
    psi_panel.menu:SetTitle( "" )
    psi_panel.menu:SetBackgroundBlur( true )
    psi_panel.menu:SetVisible( true )
    psi_panel.menu:SetDraggable( false )
    psi_panel.menu:ShowCloseButton( false )
    psi_panel.menu:SetDeleteOnClose( true )
    psi_panel.menu:DockPadding(4,4,4,4)
    psi_panel.menu.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0,0,0, 0 ) )
    end

    --slot top bar
    local function slot_top_bar()
        psi_panel.top = vgui.Create( "DPanel", psi_panel.menu )
        psi_panel.top:SetSize( menu_frame.w, 20 )
        psi_panel.top:Dock( TOP )
        psi_panel.top:DockPadding( 0, 0, 0, 0 )
        psi_panel.top.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 0 ) )
        end

        psi_panel.accent = vgui.Create( "DPanel", psi_panel.top )
        psi_panel.accent:SetSize( 10, psi_panel.menu:GetTall() )
        psi_panel.accent:Dock( LEFT )
        psi_panel.accent:DockMargin( 0, 0, 4, 0 )
        psi_panel.accent.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, Color( 78, 75, 66, 255 ) )
        end

        psi_panel.label = vgui.Create( "DPanel", psi_panel.top )
        psi_panel.label:SetSize( psi_panel.menu:GetWide() * .85, psi_panel.menu:GetTall() )
        psi_panel.label:Dock( LEFT )
        psi_panel.label:DockMargin( 0, 0, 4, 0 )
        psi_panel.label.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, Color( 78, 75, 66, 255 ) )
        end

        psi_panel.close = vgui.Create( "DButton", psi_panel.top )
        psi_panel.close:SetSize( 40, 20 )
        psi_panel.close:Dock( FILL )
        psi_panel.close:SetText( "X" )
        psi_panel.close:SetTextColor( Color( 255, 255, 255 ) )
        psi_panel.close:SetFont( "DermaDefault" )
        psi_panel.close.DoClick = function()
            psi_panel.menu:Close()
        end
        psi_panel.close.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, Color( 78, 75, 66, 255 ) )
        end
    end

    slot_top_bar()

    --slot frame
    psi_panel.slot = vgui.Create( "DPanel", psi_panel.menu )
    psi_panel.slot:SetPos( 0, 30 )
    psi_panel.slot:SetSize( menu_frame.w, menu_frame.h * .2 )
    psi_panel.slot:CenterHorizontal()
    psi_panel.slot:Dock( TOP )
    psi_panel.slot:DockMargin( 0, 4, 0, 4 )
    psi_panel.slot.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 218, 212, 187, 255 ) )
    end

    --test tooltippanel
    local panel = vgui.Create( "Panel" )
    panel:SetSize( 100, 100 )
    panel:SetVisible( false )
    panel.Paint = function( self, width, height )
        surface.SetDrawColor( 255, 0, 0 )
        surface.DrawRect( 0, 0, width, height)
    end

    --slot text
    psi_panel.slot_text = vgui.Create( "DLabel", psi_panel.slot )
    psi_panel.slot_text:SetSize( 100, 20 )
    psi_panel.slot_text:SetPos( 0, 0 )

    --slot buttons
    --[[for i = 1, slot_count do
        local ability = ply.namjepsi_slots[i] == "none" and nil or namjepsi.abilities[ply.namjepsi_slots[i]]
--[[
        psi_panel["slot_" .. i] = vgui.Create( "DImageButton", psi_panel.slot )
        psi_panel["slot_" .. i]:SetSize( psi_panel.slot:GetWide() / 8, psi_panel.slot:GetTall() )
        psi_panel["slot_" .. i]:SetPos((i - 1) * (psi_panel.slot:GetWide() / 8), 0 )
        psi_panel["slot_" .. i]:SetImage( ability and ability.icon or "vgui/noability.png" )
        psi_panel["slot_" .. i]:SetTooltipPanel( panel )
        psi_panel["slot_" .. i]:SetTooltipDelay(0)
        psi_panel["slot_" .. i]:Dock( LEFT )
        psi_panel["slot_" .. i]:DockMargin( 0, 0, 0, 0 )
        psi_panel["slot_" .. i].Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, Color( 78, 75, 66, 255 ) )
        end
        psi_panel["slot_" .. i].DoClick = function()
            print(ply.namjepsi_slots[i])
        end
    end]]

    --cost/stats frame
    psi_panel.cost = vgui.Create( "DPanel", psi_panel.menu )
    psi_panel.cost:SetSize( menu_frame.w, menu_frame.h * .1 )
    psi_panel.cost:Dock( TOP )
    psi_panel.cost:DockMargin( 0, 0, 0, 4 )
    psi_panel.cost.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 78, 75, 66, 100 ) )
    end

    --slot top bar
    local function inv_top_bar()
        psi_panel.inv_top = vgui.Create( "DPanel", psi_panel.menu )
        psi_panel.inv_top:SetSize( menu_frame.w, 20 )
        psi_panel.inv_top:Dock( TOP )
        psi_panel.inv_top:DockPadding( 0, 0, 0, 0 )
        psi_panel.inv_top.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 0 ) )
        end

        psi_panel.accent = vgui.Create( "DPanel", psi_panel.inv_top )
        psi_panel.accent:SetSize( 10, psi_panel.menu:GetTall() )
        psi_panel.accent:Dock( LEFT )
        psi_panel.accent:DockMargin( 0, 0, 4, 0 )
        psi_panel.accent.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, Color( 78, 75, 66, 255 ) )
        end

        psi_panel.label = vgui.Create( "DPanel", psi_panel.inv_top )
        psi_panel.label:SetSize( psi_panel.menu:GetWide() * .85, psi_panel.menu:GetTall() )
        psi_panel.label:Dock( FILL )
        psi_panel.label.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, Color( 78, 75, 66, 255 ) )
        end
    end

    inv_top_bar()

    --inv frame
    psi_panel.inv = vgui.Create( "DPanel", psi_panel.menu )
    psi_panel.inv:SetSize( menu_frame.w, menu_frame.h * .6 )
    psi_panel.inv:CenterHorizontal()
    psi_panel.inv:AlignBottom()
    psi_panel.inv:Dock( FILL )
    psi_panel.inv:DockMargin( 0, 4, 0, 4 )
    psi_panel.inv.Paint = function( self, w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 218, 212, 187, 255 ) )
    end

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