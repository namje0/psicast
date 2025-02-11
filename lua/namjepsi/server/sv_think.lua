local function ply_think(ply)
	if !IsValid(ply) then return end
	if !ply:Alive() then return end

	if ply:GetNW2Bool("namjepsi_awakened") then
		--TODO: convars for energy regen
		local recharge_rate = FrameTime() * .5

		player_energy = ply:GetNW2Float("namjepsi_energy")
		player_max_energy = ply:GetNW2Int("namjepsi_max_energy")

		--TODO: if convar for passive regen and sitting regen
		if ply:InVehicle() then
			recharge_rate = recharge_rate * 50
		end

		player_energy = math.Approach(player_energy, player_max_energy, recharge_rate)

		ply:SetNW2Float("namjepsi_energy", player_energy)
	end
end
hook.Add("PlayerPostThink", "namjepsi_ply_think", ply_think)