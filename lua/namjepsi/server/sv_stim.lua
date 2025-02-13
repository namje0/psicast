function namjepsi.stim(len, ply)
	print("stimming!!!")
	if !IsValid(ply) or !ply:Alive() then return end
	local stim_count = ply:GetAmmoCount( "namje_psychostim" )
	local energy = ply:GetNW2Float("namjepsi_energy")
	local max_energy = ply:GetNW2Int("namjepsi_max_energy")

	if stim_count <= 0 or energy >= max_energy then return end

	ply:SetNW2Int("namjepsi_energy", math.Clamp(energy + max_energy * .4, 0, GetConVar("namjepsi_overcharge"):GetBool() and max_energy * 2 or max_energy))
	ply:RemoveAmmo(1, "namje_psychostim")
end
net.Receive("namjepsi_stim", namjepsi.stim)