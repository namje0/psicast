function namjepsi.end_channel(ply, ability, from_client)
	if !ability then error("Ability " .. ability.intName .. "not found!") return end
	timer.Remove("namjepsi_" .. ability.intName .. "_channel_" .. ply:UserID())
	if !ply.namjepsi_channel_args then return end
	ability.channelEnd(ply, ply.namjepsi_channel_args)
	ply.namjepsi_channel_args = nil
	ply.namjepsi_cooldowns[ability.intName] = CurTime() + ability.cooldown

	if !from_client then
		net.Start("namjepsi_end_channel")
		net.Send(ply)
	end
end

function namjepsi.cast(len, ply)
	if !IsValid(ply) or !ply:Alive() then return end

	local slot = net.ReadInt(4)
	local range = net.ReadInt(16)
	local ability = namjepsi.abilities[ply.namjepsi_slots[slot]]
	if !ability then error("Ability " .. ply.namjepsi_slots[slot] .. "not found!") return end

	if ply.namjepsi_channel_args then
		error("Attempted to cast ability while still channeling for " .. ply:Name())
		return
	end

	print("casting " .. ply.namjepsi_slots[slot])

	range = range * 1.2

	local args
	local target_entities = istable(ability.targeting)
	if target_entities then
		local net_target = net.ReadEntity()
		local self_target = net_target == ply and true or false
		local target
		local target_types = ability.targeting
		if ability.areaTargeting then
			target = ability.areaTargeting(ply, range, self_target)
		else
			if self_target then
				target = ply
			else
				local tr = util.TraceLine( {
					start = ply:GetShootPos(),
					endpos = ply:GetShootPos() + ply:GetAimVector() * range,
					filter = ply,
					mask = MASK_SHOT_HULL
				} )
				if ( !IsValid( tr.Entity ) ) then
					tr = util.TraceHull( {
						start = ply:GetShootPos(),
						endpos = ply:GetShootPos() + ply:GetAimVector() * range,
						filter = ply,
						mins = Vector( -10, -10, -8 ),
						maxs = Vector( 10, 10, 8 ),
						mask = MASK_SHOT_HULL
					} )
				end
				if (table.HasValue(target_types,"npc")) then
					if ( tr.Hit and tr.Entity:IsNPC()) then
						target = tr.Entity
					elseif ( tr.Hit and table.HasValue(target_types,tr.Entity:GetClass()) ) then
						target = tr.Entity
					end
				else
					if ( tr.Hit and table.HasValue(target_types,tr.Entity:GetClass()) ) then
						target = tr.Entity
					end
				end
			end
		end
		--[[local distance = ply:GetPos():Distance(target:GetPos())
		if distance > ability.range + 10 then
			target = nil
		end]]

		if !target then
			net.Start("namjepsi_invalid_cast")
			net.WriteString(ability.intName)
			net.Send(ply)
			print("Target cast for " .. ply:Name() .. " was invalid for " .. ability.intName)
			return
		elseif target != net_target then
			net.Start("namjepsi_invalid_cast")
			net.WriteString(ability.intName)
			net.Send(ply)
			print("Target cast for " .. ply:Name() .. " was at " .. target:EntIndex() .. " instead of expected " .. expected_target:EntIndex() .. " for " .. ability.intName)
			return
		end
		args = target
	else
		local pos
		if ability.areaTargeting then
			pos = ability.areaTargeting(ply, range)
		else
			local tr = util.TraceLine( {
				start = ply:GetShootPos(),
				endpos = ply:GetShootPos() + ply:GetAimVector() * math.floor(math.Clamp(range, 50, ability.range * 1.2)),
				filter = ply,
				mask = MASK_SHOT
			} )
			pos = tr.HitPos
		end

		if !pos then return end
		args = pos
	end

	if !args then return end
	local cost = ability.cost()

	if ability.castType == 1 then
		ability.effect(ply, args)
		ply:SetNW2Float("namjepsi_energy", math.Clamp(ply:GetNW2Float("namjepsi_energy") - cost, 0, GetConVar("namjepsi_overcharge"):GetBool() and ply:GetNW2Int("namjepsi_max_energy") * 2 or ply:GetNW2Int("namjepsi_max_energy")))
		ply.namjepsi_cooldowns[ability.intName] = CurTime() + ability.cooldown
	elseif ability.castType == 2 then
		ability.channelStart(ply, args)
		--[[hook.Add( "Think", "namjepsi_" .. ability.intName .. "_channel_" .. ply:UserID(), function()
			ability.effect(ply, args)
		end)]]
		ply.namjepsi_channel_args = args
		timer.Create("namjepsi_" .. ability.intName .. "_channel_" .. ply:UserID(), .2, 0, function()
			if ability.effect then
				ability.effect(ply, args)
			end
			ply:SetNW2Float("namjepsi_energy", math.Clamp(ply:GetNW2Float("namjepsi_energy") - cost, 0, GetConVar("namjepsi_overcharge"):GetBool() and ply:GetNW2Int("namjepsi_max_energy") * 2 or ply:GetNW2Int("namjepsi_max_energy")))
			if ply:GetNW2Float("namjepsi_energy") < cost then
				namjepsi.end_channel(ply, ability, false)
			end

			if ability.channelRange then
				if !IsValid(args) then return end
				local dist = ply:GetPos():Distance(type(args) != "Vector" and args:GetPos() or args)
				if dist > ability.channelRange then
					namjepsi.end_channel(ply, ability, false)
				end
			end
		end)
		hook.Add("DoPlayerDeath", "namjepsi_" .. ability.intName .. "_channel_death_" .. ply:UserID(), function(dead_ply)
			if dead_ply != ply then return end
			namjepsi.end_channel(ply, ability, false)
			hook.Remove("DoPlayerDeath", "namjepsi_" .. ability.intName .. "_channel_death_" .. ply:UserID())
		end)
	end
end
net.Receive("namjepsi_cast", namjepsi.cast)
net.Receive("namjepsi_end_channel", function(len, ply)
	local slot = net.ReadInt(4)
	local ability = namjepsi.abilities[ply.namjepsi_slots[slot]]
	if !ability then return end
	namjepsi.end_channel(ply, ability, true)
end)


net.Receive("namjepsi_update_slot", function(len, ply)
	if !IsValid(ply) then return end

	local player_slots = ply.namjepsi_slots
	local slot = net.ReadUInt(3)
	local ability = net.ReadString()

	if !player_slots[slot] then return end
	player_slots[slot] = ability

	ply.namjepsi_slots = player_slots
	print("changed ability for slot " .. slot .. " on server to " .. ability)
	PrintTable(ply.namjepsi_slots)
end)