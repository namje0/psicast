namjepsi.abilities["targetTest"] = {
	intName = "targetTest",
	name = "Vaporize Target",
	desc = "Kill.",
	theme = Color(159,123,163),
	icon = "vgui/namjepsi_abilities/melon.png",

	adminOnly = false,
	castType = "instant",
	targeting = "Area",
	selfOnly = false,
	range = 1500,
	radius = 20,
	cooldown = 4,
	cost = function()
		return 12
	end,

	effect = function(ply, ...)
		local args = ...
		if CLIENT then
			print("test effect client")
		end
		if SERVER then
			local pos = Vector(args[1], args[2], args[3])
			local ent = ents.Create("prop_physics")
			ent:SetModel("models/props_junk/watermelon01.mdl")
			ent:SetPos(pos)
			ent:Spawn()

			local effect_data = EffectData()
			effect_data:SetOrigin( pos )
			effect_data:SetNormal(pos )
			util.Effect( "balloon_pop", effect_data )
		end
	end
}