local function ply_think(ply)
	if !IsValid(ply) then return end
	if !ply:Alive() then return end

	if ply:GetNW2Bool("namjepsi_awakened") then
		--TODO: convars for energy regen
		local approach_rate = FrameTime() * .5

		player_energy = ply:GetNW2Float("namjepsi_energy")
		player_max_energy = ply:GetNW2Int("namjepsi_max_energy")

		--TODO: if convar for passive regen and sitting regen
		if ply:InVehicle() then
			approach_rate = approach_rate * 50
		end

		if player_energy > player_max_energy then
			approach_rate = FrameTime() * 5
		end

		player_energy = math.Approach(player_energy, player_max_energy, approach_rate)

		ply:SetNW2Float("namjepsi_energy", player_energy)
	end
end
hook.Add("PlayerPostThink", "namjepsi_ply_think", ply_think)