function namjepsi.cast(len, ply)
	if !IsValid(ply) or !ply:Alive() then return end

	local slot = net.ReadDouble()
	local ability = namjepsi.abilities[ply.namjepsi_slots[slot]]
	if !ability then error("Ability " .. ply.namjepsi_slots[slot] .. "not found!") return end

	print("casting " .. ply.namjepsi_slots[slot])

	--get target/pos
	local target_entities = istable(ability.targeting)
	local pos, target
	if target_entities then
		print("target ent")
	else
		local tr = util.TraceLine( {
			start = ply:GetShootPos(),
			endpos = ply:GetShootPos() + ply:GetAimVector() * ability.range,
			filter = ply,
			mask = MASK_SHOT
		} )
		pos = tr.HitPos
		print(pos)
	end

	ability.effect(ply, pos)

	local cost = ability.cost()
	ply:SetNW2Int("namjepsi_energy", math.Clamp(ply:GetNW2Int("namjepsi_energy") - cost, 0, ply:GetNW2Int("namjepsi_max_energy")))
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