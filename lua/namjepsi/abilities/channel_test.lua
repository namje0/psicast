namjepsi.abilities["channel_test"] = {
	intName = "channel_test",
	name = "Channel Ability",
	desc = "Test test test, test",
	theme = Color(146,173,70),
	icon = "vgui/namjepsi_abilities/buckteeblast.png",

	adminOnly = false,
	castType = 2,
	targeting = { "player", "npc" },
	selfOnly = false,
	range = 500,
	channelRange = 550,
	radius = 0,
	cooldown = 4,
	cost = function()
		return 2
	end,

	channelStart = function(ply, ...)
		if CLIENT then
			print("channel start client")
			local target = ...
			local effect_data = EffectData()
			effect_data:SetOrigin( target:LocalToWorld(target:OBBCenter()) )
			effect_data:SetNormal( target:LocalToWorld(target:OBBCenter()) )
			util.Effect( "TeslaHitboxes", effect_data )
		end
	end,

	channelEnd = function(ply, ...)
		local target = ...
		if !IsValid(target) then return end
		if CLIENT then
			print("channel end client")
			local effect_data = EffectData()
			effect_data:SetOrigin(target:LocalToWorld(target:OBBCenter()))
			effect_data:SetNormal(target:LocalToWorld(target:OBBCenter()) )
			util.Effect( "VortDispel", effect_data )
			util.Effect( "HL1Gib", effect_data )
		end
		if SERVER then
			--[[local ent = ents.Create("prop_physics")
			ent:SetModel("models/props_junk/watermelon01.mdl")
			ent:SetPos(target:GetPos())
			ent:Spawn()]]
			target:EmitSound("weapons/physcannon/energy_disintegrate4.wav")
		end
	end,

	effect = function(ply, ...)
		local target = ...
		if !IsValid(target) then
			local ability = namjepsi.abilities["channel_test"]
			print("time to remove")
			if SERVER then
				namjepsi.end_channel(ply, ability)
			end
			--timer.Remove("namjepsi_" .. ability.intName .. "_channel_" .. ply:UserID())
			return
		end
		if CLIENT then
			print(target:GetMaxHealth())
		end
		if SERVER then
			local dmg = 10
			local d = DamageInfo()
			d:SetDamage( dmg )
			d:SetAttacker( ply )
			d:SetDamageType( DMG_DISSOLVE )

			target:EmitSound("ambient/energy/spark" .. math.random(1,6) .. ".wav")
			local effect_data = EffectData()
			effect_data:SetOrigin( target:LocalToWorld(target:OBBCenter()) )
			effect_data:SetNormal(target:LocalToWorld(target:OBBCenter()) )
			util.Effect( "VortDispel", effect_data )

			if target:Health() - dmg <= 0 then
				local ability = namjepsi.abilities["channel_test"]
				namjepsi.end_channel(ply, ability)
			end

			target:TakeDamageInfo( d )
		end
	end
}