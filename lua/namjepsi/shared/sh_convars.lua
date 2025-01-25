CreateConVar( "namjepsi_enable", "1", FCVAR_ARCHIVE, "Enable casting and psi menu" )
CreateConVar( "namjepsi_slot_amount", "3", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Amount of active ability slots" )

local function namjepsi_menu_settings( panel )
    panel:NumSlider( "Ability Slots", "namjepsi_slot_amount", 1, 10, 0)
end

local function namjepsi_menu()
    spawnmenu.AddToolMenuOption( "Options",
    "PSIcast",
    "namjepsi_menu",
    "Settings",
    "",
    "",
    namjepsi_menu_settings )
end

hook.Add( "PopulateToolMenu", "namjepsi_menu", namjepsi_menu )

cvars.AddChangeCallback("namjepsi_slot_amount", function(convar_name, value_old, value_new)
    print(convar_name, value_old, value_new)
end)