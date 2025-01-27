CreateConVar( "namjepsi_enable", "1", FCVAR_ARCHIVE, "Enable casting and psi menu", 0, 1 )
CreateConVar( "namjepsi_slot_amount", "3", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Amount of active ability slots", 1, 8 )
CreateConVar( "namjepsi_save_inv_on_death", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Saves a player's ability inventory/slots on death", 0, 1 )
CreateConVar( "namjepsi_spawn_with_all_abilities", "1", FCVAR_ARCHIVE, "Spawns the player with all abilities available", 0, 1 )

local function namjepsi_menu_settings( panel )
    panel:NumSlider( "Ability Slots", "namjepsi_slot_amount", 1, 8, 0)
    panel:CheckBox( "Save Inventory on Death", "namjepsi_save_inv_on_death" )
    panel:CheckBox( "Spawn with all Abilities", "namjepsi_spawn_with_all_abilities" )
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