namjepsi.ability_effects["test"] = function(ply, pos, target)
	if CLIENT then
		print("test effect client")
	end
	if SERVER then
		print("test effect server")
		local effectdata = EffectData()
		effectdata:SetOrigin( pos )
		effectdata:SetNormal(pos )
		util.Effect( "cball_explode", effectdata )
	end
end