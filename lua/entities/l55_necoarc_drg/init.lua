if not DrGBase then return end

include('shared.lua')

ENT.PhoneDelayTime = CurTime()

ENT.PossessionBinds = {
	[IN_ATTACK2] = {
		{
			coroutine = true,
			onkeydown = function(self) 
				self:ThrowRedRings(true) 
			end
		}
	},
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
				self:UseSpecialAttack(5, true) -- Eye laser attack
			end
		}
	},
	[KEY_X] = {
		{
			coroutine = true,
			onbuttondown = function(self, ply)
				self:UseSpecialAttack(4, true) -- Breath attack
			end
		}
	},
	[KEY_2] = {
		{
			coroutine = true,
			onbuttondown = function(self, ply)
				self:UseSpecialAttack(5, true) -- Summon attack
			end
		}
	},
	[KEY_G] = {
		{
			coroutine = true,
			onbuttondown = function(self, ply)
				self:UseSpecialAttack(1, true) -- Phone attack
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
			coroutine = false,
			onkeydown = function(self)
				if not self:IsOnGround() then return end

				self:Jump(170, 1, self.PossessionFaceForward)
				self:SetVelocity(self:GetForward() * 700 + self:GetUp() * 550)
			end
		}
	},
	[IN_DUCK] = {
		{
			coroutine = true,
			onkeydown = function(self) 
				self:BurrowTo(self:PossessorTrace().HitPos) 
			end
		}
	},
	[IN_ATTACK] = {
		{
			coroutine = true,
			onkeydown = function(self)
				self:AttackSky(true)

				if not self:IsOnGround() then return end

				local ply = self:GetPossessor()

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

ENT.SpecialAttacks = {
	[1] = function(self, ignoreCooldown) -- Phone attack
		local cooldown = self:GetCooldown("PhoneAttackCooldown")
		if not ignoreCooldown and (not cooldown or cooldown ~= 0) then return end

		self:SetCooldown("PhoneAttackCooldown", 10)
		self:PhoneAttack()
	end,

	[2] = function(self, ignoreCooldown) -- Eye laser attack
		local cooldown = self:GetCooldown("EyeLaserCooldown")
		if not ignoreCooldown and (not cooldown or cooldown ~= 0) then return end

		if self:GetCooldown("EyeLaserCooldown") == 0 then
			self:SetCooldown("EyeLaserCooldown", 7.21)
			self:EmitSound("Neco-Arc/neco30.wav", 400)
			self:SetSkin(1)
			
			timer.Create("EyeAttack", 0, 28, function()
				ParticleEffectAttach("SEVV_FREES_LINUX_BEAM1", PATTACH_POINT_FOLLOW, self, 3)

				self:EyeDamage()
			end)

			self:PlaySequenceAndMove("neco_eyes", 1, self.FaceEnemy)
			self:SetSkin(0)

			timer.Remove("EyeAttack")
		end
	end,

	[3] = function(self, ignoreCooldown) -- Burrow near enemy
		local cooldown = self:GetCooldown("BurrowCooldown")
		if not ignoreCooldown and (not cooldown or cooldown ~= 0) then return end

		self:SetCooldown("BurrowCooldown", 3.23)
		self:BurrowToEnemy()
	end,

	[4] = function(self, ignoreCooldown) -- Breath attack
		local cooldown = self:GetCooldown("BreathCooldown")
		if not ignoreCooldown and (not cooldown or cooldown ~= 0) then return end

		self:SetCooldown("BreathCooldown", 6.23)
		self:EmitSound("Neco-Arc/neco31.wav", 400)
		self:SetGodMode(true)

		timer.Create("BreathAttack", 0, 28, function()
			ParticleEffectAttach("SEVV_FREES_LINUX_BREATH", PATTACH_POINT_FOLLOW, self, 3)

			self:BreathDamage()
		end)

		self:PlaySequenceAndMove("neco_breath", 1, self.FaceEnemy)
		self:SetGodMode(false)

		timer.Remove("BreathAttack")
	end,

	[5] = function(self, ignoreCooldown) -- Summon clones attack
		local cooldown = self:GetCooldown("SummonCooldown")
		if not ignoreCooldown and (not cooldown or cooldown ~= 0) then return end

		self:SetCooldown("SummonCooldown", 7.23)
		self:SetGodMode(true)
		self:EmitSound("Neco-Arc/neco95.wav")
		self:SummonClones()
		self:PlaySequenceAndMove("neco_summon", 1, self.PossessionFaceForward)
		self:SetGodMode(false)
	end,

	[6] = function(self)
		self:ThrowRedRings(false)
	end
}

function ENT:CustomInitialize()
	self.IdleAnimation = "neco_idle"
	self.RunAnimation = "neco_run"
	self.WalkAnimation = "neco_walk"
	self.JumpAnimation = "neco_jump"

	self.RunSpeed = 301
	self.WalkSpeed = 100

	self:SetHealthRegen(300)
	self:SetDefaultRelationship(D_HT)

	self:SequenceEvent("neco_dodge1", 2 / 10, self.Step)
	self:SequenceEvent("neco_dodge2", 2 / 10, self.Step)
	self:SequenceEvent("neco_dodge3", 2 / 10, self.Step)
	self:SequenceEvent("neco_dodge4", 2 / 10, self.Step)
	self:SequenceEvent("neco_slam", 1.4 / 10, self.Attack3)
	self:SequenceEvent("neco_walk", 2.3 / 10, self.Step)
	self:SequenceEvent("neco_walk", 5.11 / 10, self.Step)
	self:SequenceEvent("neco_run", 2 / 10, self.Step)
	self:SequenceEvent("neco_run", 5.4 / 10, self.Step)
	self:SequenceEvent("neco_attack1", 3.4 / 10, self.Attack1)
	self:SequenceEvent("neco_attack2", 3.4 / 10, self.Attack2)
	self:SequenceEvent("neco_attack3", 3.4 / 10, self.Attack1)
	self:SequenceEvent("neco_attack3", 5.4 / 10, self.Attack1)
	self:SequenceEvent("neco_kick", 1.4 / 10, self.Attack2)
	self:SequenceEvent("neco_drill", 1 / 4, self.Attack1)
	self:SequenceEvent("neco_drill", 2 / 4, self.Attack2)
	self:SequenceEvent("neco_drill", 3 / 4, self.Attack1)
	self:SequenceEvent("neco_drill", 4 / 4, self.Attack1)
	self:SequenceEvent("neco_attack1", 2.3 / 10, self.Step)
	self:SequenceEvent("neco_attack1", 5.11 / 10, self.Step)
	self:SequenceEvent("neco_attack2", 2.3 / 10, self.Step)
	self:SequenceEvent("neco_attack2", 5.11 / 10, self.Step)
	self:SequenceEvent("neco_attack3", 2.3 / 10, self.Step)
	self:SequenceEvent("neco_attack3", 5.11 / 10, self.Step)
end

function ENT:UseSpecialAttack(attackID, ignoreCooldown)
	local specialAttacks = self.SpecialAttacks

	if not attackID then
		attackID = math.random(1, #specialAttacks)
	end

	local attack = specialAttacks[attackID]
	if not attack then return end

	attack(self, ignoreCooldown)
end

function ENT:AttackSky(isPossessed)
	if isPossessed then
		local ply = self:GetPossessor()

		if ply:IsValid() and ply:KeyDown(IN_ATTACK2) then
			ParticleEffectAttach("SEVV_FREES_LINUX_SPLODE", PATTACH_POINT_FOLLOW, self, 1)

			self:Jump(100)
			self:EmitSound("Neco-Arc/neco95.wav", 600)
			self:PlaySequenceAndMove("neco_slam", 1, self.PossessionFaceForward)
		end
	elseif self:IsOnGround() then 
		return 
	end

	ParticleEffectAttach("SEVV_FREES_LINUX_ATTACK", PATTACH_POINT_FOLLOW, self, 1)

	self:PlaySequenceAndMove("neco_drill", 1, self.PossessionFaceForward)
end

function ENT:BurrowTo(pos)
	ParticleEffectAttach("SEVV_FREES_LINUX_DUST", PATTACH_POINT_FOLLOW, self, 1)

	self:PlaySequenceAndMove("neco_enter")

	if navmesh.IsLoaded() then 
		local area = navmesh.GetNearestNavArea(pos)

		if area:IsValid() then
			pos = area:GetClosestPointOnArea(pos) or pos 
		end
	end

	ParticleEffectAttach("SEVV_FREES_LINUX_DUST", PATTACH_POINT_FOLLOW, self, 1)

	self:SetPos(pos)
	self:DropToFloor()
	self:PlaySequenceAndMove("neco_exit")
	self:Jump(300)
end

function ENT:Attack1()
	self:PlayVOX()

	self:Attack({
		damage = 500,
		viewpunch = Angle(4060, 4060, 4060),
		type = DMG_BLAST,
		range = 100,
		force = Vector(1000600, 660, 900600)
	}, function(_, hit)
		self:PushEntity(hit, Vector(460, 260, 70))
		if #hit > 0 then self:EmitSound("npc/fast_zombie/claw_strike" .. math.random(1, 3) .. ".wav") end
	end)
end

function ENT:EyeDamage()
	self:Attack({
		damage = 918,
		range = 630,
		delay = 0,
		radius = 350,
		force = Vector(800, 100, 100),
		type = DMG_BULLET,
		viewpunch = Angle(30, math.random(-16, 20), 0),
	}, function(_, hit)
		self:PushEntity(hit, Vector(80, 90, 4))
		if #hit > 0 then
			self:EmitSound("npc/fast_zombie/claw_strike" .. math.random(1, 3) .. ".wav")
		end
	end)
end

function ENT:BreathDamage()
	self:Attack({
		damage = 618,
		range = 630,
		delay = 0,
		radius = 350,
		force = Vector(800, 100, 100),
		type = DMG_SLOWBURN,
		viewpunch = Angle(30, math.random(-16, 20), 0),
	}, function(_, hit)
		self:PushEntity(hit, Vector(80, 90, 4))
		if #hit > 0 then
			local enemy = self:GetClosestEnemy()
			
			if IsValid(enemy) then
				self:EmitSound("npc/fast_zombie/claw_strike" .. math.random(1, 3) .. ".wav")
				enemy:Ignite(20, 10)
			end
		end
	end)
end

function ENT:PlayVOX()
	if not self:GetCooldown("VOX1") then return end

	if self:GetCooldown("VOX1") == 0 then
		self:SetCooldown("VOX1", 1)
		self:EmitSound("Neco-Arc/attack" .. math.random(1, 19) .. ".wav")
	end
end

function ENT:Attack2()
	self:PlayVOX()

	self:Attack({
		damage = 500,
		viewpunch = Angle(4060, 4060, 4060),
		type = DMG_BLAST,
		range = 100,
		force = Vector(1000600, 660, 900600)
	}, function(self, hit)
		self:PushEntity(hit, Vector(700, 700, 80))
		if #hit > 0 then self:EmitSound("npc/fast_zombie/claw_strike" .. math.random(1, 3) .. ".wav") end
	end)
end

function ENT:Attack3()
	self:PlayVOX()

	self:Attack({
		damage = 800,
		viewpunch = Angle(4060, 4060, 4060),
		type = DMG_BLAST,
		range = 200,
		angle = 400,
		force = Vector(1000600, 660, 900600)
	}, function(self, hit)
		self:PushEntity(hit, Vector(370, 170, 680))
		if #hit > 0 then self:EmitSound("npc/fast_zombie/claw_strike" .. math.random(1, 3) .. ".wav") end
	end)
end

function ENT:Step()
	self:EmitSound("Neco-Arc/footstep0" .. math.random(1, 5) .. ".wav")
end

function ENT:PhoneAttack()
	if CurTime() <= self.PhoneDelayTime then return end

	local enemy = self:GetClosestEnemy()
	if not enemy:IsValid() then return end

	local phone = ents.Create("bonemerge")
	if not phone:IsValid() then return end

	self.PhoneDelayTime = CurTime() + 4

	phone:SetModel("models/Items/battery.mdl")
	phone:SetOwner(self)
	phone:SetParent(self)
	phone:Fire("SetParentAttachment", "necohand")
	phone:SetLocalPos(self:GetAttachment(self:LookupAttachment("necohand")).Pos)
	phone:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	phone:Spawn()
	phone:SetModelScale(1)
	phone:SetMaterial("")
	phone:Activate()
	phone:SetSolid(SOLID_NONE)

	self:DeleteOnRemove(phone)
	self:PlayVOX()
	self:PlaySequenceAndMove("neco_phone", 1, self.PossessionFaceForward)
	
	enemy:TakeDamage(5815, self, self)
	enemy:EmitSound("Neco-Arc/neco33.wav", 500)

	phone:Remove()

	ParticleEffect("SEVV_FREES_LINUX_GODBEAM", enemy:GetPos(), self:GetAngles())
end

function ENT:ThrowRedRings(isPossessed)
	if self:GetCooldown("RedRingDelay") > 0 then return end

	local proj = self:CreateProjectile("ncarc_ring_l55")
	if not proj:IsValid() then return end

	local pos = self:GetPos()

	if isPossessed then
		local hitPos = self:PossessorTrace().HitPos

		proj:SetPos(pos + (hitPos - pos):GetNormalized() + Vector(20, 40, 137))
		proj:DrG_AimAt(hitPos, 30000)
	else
		local enemy = self:GetEnemy()
		if not enemy:IsValid() then return end

		proj:SetPos(pos + Vector(20, 10, self:Height() * 0.40))
		proj:DrG_AimAt(enemy, 91000)

		proj:DrG_Timer(2, function()
			local phys = proj:GetPhysicsObject()

			if phys:IsValid() then
				phys:EnableGravity(false)
			end
		end)

		proj.CustomThink = function() end
	end

	self:SetCooldown("RedRingDelay", 2)
	self:SetVelocity(self:GetForward() * 40 + self:GetUp() * 950)

	self:EmitSound("Neco-Arc/neco58.wav")
	self:Jump(470, 1, self.PossessionFaceForward)
end

function ENT:Dodge(enemy)
	local cooldown = self:GetCooldown("DodgeCooldown")
	if not cooldown or cooldown ~= 0 then return end

	local terma = math.random(1, 4)

	if terma == 1 then
		self:SetCooldown("DodgeCooldown", 4.90)
	elseif terma == 2 then
		self:SetCooldown("DodgeCooldown", 3.21)
	elseif terma > 2 then
		self:SetCooldown("DodgeCooldown", 1.23)
	end

	self:PlaySequence("dodge" .. terma, 1, self.FaceEnemy)
end

function ENT:BurrowToEnemy()
	local enemy = self:GetEnemy()

	if not enemy:IsValid() then
		return false
	end

	ParticleEffectAttach("SEVV_FREES_LINUX_DUST", PATTACH_POINT_FOLLOW, self, 1)

	self:PlaySequenceAndMove("neco_enter")

	local rigth = math.random(-50, 50)
	local left = math.random(-40, 50)

	self:SetPos(enemy:GetPos() + Vector(left, right, 10))

	ParticleEffectAttach("SEVV_FREES_LINUX_DUST", PATTACH_POINT_FOLLOW, self, 1)

	self:PlaySequenceAndMove("neco_exit")
end

function ENT:SummonClones(dmg, delay, hitgroup)
	if not self:GetCooldown("CloneAttack") or self:GetCooldown("CloneAttack") ~= 0 then return end

	self:SetCooldown("CloneAttack", 7.23)

	local creator = self:GetCreator()
	local hasCreator = creator:IsValid()

	for i = 1, 4 do
		local clone = ents.Create("l55_necoarc_drg")
		if not clone:IsValid() then continue end

		clone:SetPos(self:EyePos())
		clone:SetAngles(self:GetAngles())
		clone:Spawn()
		clone:SetCollisionGroup(COLLISION_GROUP_WORLD)

		if hasCreator then 
			creator:DrG_AddUndo(clone, "NPC", "Undone Neco Arc (Clone)") 
		end
	end
end

function ENT:OnMeleeAttack(enemy)
	self:Dodge(enemy)
	self:AttackSky(false)
	self:Dodge(enemy)

	local terma = math.random(1, 3)

	if terma == 1 then
		ParticleEffectAttach("SEVV_FREES_LINUX_SPLODE", PATTACH_POINT_FOLLOW, self, 1)

		self:Jump(100)
		self:EmitSound("Neco-Arc/neco95.wav", 600)
		self:PlaySequenceAndMove("neco_slam", 1, self.FaceEnemy)
	elseif terma == 2 then
		ParticleEffectAttach("SEVV_FREES_LINUX_ATTACK", PATTACH_POINT_FOLLOW, self, 1)

		self:PlaySequenceAndMove("neco_attack" .. math.random(1, 3), 1, self.FaceEnemy)
	elseif terma == 3 then
		ParticleEffectAttach("SEVV_FREES_LINUX_ATTACK", PATTACH_POINT_FOLLOW, self, 1)

		self:PlaySequenceAndMove("neco_kick", 1, self.FaceEnemy)
	end

	self:Dodge(enemy)
end

function ENT:OnRangeAttack(enemy)
	self:JumpAttack()
	self:FaceTowards(enemy)
	self:SetGodMode(true)
	self:UseSpecialAttack()
	self:SetGodMode(false)
	self:Dodge(enemy)
end

function ENT:Dancel()
	self:CallInCoroutineOverride(function(self, delay)
		self:EmitSound("Neco-Arc/nya.wav")
		self:PlaySequenceAndMoveOverride("neco_dance", {
			overrider = true,
			overridable = false
		}, {
			rate = 1,
			gravity = true,
			collisions = false
		})

		self:Timer(1, function() end)
	end)
end

--[[function ENT:OnOtherKilled(ent, dmg)
	if self:IsPossessed() then return end
	if not self:GetCooldown("Lmao") then return end
	if self:GetCooldown("Lmao") == 0 then
		self:SetCooldown("Lmao", 19)
		local attacker = dmg:GetAttacker()
		if IsValid(attacker) and attacker == self then self:Dancel() end
	end
end]]

function ENT:JumpAttack()
	if not self:IsOnGround() then return end

	local cooldown = self:GetCooldown("JumpCooldown")
	if not cooldown or cooldown ~= 0 then return end

	self:Jump(170, 1, self.FaceEnemy)
	self:SetVelocity(self:GetForward() * 700 + self:GetUp() * 550)
	self:SetCooldown("JumpCooldown", 2)
end

function ENT:OnIdle()
	self:AddPatrolPos(self:RandomPos(1900))
end

function ENT:OnLandOnGround()
	ParticleEffectAttach("SEVV_FREES_LINUX_SLAM", PATTACH_POINT_FOLLOW, self, 1)
end

function ENT:OnRemove()
	timer.Remove("EyeAttack")
	timer.Remove("BreathAttack")
end