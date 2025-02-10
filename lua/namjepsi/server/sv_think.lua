local function ply_think(ply)
	if !IsValid(ply) then return end
	if !ply:Alive() then return end

	if ply:GetNW2Bool("namjepsi_awakened") then
		player_energy = ply:GetNW2Float("namjepsi_energy")
		player_max_energy = ply:GetNW2Int("namjepsi_max_energy")

		player_energy = math.Approach(player_energy, player_max_energy, FrameTime() * 50)
		ply:SetNW2Float("namjepsi_energy", player_energy)
	end
end
hook.Add("PlayerPostThink", "namjepsi_ply_think", ply_think)