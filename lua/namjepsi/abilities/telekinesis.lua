namjepsi.abilities["telekinesis"] = {
	intName = "telekinesis",
	name = "Telekinesis",
	desc = "Grab objects. E to launch them. Can't grab heavier objects, and cost is based on weight",
	theme = Color(79,77,197),
	icon = "vgui/namjepsi_abilities/telekinesis.png",

	adminOnly = false,
	castType = 2,
	targeting = {"prop_physics", "prop_ragdoll"},
	range = 500,
	channelRange = 0,
	radius = 0,
	cooldown = 3,
	cost = function(ply, ...)
		local target = ...
		if IsValid(target) then
			local phys = target:GetPhysicsObject()
			if IsValid(phys) then
				local volume = target:OBBMaxs().x * target:OBBMaxs().y * target:OBBMaxs().z
				local mass = phys:GetMass();

				local max_volume = 25000;
				local max_mass = 300;

				if volume > max_volume or mass > max_mass then
					return nil
				end

				local normalized_vol = math.Clamp(volume / max_volume, 0, 1);
				local normalized_mass = math.Clamp(mass / max_mass, 0, 1);
				local weight = (normalized_mass - normalized_vol) * 0.5 + 0.5;

				return math.Round(math.Clamp((normalized_vol * (1 - weight) + normalized_mass * weight) * 5, .2, 5), 1)
			else
				target:PhysicsInit(6)
			end
			return nil
		else
			return nil
		end
	end,

	areaTargeting = function(ply, range)
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
		local target = tr.Entity
		if !IsValid(target) then
			return nil
		end
		local phys = target:GetPhysicsObject()
		if IsValid(phys) then
			local volume = target:OBBMaxs().x * target:OBBMaxs().y * target:OBBMaxs().z
			local mass = phys:GetMass();

			local max_volume = 25000;
			local max_mass = 300;
			if volume > max_volume or mass > max_mass then
				return nil
			else
				return target
			end
		else
			target:PhysicsInit(6)
		end
		return nil
	end,

	channelStart = function(ply, ...)
		local target = ...
		if CLIENT then
			hook.Add("PlayerBindPress", "namjepsi_telekinesis", function()
				if input.IsKeyDown(15) then
					net.Start("namjepsi_telekinesis_launch")
					net.SendToServer()
					return true
				end
			end)
		end
		if SERVER then
			net.Receive("namjepsi_telekinesis_launch", function(len, net_ply)
				if ply != net_ply then return end
				if !IsValid(target) then return end

				local ability = namjepsi.abilities["telekinesis"]
				if SERVER then
					namjepsi.end_channel(ply, ability)
				end

				local launch_speed = 1500
				target:GetPhysicsObject():SetVelocity(ply:GetAimVector() * launch_speed)
			end)

			hook.Add("Think", "namjepsi_telekinesis_" .. ply:UserID(), function()
				if !IsValid(ply) or !IsValid(target) then return end

				local phys = target:GetPhysicsObject()
				if !IsValid(phys) then return end

				if phys:IsAsleep() then
					phys:Wake()
				end

				local tr = util.TraceLine( {
					start = ply:GetShootPos(),
					endpos = ply:GetShootPos() + ply:GetAimVector() * 100,
					filter = {ply, target},
					mask = MASK_SHOT
				} )
				local target_pos = tr.HitPos

				local current_pos = target:LocalToWorld(target:OBBCenter())
				local delta_pos = target_pos - current_pos
				delta_pos.z = delta_pos.z + 3

				local velocity = delta_pos * 5

				phys:SetVelocity(velocity)
				local current_angles = phys:GetAngles()
				local target_angles = ply:EyeAngles()
				local new_angles = LerpAngle(FrameTime() * 10, current_angles, target_angles)
				phys:SetAngles(new_angles)
			end)
		end
	end,

	channelEnd = function(ply, ...)
		local target = ...
		if !IsValid(target) then
			return
		end
		if CLIENT then
			hook.Remove("PlayerBindPress", "namjepsi_telekinesis")
		end
		if SERVER then
			hook.Remove("Think", "namjepsi_telekinesis_" .. ply:UserID())
			--[[local launchSpeed = 1500 -- Adjust launch speed as needed
			local launchVector = ply:GetAimVector() * launchSpeed

			target:GetPhysicsObject():SetVelocity(launchVector)]]
			target:SetNetworkOrigin(target:GetPos())
			target:GetPhysicsObject():Wake()
		end
	end,

	effect = function(ply, ...)
		local target = ...
		if !IsValid(target) then
			local ability = namjepsi.abilities["telekinesis"]
			print("time to remove")
			if SERVER then
				namjepsi.end_channel(ply, ability)
			end
			return
		end
	end
}