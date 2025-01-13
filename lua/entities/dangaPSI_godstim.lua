AddCSLuaFile()

ENT.Type                     = "anim"
ENT.Base                     = "base_anim"
ENT.RenderGroup              = RENDERGROUP_TRANSLUCENT
ENT.PrintName                = "Lotta Hypos"
ENT.Category                 = "PSIcast"
ENT.Spawnable		= true
ENT.AdminOnly = true

if SERVER then

    AddCSLuaFile("shared.lua")

    function ENT:Initialize()
        self.Entity:SetModel("models/namje/psychostim.mdl")
        
        self.Entity:PhysicsInit(SOLID_VPHYSICS)
        self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
        self.Entity:SetSolid(SOLID_VPHYSICS)
        
        self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        
        local phys = self.Entity:GetPhysicsObject()
        
        if (phys:IsValid()) then
            phys:Wake()
        end

        self.Entity:SetUseType(SIMPLE_USE)
    end

    function ENT:Use(activator, caller)
        if (activator:IsPlayer()) then
            activator:GiveAmmo(50, "namje_psychostim")
            self.Entity:Remove()
        end
    end
end