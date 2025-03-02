namjepsi.abilities["lockpick"] = {
	intName = "lockpick",
	name = "Lockpick",
	desc = "Unlocks and opens doors",
	theme = Color(77,197,117),
	icon = "vgui/namjepsi_abilities/lockpick.png",

	adminOnly = false,
	castType = 1,
	targeting = {"prop_door_rotating","func_door","func_door_rotating"},
	range = 400,
	radius = 0,
	cooldown = 5,
	cost = function()
		return 35
	end,

	effect = function(ply, ...)
		local target = ...
		if (!IsValid(target)) then return end
		if CLIENT then
		end
		if SERVER then
			if (target:GetInternalVariable( "m_bLocked" )) then
				target:Fire("unlock")
				target:EmitSound("npc/metropolice/gear" .. math.random(1, 6) .. ".wav")
			end
			target:Fire("Open")
		end
	end
}