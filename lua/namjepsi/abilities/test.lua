namjepsi.abilities["test"] = {
	intName = "test",
	name = "Test Ability",
	desc = "Test test test, test",
	theme = Color(21,255,186,255),
	icon = "vgui/stimlogo.png",

	adminOnly = false,
	castType = "instant",
	targeting = "Area",
	selfOnly = false,
	range = 800,
	radius = 120,
	cooldown = 3,
	cost = function()
		return 40
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
			util.Effect( "cball_explode", effect_data )
		end
	end
}