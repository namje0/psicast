local slot_width_percent = 0.15
local function set_slot_ability(slot, ability_name)
    local player_slots = LocalPlayer().namjepsi_slots

    if !player_slots[slot] then return end

    player_slots[slot] = ability_name

    LocalPlayer().namjepsi_slots = player_slots
    print("changed ability for slot " .. slot .. " on client")
    PrintTable(LocalPlayer().namjepsi_slots)

    net.Start("namjepsi_update_slot")
    net.WriteUInt(slot, 3)
    net.WriteString(ability_name)
    net.SendToServer()
end

local function close_menu()
    if IsValid(namjepsi.psi_menu) then
        gui.EnableScreenClicker(false)
        namjepsi.psi_menu:Remove()
    end
end

local function create_ability_slot(parent, player_slot)
    local slot = LocalPlayer().namjepsi_slots[player_slot]
    local ability = namjepsi.abilities[slot]

    local slot_panel = vgui.Create("DPanel")
    slot_panel:SetSize(parent:GetWide() * slot_width_percent, parent:GetTall())

    function slot_panel:Paint(w, h)
        draw.RoundedBox( 0, 0, 0, w, h, Color( 192, 180, 150, 255 ) )
    end

    local gradient = vgui.Create("DImage", slot_panel)
    gradient:SetSize(slot_panel:GetWide(), slot_panel:GetTall())
    gradient:SetImage("vgui/gradient.png")
    gradient:SetImageColor(ability and ability.theme or Color( 150,150,150))

    local button = vgui.Create("DImageButton", slot_panel)
    button:SetSize(slot_panel:GetWide(), slot_panel:GetTall())
    button:Dock(FILL)
    button:SetImage(ability and ability.icon or "vgui/noability.png")
    button:SetColor(Color(78, 75, 66))
    function button:DoClick()
        ability_menu(player_slot)
    end

    return slot_panel
end

local function regen_slots(parent)
    local num_slots = LocalPlayer().namjepsi_slots
    if not num_slots then
        print("err")
        return
    end

    if namjepsi.psi_menu.slot_grid then namjepsi.psi_menu.slot_grid:Remove() end

    namjepsi.psi_menu.slot_grid = vgui.Create("DGrid", parent)
    namjepsi.psi_menu.slot_grid:SetPos(0, 0)
    namjepsi.psi_menu.slot_grid:SetCols(6)
    namjepsi.psi_menu.slot_grid:SetColWide(parent:GetWide() / 6)
    namjepsi.psi_menu.slot_grid:SetRowHeight(parent:GetTall())
    namjepsi.psi_menu.slot_grid:Dock(FILL)

    for i = 1, 6 do
        if i <= #num_slots then
            local slot = create_ability_slot(parent, i)
            namjepsi.psi_menu.slot_grid:AddItem(slot)
        else
            --inaccessible slot
            local slot = vgui.Create("DPanel")
            slot:SetSize(parent:GetWide() * slot_width_percent, parent:GetTall())

            function slot:Paint(w, h)
                draw.RoundedBox( 0, 0, 0, w, h, Color( 108, 108, 98, 255 ) )
            end

            namjepsi.psi_menu.slot_grid:AddItem(slot)
        end
    end
end

function ability_menu(slot)
    local ability_inventory = LocalPlayer().namjepsi_inv
    local startTime = SysTime()

    local back = vgui.Create("DButton", namjepsi.psi_menu)
    back:SetSize(ScrW(), ScrH())
    back:SetPos(0, 0)
    back:SetText("")
    function back:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
        Derma_DrawBackgroundBlur(self, startTime)
    end

    function back:DoClick()
        back:Remove()
    end

    local frame_width_percent = 0.4
    local frame_height_percent = 0.3
    local frame_width = ScrW() * frame_width_percent
    local frame_height = ScrH() * frame_height_percent

    local menu_panel = vgui.Create("DPanel", back)
    menu_panel:SetSize(frame_width, frame_height)
    menu_panel:SetPos((ScrW() / 2) - frame_width / 2, (ScrH() / 2) - frame_height / 2)
    menu_panel:DockPadding(4, 4, 4, 4)

    function menu_panel:Paint(w, h)
        draw.RoundedBox( 0, 0, 0, w, h, Color( 218, 212, 187, 255 ) )
    end

    local ability_grid = vgui.Create("DGrid", menu_panel)
    ability_grid:SetPos(0, 0)
    ability_grid:SetCols(6)
    ability_grid:SetColWide(menu_panel:GetWide() / 6)
    ability_grid:SetRowHeight(100)
    ability_grid:Dock(FILL)

    --empty slot
    local empty_panel = vgui.Create("DPanel")
    empty_panel:SetSize(80, 80)

    function empty_panel:Paint(w, h)
        draw.RoundedBox( 0, 0, 0, w, h, Color( 192, 180, 150, 255 ) )
    end

    local empty_gradient = vgui.Create("DImage", empty_panel)
    empty_gradient:SetSize(empty_panel:GetSize())
    empty_gradient:SetImage("vgui/gradient.png")
    empty_gradient:SetImageColor(Color( 150, 150, 150))

    local empty_button = vgui.Create("DImageButton", empty_panel)
    empty_button:SetSize(empty_panel:GetSize())
    empty_button:Dock(FILL)
    empty_button:SetImage("vgui/noability.png")
    empty_button:SetColor(Color(78, 75, 66))

    function empty_button:DoClick()
        set_slot_ability(slot, "none")
        back:Remove()
        regen_slots(namjepsi.psi_menu.slot_panel)
    end

    ability_grid:AddItem(empty_panel)

    for k, v in pairs(ability_inventory) do
        print(k,v)
        local ability = namjepsi.abilities[k]

        if !ability then continue end

        local ability_panel = vgui.Create("DPanel")
        ability_panel:SetSize(80, 80)

        function ability_panel:Paint(w, h)
            draw.RoundedBox( 0, 0, 0, w, h, Color( 192, 180, 150, 255 ) )
        end

        local gradient = vgui.Create("DImage", ability_panel)
        gradient:SetSize(ability_panel:GetSize())
        gradient:SetImage("vgui/gradient.png")
        gradient:SetImageColor(ability and ability.theme or Color( 65, 65, 65))

        local button = vgui.Create("DImageButton", ability_panel)
        button:SetSize(ability_panel:GetSize())
        button:Dock(FILL)
        button:SetImage(ability and ability.icon or "vgui/noability.png")
        button:SetColor(Color(78, 75, 66))

        function button:DoClick()
            set_slot_ability(slot, k)
            back:Remove()
            regen_slots(namjepsi.psi_menu.slot_panel)
        end

        ability_grid:AddItem(ability_panel)
    end
