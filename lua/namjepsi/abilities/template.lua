--redo it later

namjepsi.abilities["template"] = {
	intName = "test", --internal name for an ability
	name = "Test Ability", --display name for an ability
	desc = "Test test test, test",
	theme = Color(21,255,186,255), --color theme for the ability; used for highlights and icon color
	icon = "vgui/stimlogo.png", --icon should be white, since it will be colored by the theme

	adminOnly = false, --only affects the spawnable ability entity, which means players can use the ability if that was spawned for them
	castType = 1, --either 1 or "channel". instant abilities are casted immediately upon release, while channel abilities persist until +psicast is pressed again or energy runs out
	targeting = "area", --either "area" or a table of entities. area dictates a position the player is aiming at within the range, while target abilities affect a single target which can be any entity, including the caster if "player" is included in the table
	selfOnly = false, --whether the ability can only target the player casting it, only relevant if targeting is set to "target"
	range = 800, --maximum range the player can cast the ability
	radius = 120,
	cooldown = 3,
	cost = function(ply, ...)
		return 40
	end,

	effect = function(ply, pos, target)
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