local function ply_think(ply)
	if !IsValid(ply) then return end
	if !ply:Alive() then return end

	if ply:GetNW2Bool("namjepsi_awakened") then
		--cooldown
		local cooldowns = ply.namjepsi_cooldowns
		if cooldowns then
			for slot, time in pairs(cooldowns) do
				if time < CurTime() then
					print("cooldown complete for " .. slot)
					cooldowns[slot] = nil
					net.Start("namjepsi_complete_cd")
					net.WriteInt(slot, 8)
					net.Send(ply)
				end
			end
		end
		--energy regen/decay
		local approach_rate = 0
		if ply:InVehicle() and GetConVar("namjepsi_sitting_regen"):GetBool() then
			approach_rate = GetConVar("namjepsi_sitting_rate"):GetFloat()
		elseif GetConVar("namjepsi_passive_regen"):GetBool() then
			approach_rate = GetConVar("namjepsi_passive_rate"):GetFloat()
		end

		player_energy = ply:GetNW2Float("namjepsi_energy")
		player_max_energy = ply:GetNW2Int("namjepsi_max_energy")

		if player_energy > player_max_energy then
			if GetConVar("namjepsi_overcharge"):GetBool() then
				approach_rate = GetConVar("namjepsi_decay_rate"):GetFloat()
			else
				player_energy = player_max_energy
			end
		end

		if approach_rate > 0 then
			player_energy = math.Approach(player_energy, player_max_energy, FrameTime() * approach_rate)
			ply:SetNW2Float("namjepsi_energy", player_energy)
		end
	end
end
hook.Add("PlayerPostThink", "namjepsi_ply_think", ply_think)