if not DrGBase then -- return if DrGBase isn't installed
	return
end

ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)
ENT.PrintName = "Neco Arc Clone"
ENT.Models = {"models/linux55/necoarc_animated/necoarc1.mdl"}
ENT.Category = "Melty Blood"
ENT.ModelScale = 1
ENT.BloodColor = BLOOD_COLOR_RED
ENT.CollisionBounds = Vector(10, 12, 100)
ENT.Spawnable = false
ENT.SpawnHealth = 70
ENT.RangeAttackRange = 850
ENT.MeleeAttackRange = 100
ENT.ReachEnemyRange = 20
ENT.AvoidEnemyRange = 30
ENT.Factions = {"FACTION_BURENNYU"}
ENT.EyeBone = "head_JNT"
ENT.EyeOffset = Vector(7.5, 0, 5)
-- Possession --
ENT.PossessionCrosshair = true
ENT.PossessionEnabled = false
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

function ENT:OnRemove()
	timer.Remove("redditor")
end

function ENT:Youfuckingrepeater()
	self:Timer(4, function() if self.CanPhone == nil then self.CanPhone = true end end)
end

ENT.PossessionBinds = {
	[IN_RELOAD] = {
		{
			coroutine = true,
			onkeydown = function(self)
				local ply = self:GetPossessor()
				if ply:KeyDown(IN_BACK) then
					self:PlaySequenceAndMove("neco_dodge4", 1, self.PossessionFaceForward)
				elseif ply:KeyDown(IN_MOVELEFT) then
					self:PlaySequenceAndMove("neco_dodge2", 1, self.PossessionFaceForward)
				elseif ply:KeyDown(IN_MOVERIGHT) then
					self:PlaySequenceAndMove("neco_dodge1", 1, self.PossessionFaceForward)
				elseif ply:KeyDown(IN_FORWARD) then
					self:PlaySequenceAndMove("neco_dodge3", 1, self.PossessionFaceForward)
				end
			end
		}
	},
	[KEY_F] = {
		{
			coroutine = true,
			onbuttondown = function(self, ply)
				self:EmitSound("Neco-Arc/neco30.wav", 400)
				self:SetSkin(1)
				timer.Create("redditor", 0, 28, function()
					ParticleEffectAttach("SEVV_FREES_LINUX_BEAM1", PATTACH_POINT_FOLLOW, self, 3)
					self:EyeDamage()
				end)

				self:PlaySequenceAndMove("neco_eyes", 1, self.PossessionFaceForward)
				self:SetSkin(0)
				timer.Remove("redditor")
			end
		}
	},
	[KEY_2] = {
		{
			coroutine = true,
			onbuttondown = function(self, ply)
				self:EmitSound("Neco-Arc/neco95.wav")
				self:PlaySequenceAndMove("neco_summon", 1, self.PossessionFaceForward)
			end
		}
	},
	[KEY_G] = {
		{
			coroutine = true,
			onbuttondown = function(self, ply)
				if self.CanPhone == true then
					local enemy = self:GetClosestEnemy()
					if IsValid(enemy) then
						self:VOX_ATTACK()
						self:Get_PHONE()
						self:PlaySequenceAndMove("neco_phone", 1, self.PossessionFaceForward)
						enemy:TakeDamage(5815, self, self)
						ParticleEffect("SEVV_FREES_LINUX_GODBEAM", enemy:GetPos(), self:GetAngles())
						enemy:EmitSound("Neco-Arc/neco33.wav", 500)
						self.CanPhone = nil
						self.ExtraGunModel1:Remove()
						self:Youfuckingrepeater()
					end
				end
			end
		}
	},
	[KEY_4] = {
		{
			coroutine = true,
			onbuttondown = function(self, ply)
				self:EmitSound("Neco-Arc/nya.wav")
				self:PlaySequenceAndMove("neco_dance", 1, self.PossessionFaceForward)
			end
		}
	},
	[IN_JUMP] = {
		{
			coroutine = true,
			onkeydown = function(self)
				self:Timer(0, function()
					if not self:IsOnGround() then return end
					self:Jump(170, 1, self.PossessionFaceForward)
					self:SetVelocity(self:GetForward() * 700 + self:GetUp() * 550)
				end)
			end
		}
	},
	[IN_DUCK] = {
		{
			coroutine = true,
			onkeydown = function(self) self:BurrowTo(self:PossessorTrace().HitPos) end
		}
	},
	[IN_ATTACK] = {
		{
			coroutine = true,
			onkeydown = function(self)
				local ply = self:GetPossessor()
				self:AttackSky()
				if not self:IsOnGround() then return end
				if ply:KeyDown(IN_SPEED) then
					ParticleEffectAttach("SEVV_FREES_LINUX_ATTACK", PATTACH_POINT_FOLLOW, self, 1)
					self:PlaySequenceAndMove("neco_attack" .. math.random(1, 3), 1, self.PossessionFaceForward)
				elseif not ply:KeyDown(IN_SPEED) and not ply:KeyDown(IN_ATTACK2) then
					self:PlaySequenceAndMove("neco_kick", 1, self.PossessionFaceForward)
				end
			end
		}
	}
}

