AddCSLuaFile()

ENT.Base = 'base_anim'
ENT.Type = 'anim'

ENT.RenderGroup = RENDERGROUP_BOTH

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end

    ENT.DrawTranslucent = ENT.Draw
end