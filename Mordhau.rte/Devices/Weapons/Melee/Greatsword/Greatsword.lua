
function stringInsert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end


function playAttackAnimation(self, animation)
	self.attackAnimationIsPlaying = true
	self.currentAttackSequence = 1
	self.currentAttackAnimation = animation
	self.attackAnimationTimer:Reset()
	self.attackAnimationCanHit = true
	return
end
--[[
function OnAttach(self)
	self.Frame = 1;
	self.equipSound:Play(self.Pos);
	self.equipAnim = true;
	self.equipAnimationTimer:Reset();
	self.unequipAnim = false;
end

function OnDetach(self)
	self.Frame = 6;
	self.unequipSound:Play(self.Pos);
	self.unequipAnim = true;
	self.equipAnimationTimer:Reset();
	self.equipAnim = false;
end
]]
function Create(self)
	
	self.equipAnimationTimer = Timer();

	self.originalStanceOffset = Vector(self.StanceOffset.X * self.FlipFactor, self.StanceOffset.Y)
	
	self.attackAnimations = {}
	self.attackAnimationCanHit = false
	self.attackAnimationsSounds = {}
	self.attackAnimationsGFX = {}
	self.attackAnimationTimer = Timer();
	
	self.currentAttackAnimation = 0;
	self.currentAttackSequence = 0;
	self.currentAttackStart = false
	self.attackAnimationIsPlaying = false
	
	--TODO FIL
	-- change "charge" to stab and "regular" to slash/strike/normal
	
	self.terrainHitSounds = {
	[12] = CreateSoundContainer("MeleeTerrainHit Concrete Mordhau", "Mordhau.rte"),
	[164] = CreateSoundContainer("MeleeTerrainHit Concrete Mordhau", "Mordhau.rte"),
	[177] = CreateSoundContainer("MeleeTerrainHit Concrete Mordhau", "Mordhau.rte"),
	[9] = CreateSoundContainer("MeleeTerrainHit Dirt Mordhau", "Mordhau.rte"),
	[10] = CreateSoundContainer("MeleeTerrainHit Dirt Mordhau", "Mordhau.rte"),
	[11] = CreateSoundContainer("MeleeTerrainHit Dirt Mordhau", "Mordhau.rte"),
	[128] = CreateSoundContainer("MeleeTerrainHit Dirt Mordhau", "Mordhau.rte"),
	[6] = CreateSoundContainer("MeleeTerrainHit Sand Mordhau", "Mordhau.rte"),
	[8] = CreateSoundContainer("MeleeTerrainHit Sand Mordhau", "Mordhau.rte"),
	[178] = CreateSoundContainer("MeleeTerrainHit SolidMetal Mordhau", "Mordhau.rte"),
	[179] = CreateSoundContainer("MeleeTerrainHit SolidMetal Mordhau", "Mordhau.rte"),
	[180] = CreateSoundContainer("MeleeTerrainHit SolidMetal Mordhau", "Mordhau.rte"),
	[181] = CreateSoundContainer("MeleeTerrainHit SolidMetal Mordhau", "Mordhau.rte"),
	[182] = CreateSoundContainer("MeleeTerrainHit SolidMetal Mordhau", "Mordhau.rte")}
	
	local attackPhase
	local regularAttackSounds = {}
	local i
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--regularAttackSounds.hitDefaultSound
	--regularAttackSounds.hitDefaultSoundVariations
	
	regularAttackSounds.hitDeflectSound = CreateSoundContainer("Slash Metal Greatsword Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitFleshSound = CreateSoundContainer("Slash Flesh Greatsword Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitMetalSound = CreateSoundContainer("Slash Metal Greatsword Mordhau", "Mordhau.rte");
	
	local chargeAttackSounds = {}
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--chargeAttackSounds.hitDefaultSound
	--chargeAttackSounds.hitDefaultSoundVariations
	
	chargeAttackSounds.hitDeflectSound = CreateSoundContainer("Stab Metal Greatsword Mordhau", "Mordhau.rte");
	
	chargeAttackSounds.hitFleshSound = CreateSoundContainer("Stab Flesh Greatsword Mordhau", "Mordhau.rte");
	
	chargeAttackSounds.hitMetalSound = CreateSoundContainer("Stab Metal Greatsword Mordhau", "Mordhau.rte");
	
	local regularAttackGFX = {}
	
	regularAttackGFX.hitTerrainSoftGFX = "Melee Terrain Soft Effect Mordhau"
	regularAttackGFX.hitTerrainHardGFX = "Melee Terrain Hard Effect Mordhau"
	regularAttackGFX.hitFleshGFX = "Melee Flesh Effect Mordhau"
	regularAttackGFX.hitMetalGFX = "Melee Terrain Hard Effect Mordhau"
	regularAttackGFX.hitDeflectGFX = "Melee Terrain Hard Effect Mordhau"
	
	-- Regular Attack
	attackPhase = {}
	
	-- Prepare
	i = 1
	attackPhase[i] = {}
	attackPhase[i].durationMS = 250
	
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	attackPhase[i].frameStart = 6
	attackPhase[i].frameEnd = 6
	attackPhase[i].angleStart = 0
	attackPhase[i].angleEnd = 45
	attackPhase[i].offsetStart = Vector(0, 0)
	attackPhase[i].offsetEnd = Vector(-6, -5)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	attackPhase[i] = {}
	attackPhase[i].durationMS = 300
	
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	attackPhase[i].frameStart = 6
	attackPhase[i].frameEnd = 6
	attackPhase[i].angleStart = 45
	attackPhase[i].angleEnd = 45
	attackPhase[i].offsetStart = Vector(-6, -5)
	attackPhase[i].offsetEnd = Vector(-6, -5)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	attackPhase[i] = {}
	attackPhase[i].durationMS = 150
	
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 5
	attackPhase[i].attackStunChance = 0.2
	attackPhase[i].attackRange = 20
	attackPhase[i].attackPush = 1
	attackPhase[i].attackVector = Vector(0, -8) -- local space vector relative to position and rotation
	
	attackPhase[i].frameStart = 7
	attackPhase[i].frameEnd = 11
	attackPhase[i].angleStart = 30
	attackPhase[i].angleEnd = -50
	attackPhase[i].offsetStart = Vector(-6, -5)
	attackPhase[i].offsetEnd = Vector(7, -2)
	
	attackPhase[i].soundStart = CreateSoundContainer("Slash Greatsword Mordhau", "Mordhau.rte");
	
	attackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	attackPhase[i] = {}
	attackPhase[i].durationMS = 45
	
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 5
	attackPhase[i].attackStunChance = 0.2
	attackPhase[i].attackRange = 20
	attackPhase[i].attackPush = 1
	attackPhase[i].attackVector = Vector(0, -8) -- local space vector relative to position and rotation
	
	attackPhase[i].frameStart = 11
	attackPhase[i].frameEnd = 11
	attackPhase[i].angleStart = -50
	attackPhase[i].angleEnd = -90
	attackPhase[i].offsetStart = Vector(7, -2)
	attackPhase[i].offsetEnd = Vector(7, -2)
	
	attackPhase[i].soundStart = nil
	
	attackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	attackPhase[i] = {}
	attackPhase[i].durationMS = 150
	
	attackPhase[i].canDamage = true
	attackPhase[i].attackDamage = 5
	attackPhase[i].attackStunChance = 0.2
	attackPhase[i].attackRange = 15
	attackPhase[i].attackPush = 1
	attackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 90;
	
	attackPhase[i].frameStart = 11
	attackPhase[i].frameEnd = 6
	attackPhase[i].angleStart = -90
	attackPhase[i].angleEnd = -100
	attackPhase[i].offsetStart = Vector(7 , -2)
	attackPhase[i].offsetEnd = Vector(15, -4)
	
	attackPhase[i].soundStart = nil
	
	attackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	attackPhase[i] = {}
	attackPhase[i].durationMS = 140
	
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	attackPhase[i].frameStart = 6
	attackPhase[i].frameEnd = 7
	attackPhase[i].angleStart = -90
	attackPhase[i].angleEnd = -20
	attackPhase[i].offsetStart = Vector(15, -4)
	attackPhase[i].offsetEnd = Vector(3, 0)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
	attackPhase[i] = {}
	attackPhase[i].durationMS = 140
	
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	attackPhase[i].frameStart = 7
	attackPhase[i].frameEnd = 6
	attackPhase[i].angleStart = -20
	attackPhase[i].angleEnd = 0
	attackPhase[i].offsetStart = Vector(3, 0)
	attackPhase[i].offsetEnd = Vector(3, 0)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[1] = regularAttackSounds
	self.attackAnimationsGFX[1] = regularAttackGFX
	self.attackAnimations[1] = attackPhase
	
	-- Charge Attack (stab)
	chargeAttackPhase = {}
	
	-- Prepare
	i = 1
	chargeAttackPhase[i] = {}
	chargeAttackPhase[i].durationMS = 200
	
	chargeAttackPhase[i].canDamage = false
	chargeAttackPhase[i].attackDamage = 0
	chargeAttackPhase[i].attackStunChance = 0
	chargeAttackPhase[i].attackRange = 0
	chargeAttackPhase[i].attackPush = 0
	chargeAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	chargeAttackPhase[i].frameStart = 6
	chargeAttackPhase[i].frameEnd = 6
	chargeAttackPhase[i].angleStart = 0
	chargeAttackPhase[i].angleEnd = -60
	chargeAttackPhase[i].offsetStart = Vector(0, 0)
	chargeAttackPhase[i].offsetEnd = Vector(-2, -3)
	
	chargeAttackPhase[i].soundStart = nil
	chargeAttackPhase[i].soundStartVariations = 0
	
	chargeAttackPhase[i].soundEnd = nil
	chargeAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	chargeAttackPhase[i] = {}
	chargeAttackPhase[i].durationMS = 500
	
	chargeAttackPhase[i].canDamage = false
	chargeAttackPhase[i].attackDamage = 0
	chargeAttackPhase[i].attackStunChance = 0
	chargeAttackPhase[i].attackRange = 0
	chargeAttackPhase[i].attackPush = 0
	chargeAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	chargeAttackPhase[i].frameStart = 6
	chargeAttackPhase[i].frameEnd = 6
	chargeAttackPhase[i].angleStart = -60
	chargeAttackPhase[i].angleEnd = -70
	chargeAttackPhase[i].offsetStart = Vector(-2, -3)
	chargeAttackPhase[i].offsetEnd = Vector(-3, -4)
	
	chargeAttackPhase[i].soundStart = nil
	chargeAttackPhase[i].soundStartVariations = 0
	
	chargeAttackPhase[i].soundEnd = nil
	chargeAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	chargeAttackPhase[i] = {}
	chargeAttackPhase[i].durationMS = 190
	
	chargeAttackPhase[i].canDamage = false
	chargeAttackPhase[i].attackDamage = 6
	chargeAttackPhase[i].attackStunChance = 0.2
	chargeAttackPhase[i].attackRange = 20
	chargeAttackPhase[i].attackPush = 0.8
	chargeAttackPhase[i].attackVector = Vector(0, -8) -- local space vector relative to position and rotation
	
	chargeAttackPhase[i].frameStart = 6
	chargeAttackPhase[i].frameEnd = 6
	chargeAttackPhase[i].angleStart = -70
	chargeAttackPhase[i].angleEnd = -80
	chargeAttackPhase[i].offsetStart = Vector(-3, -4)
	chargeAttackPhase[i].offsetEnd = Vector(0, -5)
	
	chargeAttackPhase[i].soundStart = CreateSoundContainer("Stab Greatsword Mordhau", "Mordhau.rte");
	
	chargeAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	chargeAttackPhase[i] = {}
	chargeAttackPhase[i].durationMS = 45
	
	chargeAttackPhase[i].canDamage = false
	chargeAttackPhase[i].attackDamage = 6
	chargeAttackPhase[i].attackStunChance = 0.2
	chargeAttackPhase[i].attackRange = 20
	chargeAttackPhase[i].attackPush = 0.8
	chargeAttackPhase[i].attackVector = Vector(0, -8) -- local space vector relative to position and rotation
	
	chargeAttackPhase[i].frameStart = 6
	chargeAttackPhase[i].frameEnd = 6
	chargeAttackPhase[i].angleStart = -80
	chargeAttackPhase[i].angleEnd = -90
	chargeAttackPhase[i].offsetStart = Vector(0, -5)
	chargeAttackPhase[i].offsetEnd = Vector(4, -6)
	
	chargeAttackPhase[i].soundStart = nil
	
	chargeAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	chargeAttackPhase[i] = {}
	chargeAttackPhase[i].durationMS = 160
	
	chargeAttackPhase[i].canDamage = true
	chargeAttackPhase[i].attackDamage = 6
	chargeAttackPhase[i].attackStunChance = 0.2
	chargeAttackPhase[i].attackRange = 15
	chargeAttackPhase[i].attackPush = 0.8
	chargeAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	chargeAttackPhase[i].attackAngle = 90;
	
	chargeAttackPhase[i].frameStart = 6
	chargeAttackPhase[i].frameEnd = 6
	chargeAttackPhase[i].angleStart = -90
	chargeAttackPhase[i].angleEnd = -90
	chargeAttackPhase[i].offsetStart = Vector(4 , -6)
	chargeAttackPhase[i].offsetEnd = Vector(15, -6)
	
	chargeAttackPhase[i].soundStart = nil
	
	chargeAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	chargeAttackPhase[i] = {}
	chargeAttackPhase[i].durationMS = 150
	
	chargeAttackPhase[i].canDamage = false
	chargeAttackPhase[i].attackDamage = 0
	chargeAttackPhase[i].attackStunChance = 0
	chargeAttackPhase[i].attackRange = 0
	chargeAttackPhase[i].attackPush = 0
	chargeAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	chargeAttackPhase[i].frameStart = 6
	chargeAttackPhase[i].frameEnd = 7
	chargeAttackPhase[i].angleStart = -90
	chargeAttackPhase[i].angleEnd = -60
	chargeAttackPhase[i].offsetStart = Vector(15, -6)
	chargeAttackPhase[i].offsetEnd = Vector(7, -3)
	
	chargeAttackPhase[i].soundStart = nil
	chargeAttackPhase[i].soundStartVariations = 0
	
	chargeAttackPhase[i].soundEnd = nil
	chargeAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
	chargeAttackPhase[i] = {}
	chargeAttackPhase[i].durationMS = 150
	
	chargeAttackPhase[i].canDamage = false
	chargeAttackPhase[i].attackDamage = 0
	chargeAttackPhase[i].attackStunChance = 0
	chargeAttackPhase[i].attackRange = 0
	chargeAttackPhase[i].attackPush = 0
	chargeAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	chargeAttackPhase[i].frameStart = 7
	chargeAttackPhase[i].frameEnd = 6
	chargeAttackPhase[i].angleStart = -60
	chargeAttackPhase[i].angleEnd = 0
	chargeAttackPhase[i].offsetStart = Vector(7, -3)
	chargeAttackPhase[i].offsetEnd = Vector(3, 0)
	
	chargeAttackPhase[i].soundStart = nil
	chargeAttackPhase[i].soundStartVariations = 0
	
	chargeAttackPhase[i].soundEnd = nil
	chargeAttackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[2] = chargeAttackSounds
	self.attackAnimationsGFX[2] = regularAttackGFX
	self.attackAnimations[2] = chargeAttackPhase
	
	-- replace with your own code if you wish
	
	-- default "regular attack and charged attack behaviour"
	
	self.startedCharging = false
	self.isCharging = false
	self.isCharged = false
	
	self.chargeStartTimer = Timer()
	self.chargeStartTime = 200
	self.chargeTimer = Timer()
	self.chargeTime = 700
	
	self.chargeStanceOffset = Vector(-1,-6)
	self.chargeAngle = 3
	
	self.chargeSound = nil;
	
	self.chargeEndSound = nil;
	
	self.rotation = 0
	self.rotationInterpolation = 1 -- 0 instant, 1 smooth, 2 wiggly smooth
	self.rotationInterpolationSpeed = 35
	
	self.stance = Vector(0, 0)
	self.stanceInterpolation = 0 -- 0 instant, 1 smooth
	self.stanceInterpolationSpeed = 25
end

function Update(self)
	local act = self:GetRootParent();
	local actor = MovableMan:IsActor(act) and ToActor(act) or nil;
	local player = false
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		actor:GetController():SetState(Controller.AIM_SHARP,false);
		self.parent = actor;
		if actor:IsPlayerControlled() then
			player = true
		end
	end
	
	--if self.equipAnim or self.unequipAnim then
		--[[
		if self.equipAnim == true then
			if self.equipAnimationTimer:IsPastSimMS(30) then
				self.Frame = self.Frame + 1;
				if self.Frame == 6 then
					self.equipAnim = false;
				end
				self.equipAnimationTimer:Reset();
			end
		elseif self.unequipAnim == true then
			if self.equipAnimationTimer:IsPastSimMS(30) then
				self.Frame = self.Frame - 1;
				if self.Frame == 1 then
					self.unequipAnim = false;
				end
				self.equipAnimationTimer:Reset();
			end
		end
		]]
	--else
	if (true) then --          :-)
	
		-- INPUT
		local charge = false
		local attacked = false
		
		if player then -- PLAYER INPUT
			charge = (self:IsActivated() and not self.isCharged) or (self.isCharging and not self.isCharged)
		else -- AI
			attacked = self:IsActivated() and not self.attackAnimationIsPlaying
		end
		
		-- replace with your own code if you wish
		-- default "regular attack and charged attack behaviour"
		
		if charge and not self.attackAnimationIsPlaying then
			if not self.startedCharging then
				self.startedCharging = true
			end
			if not self.isCharging and self.chargeStartTimer:IsPastSimMS(self.chargeStartTime) then
				self.isCharging = true
				if self.chargeSound then
					self.chargeSound:Play(self.Pos);
				end
				if self.VOValueSet ~= true then
					self.parent:SetNumberValue("Extreme Attack", 1);
					self.VOValueSet = true;
				end
			end
			
			if self.isCharging then
				if self.chargeTimer:IsPastSimMS(self.chargeTime) then
					if not self.isCharged then
						self.isCharged = true
					end
				end
			end
		else
			self.chargeStartTimer:Reset()
			self.chargeTimer:Reset()
			if self.isCharging or self.startedCharging then
				self.isCharging = false
				self.startedCharging = false
				if self.chargeEndSound then
					self.chargeEndSound:Play(self.Pos);
				end
				attacked = true
			end
		end
		
		-- INPUT TO OUTPUT
		
		-- replace with your own code if you wish
		-- default "regular attack and charged attack behaviour"
		if attacked then
			if self.isCharged then
				self.isCharged = false
				self.wasCharged = true;
				playAttackAnimation(self, 2) -- charged attack
				self.parent:SetNumberValue("Medium Attack", 1); --here for extra movement sounds on parent knight
			else
				playAttackAnimation(self, 1) -- regular attack
			end
		end
		
		-- ANIMATION PLAYER
		local stanceTarget = Vector(0, 0)
		local rotationTarget = 0
		
		local canDamage = false
		local damageVector = Vector(0,0)
		local damageRange = 1
		local damageStun = 0
		local damagePush = 1
		local damage = 0
		
		-- charge animation, remove/replace it if you wish
		local chargeFactor = math.min(self.chargeTimer.ElapsedSimTimeMS / self.chargeTime, 1)
		stanceTarget = stanceTarget + self.chargeStanceOffset * chargeFactor
		rotationTarget = rotationTarget + self.chargeAngle / 180 * math.pi * chargeFactor
		
		
		if self.attackAnimationIsPlaying and currentAttackAnimation ~= 0 then -- play the animation
		
			if self.VOValueSet ~= true then
				self.parent:SetNumberValue("Medium Attack", 1);
				self.VOValueSet = true;
			end
		
			local animation = self.currentAttackAnimation
			local attackPhases = self.attackAnimations[animation]
			local currentPhase = attackPhases[self.currentAttackSequence]
			
			local factor = self.attackAnimationTimer.ElapsedSimTimeMS / currentPhase.durationMS
			
			if not self.currentAttackStart then -- Start of the sequence
				self.currentAttackStart = true
				if currentPhase.soundStart then
					currentPhase.soundStart:Play(self.Pos);
				end
			end
			
			canDamage = currentPhase.canDamage or false
			damage = currentPhase.attackDamage or 0
			damageVector = currentPhase.attackVector or Vector(0,0)
			damageAngle = currentPhase.attackAngle or 0
			damageRange = currentPhase.attackRange or 0
			damageStun = currentPhase.attackStunChance or 0
			damagePush = currentPhase.attackPush or 0
			
			rotationTarget = rotationTarget + (currentPhase.angleStart * (1 - factor) + currentPhase.angleEnd * factor) / 180 * math.pi -- interpolate rotation
			stanceTarget = stanceTarget + (currentPhase.offsetStart * (1 - factor) + currentPhase.offsetEnd * factor) -- interpolate stance offset
			local frameChange = currentPhase.frameEnd - currentPhase.frameStart
			self.Frame = math.floor(currentPhase.frameStart + math.floor(frameChange * factor, 0.55))
			
			-- DEBUG
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 40), "animation = "..animation, true, 0);
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "sequence = "..self.currentAttackSequence, true, 0);
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 30), "factor = "..math.floor(factor * 100).."/100", true, 0);
			if self.attackAnimationTimer:IsPastSimMS(currentPhase.durationMS) then
				if (self.currentAttackSequence+1) <= #attackPhases then
					self.currentAttackSequence = self.currentAttackSequence + 1
				else
					self.VOValueSet = false;
					self.wasCharged = false;
					self.currentAttackAnimation = 0
					self.currentAttackSequence = 0
					self.attackAnimationIsPlaying = false
				end
				
				if currentPhase.soundEnd then
					currentPhase.soundEnd:Play(self.Pos);
				end
				
				self.currentAttackStart = false
				self.attackAnimationTimer:Reset()
				self.attackAnimationCanHit = true
				canDamage = false
			end
		else -- default behaviour, modify it if you wish
			if self:IsAttached() then
				self.Frame = 6;
			else
				self.Frame = 1;
			end
		end
		
		if self.stanceInterpolation == 0 then
			self.stance = stanceTarget
		elseif self.stanceInterpolation == 1 then
			self.stance = (self.stance + stanceTarget * TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed);
		end
		
		rotationTarget = rotationTarget * self.FlipFactor
		if self.rotationInterpolation == 0 then
			self.rotation = rotationTarget
		elseif self.rotationInterpolation == 1 then
			self.rotation = (self.rotation + rotationTarget * TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed);
		end
		local pushVector = Vector(10 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		
		self.StanceOffset = self.originalStanceOffset + self.stance
		--self.InheritedRotAngleOffset = self.rotation
		self.RotAngle = self.RotAngle + self.rotation
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		self.Pos = self.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-self.rotation);
		
		-- COLLISION DETECTION
		
		--self.attackAnimationsSounds[1]
		if canDamage and self.attackAnimationCanHit then -- Detect collision
			--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + attackOffset,  13);
			local hit = false
			local hitType = 0
			local team = 0
			if actor then team = actor.Team end
			local rayVec = Vector(damageRange * self.FlipFactor, 0):RadRotate(self.RotAngle):DegRotate(damageAngle*self.FlipFactor)--damageVector:RadRotate(self.RotAngle) * Vector(self.FlipFactor, 1)
			local rayOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(damageVector.X * self.FlipFactor, damageVector.Y):RadRotate(self.RotAngle)
			
			--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
			--PrimitiveMan:DrawCirclePrimitive(self.Pos, 3, 5);
			
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
			if moCheck and moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local MO = MovableMan:GetMOFromID(moCheck)
				hit = true
				if IsMOSRotating(MO) then
					MO = ToMOSRotating(MO)
					MO.Vel = MO.Vel + (self.Vel + pushVector) / MO.Mass * 15 * (damagePush)
					local crit = RangeRand(0, 1) < damageStun
					local woundName = MO:GetEntryWoundPresetName()
					local woundNameExit = MO:GetExitWoundPresetName()
					local woundOffset = (rayHitPos - MO.Pos):RadRotate(MO.RotAngle * -1.0)
					
					local material = MO.Material.PresetName
					--if crit then
					--	woundName = woundNameExit
					--end
					
					if string.find(material,"Flesh") or string.find(woundName,"Flesh") or string.find(woundNameExit,"Flesh") or string.find(material,"Bone") or string.find(woundName,"Bone") or string.find(woundNameExit,"Bone") then
						hitType = 1
					else
						hitType = 2
					end
					if string.find(material,"Flesh") or string.find(woundName,"Flesh") or string.find(woundNameExit,"Flesh") then
						if self.attackAnimationsGFX[self.currentAttackAnimation].hitFleshGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitFleshGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
					elseif string.find(material,"Metal") or string.find(woundName,"Metal") or string.find(woundNameExit,"Metal") or string.find(material,"Stuff") or string.find(woundName,"Dent") or string.find(woundNameExit,"Dent") then
						if self.attackAnimationsGFX[self.currentAttackAnimation].hitMetalGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitMetalGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
					end
					
					if MO:IsDevice() and math.random(1,3) >= 2 then
						if self.attackAnimationsGFX[self.currentAttackAnimation].hitDeflectGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitDeflectGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
						
						crit = true
					end
					
					local woundsToAdd = math.floor((damage) + RangeRand(0,0.9))
					
					-- Hurt the actor, add extra damage
					local actorHit = MovableMan:GetMOFromID(MO.RootID)
					if (actorHit and IsActor(actorHit)) then-- and (MO.RootID == moCheck or (not IsAttachable(MO) or string.find(MO.PresetName,"Arm") or string.find(MO,"Leg") or string.find(MO,"Head"))) then -- Apply addational damage
					
						actorHit = ToActor(actorHit)
						actorHit.Vel = actorHit.Vel + (self.Vel + pushVector) / actorHit.Mass * ((50 + self.Mass) * (actorHit.Mass / 100)) * (damagePush) * 0.8
						
						--print(actorHit.Material.StructuralIntegrity)
						--actor.Health = actor.Health - 8 * damageMulti;
						
						local addWounds = true;
						
						if (actorHit.Health - (damage * 10)) < 0 then -- bad estimation, but...
							if math.random(0, 100) < 15 then
								self.parent:SetNumberValue("Attack Killed", 1); -- celebration!!
							end
						end
						if IsAHuman(actorHit) then
							local actorHuman = ToAHuman(actorHit)
							if MO.ID == actorHuman.Head.ID or MO.ID == actorHuman.FGArm.ID or MO.ID == actorHuman.BGArm.ID or MO.ID == actorHuman.FGLeg.ID or MO.ID == actorHuman.BGLeg.ID then
								-- two different ways to dismember: 1. if wounds would gib the limb hit, dismember it instead 2. low hp and crit
								if MO.WoundCount + woundsToAdd > MO.GibWoundLimit then
									ToMOSRotating(actorHuman):RemoveAttachable(ToAttachable(MO), true, true);
									addWounds = false;
								elseif actorHuman.Health < 20 and crit then
									ToMOSRotating(actorHuman):RemoveAttachable(ToAttachable(MO), true, true);
									addWounds = false;
								end
							end
						end
						
						if addWounds == true then
							for i = 1, woundsToAdd do
								MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end
						end
						
						if self.wasCharged then
							if crit then
								actorHit:GetController():SetState(Controller.BODY_CROUCH,true);
								actorHit:GetController():SetState(Controller.WEAPON_CHANGE_NEXT,false);
								actorHit:GetController():SetState(Controller.WEAPON_CHANGE_PREV,false);
								actorHit:GetController():SetState(Controller.WEAPON_FIRE,false);
								actorHit:GetController():SetState(Controller.AIM_SHARP,false);
								actorHit:GetController():SetState(Controller.WEAPON_PICKUP,false);
								actorHit:GetController():SetState(Controller.WEAPON_DROP,true);
								actorHit:GetController():SetState(Controller.BODY_JUMP,false);
								actorHit:GetController():SetState(Controller.BODY_JUMPSTART,false);
								actorHit:GetController():SetState(Controller.MOVE_LEFT,false);
								actorHit:GetController():SetState(Controller.MOVE_RIGHT,false);
								actorHit:FlashWhite(150);
								if math.random(0, 100) < 30 then
									self.parent:SetNumberValue("Attack Success", 1); -- celebration!!
								end
							end
						else
							if crit then
								actorHit:GetController():SetState(Controller.BODY_CROUCH,true);
								actorHit:GetController():SetState(Controller.WEAPON_CHANGE_NEXT,false);
								actorHit:GetController():SetState(Controller.WEAPON_CHANGE_PREV,false);
								actorHit:GetController():SetState(Controller.WEAPON_FIRE,false);
								actorHit:GetController():SetState(Controller.AIM_SHARP,false);
								actorHit:GetController():SetState(Controller.WEAPON_PICKUP,false);
								actorHit:GetController():SetState(Controller.WEAPON_DROP,false);
								actorHit:GetController():SetState(Controller.BODY_JUMP,false);
								actorHit:GetController():SetState(Controller.BODY_JUMPSTART,false);
								actorHit:GetController():SetState(Controller.MOVE_LEFT,false);
								actorHit:GetController():SetState(Controller.MOVE_RIGHT,false);
								actorHit:FlashWhite(50);
							end
						end
					else -- generic wound adding for non-actors
						for i = 1, woundsToAdd do
							MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					end
				end
				self.isCharged = false
			else
				local terrCheck = SceneMan:CastMaxStrengthRay(rayOrigin, rayOrigin + rayVec, 2); -- Raycast
				if terrCheck > 5 then
					local rayHitPos = SceneMan:GetLastRayHitPos()
					hit = true
					self.attack = false
					self.charged = false
					
					local terrPixel = SceneMan:GetTerrMatter(rayHitPos.X, rayHitPos.Y)
			
					if terrPixel ~= 0 then -- 0 = air
						if self.terrainHitSounds[terrPixel] ~= nil then
							self.terrainHitSounds[terrPixel]:Play(self.Pos);
						else -- default to concrete
							self.terrainHitSounds[177]:Play(self.Pos);
						end
					end
					
					if terrCheck >= 100 then
						if self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainHardGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainHardGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
						
						hitType = 4 -- Hard
					else
						if self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainSoftGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainHardGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
						
						hitType = 3 -- Soft
					end
				end
			end
			
			if hit then
				if hitType == 0 then -- Default
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound:Play(self.Pos);
					end
				elseif hitType == 1 then -- Flesh
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSound:Play(self.Pos);
					end
				elseif hitType == 2 then -- Metal
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSound:Play(self.Pos);
					end
				end
				self.attackAnimationCanHit = false
			end
		end
	end
end