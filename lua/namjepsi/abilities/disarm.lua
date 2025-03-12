namjepsi.abilities["disarm"] = {
	intName = "disarm",
	name = "Disarm",
	desc = "Disarm the target, throwing their active weapon towards you. Cost based on target health, with players more expensive. Get out of there stalker!",
	theme = Color(80,207,148),
	icon = "vgui/namjepsi_abilities/disarm.png",

	adminOnly = false,
	castType = 1,
	targeting = { "player", "npc" },
	range = 500,
	radius = 0,
	cooldown = 4.5,
	castAnim = "castself",
	cost = function(ply, ...)
		local target = ...
		if IsValid(target) then
			if target:IsPlayer() then
				local has_wep = target:GetActiveWeapon()
				if IsValid(has_wep) then
					return math.Round(target:Health() * 2)
				else
					return nil
				end
			elseif target:IsNPC() then
				local has_wep = target:GetActiveWeapon()
				if IsValid(has_wep) then
					return math.Round(target:Health() * 1.5)
				else
					return nil
				end
			end
		else
			return nil
		end
	end,

	effect = function(ply, ...)
		local target = ...
		if (!IsValid(target)) then return end
		if SERVER then
			-- Some NPCs on some maps delete their weapons when the weapon is dropped, we don't want that.
			target:SetKeyValue( "spawnflags", bit.band( target:GetSpawnFlags(), bit.bnot( SF_NPC_NO_WEAPON_DROP ) ) )
			target:DropWeapon( nil, ply:GetPos() )
		end
	end
}