function ENT:AttackSky()
	local ply = self:GetPossessor()
	if not self:IsOnGround() then
		ParticleEffectAttach("SEVV_FREES_LINUX_ATTACK", PATTACH_POINT_FOLLOW, self, 1)
		self:PlaySequenceAndMove("neco_drill", 1, self.PossessionFaceForward)
	elseif ply:KeyDown(IN_ATTACK2) then
		self:Jump(100)
		self:EmitSound("Neco-Arc/neco95.wav", 600)
		ParticleEffectAttach("SEVV_FREES_LINUX_SPLODE", PATTACH_POINT_FOLLOW, self, 1)
		self:PlaySequenceAndMove("neco_slam", 1, self.PossessionFaceForward)
	end
end

function ENT:OnLandOnGround()
	self:CallInCoroutine(function(self, delay)
		if delay > 0.1 then return end
		ParticleEffectAttach("SEVV_FREES_LINUX_SLAM", PATTACH_POINT_FOLLOW, self, 1)
	end)
end

function ENT:Get_PHONE()
	self.ExtraGunModel1 = ents.Create("bodybonemerge")
	self.ExtraGunModel1:SetModel("models/Items/battery.mdl")
	self.ExtraGunModel1:SetOwner(self)
	self.ExtraGunModel1:SetParent(self)
	self.ExtraGunModel1:Fire("SetParentAttachment", "necohand")
	self.ExtraGunModel1:SetLocalPos(self:GetAttachment(self:LookupAttachment("necohand")).Pos)
	self.ExtraGunModel1:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self.ExtraGunModel1:Spawn()
	self.ExtraGunModel1:SetModelScale(1)
	self.ExtraGunModel1:SetMaterial("")
	self.ExtraGunModel1:Activate()
	self.ExtraGunModel1:SetSolid(SOLID_NONE)
	self:DeleteOnRemove(self.ExtraGunModel1)
end

ENT.OnIdleSounds = {"Neco-Arc/idle1.wav", "Neco-Arc/idle2.wav", "Neco-Arc/idle3.wav", "Neco-Arc/idle4.wav", "Neco-Arc/idle5.wav", "Neco-Arc/idle6.wav"}
ENT.OnDamageSounds = {"Neco-Arc/pain1.wav", "Neco-Arc/pain2.wav", "Neco-Arc/pain3.wav", "Neco-Arc/pain4.wav"}
function ENT:Ishittedmyself()
	self:EmitSound("ser/rmine_shockvehicle2.wav", 75, 200, 14)
end

function ENT:BurrowTo(pos)
	ParticleEffectAttach("SEVV_FREES_LINUX_DUST", PATTACH_POINT_FOLLOW, self, 1)
	self:PlaySequenceAndMove("neco_enter")
	if navmesh.IsLoaded() then pos = navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos) or pos end
	self:SetPos(pos)
	self:DropToFloor()
	ParticleEffectAttach("SEVV_FREES_LINUX_DUST", PATTACH_POINT_FOLLOW, self, 1)
	self:PlaySequenceAndMove("neco_exit")
	self:Jump("300")
end

function ENT:NECO_ATK1()
	self:VOX_ATTACK()
	self:Attack({
		damage = 80,
		viewpunch = Angle(4060, 4060, 4060),
		type = DMG_BLAST,
		range = 100,
		force = Vector(1000600, 660, 900600)
	}, function(self, hit)
		self:PushEntity(hit, Vector(60, 60, 70))
		if #hit > 0 then self:EmitSound("npc/fast_zombie/claw_strike" .. math.random(1, 3) .. ".wav") end
	end)
end

function ENT:EyeDamage()
	self:Attack({
		damage = 418,
		range = 630,
		delay = 0,
		radius = 350,
		force = Vector(800, 100, 100),
		type = DMG_BULLET,
		viewpunch = Angle(30, math.random(-16, 20), 0),
	}, function(self, hit)
		self:PushEntity(hit, Vector(80, 90, 4))
		if #hit > 0 then
			self:EmitSound("npc/fast_zombie/claw_strike" .. math.random(1, 3) .. ".wav")
		else
		end
	end)
