if not DrGBase then return end

AddCSLuaFile()

game.AddParticles("particles/sevv_linux_curse_stuff.pcf")

ENT.Base = "drgbase_nextbot"
ENT.PrintName = "Neco Arc"

ENT.Models = {"models/zaurzo_dughoo/necoarc_animated/necoarc1.mdl"}
ENT.Category = "Melty Blood"
ENT.ModelScale = 1

ENT.BloodColor = BLOOD_COLOR_RED
ENT.CollisionBounds = Vector(10, 12, 100)

ENT.SpawnHealth = 150000
ENT.RunAnimRate = 2
ENT.WalkAnimRate = 1
ENT.RangeAttackRange = 850
ENT.MeleeAttackRange = 100
ENT.ReachEnemyRange = 20
ENT.AvoidEnemyRange = 30
ENT.SpotDuration = 130

ENT.Factions = {"FACTION_BURENNYU"}

ENT.EyeBone = "head_JNT"
ENT.EyeOffset = Vector(7.5, 0, 5)

ENT.PossessionCrosshair = true
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_1DIR
ENT.PossessionViews = {
	{
		offset = Vector(0, 70, 30),
		distance = 190
	},
	{
		offset = Vector(15, 0, 8),
		distance = 0,
		eyepos = true
	}
}

ENT.OnIdleSounds = {"Neco-Arc/idle1.wav", "Neco-Arc/idle2.wav", "Neco-Arc/idle3.wav", "Neco-Arc/idle4.wav", "Neco-Arc/idle5.wav", "Neco-Arc/idle6.wav"}
ENT.OnDamageSounds = {"Neco-Arc/pain1.wav", "Neco-Arc/pain2.wav", "Neco-Arc/pain3.wav", "Neco-Arc/pain4.wav"}

local function createColorProxy(name)
    local funcName = 'Get' .. name .. 'Color'

	ENT[funcName] = function(self)
        return self:GetNWVector(name, false) or nil
    end

	if SERVER then return end

    name = 'Neco' .. name .. 'Color'

    local proxy = {
        name = name, 

        init = function(self, _, values)
            local r, g, b = string.match(values.default, "(%d+) (%d+) (%d+)")

            self.default = Color(r, g, b):ToVector()
            self.result = values.resultvar
        end,

        bind = function(self, mat, ent)
            local getColorFunc = ent[funcName]

            if not getColorFunc then 
                mat:SetVector(self.result, self.default)
            else
                mat:SetVector(self.result, getColorFunc(ent) or self.default)
            end
       end 
    }

	matproxy.Add(proxy)
end

createColorProxy('Shirt')
createColorProxy('Skirt')
createColorProxy('Eyes')
createColorProxy('Tail')
createColorProxy('Legs')
createColorProxy('Pupils')
createColorProxy('Skin')
createColorProxy('Hair')
createColorProxy('Ears')

DrGBase.AddNextbot(ENT)