namjepsi.abilities["ghost"] = {
	intName = "ghost",
	name = "Ghost",
	desc = "Render yourself invisible and undetectable",
	theme = Color(168,53,143),
	icon = "vgui/namjepsi_abilities/ghost.png",

	adminOnly = false,
	castType = 2,
	targeting = 2,
	range = 500,
	channelRange = 800,
	radius = 0,
	cooldown = 4,
	cost = function(ply, ...)
		return 3
	end,

	channelStart = function(ply)
		if CLIENT then
			ply:ScreenFade( SCREENFADE.IN, Color( 190, 58, 190, 50), .6, 0 )
			local cc = {
				["$pp_colour_addr"] = 0.2,
				["$pp_colour_addg"] = 0.1,
				["$pp_colour_addb"] = 0.2,
				["$pp_colour_brightness"] = -0.12,
				["$pp_colour_contrast"] = 1.1,
				["$pp_colour_colour"] = 1.2,
				["$pp_colour_mulr"] = 0,
				["$pp_colour_mulg"] = 0,
				["$pp_colour_mulb"] = 0
			}
			hook.Add( "RenderScreenspaceEffects", "namjepsi_ghost", function()
				DrawSharpen( 1, 1 )
				DrawColorModify( cc )
			end)
		end
		if SERVER then
			ply:SetNoDraw(true)
			ply:SetNoTarget(true)
		end
	end,

	channelEnd = function(ply)
		if CLIENT then
			hook.Remove( "RenderScreenspaceEffects", "namjepsi_ghost" )
			ply:ScreenFade( SCREENFADE.IN, Color( 190, 58, 190, 50), .6, 0 )
		end
		if SERVER then
			ply:SetNoDraw(false)
			ply:SetNoTarget(false)
		end
	end,
}