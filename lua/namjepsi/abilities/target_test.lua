namjepsi.abilities["target_test"] = {
	intName = "target_test",
	name = "Test Ability",
	desc = "Test test test, test",
	theme = Color(207,80,186),
	icon = "vgui/namjepsi_abilities/buckteeblast.png",

	adminOnly = false,
	castType = "instant",
	targeting = { "player", "npc", "prop_physics" },
	selfOnly = false,
	range = 500,
	radius = 0,
	cooldown = 4.5,
	cost = function()
		return 25
	end,

	effect = function(ply, ...)
		local target = ...
		if (!IsValid(target)) then return end
		if CLIENT then
			print(target:GetMaxHealth())
		end
		if SERVER then
			target:EmitSound("ambient/levels/labs/electric_explosion1.wav")
			local d = DamageInfo()
			d:SetDamage( target:GetMaxHealth() * 2 )
			d:SetAttacker( ply )
			d:SetDamageType( DMG_DISSOLVE )
			target:TakeDamageInfo( d )
		end
	end
}