namjepsi.abilities["phase_shift"] = {
	intName = "phase_shift",
	name = "Phase Shift",
	desc = "Enter another dimension, becoming invulnerable and moving faster",
	theme = Color(207,53,169),
	icon = "vgui/namjepsi_abilities/blink.png",

	adminOnly = false,
	castType = 2,
	targeting = { "player" },
	selfOnly = false,
	range = 500,
	channelRange = 800,
	radius = 0,
	cooldown = 4,
	cost = function()
		return 3
	end,

	channelStart = function(ply, ...)
		if CLIENT then
			ply:ScreenFade( SCREENFADE.IN, Color( 190, 58, 190, 50), .6, 0 )
			local cc = {
				["$pp_colour_addr"] = 0.4,
				["$pp_colour_addg"] = 0.2,
				["$pp_colour_addb"] = 0.4,
				["$pp_colour_brightness"] = -0.12,
				["$pp_colour_contrast"] = 1.1,
				["$pp_colour_colour"] = 1.2,
				["$pp_colour_mulr"] = 0,
				["$pp_colour_mulg"] = 0,
				["$pp_colour_mulb"] = 0
			}
			hook.Add( "RenderScreenspaceEffects", "namjepsi_ghost", function()
				DrawMaterialOverlay( "effects/tp_eyefx/tpeye2", 1 )
				DrawMaterialOverlay( "effects/tp_eyefx/tpeye2", 1 )
				DrawMaterialOverlay( "effects/tp_eyefx/tpeye2", 1 )
				DrawMaterialOverlay( "effects/tp_eyefx/tpeye2", 1 )
				DrawMaterialOverlay( "effects/tp_eyefx/tpeye2", 1 )
				DrawMaterialOverlay( "effects/tp_eyefx/tpeye2", 1 )
				DrawSharpen( 1, 1 )
				DrawColorModify( cc )
			end)
		end
		if SERVER then
			ply:SetNoDraw(true)
			ply:SetNoTarget(true)
			hook.Add( "Move", "namjepsi_ghost_move_" .. ply:UserID(), function( _, mv, usrcmd )
				local speed = mv:GetMaxSpeed() * 4
				mv:SetMaxSpeed( ply:GetWalkSpeed() * 4 )
				mv:SetMaxClientSpeed( ply:GetWalkSpeed() * 4 )
			end )

			hook.Add( "PlayerShouldTakeDamage", "namjepsi_ghost_dmg_" .. ply:UserID(), function(hook_ply)
				if hook_ply == ply then
					return false
				end
			end )

			hook.Add( "PlayerFootstep", "namjepsi_ghost_step_", function(hook_ply)
				if hook_ply == ply then
					return true
				end
			end )
		end
	end,

	channelEnd = function(ply, ...)
		if CLIENT then
			hook.Remove( "RenderScreenspaceEffects", "namjepsi_ghost" )
			ply:ScreenFade( SCREENFADE.IN, Color( 243, 53, 243), .6, 0 )
		end
		if SERVER then
			ply:SetNoDraw(false)
			ply:SetNoTarget(false)
			hook.Remove( "Move", "namjepsi_ghost_move_" .. ply:UserID() )
			hook.Remove( "PlayerShouldTakeDamage", "namjepsi_ghost_dmg_" .. ply:UserID() )
			hook.Remove( "PlayerFootstep", "namjepsi_ghost_step_" .. ply:UserID() )
		end
	end,
}