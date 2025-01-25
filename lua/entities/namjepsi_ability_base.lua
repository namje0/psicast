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