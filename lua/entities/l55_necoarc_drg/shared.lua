if not DrGBase then return end

AddCSLuaFile()

ENT.Base = "drgbase_nextbot"
ENT.PrintName = "Neco Arc"

ENT.Models = {"models/linux55/necoarc_animated/necoarc1.mdl"}
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

DrGBase.AddNextbot(ENT)