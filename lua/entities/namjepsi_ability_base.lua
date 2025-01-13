AddCSLuaFile()

ENT.Type                     = "anim"
ENT.Base                     = "base_anim"
ENT.RenderGroup              = RENDERGROUP_TRANSLUCENT
ENT.PrintName                = "PSI Ability Base"
ENT.Category                 = "PSIcast - Abilities"
ENT.Spawnable		= true
ENT.AdminOnly = false
ENT.Icon = "vgui/stimlogo.png"

--The ability to give to the player when used by them
ENT.Ability = "test"

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
        --TODO: Add ability to player
        if (activator:IsPlayer()) then
            activator:GiveAmmo(1, "namje_psychostim")
            self:Remove()
        end
    end
end