end

local function accent_bar(parent, close)
    local bar = vgui.Create( "DPanel", parent )
    bar:SetSize( parent:GetWide(), 20 )
    bar:Dock( TOP )
    bar:DockPadding( 0, 0, 0, 0 )

    function bar:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 0 ) )
    end

    local accent = vgui.Create( "DPanel", bar )
    accent:SetSize( 10, parent:GetTall() )
    accent:Dock( LEFT )
    accent:DockMargin( 0, 0, 4, 0 )

    function accent:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 78, 75, 66, 255 ) )
    end

    local label = vgui.Create( "DPanel", bar )
    label:SetSize( close and parent:GetWide() * .9 or parent:GetWide(), parent:GetTall() )
    label:Dock( LEFT )
    label:DockMargin( 0, 0, 4, 0 )

    function label:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 78, 75, 66, 255 ) )
    end

    if close then
        local close_button = vgui.Create( "DButton", bar )
        close_button:SetSize( 40, 20 )
        close_button:Dock( FILL )
        close_button:SetText( "X" )
        close_button:SetTextColor( Color( 255, 255, 255 ) )
        close_button:SetFont( "DermaDefault" )

        function close_button:Paint(w, h)
            draw.RoundedBox( 0, 0, 0, w, h, Color( 78, 75, 66, 255 ) )
        end

        function close_button:DoClick()
            close_menu()
        end
    end
end

local function open_menu()
    local startTime = SysTime()

    if IsValid(namjepsi.psi_menu) then
        return
    end

    gui.EnableScreenClicker(true)
    namjepsi.psi_menu = vgui.Create( "DFrame" )
    namjepsi.psi_menu:SetPos(0, 0)
    --namjepsi.psi_menu:Center()
    namjepsi.psi_menu:SetSize(ScrW(), ScrH())
    namjepsi.psi_menu:SetTitle("")
    namjepsi.psi_menu:SetDraggable(false)
    namjepsi.psi_menu:ShowCloseButton(false)
    namjepsi.psi_menu:SetDeleteOnClose(true)

    function namjepsi.psi_menu:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
        Derma_DrawBackgroundBlur(self, startTime)
    end

    function namjepsi.psi_menu:Think()
        if !IsValid(LocalPlayer()) or !LocalPlayer():Alive() then
            close_menu()
        end
    end

    local frame_width_percent = 0.4
    local frame_height_percent = 0.3
    local frame_width = ScrW() * frame_width_percent
    local frame_height = ScrH() * frame_height_percent

    local main_panel = vgui.Create("DPanel", namjepsi.psi_menu)
    main_panel:SetSize(frame_width, frame_height)
    main_panel:SetPos((ScrW() / 2) - frame_width / 2, (ScrH() / 2) - frame_height / 2)
    main_panel:DockPadding(4, 4, 4, 4)

    function main_panel:Paint(w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 0 ) )
    end

    accent_bar(main_panel, true)

    local slot_panel_height_percent = 0.35
    local slot_panel_height = frame_height * slot_panel_height_percent
    namjepsi.psi_menu.slot_panel = vgui.Create("DPanel", main_panel)
    --slot_panel:SetPos(5, 25)
    namjepsi.psi_menu.slot_panel:Dock(TOP)
    namjepsi.psi_menu.slot_panel:DockMargin( 0, 4, 0, 0 )
    namjepsi.psi_menu.slot_panel:SetSize(frame_width - 10, slot_panel_height)

    function namjepsi.psi_menu.slot_panel:Paint(w, h)
        draw.RoundedBox( 0, 0, 0, w, h, Color( 218, 212, 187, 255 ) )
    end

    regen_slots(namjepsi.psi_menu.slot_panel)

    local cost_panel_height_percent = 0.15
    local cost_panel_height = frame_height * cost_panel_height_percent
    local cost_panel = vgui.Create("DPanel", main_panel)
    --cost_panel:SetPos(5, 25)
    cost_panel:Dock(TOP)
    cost_panel:SetSize(frame_width - 10, cost_panel_height)
    cost_panel:DockMargin( 0, 0, 0, 16 )

    function cost_panel:Paint(w, h)
        draw.RoundedBox( 0, 0, 0, w, h, Color( 78, 75, 66, 255 ) )
    end

    accent_bar(main_panel, false)

    local stat_panel = vgui.Create("DPanel", main_panel)
    stat_panel:Dock(FILL)
    stat_panel:DockMargin( 0, 4, 0, 0 )

    function stat_panel:Paint(w, h)
        draw.RoundedBox( 0, 0, 0, w, h, Color( 218, 212, 187, 255 ) )
    end
end

list.Add( "DesktopWindows", {
    icon = "vgui/stimlogo.png",
    title = "PSI Menu",
    init = function() open_menu() end,
})