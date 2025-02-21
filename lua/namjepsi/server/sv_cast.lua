function namjepsi.cast(len, ply)
	if !IsValid(ply) or !ply:Alive() then return end

	local slot = net.ReadInt(4)
	local range = net.ReadInt(16)
	local ability = namjepsi.abilities[ply.namjepsi_slots[slot]]
	if !ability then error("Ability " .. ply.namjepsi_slots[slot] .. "not found!") return end

	print("casting " .. ply.namjepsi_slots[slot])

	range = range * 1.2

	--get target/pos
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
						mins = Vector( -40, -40, -24 ),
						maxs = Vector( 40, 40, 24 ),
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
		ability.effect(ply, target)
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
		ability.effect(ply, pos)
	end

	local cost = ability.cost()
	ply:SetNW2Float("namjepsi_energy", math.Clamp(ply:GetNW2Float("namjepsi_energy") - cost, 0, GetConVar("namjepsi_overcharge"):GetBool() and ply:GetNW2Int("namjepsi_max_energy") * 2 or ply:GetNW2Int("namjepsi_max_energy")))

	--CD
	ply.namjepsi_cooldowns[ability.intName] = CurTime() + ability.cooldown
end
net.Receive("namjepsi_cast", namjepsi.cast)

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