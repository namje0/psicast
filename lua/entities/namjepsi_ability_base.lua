AddCSLuaFile()

ENT.Type                     = "anim"
ENT.Base                     = "base_anim"
ENT.RenderGroup              = RENDERGROUP_TRANSLUCENT
ENT.PrintName                = "PSI Ability Base"
ENT.Category                 = "PSIcast - Abilities"
ENT.Spawnable		= false
ENT.AdminOnly = false
ENT.Icon = "vgui/stimlogo.png"

--The ability to give to the player when used by them
ENT.Ability = "test"
ENT.AbilityData = nil

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/Items/battery.mdl")

        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

        local phys = self:GetPhysicsObject()

        if (phys:IsValid()) then
            phys:Wake()
        end

        self:SetUseType(SIMPLE_USE)
    end

    function ENT:Use(activator, caller)
        if (activator:IsPlayer()) then
            if namjepsi.has_psi(activator, self.Ability) then
                activator:PrintMessage(HUD_PRINTTALK, "You already have this ability!")
                return true
            end
            namjepsi.give_psi(activator, self.Ability, false)
            activator:PrintMessage(HUD_PRINTTALK, namjepsi.abilities[self.Ability]["name"] .. " unlocked")
            self:Remove()
        end
    end
end

if CLIENT then
    function ENT:Initialize()
        self:Draw()
        self.alpha = 0
    end

    local function DrawIcon( pos, ang, scale, ability, flip, alpha )
        if ( flip ) then
            -- Flip the angle 180 degrees around the UP axis
            ang:RotateAroundAxis( Vector( 0, 0, 1 ), 180 )
        end

        cam.Start3D2D( pos, ang, scale )

        surface.SetDrawColor(Color(78, 75, 66, math.Clamp(alpha, 0, 155)))
        surface.DrawTexturedRect(-25, 0, 50, 50)

        surface.SetDrawColor(ability and Color(ability.theme.r, ability.theme.g, ability.theme.b, alpha) or Color(150,150,150, alpha))
        surface.SetMaterial(Material("vgui/gradient.png"))
        surface.DrawTexturedRect(-25, 0, 50, 50)

        surface.SetDrawColor(Color(255, 255 ,255, alpha))
        surface.SetMaterial(ability and Material(ability.icon) or Material("vgui/noability.png"))
        surface.DrawTexturedRect(-25, 0, 50, 50)

        cam.End3D2D()
    end

    function ENT:Draw()
        self:DrawModel()

        local pos = self:LocalToWorld(self:OBBCenter())
        local ang = Angle( 0, SysTime() * 100 % 360, 90 )
        local heightOffset = Vector(0, 0, 1) * 20  -- Adjust this value to change height
        pos = pos + heightOffset

        local local_player = LocalPlayer()
        local dist = local_player:GetPos():Distance(self:GetPos())
        local max_dist = 500

        if dist <= max_dist then
            local alpha = 0

            if dist <= max_dist then
                alpha = math.Clamp(255 * (max_dist - dist) / (max_dist / 3), 0, 255)
            else
                alpha = 255
            end

            self.alpha = alpha

            DrawIcon( pos, ang, 0.2, self.AbilityData, false, alpha )
            DrawIcon( pos, ang, 0.2, self.AbilityData, true, alpha )
        end
    end
end