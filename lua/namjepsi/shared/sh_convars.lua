CreateConVar( "namjepsi_enable", "1", FCVAR_ARCHIVE, "Enable casting and psi menu", 0, 1 )
CreateConVar( "namjepsi_slot_amount", "3", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Amount of active ability slots", 1, 6 )
CreateConVar( "namjepsi_save_inv_on_death", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Saves a player's ability inventory/slots on death", 0, 1 )
CreateConVar( "namjepsi_spawn_with_all_abilities", 1, FCVAR_ARCHIVE, "Spawns the player with all abilities available", 0, 1 )

CreateConVar( "namjepsi_energy_cap", 100, FCVAR_ARCHIVE + FCVAR_REPLICATED, "The maximum energy a player can have (Overcharge up to double this amount)", 1, 1000 )
CreateConVar( "namjepsi_overcharge", 1, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Excess energy gained will decay overtime, disable to remove excess energy", 0, 1 )

CreateConVar( "namjepsi_passive_regen", 1, FCVAR_ARCHIVE, "Enables passive energy regen", 0, 1 )
CreateConVar( "namjepsi_regen_rate", .5, FCVAR_ARCHIVE, "The energy regen rate for the passive regen", .1, 10 )


local function divider(parent)
    local divider = vgui.Create("DPanel", parent)
    divider:SetTall(4)
    return divider
end

local function namjepsi_main_settings(panel)
    panel:CheckBox( "Enabled", "namjepsi_enable" )
    panel:ControlHelp( "Enable or disable the casting system" )

    panel:NumSlider( "Ability Slots", "namjepsi_slot_amount", 1, 6, 0)
    panel:ControlHelp( "The amount of ability slots available to the player" )

    panel:CheckBox( "Save Inventory on Death", "namjepsi_save_inv_on_death" )
    panel:CheckBox( "Spawn with all Abilities", "namjepsi_spawn_with_all_abilities" )
end

local function namjepsi_energy_settings(panel)
    panel:NumSlider( "Energy Cap", "namjepsi_energy_cap", 1, 100, 0)

    panel:CheckBox( "Toggle overcharge", "namjepsi_overcharge" )
    panel:ControlHelp( "Excess energy gained will decay overtime, disable to remove excess energy" )

    divider(panel)

    panel:CheckBox( "Toggle Energy Regen", "namjepsi_passive_regen" )
    panel:ControlHelp( "Enable or disable passive regen up to maximum energy" )

    panel:NumSlider( "Energy Regen Rate", "namjepsi_regen_rate", .1, 10, 1)
end

local function namjepsi_menu()
    spawnmenu.AddToolMenuOption( "Options", "PSIcast", "namjepsi_main_menu", "Main", "", "", namjepsi_main_settings )
    spawnmenu.AddToolMenuOption( "Options", "PSIcast", "namjepsi_energy_menu", "Energy", "", "", namjepsi_energy_settings )
end

hook.Add( "PopulateToolMenu", "namjepsi_menu", namjepsi_menu )

cvars.AddChangeCallback("namjepsi_slot_amount", function(convar_name, value_old, value_new)
    print(convar_name, value_old, value_new)
end)