end

function ENT:VOX_ATTACK()
	if not self:GetCooldown("VOX1") then return end
	if self:GetCooldown("VOX1") == 0 then
		self:SetCooldown("VOX1", 1)
		self:EmitSound("Neco-Arc/attack" .. math.random(1, 19) .. ".wav")
	end
end

function ENT:NECO_ATK2()
	self:VOX_ATTACK()
	self:Attack({
		damage = 80,
		viewpunch = Angle(4060, 4060, 4060),
		type = DMG_BLAST,
		range = 100,
		force = Vector(1000600, 660, 900600)
	}, function(self, hit)
		self:PushEntity(hit, Vector(700, 700, 80))
		if #hit > 0 then self:EmitSound("npc/fast_zombie/claw_strike" .. math.random(1, 3) .. ".wav") end
	end)
end

function ENT:NECO_ATK3()
	self:VOX_ATTACK()
	self:Attack({
		damage = 180,
		viewpunch = Angle(4060, 4060, 4060),
		type = DMG_BLAST,
		range = 200,
		angle = 400,
		force = Vector(1000600, 660, 900600)
	}, function(self, hit)
		self:PushEntity(hit, Vector(70, 70, 680))
		if #hit > 0 then self:EmitSound("npc/fast_zombie/claw_strike" .. math.random(1, 3) .. ".wav") end
	end)
end

function ENT:Step()
	self:EmitSound("Neco-Arc/footstep0" .. math.random(1, 5) .. ".wav")
end

