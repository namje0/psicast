namjepsi.abilities["test"] = {
	intName = "test",
	name = "Test Ability",
	desc = "Test test test, test",
	theme = Color(255,154,21),
	icon = "vgui/namjepsi_abilities/buckteeblast.png",

	adminOnly = false,
	castType = "instant",
	targeting = "Area",
	selfOnly = false,
	range = 500,
	radius = 100,
	cooldown = 4.5,
	cost = function()
		return 25
	end,

	effect = function(ply, ...)
		local args = ...
		if CLIENT then
			print("test effect client")
		end
		if SERVER then
			local pos = Vector(args[1], args[2], args[3])
			local ability = namjepsi.abilities["test"]
			local effect_data = EffectData()
			effect_data:SetOrigin( pos )
			effect_data:SetNormal(pos )
			util.Effect( "Explosion", effect_data )
			util.BlastDamage( ply, ply, pos, ability.radius, 100 )
		end
	end
}