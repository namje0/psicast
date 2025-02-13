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
	range = 600,
	radius = 120,
	cooldown = 4.5,
	cost = function()
		return 25
	end,

	areaTargeting = function()
		return nil
	end,

	effect = function(ply, ...)
		local args = ...
		local pos = Vector(args[1], args[2], args[3])
		if CLIENT then
			print("test effect client")
		end
		if SERVER then
			print("test effect server")
			local effect_data = EffectData()
			effect_data:SetOrigin( pos )
			effect_data:SetNormal(pos )
			util.Effect( "Explosion", effect_data )
			util.BlastDamage( ply, ply, pos, 100, 100 )
		end
	end
}