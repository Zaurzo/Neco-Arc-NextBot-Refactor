if not DrGBase then return end -- return if DrGBase isn't installed

AddCSLuaFile()

ENT.Base = "proj_drg_default"

-- Misc --
ENT.PrintName = "Plasma Ball"
ENT.Category = "DrGBase"
ENT.AdminOnly = false
ENT.Spawnable = false
ENT.Models = {"models/props_phx/ww2bomb.mdl"}
-- Physics --
ENT.Gravity = false
ENT.Physgun = false
ENT.Gravgun = true

-- Contact --
ENT.OnContactDecals = {"Scorch"}

-- Sounds --
ENT.OnRemoveSounds = {}

-- Effects --
ENT.AttachEffects = {"SEVV_FREES_LINUX_RING"}
ENT.OnContactEffects = {}

if SERVER then
    function ENT:CustomInitialize()
        self:SetNoDraw(true)
        self:DynamicLight(Color(255, 215, 0), 600, 1)
    end
    
    function ENT:CustomThink()
        ParticleEffectAttach("SEVV_FREES_LINUX_RING", PATTACH_ABSORIGIN_FOLLOW, self, 0)

        local phys = self:GetPhysicsObject()
        if not phys:IsValid() or phys:IsGravityEnabled() then return end

        self:SetVelocity(self:GetVelocity():GetNormalized() * 12600)
    end

    function ENT:Explode()
        self:EmitSound("Neco-Arc/neco35.wav", 9581, 100)

        util.ScreenShake(self:GetPos(), 10, 20, 3, 3200)
    end

    function ENT:OnContact(ent)
        self:Explode()
        self:Explosion(self:GetDamage(), self:GetRange())
        self:Remove() 
    end
end

function ENT:GetDamage()
    return math.Clamp(self:GetNW2Float("DrGBaseDamage", 680), 0, math.huge)
end

function ENT:GetRange()
    return math.Clamp(self:GetNW2Float("DrGBaseRange", 440), 0, math.huge)
end

function ENT:GetRadius()
    return math.Clamp(self:GetNW2Float("DrGBaseRadius", 44), 0, math.huge)
end