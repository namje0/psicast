namjepsi.abilities["blink"] = {
	intName = "blink",
	name = "Blink",
	desc = "Short distance teleportation. Needs solid ground",
	theme = Color(75,143,207),
	icon = "vgui/namjepsi_abilities/blink.png",

	adminOnly = false,
	castType = 1,
	targeting = 1,
	range = 450,
	radius = 15,
	cooldown = 4,
	castAnim = "castself",
	cost = function(ply, ...)
		return 20
	end,

	areaTargeting = function(ply, range)
		local pos
		local hull_trace = util.TraceHull({
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:EyeAngles():Forward() * range,
			filter = ply,
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 71),
			mask = MASK_PLAYERSOLID
		});
		local ground_trace = util.TraceEntity({
			start = hull_trace.HitPos + Vector(0, 0, 1),
			endpos = hull_trace.HitPos - (ply:EyePos() - ply:GetPos() + Vector(0, 0, 100)),
			filter = ply
		}, ply);
		if ground_trace.Hit then
			if (hull_trace.Hit and hull_trace.HitNormal.z <= 0) then
				local ledge_forward = Angle(0, hull_trace.HitNormal:Angle().y, 0):Forward();
				local edge_trace = util.TraceEntity({
					start = hull_trace.HitPos - ledge_forward * 33 + Vector(0, 0, 40),
					endpos = hull_trace.HitPos - ledge_forward * 33,
					filter = ply
				}, ply);

				if (edge_trace.Hit and !edge_trace.AllSolid) then
					local clear_trace = util.TraceHull({
						start = hull_trace.HitPos,
						endpos = hull_trace.HitPos + Vector(0, 0, 35),
						mins = Vector(-16, -16, 0),
						maxs = Vector(16, 16, 1),
						filter = ply
					});
					if clear_trace.Hit then
						return nil
					end
					--pos = ground_trace.HitPos
				elseif !edge_trace.Hit then
					return nil
				end;
			end;
			pos = ground_trace.HitPos
			return pos
		else
			--[[
			local tr = util.TraceLine( {
				start = ply:GetShootPos(),
				endpos = ply:GetShootPos() + ply:GetAimVector() * namjepsi.range,
				filter = ply,
				mask = MASK_SHOT
			} )
			pos = tr.HitPos
			return pos]]
			return nil
		end
	end,

	effect = function(ply, ...)
		local args = ...
		if CLIENT then
			ply:ScreenFade( SCREENFADE.IN, Color(75,143,207, 50), .6, 0 )
		end
		if SERVER then
			local pos = Vector(args[1], args[2], args[3])
			ply:SetPos(pos)

			local effect_data = EffectData()
			effect_data:SetOrigin( pos )
			effect_data:SetNormal(pos )
			util.Effect( "balloon_pop", effect_data )
		end
	end
}