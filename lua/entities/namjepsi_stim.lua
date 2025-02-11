AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.PrintName = "PSI Hypo"
ENT.Category = "PSIcast"
ENT.Spawnable = true
ENT.AdminOnly = false

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/danga1w1/psychostim.mdl")

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
            activator:GiveAmmo(1, "namje_psychostim")
            self:Remove()
        end
    end
end