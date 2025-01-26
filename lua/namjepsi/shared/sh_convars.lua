CreateConVar( "namjepsi_enable", "1", FCVAR_ARCHIVE, "Enable casting and psi menu" )
CreateConVar( "namjepsi_slot_amount", "3", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Amount of active ability slots" )
CreateConVar( "namjepsi_save_inv_on_death", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Saves a player's ability inventory/slots on death" )
CreateConVar( "namjepsi_spawn_with_all_abilities", "1", FCVAR_ARCHIVE, "Spawns the player with all abilities available" )

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