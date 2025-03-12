namjepsi.abilities["spawnbound"] = {
	intName = "spawnbound",
	name = "Spawnbound",
	desc = "Warp the target to a random spawn point",
	theme = Color(70,214,202),
	icon = "vgui/namjepsi_abilities/spawnbound.png",

	adminOnly = false,
	castType = 1,
	targeting = 2,
	range = 450,
	radius = 20,
	cooldown = 1,
	castAnim = "castself",
	cost = function(ply, ...)
		return 1
	end,

	effect = function(ply)
		if SERVER then
			local spawns = ents.FindByClass("info_player_start")
			local random_spawn = math.random(#spawns)

			local pos = spawns[random_spawn]:GetPos()

			ply:SetPos(pos)

			local effect_data = EffectData()
			effect_data:SetOrigin( pos )
			effect_data:SetNormal(pos )
			util.Effect( "balloon_pop", effect_data )
		end
	end
}