if SERVER then
	function ENT:CustomInitialize()
		self:SequenceEvent("neco_dodge1", 2 / 10, self.Step)
		self:SequenceEvent("neco_dodge2", 2 / 10, self.Step)
		self:SequenceEvent("neco_dodge3", 2 / 10, self.Step)
		self:SequenceEvent("neco_dodge4", 2 / 10, self.Step)
		self.IdleAnimation = "neco_idle"
		self.RunAnimation = "neco_run"
		self.WalkAnimation = "neco_walk"
		self.JumpAnimation = "neco_jump"
		self.RunSpeed = 301
		self.WalkSpeed = 100
		self:SetDefaultRelationship(D_HT)
		self:SequenceEvent("neco_slam", 1.4 / 10, self.NECO_ATK3)
		self:SequenceEvent("neco_walk", 2.3 / 10, self.Step)
		self:SequenceEvent("neco_walk", 5.11 / 10, self.Step)
		self:SequenceEvent("neco_run", 2 / 10, self.Step)
		self:SequenceEvent("neco_run", 5.4 / 10, self.Step)
		self:SequenceEvent("neco_attack1", 3.4 / 10, self.NECO_ATK1)
		self:SequenceEvent("neco_attack2", 3.4 / 10, self.NECO_ATK2)
		self:SequenceEvent("neco_attack3", 3.4 / 10, self.NECO_ATK1)
		self:SequenceEvent("neco_attack3", 5.4 / 10, self.NECO_ATK1)
		self:SequenceEvent("neco_kick", 1.4 / 10, self.NECO_ATK2)
		self:SequenceEvent("neco_drill", 1 / 4, self.NECO_ATK1)
		self:SequenceEvent("neco_drill", 2 / 4, self.NECO_ATK2)
		self:SequenceEvent("neco_drill", 3 / 4, self.NECO_ATK1)
		self:SequenceEvent("neco_drill", 4 / 4, self.NECO_ATK1)
		self.CanPhone = true
	end

	ENT.RunAnimRate = 2
	ENT.WalkAnimRate = 2
	function ENT:NecoArc_ATTACKe_NPC(enemy)
		self:NecoArc_NPC_dodge(enemy)
		self:AttackSky_1()
		local terma = math.random(3)
		if terma == 1 then
			self:Jump(100)
			self:EmitSound("Neco-Arc/neco95.wav", 600)
			ParticleEffectAttach("SEVV_FREES_LINUX_SPLODE", PATTACH_POINT_FOLLOW, self, 1)
			self:PlaySequenceAndMove("neco_slam", 1, self.FaceEnemy)
		end

		if terma == 2 then
			ParticleEffectAttach("SEVV_FREES_LINUX_ATTACK", PATTACH_POINT_FOLLOW, self, 1)
			self:PlaySequenceAndMove("neco_attack" .. math.random(1, 3), 1, self.FaceEnemy)
		end

		if terma == 3 then
			ParticleEffectAttach("SEVV_FREES_LINUX_ATTACK", PATTACH_POINT_FOLLOW, self, 1)
			self:PlaySequenceAndMove("neco_kick", 1, self.FaceEnemy)
		end
	end

	function ENT:AttackSky_1()
		if not self:IsOnGround() then
			ParticleEffectAttach("SEVV_FREES_LINUX_ATTACK", PATTACH_POINT_FOLLOW, self, 1)
			self:PlaySequenceAndMove("neco_drill", 1, self.FaceEnemy)
		end
	end

	function ENT:NecoArc_NPC_SPECIAL(enemy)
		local terma = math.random(3)
		if terma == 1 then
			if not self:GetCooldown("Grab4") then return end
			if self:GetCooldown("Grab4") == 0 then
				self:SetCooldown("Grab4", 9.90)
				self:NecoPhone_1()
			end
		end

		if terma == 2 then
			if not self:GetCooldown("Grab4") then return end
			if self:GetCooldown("Grab4") == 0 then
				self:SetCooldown("Grab4", 7.21)
				self:EmitSound("Neco-Arc/neco30.wav", 400)
				self:SetSkin(1)
				timer.Create("redditor", 0, 28, function()
					ParticleEffectAttach("SEVV_FREES_LINUX_BEAM1", PATTACH_POINT_FOLLOW, self, 3)
					self:EyeDamage()
				end)

				self:PlaySequenceAndMove("neco_eyes", 1, self.PossessionFaceForward)
				self:SetSkin(0)
				timer.Remove("redditor")
			end
		end

		if terma == 3 then
			if not self:GetCooldown("Grab4") then return end
			if self:GetCooldown("Grab4") == 0 then
				self:SetCooldown("Grab4", 3.23)
				self:Neco_burrower()
			end
		end

		if terma == 4 then
			if not self:GetCooldown("Grab4") then return end
			if self:GetCooldown("Grab4") == 0 then
				self:SetCooldown("Grab4", 1.23)
				self:PlaySequence("dodge4", 1, self.FaceEnemy)
			end
		end
	end

	function ENT:NecoPhone_1()
		if self.CanPhone == true then
			local enemy = self:GetClosestEnemy()
			if IsValid(enemy) then
				self:VOX_ATTACK()
				self:Get_PHONE()
				self:PlaySequenceAndMove("neco_phone", 1, self.PossessionFaceForward)
				enemy:TakeDamage(5815, self, self)
				ParticleEffect("SEVV_FREES_LINUX_GODBEAM", enemy:GetPos(), self:GetAngles())
				enemy:EmitSound("Neco-Arc/neco33.wav", 500)
				self.CanPhone = nil
				self.ExtraGunModel1:Remove()
				self:Youfuckingrepeater()
			end
		end
	end

	function ENT:NecoArc_NPC_dodge(enemy)
		local terma = math.random(4)
		if terma == 1 then
			if not self:GetCooldown("Dodge") then return end
			if self:GetCooldown("Dodge") == 0 then
				self:SetCooldown("Dodge", 4.90)
				self:PlaySequence("dodge1", 1, self.FaceEnemy)
			end
		end

		if terma == 2 then
			if not self:GetCooldown("Dodge") then return end
			if self:GetCooldown("Dodge") == 0 then
				self:SetCooldown("Dodge", 3.21)
				self:PlaySequence("dodge2", 1, self.FaceEnemy)
			end
		end

		if terma == 3 then
			if not self:GetCooldown("Dodge") then return end
			if self:GetCooldown("Dodge") == 0 then
				self:SetCooldown("Dodge", 1.23)
				self:PlaySequence("dodge3", 1, self.FaceEnemy)
			end
		end

		if terma == 4 then
			if not self:GetCooldown("Dodge") then return end
			if self:GetCooldown("Dodge") == 0 then
				self:SetCooldown("Dodge", 1.23)
				self:PlaySequence("dodge4", 1, self.FaceEnemy)
			end
		end
	end

	ENT.SpotDuration = 130
	function ENT:SpawnTHE_Burennyuu(dmg, delay, hitgroup)
		if not self:GetCooldown("Turn1") then return end
		if self:GetCooldown("Turn1") == 0 then
			self:SetCooldown("Turn1", 1)
			self:SpawnTHE_Burennyuu2(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu3(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu4(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu5(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu6(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu2(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu3(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu4(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu5(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu6(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu2(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu2(dmg, delay, hitgroup)
			self:SpawnTHE_Burennyuu3(dmg, delay, hitgroup)
			local headcrab = ents.Create("funnieslinux55_necoarc2")
			if not IsValid(headcrab) then return end
			headcrab:SetPos(self:EyePos())
			headcrab:SetAngles(self:GetAngles())
			headcrab:Spawn()
			if IsValid(self:GetCreator()) then self:GetCreator():DrG_AddUndo(headcrab, "NPC", "Undone big fart explosion") end
		end
	end

	function ENT:SpawnTHE_Burennyuu2(dmg, delay, hitgroup)
		local headcrab = ents.Create("funnieslinux55_necoarc2")
		if not IsValid(headcrab) then return end
		headcrab:SetPos(self:EyePos())
		headcrab:SetAngles(self:GetAngles())
		headcrab:Spawn()
		if IsValid(self:GetCreator()) then self:GetCreator():DrG_AddUndo(headcrab, "NPC", "Undone big fart explosion") end
	end

	function ENT:SpawnTHE_Burennyuu3(dmg, delay, hitgroup)
		local headcrab = ents.Create("funnieslinux55_necoarc2")
		if not IsValid(headcrab) then return end
		headcrab:SetPos(self:EyePos())
		headcrab:SetAngles(self:GetAngles())
		headcrab:Spawn()
		if IsValid(self:GetCreator()) then self:GetCreator():DrG_AddUndo(headcrab, "NPC", "Undone big fart explosion") end
	end

	function ENT:SpawnTHE_Burennyuu4(dmg, delay, hitgroup)
		local headcrab = ents.Create("funnieslinux55_necoarc2")
		if not IsValid(headcrab) then return end
		headcrab:SetPos(self:EyePos())
		headcrab:SetAngles(self:GetAngles())
		headcrab:Spawn()
		if IsValid(self:GetCreator()) then self:GetCreator():DrG_AddUndo(headcrab, "NPC", "Undone big fart explosion") end
	end

	function ENT:SpawnTHE_Burennyuu5(dmg, delay, hitgroup)
		local headcrab = ents.Create("funnieslinux55_necoarc2")
		if not IsValid(headcrab) then return end
		headcrab:SetPos(self:EyePos())
		headcrab:SetAngles(self:GetAngles())
		headcrab:Spawn()
		if IsValid(self:GetCreator()) then self:GetCreator():DrG_AddUndo(headcrab, "NPC", "Undone big fart explosion") end
	end

	function ENT:SpawnTHE_Burennyuu6(dmg, delay, hitgroup)
		local headcrab = ents.Create("funnieslinux55_necoarc2")
		if not IsValid(headcrab) then return end
		headcrab:SetPos(self:EyePos())
		headcrab:SetAngles(self:GetAngles())
		headcrab:Spawn()
		if IsValid(self:GetCreator()) then self:GetCreator():DrG_AddUndo(headcrab, "NPC", "Undone big fart explosion") end
	end

	function ENT:OnMeleeAttack(enemy, ent)
		self:NecoArc_ATTACKe_NPC(enemy)
	end

	function ENT:OnRangeAttack(enemy)
		self:FaceTowards(enemy)
		self:NecoArc_NPC_dodge(enemy)
	end

	function ENT:OnOtherKilled()
		self:EmitSound("ser/rmine_blip3.wav", 910000000)
	end

	function ENT:Neco_Jumper(dmg, delay, hitgroup)
		if not self:GetCooldown("Turn1") then return end
		if self:GetCooldown("Turn1") == 0 then
			self:SetCooldown("Turn1", 2)
			self:Timer(0, function()
				if not self:IsOnGround() then return end
				self:Jump(170, 1, self.FaceEnemy)
				self:SetVelocity(self:GetForward() * 700 + self:GetUp() * 550)
			end)
		end
	end

	function ENT:CustomThink()
	end

	function ENT:OnIdle()
		self:AddPatrolPos(self:RandomPos(1900))
	end
end

function ENT:Neco_burrower()
	if self:GetEnemy():IsValid() then
		ParticleEffectAttach("SEVV_FREES_LINUX_DUST", PATTACH_POINT_FOLLOW, self, 1)
		self:PlaySequenceAndMove("neco_enter")
		local rigth = math.random(-50, 50)
		local left = math.random(-40, 50)
		local pos = self:GetEnemy():GetPos()
		self:SetPos(pos + Vector(left, right, 10))
		ParticleEffectAttach("SEVV_FREES_LINUX_DUST", PATTACH_POINT_FOLLOW, self, 1)
		self:PlaySequenceAndMove("neco_exit")
	end
end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)