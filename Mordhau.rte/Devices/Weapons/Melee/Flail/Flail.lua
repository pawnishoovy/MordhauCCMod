
function stringInsert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end


function playAttackAnimation(self, animation)
	self.attackAnimationIsPlaying = true
	self.currentAttackStart = false;
	self.currentAttackSequence = self.phaseStart or 1;
	self.phaseStart = nil;
	self.currentAttackAnimation = animation
	self.attackAnimationTimer:Reset()
	self.attackAnimationCanHit = true
	self.blockedNullifier = true;
	self.Recovering = false;
	self.partiallyRecovered = false;
	self.Attacked = false;
	if self.pseudoPhase then
	
		self.usePseudoPhase = true;
		
	end
	
	self.IDToIgnore = nil;
	
	if self.ignoreUnbuffering then
		self.ignoreUnbuffering = nil;
	else
		self.moveBuffered = false;
	end
	
	self.Twirled = false;
		
	if self.Parrying == true then
		self:SetStringValue("Parrying Type", self.attackAnimationsTypes[self.currentAttackAnimation]);
		-- make our parrying shield counter alongside us
		-- and here i sit and wonder... parrying daggers?
		local BGItem = self.parent.EquippedBGItem;				
		if BGItem and BGItem:IsInGroup("Mordhau Counter Shields") then
			ToHeldDevice(BGItem):SetStringValue("Parrying Type", self.attackAnimationsTypes[self.currentAttackAnimation]);
		end
	end
	
	return
end

-- function OnAttach(self)

	-- self.Frame = 1;
	-- self.equipSound:Play(self.Pos);
	-- self.equipAnim = true;
	-- self.equipAnimationTimer:Reset();
	-- self.unequipAnim = false;
	
-- end

function OnDetach(self)

	-- self.Frame = 6;
	-- self.unequipSound:Play(self.Pos);
	-- self.unequipAnim = true;
	-- self.equipAnimationTimer:Reset();
	-- self.equipAnim = false;
	
	
end

function FlailCreateChainSegment(self, isBall)
	local chainPoint = {}
	chainPoint.position = Vector(self.Pos.X, self.Pos.Y)
	chainPoint.velocity = Vector(0, 0)
	chainPoint.mass = 1.0 * (isBall and self.chainBallMassFactor or 1.0)
	
	if isBall then
		local ball = CreateAttachable("Flail Ball", "Mordhau.rte");
		self:AddAttachable(ball);
		
		chainPoint.uid = ball.UniqueID
	else
		local chain = CreateAttachable("Flail Chain", "Mordhau.rte");
		self:AddAttachable(chain);
		
		chain.Frame = #self.chainSegments % 2
		chainPoint.uid = chain.UniqueID
	end
	
	return chainPoint
end

function FlailGetOrigin(self)
	local baseLength = 6.5
	local weaponLengths = {
		baseLength, -- 000
		baseLength, -- 001
		baseLength, -- 002
		baseLength, -- 003
		baseLength, -- 004
		baseLength, -- 005
		baseLength - 1, -- 006
		baseLength - 3, -- 007
		baseLength - 6, -- 008
		baseLength - 8, -- 009
		baseLength - 12, -- 010
		baseLength - 17, -- 011
		baseLength - 11, -- 012
		baseLength - 7, -- 013
		baseLength - 5, -- 014
		baseLength - 2, -- 015
		baseLength - 1, -- 016
		baseLength -- 017
	}
	
	local weaponLength = weaponLengths[self.Frame + 1]
	
	return self.Pos + Vector(0, -weaponLength):RadRotate(self.RotAngle)
end

function FlailHandleChain(self)
	local lastOrigin = FlailGetOrigin(self)
	local lastSegment
	
	local weaponVel = SceneMan:ShortestDistance(self.chainLastOrigin, lastOrigin, SceneMan.SceneWrapsX)
	
	local timeScale = TimerMan.DeltaTimeSecs * 1.0
	
	self.chainMovementFactor = 0
	
	for i, segment in ipairs(self.chainSegments) do
		local pos = Vector(segment.position.X, segment.position.Y)
		local vel = Vector(segment.velocity.X, segment.velocity.Y)
		
		-- Gravity
		vel = vel + SceneMan.GlobalAcc * timeScale
		
		-- Friction
		local friction = 1.0--(3 - math.min(math.max((dif.Magnitude), 1), 2)) * 7.0
		vel = Vector(vel.X , vel.Y) / (1 + timeScale * friction)
		
		-- Inherit velocity, etc
		
		if lastSegment then
			--local velToAddA = Vector(lastSegment.velocity.X, lastSegment.velocity.Y) * TimerMan.DeltaTimeSecs * lastSegment.mass
			--local velToAddB = Vector(vel.X, vel.Y) * TimerMan.DeltaTimeSecs * segment.mass
			
			--vel = vel - velToAddA
			local factorA = timeScale * lastSegment.mass * 10
			local factorB = timeScale * segment.mass  * 10
			
			lastSegment.velocity = (lastSegment.velocity + vel * factorB) / (1 + factorB)
			vel = (vel + lastSegment.velocity * factorA) / (1 + factorA)
			
			--lastSegment.velocity = lastSegment.velocity + velToAddB
		end
		
		if i == 1 then
			vel = vel + weaponVel
		end
		
		-- Travel
		pos = pos + vel * GetPPM() * timeScale-- * segment.mass
		
		-- Limit, distance constraint
		local difference = SceneMan:ShortestDistance(lastOrigin, pos, SceneMan.SceneWrapsX)
		local pull = Vector(difference.X, difference.Y).Normalized * math.min(math.pow(math.max(difference.Magnitude - self.chainSegmentLength + 1, 0) * 2.0, 2), 140) * timeScale
		pos = lastOrigin + Vector(difference.X, difference.Y):ClampMagnitude(self.chainSegmentLength, 0)
		vel = vel - pull-- / segment.mass
		
		--if lastSegment then
		--	lastSegment.velocity = lastSegment.velocity - pull
		--end
		
		-- Update
		segment.position = Vector(pos.X, pos.Y)
		segment.velocity = Vector(vel.X, vel.Y)
		
		-- Move MOs
		local mo = ToAttachable(MovableMan:FindObjectByUniqueID(segment.uid))
		if mo then
			mo.Pos = segment.position
			mo.RotAngle = difference.AbsRadAngle
		end
		
		-- Debug
		--[[
		if i == self.chainLength+1 then
			PrimitiveMan:DrawCircleFillPrimitive(segment.position, self.chainBallRadius, 13);
		else
			PrimitiveMan:DrawCirclePrimitive(segment.position, self.chainSegmentLength * 0.5, 13);
		end]]
		
		--PrimitiveMan:DrawLinePrimitive(segment.position, segment.position + segment.velocity, 5);
		
		lastOrigin = Vector(segment.position.X, segment.position.Y)
		lastSegment = segment
		
		self.chainMovementFactor = self.chainMovementFactor + vel.Magnitude
	end
	
	self.chainMovementFactor = self.chainMovementFactor / #self.chainSegments
	self.chainMovementFactor = math.min(math.max(self.chainMovementFactor - 4, 0.0) * 0.15, 1.0)
	
	--local hudpos = self.Pos + Vector(0, -40)
	--PrimitiveMan:DrawBoxFillPrimitive(hudpos + Vector(-10, -2), hudpos + Vector(-10 + 20 * self.chainMovementFactor, 2), 5)
	
	-- Ball physics and collision
	--[[
	if self.chainBall then
		local pos = Vector(self.chainBall.position.X, self.chainBall.position.Y)
		
		local collisions = 0
		local normal = Vector(0,0)
		
		local radius = self.chainBallRadius * 2.0 + 1
		local maxi = 8
		for i = 1, maxi do
			local angle = (math.pi * 2) / maxi * i
			local vec = Vector(radius, 0):RadRotate(angle)
			local point = pos + vec 
			
			local terrCheck = SceneMan:GetTerrMatter(point.X, point.Y)
			if terrCheck and terrCheck ~= 0 then
				collisions = collisions + 1
				normal = normal + vec
			end
			PrimitiveMan:DrawLinePrimitive(point, point, 5);
			
		end
		if collisions < 2 then
			self.chainBallLastPos = Vector(self.chainBall.position.X, self.chainBall.position.Y)
		end
		
		if collisions > 0 then
			normal = normal.Normalized
			--self.chainBall.velocity = self.chainBall.velocity - Vector(normal.X, normal.Y):SetMagnitude(self.chainBall.velocity.Magnitude) * timeScale * 10
			
			if collisions > maxi * 0.5 then
				self.chainBall.position = Vector(self.chainBallLastPos.X, self.chainBallLastPos.Y)
			end
		end
		
	end]]
	
	self.chainLastOrigin = FlailGetOrigin(self)
end

function Create(self)
	
	self.equipSound = CreateSoundContainer("HaftedSmall Equip Mordhau", "Mordhau.rte");
	self.equipSound.Pitch = 1.0;
	
	self.pickUpSound = CreateSoundContainer("Metal Pickup Mordhau", "Mordhau.rte");
	self.pickUpSound.Pitch = 1.0;

	-- flail chain and physics!
	
	self.chainLastOrigin = FlailGetOrigin(self)
	
	self.chainLength = 3
	self.chainSegmentLength = 3
	self.chainBallMassFactor = 3.0
	self.chainBallRadius = 2
	self.chainSegments = {}
	
	self.chainMovementFactor = 0
	
	for i = 1, self.chainLength do
		self.chainSegments[i] = FlailCreateChainSegment(self, false)
	end
	self.chainSegments[self.chainLength + 1] = FlailCreateChainSegment(self, true)
	
	self.chainBall = self.chainSegments[self.chainLength + 1]
	self.chainBallLastPos = Vector(self.chainBall.position.X, self.chainBall.position.Y)
	
	self.chainHeavyMovement = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	self.chainLoop = CreateSoundContainer("Chain Loop Flail Mordhau", "Mordhau.rte");
	self.chainLoop.Volume = 0;
	self.chainLoop:Play(self.Pos);
	self.chainSwingLoop = CreateSoundContainer("Chain Swing Loop Flail Mordhau", "Mordhau.rte");
	self.chainSwingLoop.Volume = 0;
	self.chainSwingLoop:Play(self.Pos);
	
	self.chainLoopVolumeTarget = 0;
	self.chainSwingLoopVolumeTarget = 0;
	
	-- throwing stuff
	
	self.bounceSound = CreateSoundContainer("Bounce Javelin", "Mordhau.rte");

	self.throwSound = CreateSoundContainer("Throw ThrowingAxe", "Mordhau.rte");
	self.throwSoundPlayed = false;
	
	self.spinSound = CreateSoundContainer("Spin ThrowingAxe", "Mordhau.rte");
	self.spinTimer = Timer();
	self.spinDelay = 170;
	
	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("MeleeTerrainHit Concrete Mordhau", "Mordhau.rte"),
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
			[182] = CreateSoundContainer("MeleeTerrainHit SolidMetal Mordhau", "Mordhau.rte")}}
			
	self.soundHitFlesh = CreateSoundContainer("Slash Flesh Warhammer Mordhau", "Mordhau.rte");
	self.soundHitMetal = CreateSoundContainer("Slash Metal Warhammer Mordhau", "Mordhau.rte");
	

	self.equipAnimationTimer = Timer();
	
	self.swingRotationFrames = 1; -- this is the amount of frames it takes us to go from sideways to facing forwards again (after a swing)
								  -- for swords this might just be one, for big axes it could be as high as 4

	self.originalStanceOffset = Vector(self.StanceOffset.X * self.FlipFactor, self.StanceOffset.Y)
	
	self.originalBaseRotation = -15;
	self.baseRotation = -15;
	
	self.attackAnimations = {}
	self.attackAnimationCanHit = false
	self.attackAnimationsSounds = {}
	self.attackAnimationsGFX = {}
	self.attackAnimationsTypes = {}
	self.attackAnimationTimer = Timer();
	
	self.currentAttackAnimation = 0;
	self.currentAttackSequence = 0;
	self.currentAttackStart = false
	self.attackAnimationIsPlaying = false
	
	self.woundCounter = 0;
	self.breakSound = CreateSoundContainer("Hafted Wound Sound Mordhau", "Mordhau.rte");
	
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
	
	self.blockedSound = CreateSoundContainer("Basic Melee Metal Blocked Mordhau", "Mordhau.rte");
	self.parrySound = CreateSoundContainer("Basic Melee Parry Mordhau", "Mordhau.rte");
	self.heavyBlockAddSound = CreateSoundContainer("Basic Melee Wood HeavyBlockAdd Mordhau", "Mordhau.rte");
	
	self.blockSounds = {};
	self.blockSounds.Slash = CreateSoundContainer("Basic Melee Wood Block Mordhau", "Mordhau.rte");
	self.blockSounds.Stab = CreateSoundContainer("Stab Block Warhammer Mordhau", "Mordhau.rte");
	
	self.blockGFX = {};
	self.blockGFX.Slash = "Slash Block Effect Mordhau";
	self.blockGFX.Stab = "Stab Block Effect Mordhau";
	self.blockGFX.Heavy = "Heavy Block Effect Mordhau";
	self.blockGFX.Parry = "Parry Effect Mordhau";
	
	self.parriedCooldown = false;
	self.parriedCooldownTimer = Timer();
	self.parriedCooldownDelay = 1200;
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--regularAttackSounds.hitDefaultSound
	--regularAttackSounds.hitDefaultSoundVariations
	
	regularAttackSounds.hitDeflectSound = CreateSoundContainer("Slash Metal Warhammer Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitFleshSound = CreateSoundContainer("Slash Flesh Warhammer Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitMetalSound = CreateSoundContainer("Slash Metal Warhammer Mordhau", "Mordhau.rte");
	
	local stabAttackSounds = {}
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--stabAttackSounds.hitDefaultSound
	--stabAttackSounds.hitDefaultSoundVariations
	
	stabAttackSounds.hitDeflectSound = CreateSoundContainer("Stab Metal Warhammer Mordhau", "Mordhau.rte");
	
	stabAttackSounds.hitFleshSound = CreateSoundContainer("Stab Flesh Warhammer Mordhau", "Mordhau.rte");
	
	stabAttackSounds.hitMetalSound = CreateSoundContainer("Stab Metal Warhammer Mordhau", "Mordhau.rte");
	
	local regularAttackGFX = {}
	
	regularAttackGFX.hitTerrainSoftGFX = "Melee Terrain Soft Effect Mordhau"
	regularAttackGFX.hitTerrainHardGFX = "Melee Terrain Hard Effect Mordhau"
	regularAttackGFX.hitFleshGFX = "Melee Flesh Effect Mordhau"
	regularAttackGFX.hitMetalGFX = "Melee Terrain Hard Effect Mordhau"
	regularAttackGFX.hitDeflectGFX = "Melee Terrain Hard Effect Mordhau"
	
	self:SetNumberValue("Attack Types", 4)
	
	-- Regular Attack
	attackPhase = {}
	attackPhase.Type = "Slash";
	
	-- Prepare
	i = 1
	attackPhase[i] = {}
	attackPhase[i].durationMS = 300
	
	attackPhase[i].canBeBlocked = false
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].furthestReach = 25 -- for AI calculation number value setting later
	attackPhase[i].attackRange = 20
	self:SetNumberValue("Attack 1 Range", attackPhase[i].furthestReach + attackPhase[i].attackRange)
	self:SetStringValue("Attack 1 Name", "Swing");
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 90;
	
	attackPhase[i].frameStart = 6
	attackPhase[i].frameEnd = 10
	attackPhase[i].angleStart = 0
	attackPhase[i].angleEnd = -45
	attackPhase[i].offsetStart = Vector(0, 0)
	attackPhase[i].offsetEnd = Vector(4, 10)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = CreateSoundContainer("Slash Flail Mordhau", "Mordhau.rte");
	attackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	attackPhase[i] = {}
	attackPhase[i].durationMS = 250
	
	attackPhase[i].lastPrepare = true
	attackPhase[i].canBeBlocked = false
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 0;
	
	attackPhase[i].frameStart = 10
	attackPhase[i].frameEnd = 6
	attackPhase[i].angleStart = -45
	attackPhase[i].angleEnd = 70
	attackPhase[i].offsetStart = Vector(0, 10)
	attackPhase[i].offsetEnd = Vector(-10, -10)
	
	attackPhase[i].soundStart = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	attackPhase[i] = {}
	attackPhase[i].durationMS = 110
	
	attackPhase[i].canBeBlocked = true
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 3.4
	attackPhase[i].attackStunChance = 0.15
	attackPhase[i].attackRange = 21
	attackPhase[i].attackPush = 0.8
	attackPhase[i].attackVector = Vector(4, 8) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 0;
	
	attackPhase[i].frameStart = 7
	attackPhase[i].frameEnd = 11
	attackPhase[i].angleStart = 70
	attackPhase[i].angleEnd = -50
	attackPhase[i].offsetStart = Vector(-6, -10)
	attackPhase[i].offsetEnd = Vector(7, -10)
	
	attackPhase[i].soundStart = nil
	
	attackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	attackPhase[i] = {}
	attackPhase[i].durationMS = 30
	
	attackPhase[i].canBeBlocked = true
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 3.4
	attackPhase[i].attackStunChance = 0.15
	attackPhase[i].attackRange = 21
	attackPhase[i].attackPush = 0.8
	attackPhase[i].attackVector = Vector(4, 8) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 70;
	
	attackPhase[i].frameStart = 11
	attackPhase[i].frameEnd = 11
	attackPhase[i].angleStart = -50
	attackPhase[i].angleEnd = -90
	attackPhase[i].offsetStart = Vector(7, -10)
	attackPhase[i].offsetEnd = Vector(7, -2)
	
	attackPhase[i].soundStart = nil
	
	attackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	attackPhase[i] = {}
	attackPhase[i].durationMS = 110
	
	attackPhase[i].canBeBlocked = true
	attackPhase[i].canDamage = true
	attackPhase[i].attackDamage = 3.4
	attackPhase[i].attackStunChance = 0.05
	attackPhase[i].attackRange = 20
	attackPhase[i].attackPush = 0.8
	attackPhase[i].attackVector = Vector(0, 8) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 90;
	
	attackPhase[i].frameStart = 11
	attackPhase[i].frameEnd = 16
	attackPhase[i].angleStart = -90
	attackPhase[i].angleEnd = -100
	attackPhase[i].offsetStart = Vector(7 , -2)
	attackPhase[i].offsetEnd = Vector(15, -4)
	
	attackPhase[i].soundStart = nil
	
	attackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	attackPhase[i] = {}
	attackPhase[i].durationMS = 50
	
	attackPhase[i].firstRecovery = true
	attackPhase[i].canBeBlocked = false
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 90;
	
	attackPhase[i].frameStart = 16
	attackPhase[i].frameEnd = (16 + 1 + self.swingRotationFrames); -- + 1 because the actual end frame is never reached, code just goes TOWARDS it
	attackPhase[i].angleStart = -90
	attackPhase[i].angleEnd = -80
	attackPhase[i].offsetStart = Vector(15, -4)
	attackPhase[i].offsetEnd = Vector(10, 0)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
	attackPhase[i] = {}
	attackPhase[i].durationMS = 150
	
	attackPhase[i].canBeBlocked = false
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 90;
	
	attackPhase[i].frameStart = 6
	attackPhase[i].frameEnd = 6
	attackPhase[i].angleStart = -80
	attackPhase[i].angleEnd = -25
	attackPhase[i].offsetStart = Vector(10, 0)
	attackPhase[i].offsetEnd = Vector(-2, 0)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Late Recover
	i = 8
	attackPhase[i] = {}
	attackPhase[i].durationMS = 100
	
	attackPhase[i].canBeBlocked = false
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 90;
	
	attackPhase[i].frameStart = 6
	attackPhase[i].frameEnd = 7
	attackPhase[i].angleStart = -25
	attackPhase[i].angleEnd = -25
	attackPhase[i].offsetStart = Vector(-2, 0)
	attackPhase[i].offsetEnd = Vector(-3, 0)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Late Late Recover
	i = 9
	attackPhase[i] = {}
	attackPhase[i].durationMS = 80
	
	attackPhase[i].canBeBlocked = false
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 90;
	
	attackPhase[i].frameStart = 7
	attackPhase[i].frameEnd = 6
	attackPhase[i].angleStart = -25
	attackPhase[i].angleEnd = -15
	attackPhase[i].offsetStart = Vector(-3, 0)
	attackPhase[i].offsetEnd = Vector(0, 0)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[1] = regularAttackSounds
	self.attackAnimationsGFX[1] = regularAttackGFX
	self.attackAnimations[1] = attackPhase
	self.attackAnimationsTypes[1] = attackPhase.Type
	
	-- Regular Attack
	horseAttackPhase = {}
	horseAttackPhase.Type = "Slash";
	
	-- Prepare
	i = 1
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 190
	
	horseAttackPhase[i].canBeBlocked = false
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 0
	horseAttackPhase[i].attackStunChance = 0
	horseAttackPhase[i].furthestReach = 25 -- for AI calculation number value setting later
	horseAttackPhase[i].attackRange = 18
	self:SetNumberValue("Attack 2 Range", horseAttackPhase[i].furthestReach + horseAttackPhase[i].attackRange)
	self:SetStringValue("Attack 2 Name", "Horse Swing");
	horseAttackPhase[i].attackPush = 0
	horseAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 90;
	
	horseAttackPhase[i].frameStart = 6
	horseAttackPhase[i].frameEnd = 11
	horseAttackPhase[i].angleStart = -15
	horseAttackPhase[i].angleEnd = -180
	horseAttackPhase[i].offsetStart = Vector(0, 0)
	horseAttackPhase[i].offsetEnd = Vector(-6, 0)
	
	horseAttackPhase[i].soundStart = nil
	horseAttackPhase[i].soundStartVariations = 0
	
	horseAttackPhase[i].soundEnd = nil
	horseAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 300
	
	horseAttackPhase[i].lastPrepare = true
	horseAttackPhase[i].canBeBlocked = false
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 0
	horseAttackPhase[i].attackStunChance = 0
	horseAttackPhase[i].attackRange = 0
	horseAttackPhase[i].attackPush = 0
	horseAttackPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 0;
	
	horseAttackPhase[i].frameStart = 11
	horseAttackPhase[i].frameEnd = 9
	horseAttackPhase[i].angleStart = -180
	horseAttackPhase[i].angleEnd = -300
	horseAttackPhase[i].offsetStart = Vector(-6, 0)
	horseAttackPhase[i].offsetEnd = Vector(-15, -5)
	
	horseAttackPhase[i].soundStart = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	horseAttackPhase[i].soundStartVariations = 0
	
	horseAttackPhase[i].soundEnd = nil
	horseAttackPhase[i].soundEndVariations = 0
	
	-- Late Late Prepare
	i = 3
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 300
	
	horseAttackPhase[i].lastPrepare = true
	horseAttackPhase[i].canBeBlocked = false
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 0
	horseAttackPhase[i].attackStunChance = 0
	horseAttackPhase[i].attackRange = 0
	horseAttackPhase[i].attackPush = 0
	horseAttackPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 0;
	
	horseAttackPhase[i].frameStart = 9
	horseAttackPhase[i].frameEnd = 9
	horseAttackPhase[i].angleStart = -300
	horseAttackPhase[i].angleEnd = -295
	horseAttackPhase[i].offsetStart = Vector(-15, -5)
	horseAttackPhase[i].offsetEnd = Vector(-15, -6)
	
	horseAttackPhase[i].soundStart = nil
	horseAttackPhase[i].soundStartVariations = 0
	
	horseAttackPhase[i].soundEnd = CreateSoundContainer("Slash Flail Mordhau", "Mordhau.rte");
	horseAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 4
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 110
	
	horseAttackPhase[i].canBeBlocked = true
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 3.4
	horseAttackPhase[i].attackStunChance = 0.05
	horseAttackPhase[i].attackRange = 19
	horseAttackPhase[i].attackPush = 0.8
	horseAttackPhase[i].attackVector = Vector(0, 8) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 167;
	
	horseAttackPhase[i].frameStart = 9
	horseAttackPhase[i].frameEnd = 9
	horseAttackPhase[i].angleStart = -300
	horseAttackPhase[i].angleEnd = -220
	horseAttackPhase[i].offsetStart = Vector(-15, -6)
	horseAttackPhase[i].offsetEnd = Vector(-7, 2)
	
	horseAttackPhase[i].soundStart = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	
	horseAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 5
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 30
	
	horseAttackPhase[i].canBeBlocked = true
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 3.4
	horseAttackPhase[i].attackStunChance = 0.05
	horseAttackPhase[i].attackRange = 19
	horseAttackPhase[i].attackPush = 0.8
	horseAttackPhase[i].attackVector = Vector(0, 8) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 145;
	
	horseAttackPhase[i].frameStart = 9
	horseAttackPhase[i].frameEnd = 9
	horseAttackPhase[i].angleStart = -220
	horseAttackPhase[i].angleEnd = -200
	horseAttackPhase[i].offsetStart = Vector(-7, 2)
	horseAttackPhase[i].offsetEnd = Vector(0, 3)
	
	horseAttackPhase[i].soundStart = nil
	
	horseAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 6
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 135
	
	horseAttackPhase[i].canBeBlocked = true
	horseAttackPhase[i].canDamage = true
	horseAttackPhase[i].attackDamage = 3.4
	horseAttackPhase[i].attackStunChance = 0.05
	horseAttackPhase[i].attackRange = 18
	horseAttackPhase[i].attackPush = 0.8
	horseAttackPhase[i].attackVector = Vector(0, 8) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 110;
	
	horseAttackPhase[i].frameStart = 9
	horseAttackPhase[i].frameEnd = 9
	horseAttackPhase[i].angleStart = -200
	horseAttackPhase[i].angleEnd = -45
	horseAttackPhase[i].offsetStart = Vector(0 , 3)
	horseAttackPhase[i].offsetEnd = Vector(15, 7)
	
	horseAttackPhase[i].soundStart = nil
	
	horseAttackPhase[i].soundEnd = nil
	
	-- Turn Around 90
	i = 7
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 50
	
	horseAttackPhase[i].firstRecovery = false
	horseAttackPhase[i].canBeBlocked = false
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 0
	horseAttackPhase[i].attackStunChance = 0
	horseAttackPhase[i].attackRange = 0
	horseAttackPhase[i].attackPush = 0
	horseAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 90;
	
	horseAttackPhase[i].frameStart = 9
	horseAttackPhase[i].frameEnd = 9
	horseAttackPhase[i].angleStart = -45
	horseAttackPhase[i].angleEnd = -40
	horseAttackPhase[i].offsetStart = Vector(15, 7)
	horseAttackPhase[i].offsetEnd = Vector(10, 0)
	
	horseAttackPhase[i].soundStart = nil
	horseAttackPhase[i].soundStartVariations = 0
	
	horseAttackPhase[i].soundEnd = nil
	horseAttackPhase[i].soundEndVariations = 0
	
	-- Turn Around 90 again
	i = 8
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 50
	
	horseAttackPhase[i].firstRecovery = true
	horseAttackPhase[i].canBeBlocked = false
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 0
	horseAttackPhase[i].attackStunChance = 0
	horseAttackPhase[i].attackRange = 0
	horseAttackPhase[i].attackPush = 0
	horseAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 90;
	
	horseAttackPhase[i].frameStart = 9
	horseAttackPhase[i].frameEnd = 9
	horseAttackPhase[i].angleStart = -40
	horseAttackPhase[i].angleEnd = -43
	horseAttackPhase[i].offsetStart = Vector(15, 7)
	horseAttackPhase[i].offsetEnd = Vector(10, 0)
	
	horseAttackPhase[i].soundStart = nil
	horseAttackPhase[i].soundStartVariations = 0
	
	horseAttackPhase[i].soundEnd = nil
	horseAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 9
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 150
	
	horseAttackPhase[i].canBeBlocked = false
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 0
	horseAttackPhase[i].attackStunChance = 0
	horseAttackPhase[i].attackRange = 0
	horseAttackPhase[i].attackPush = 0
	horseAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 90;
	
	horseAttackPhase[i].frameStart = 9
	horseAttackPhase[i].frameEnd = 6
	horseAttackPhase[i].angleStart = -43
	horseAttackPhase[i].angleEnd = -25
	horseAttackPhase[i].offsetStart = Vector(10, 0)
	horseAttackPhase[i].offsetEnd = Vector(-2, 0)
	
	horseAttackPhase[i].soundStart = nil
	horseAttackPhase[i].soundStartVariations = 0
	
	horseAttackPhase[i].soundEnd = nil
	horseAttackPhase[i].soundEndVariations = 0
	
	-- Late Recover
	i = 10
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 100
	
	horseAttackPhase[i].canBeBlocked = false
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 0
	horseAttackPhase[i].attackStunChance = 0
	horseAttackPhase[i].attackRange = 0
	horseAttackPhase[i].attackPush = 0
	horseAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 90;
	
	horseAttackPhase[i].frameStart = 6
	horseAttackPhase[i].frameEnd = 7
	horseAttackPhase[i].angleStart = -25
	horseAttackPhase[i].angleEnd = -25
	horseAttackPhase[i].offsetStart = Vector(-2, 0)
	horseAttackPhase[i].offsetEnd = Vector(-3, 0)
	
	horseAttackPhase[i].soundStart = nil
	horseAttackPhase[i].soundStartVariations = 0
	
	horseAttackPhase[i].soundEnd = nil
	horseAttackPhase[i].soundEndVariations = 0
	
	-- Late Late Recover
	i = 11
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 80
	
	horseAttackPhase[i].canBeBlocked = false
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 0
	horseAttackPhase[i].attackStunChance = 0
	horseAttackPhase[i].attackRange = 0
	horseAttackPhase[i].attackPush = 0
	horseAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 90;
	
	horseAttackPhase[i].frameStart = 7
	horseAttackPhase[i].frameEnd = 6
	horseAttackPhase[i].angleStart = -25
	horseAttackPhase[i].angleEnd = -15
	horseAttackPhase[i].offsetStart = Vector(-3, 0)
	horseAttackPhase[i].offsetEnd = Vector(0, 0)
	
	horseAttackPhase[i].soundStart = nil
	horseAttackPhase[i].soundStartVariations = 0
	
	horseAttackPhase[i].soundEnd = nil
	horseAttackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[15] = regularAttackSounds
	self.attackAnimationsGFX[15] = regularAttackGFX
	self.attackAnimations[15] = horseAttackPhase
	self.attackAnimationsTypes[15] = horseAttackPhase.Type
	
	-- Regular Attack
	stabAttackPhase = {}
	stabAttackPhase.Type = "Slash";
	
	-- Prepare
	i = 1
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 300
	
	stabAttackPhase[i].canBeBlocked = false
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 0
	stabAttackPhase[i].attackStunChance = 0
	stabAttackPhase[i].furthestReach = 25 -- for AI calculation number value setting later
	stabAttackPhase[i].attackRange = 20
	self:SetNumberValue("Attack 2 Range", stabAttackPhase[i].furthestReach + stabAttackPhase[i].attackRange)
	self:SetStringValue("Attack 2 Name", "Stab");
	stabAttackPhase[i].attackPush = 0
	stabAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 10
	stabAttackPhase[i].angleStart = 0
	stabAttackPhase[i].angleEnd = -45
	stabAttackPhase[i].offsetStart = Vector(0, 0)
	stabAttackPhase[i].offsetEnd = Vector(4, -10)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 250
	
	stabAttackPhase[i].lastPrepare = true
	stabAttackPhase[i].canBeBlocked = false
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 0
	stabAttackPhase[i].attackStunChance = 0
	stabAttackPhase[i].attackRange = 0
	stabAttackPhase[i].attackPush = 0
	stabAttackPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 0;
	
	stabAttackPhase[i].frameStart = 10
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -45
	stabAttackPhase[i].angleEnd = 70
	stabAttackPhase[i].offsetStart = Vector(0, -10)
	stabAttackPhase[i].offsetEnd = Vector(-10, 10)
	
	stabAttackPhase[i].soundStart = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 110
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 3.4
	stabAttackPhase[i].attackStunChance = 0.15
	stabAttackPhase[i].attackRange = 21
	stabAttackPhase[i].attackPush = 0.8
	stabAttackPhase[i].attackVector = Vector(4, 8) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 0;
	
	stabAttackPhase[i].frameStart = 7
	stabAttackPhase[i].frameEnd = 11
	stabAttackPhase[i].angleStart = 70
	stabAttackPhase[i].angleEnd = -50
	stabAttackPhase[i].offsetStart = Vector(-6, 6)
	stabAttackPhase[i].offsetEnd = Vector(7, 6)
	
	stabAttackPhase[i].soundStart = CreateSoundContainer("Slash Flail Mordhau", "Mordhau.rte");
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 30
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 3.4
	stabAttackPhase[i].attackStunChance = 0.15
	stabAttackPhase[i].attackRange = 21
	stabAttackPhase[i].attackPush = 0.8
	stabAttackPhase[i].attackVector = Vector(4, 8) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 70;
	
	stabAttackPhase[i].frameStart = 11
	stabAttackPhase[i].frameEnd = 11
	stabAttackPhase[i].angleStart = -50
	stabAttackPhase[i].angleEnd = -90
	stabAttackPhase[i].offsetStart = Vector(7, 6)
	stabAttackPhase[i].offsetEnd = Vector(7, 2)
	
	stabAttackPhase[i].soundStart = nil
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 110
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = true
	stabAttackPhase[i].attackDamage = 3.4
	stabAttackPhase[i].attackStunChance = 0.05
	stabAttackPhase[i].attackRange = 20
	stabAttackPhase[i].attackPush = 0.8
	stabAttackPhase[i].attackVector = Vector(0, 8) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 11
	stabAttackPhase[i].frameEnd = 16
	stabAttackPhase[i].angleStart = -90
	stabAttackPhase[i].angleEnd = -100
	stabAttackPhase[i].offsetStart = Vector(7 , 2)
	stabAttackPhase[i].offsetEnd = Vector(15, -4)
	
	stabAttackPhase[i].soundStart = nil
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 50
	
	stabAttackPhase[i].firstRecovery = true
	stabAttackPhase[i].canBeBlocked = false
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 0
	stabAttackPhase[i].attackStunChance = 0
	stabAttackPhase[i].attackRange = 0
	stabAttackPhase[i].attackPush = 0
	stabAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 16
	stabAttackPhase[i].frameEnd = (16 + 1 + self.swingRotationFrames); -- + 1 because the actual end frame is never reached, code just goes TOWARDS it
	stabAttackPhase[i].angleStart = -90
	stabAttackPhase[i].angleEnd = -80
	stabAttackPhase[i].offsetStart = Vector(15, -4)
	stabAttackPhase[i].offsetEnd = Vector(10, 0)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 150
	
	stabAttackPhase[i].canBeBlocked = false
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 0
	stabAttackPhase[i].attackStunChance = 0
	stabAttackPhase[i].attackRange = 0
	stabAttackPhase[i].attackPush = 0
	stabAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -80
	stabAttackPhase[i].angleEnd = -25
	stabAttackPhase[i].offsetStart = Vector(10, 0)
	stabAttackPhase[i].offsetEnd = Vector(-2, 0)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Late Recover
	i = 8
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 100
	
	stabAttackPhase[i].canBeBlocked = false
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 0
	stabAttackPhase[i].attackStunChance = 0
	stabAttackPhase[i].attackRange = 0
	stabAttackPhase[i].attackPush = 0
	stabAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 7
	stabAttackPhase[i].angleStart = -25
	stabAttackPhase[i].angleEnd = -25
	stabAttackPhase[i].offsetStart = Vector(-2, 0)
	stabAttackPhase[i].offsetEnd = Vector(-3, 0)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Late Late Recover
	i = 9
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 80
	
	stabAttackPhase[i].canBeBlocked = false
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 0
	stabAttackPhase[i].attackStunChance = 0
	stabAttackPhase[i].attackRange = 0
	stabAttackPhase[i].attackPush = 0
	stabAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 7
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -25
	stabAttackPhase[i].angleEnd = -15
	stabAttackPhase[i].offsetStart = Vector(-3, 0)
	stabAttackPhase[i].offsetEnd = Vector(0, 0)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[2] = regularAttackSounds
	self.attackAnimationsGFX[2] = regularAttackGFX
	self.attackAnimations[2] = stabAttackPhase
	self.attackAnimationsTypes[2] = stabAttackPhase.Type
	
	-- Charged Attack

	overheadAttackPhase = {}
	overheadAttackPhase.Type = "Slash";
	
	-- Prepare
	i = 1
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 300
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].furthestReach = 25 -- for AI calculation number value setting later
	overheadAttackPhase[i].attackRange = 19
	self:SetNumberValue("Attack 4 Range", overheadAttackPhase[i].furthestReach + overheadAttackPhase[i].attackRange)
	self:SetStringValue("Attack 4 Name", "Overhead");
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 10
	overheadAttackPhase[i].angleStart = -15
	overheadAttackPhase[i].angleEnd = 90
	overheadAttackPhase[i].offsetStart = Vector(0, 0)
	overheadAttackPhase[i].offsetEnd = Vector(-5,-4)
	
	-- Late Prepare
	i = 2
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 300
	
	overheadAttackPhase[i].lastPrepare = true
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 11
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = 90
	overheadAttackPhase[i].angleEnd = 0
	overheadAttackPhase[i].offsetStart = Vector(-5, -13)
	overheadAttackPhase[i].offsetEnd = Vector(-4, -13)
	
	overheadAttackPhase[i].soundStart = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	overheadAttackPhase[i].soundStartVariations = 0
	
	overheadAttackPhase[i].soundEnd = CreateSoundContainer("Slash Flail Mordhau", "Mordhau.rte");
	overheadAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 3
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 40
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 5
	overheadAttackPhase[i].attackStunChance = 0.3
	overheadAttackPhase[i].attackRange = 20
	overheadAttackPhase[i].attackPush = 0.8
	overheadAttackPhase[i].attackVector = Vector(0, 8) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = 55;
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = 0
	overheadAttackPhase[i].angleEnd = 20
	overheadAttackPhase[i].offsetStart = Vector(-4, -13)
	overheadAttackPhase[i].offsetEnd = Vector(6, -10)
	
	overheadAttackPhase[i].soundStart = nil
	
	overheadAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 4
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 120
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = true
	overheadAttackPhase[i].attackDamage = 4
	overheadAttackPhase[i].attackStunChance = 0.3
	overheadAttackPhase[i].attackRange = 19
	overheadAttackPhase[i].attackPush = 1.0
	overheadAttackPhase[i].attackVector = Vector(0, 8) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = 75;
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = 20
	overheadAttackPhase[i].angleEnd = -150
	overheadAttackPhase[i].offsetStart = Vector(6, -10)
	overheadAttackPhase[i].offsetEnd = Vector(15, 15)
	
	-- Early Recover
	i = 5
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 60
	
	overheadAttackPhase[i].firstRecovery = true	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = -120
	overheadAttackPhase[i].angleEnd = -150
	overheadAttackPhase[i].offsetStart = Vector(15, 15)
	overheadAttackPhase[i].offsetEnd = Vector(10, 15)
	
	-- Recover
	i = 6
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 250
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = -120
	overheadAttackPhase[i].angleEnd = -15
	overheadAttackPhase[i].offsetStart = Vector(10, 15)
	overheadAttackPhase[i].offsetEnd = Vector(3, -5)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[3] = regularAttackSounds
	self.attackAnimationsGFX[3] = regularAttackGFX
	self.attackAnimations[3] = overheadAttackPhase
	self.attackAnimationsTypes[3] = overheadAttackPhase.Type
	
	-- why have a flail if you can't twirl it? Twirl Start
	twirlStartPhase = {}
	twirlStartPhase.Type = "Twirl";
	
	-- Wind
	i = 1
	twirlStartPhase[i] = {}
	twirlStartPhase[i].durationMS = 200

	twirlStartPhase[i].canBeBlocked = false
	twirlStartPhase[i].canDamage = false
	twirlStartPhase[i].attackDamage = 0
	twirlStartPhase[i].attackStunChance = 0
	twirlStartPhase[i].attackRange = 0
	twirlStartPhase[i].attackPush = 0
	twirlStartPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	twirlStartPhase[i].attackAngle = 90;
	
	twirlStartPhase[i].frameStart = 6
	twirlStartPhase[i].frameEnd = 6
	twirlStartPhase[i].angleStart = 0
	twirlStartPhase[i].angleEnd = -45
	twirlStartPhase[i].offsetStart = Vector(0, 0)
	twirlStartPhase[i].offsetEnd = Vector(0, 0)
	
	twirlStartPhase[i].soundStart = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	
	-- Back
	i = 2
	twirlStartPhase[i] = {}
	twirlStartPhase[i].durationMS = 150
	
	twirlStartPhase[i].canBeBlocked = false
	twirlStartPhase[i].canDamage = false
	twirlStartPhase[i].attackDamage = 0
	twirlStartPhase[i].attackStunChance = 0
	twirlStartPhase[i].attackRange = 0
	twirlStartPhase[i].attackPush = 0
	twirlStartPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	twirlStartPhase[i].attackAngle = 90;
	
	twirlStartPhase[i].frameStart = 6
	twirlStartPhase[i].frameEnd = 11
	twirlStartPhase[i].angleStart = -45
	twirlStartPhase[i].angleEnd = 90
	twirlStartPhase[i].offsetStart = Vector(0, 0)
	twirlStartPhase[i].offsetEnd = Vector(-6, -5)
	
	twirlStartPhase[i].soundStart = CreateSoundContainer("Flourish Flail Mordhau", "Mordhau.rte");
	
	-- Combo Phase
	i = 3
	twirlStartPhase[i] = {}
	twirlStartPhase[i].durationMS = 0
	
	twirlStartPhase[i].twirlComboPhase = true;
	twirlStartPhase[i].canBeBlocked = false
	twirlStartPhase[i].canDamage = false
	twirlStartPhase[i].attackDamage = 0
	twirlStartPhase[i].attackStunChance = 0
	twirlStartPhase[i].attackRange = 0
	twirlStartPhase[i].attackPush = 0
	twirlStartPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	twirlStartPhase[i].attackAngle = 0;
	
	twirlStartPhase[i].frameStart = 11
	twirlStartPhase[i].frameEnd = 11
	twirlStartPhase[i].angleStart = 90
	twirlStartPhase[i].angleEnd = 90
	twirlStartPhase[i].offsetStart = Vector(-6, -5)
	twirlStartPhase[i].offsetEnd = Vector(-6, -5)
	
	twirlStartPhase[i].soundStart = nil
	twirlStartPhase[i].soundStartVariations = 0
	
	twirlStartPhase[i].soundEnd = nil
	twirlStartPhase[i].soundEndVariations = 0	
	
	-- Forward
	i = 4
	twirlStartPhase[i] = {}
	twirlStartPhase[i].durationMS = 120
	
	twirlStartPhase[i].canBeBlocked = false
	twirlStartPhase[i].canDamage = false
	twirlStartPhase[i].attackDamage = 0
	twirlStartPhase[i].attackStunChance = 0
	twirlStartPhase[i].attackRange = 0
	twirlStartPhase[i].attackPush = 0
	twirlStartPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	twirlStartPhase[i].attackAngle = 0;
	
	twirlStartPhase[i].frameStart = 11
	twirlStartPhase[i].frameEnd = 6
	twirlStartPhase[i].angleStart = 90
	twirlStartPhase[i].angleEnd = 45
	twirlStartPhase[i].offsetStart = Vector(-6, -5)
	twirlStartPhase[i].offsetEnd = Vector(-6, -5)
	
	twirlStartPhase[i].soundStart = nil
	twirlStartPhase[i].soundStartVariations = 0
	
	twirlStartPhase[i].soundEnd = nil
	twirlStartPhase[i].soundEndVariations = 0
	
	-- Forwarder
	i = 5
	twirlStartPhase[i] = {}
	twirlStartPhase[i].durationMS = 150
	
	twirlStartPhase[i].canBeBlocked = false
	twirlStartPhase[i].canDamage = false
	twirlStartPhase[i].attackDamage = 3.4
	twirlStartPhase[i].attackStunChance = 0.15
	twirlStartPhase[i].attackRange = 20
	twirlStartPhase[i].attackPush = 0.8
	twirlStartPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	twirlStartPhase[i].attackAngle = 0;
	
	twirlStartPhase[i].frameStart = 6
	twirlStartPhase[i].frameEnd = 7
	twirlStartPhase[i].angleStart = 45
	twirlStartPhase[i].angleEnd = -20
	twirlStartPhase[i].offsetStart = Vector(-6, -5)
	twirlStartPhase[i].offsetEnd = Vector(7, -2)
	
	-- End
	i = 6
	twirlStartPhase[i] = {}
	twirlStartPhase[i].durationMS = 100
	
	twirlStartPhase[i].twirlEnd = true
	twirlStartPhase[i].canBeBlocked = false
	twirlStartPhase[i].canDamage = false
	twirlStartPhase[i].attackDamage = 3.4
	twirlStartPhase[i].attackStunChance = 0.15
	twirlStartPhase[i].attackRange = 20
	twirlStartPhase[i].attackPush = 0.8
	twirlStartPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	twirlStartPhase[i].attackAngle = 0;
	
	twirlStartPhase[i].frameStart = 7
	twirlStartPhase[i].frameEnd = 7
	twirlStartPhase[i].angleStart = -20
	twirlStartPhase[i].angleEnd = -20
	twirlStartPhase[i].offsetStart = Vector(7, -2)
	twirlStartPhase[i].offsetEnd = Vector(7, -2)
	
	twirlStartPhase[i].soundEnd = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[11] = regularAttackSounds
	self.attackAnimationsGFX[11] = regularAttackGFX
	self.attackAnimations[11] = twirlStartPhase
	self.attackAnimationsTypes[11] = twirlStartPhase.Type

	-- Twirl Continue
	twirlPhase = {}
	twirlPhase.Type = "Twirl";
	
	-- Combo Placeholder
	i = 1
	twirlPhase[i] = {}
	twirlPhase[i].durationMS = 150
	
	twirlPhase[i].canBeBlocked = false
	twirlPhase[i].canDamage = false
	twirlPhase[i].attackDamage = 0
	twirlPhase[i].attackStunChance = 0
	twirlPhase[i].attackRange = 0
	twirlPhase[i].attackPush = 0
	twirlPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	twirlPhase[i].attackAngle = 90;
	
	twirlPhase[i].frameStart = 6
	twirlPhase[i].frameEnd = 11
	twirlPhase[i].angleStart = -90
	twirlPhase[i].angleEnd = 90
	twirlPhase[i].offsetStart = Vector(0, 0)
	twirlPhase[i].offsetEnd = Vector(-6, -5)
	
	-- Combo Phase
	i = 2
	twirlPhase[i] = {}
	twirlPhase[i].durationMS = 0
	
	twirlPhase[i].twirlComboPhase = true;
	twirlPhase[i].canBeBlocked = false
	twirlPhase[i].canDamage = false
	twirlPhase[i].attackDamage = 0
	twirlPhase[i].attackStunChance = 0
	twirlPhase[i].attackRange = 0
	twirlPhase[i].attackPush = 0
	twirlPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	twirlPhase[i].attackAngle = 0;
	
	twirlPhase[i].frameStart = 11
	twirlPhase[i].frameEnd = 11
	twirlPhase[i].angleStart = 90
	twirlPhase[i].angleEnd = 90
	twirlPhase[i].offsetStart = Vector(-6, -5)
	twirlPhase[i].offsetEnd = Vector(-6, -5)
	
	twirlPhase[i].soundStart = nil
	twirlPhase[i].soundStartVariations = 0
	
	twirlPhase[i].soundEnd = nil
	twirlPhase[i].soundEndVariations = 0	
	
	-- Forward
	i = 3
	twirlPhase[i] = {}
	twirlPhase[i].durationMS = 120
	
	twirlPhase[i].canBeBlocked = false
	twirlPhase[i].canDamage = false
	twirlPhase[i].attackDamage = 0
	twirlPhase[i].attackStunChance = 0
	twirlPhase[i].attackRange = 0
	twirlPhase[i].attackPush = 0
	twirlPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	twirlPhase[i].attackAngle = 0;
	
	twirlPhase[i].frameStart = 11
	twirlPhase[i].frameEnd = 6
	twirlPhase[i].angleStart = 90
	twirlPhase[i].angleEnd = 45
	twirlPhase[i].offsetStart = Vector(-6, -5)
	twirlPhase[i].offsetEnd = Vector(-6, -5)
	
	twirlPhase[i].soundStart = CreateSoundContainer("FlourishContinue Flail Mordhau", "Mordhau.rte");
	twirlPhase[i].soundStartVariations = 0
	
	twirlPhase[i].soundEnd = nil
	twirlPhase[i].soundEndVariations = 0
	
	-- Forwarder
	i = 4
	twirlPhase[i] = {}
	twirlPhase[i].durationMS = 100
	
	twirlPhase[i].canBeBlocked = false
	twirlPhase[i].canDamage = false
	twirlPhase[i].attackDamage = 3.4
	twirlPhase[i].attackStunChance = 0.15
	twirlPhase[i].attackRange = 20
	twirlPhase[i].attackPush = 0.8
	twirlPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	twirlPhase[i].attackAngle = 0;
	
	twirlPhase[i].frameStart = 6
	twirlPhase[i].frameEnd = 7
	twirlPhase[i].angleStart = 45
	twirlPhase[i].angleEnd = -20
	twirlPhase[i].offsetStart = Vector(-6, -5)
	twirlPhase[i].offsetEnd = Vector(7, -2)
	
	twirlPhase[i].soundEnd = nil
	
	-- End
	i = 5
	twirlPhase[i] = {}
	twirlPhase[i].durationMS = 100
	
	twirlPhase[i].twirlEnd = true
	twirlPhase[i].canBeBlocked = false
	twirlPhase[i].canDamage = false
	twirlPhase[i].attackDamage = 3.4
	twirlPhase[i].attackStunChance = 0.15
	twirlPhase[i].attackRange = 20
	twirlPhase[i].attackPush = 0.8
	twirlPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	twirlPhase[i].attackAngle = 0;
	
	twirlPhase[i].frameStart = 7
	twirlPhase[i].frameEnd = 7
	twirlPhase[i].angleStart = -20
	twirlPhase[i].angleEnd = -20
	twirlPhase[i].offsetStart = Vector(7, -2)
	twirlPhase[i].offsetEnd = Vector(7, -2)
	
	twirlPhase[i].soundEnd = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[12] = regularAttackSounds
	self.attackAnimationsGFX[12] = regularAttackGFX
	self.attackAnimations[12] = twirlPhase
	self.attackAnimationsTypes[12] = twirlPhase.Type
	
	warcryPhase = {}
	warcryPhase.Type = "Twirl";
	
	-- Wind
	i = 1
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 200

	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 90;
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 6
	warcryPhase[i].angleStart = 0
	warcryPhase[i].angleEnd = -45
	warcryPhase[i].offsetStart = Vector(0, 0)
	warcryPhase[i].offsetEnd = Vector(0, 0)
	
	warcryPhase[i].soundStart = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	
	-- Back
	i = 2
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 150
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 90;
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 11
	warcryPhase[i].angleStart = -45
	warcryPhase[i].angleEnd = 90
	warcryPhase[i].offsetStart = Vector(0, 0)
	warcryPhase[i].offsetEnd = Vector(-3, -15)
	
	warcryPhase[i].soundStart = CreateSoundContainer("Flourish Flail Mordhau", "Mordhau.rte");
	
	-- Forward
	i = 3
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 120
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 0;
	
	warcryPhase[i].frameStart = 11
	warcryPhase[i].frameEnd = 6
	warcryPhase[i].angleStart = 90
	warcryPhase[i].angleEnd = 45
	warcryPhase[i].offsetStart = Vector(-3, -15)
	warcryPhase[i].offsetEnd = Vector(-3, -15)
	
	warcryPhase[i].soundStart = nil
	warcryPhase[i].soundStartVariations = 0
	
	warcryPhase[i].soundEnd = nil
	warcryPhase[i].soundEndVariations = 0
	
	-- Forwarder
	i = 4
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 150
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 3.4
	warcryPhase[i].attackStunChance = 0.15
	warcryPhase[i].attackRange = 20
	warcryPhase[i].attackPush = 0.8
	warcryPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 0;
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 7
	warcryPhase[i].angleStart = 45
	warcryPhase[i].angleEnd = -20
	warcryPhase[i].offsetStart = Vector(-3, -15)
	warcryPhase[i].offsetEnd = Vector(7, -12)
	
	-- Back
	i = 5
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 150
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 90;
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 11
	warcryPhase[i].angleStart = -20
	warcryPhase[i].angleEnd = 90
	warcryPhase[i].offsetStart = Vector(7, -12)
	warcryPhase[i].offsetEnd = Vector(-3, -15)
	
	warcryPhase[i].soundStart = CreateSoundContainer("Flourish Flail Mordhau", "Mordhau.rte");
	
	-- Forward
	i = 6
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 120
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 0;
	
	warcryPhase[i].frameStart = 11
	warcryPhase[i].frameEnd = 6
	warcryPhase[i].angleStart = 90
	warcryPhase[i].angleEnd = 45
	warcryPhase[i].offsetStart = Vector(-3, -15)
	warcryPhase[i].offsetEnd = Vector(-3, -15)
	
	warcryPhase[i].soundStart = CreateSoundContainer("FlourishContinue Flail Mordhau", "Mordhau.rte");
	warcryPhase[i].soundStartVariations = 0
	
	warcryPhase[i].soundEnd = nil
	warcryPhase[i].soundEndVariations = 0
	
	-- Forwarder
	i = 7
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 100
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 3.4
	warcryPhase[i].attackStunChance = 0.15
	warcryPhase[i].attackRange = 20
	warcryPhase[i].attackPush = 0.8
	warcryPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 0;
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 7
	warcryPhase[i].angleStart = 45
	warcryPhase[i].angleEnd = -20
	warcryPhase[i].offsetStart = Vector(-3, -15)
	warcryPhase[i].offsetEnd = Vector(7, -12)
	
	warcryPhase[i].soundEnd = nil
	
	-- End
	i = 8
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 100
	
	warcryPhase[i].warcryEnd = true
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 3.4
	warcryPhase[i].attackStunChance = 0.15
	warcryPhase[i].attackRange = 20
	warcryPhase[i].attackPush = 0.8
	warcryPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 0;
	
	warcryPhase[i].frameStart = 7
	warcryPhase[i].frameEnd = 7
	warcryPhase[i].angleStart = -20
	warcryPhase[i].angleEnd = -20
	warcryPhase[i].offsetStart = Vector(7, -12)
	warcryPhase[i].offsetEnd = Vector(0, 0)
	
	warcryPhase[i].soundEnd = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[5] = regularAttackSounds
	self.attackAnimationsGFX[5] = regularAttackGFX
	self.attackAnimations[5] = warcryPhase
	self.attackAnimationsTypes[5] = warcryPhase.Type
	
	
	-- shield warcry (shield bash)
	shieldWarcryPhase = {}
	shieldWarcryPhase.Type = "ShieldWarcry";
	
	-- Prepare
	i = 1
	shieldWarcryPhase[i] = {}
	shieldWarcryPhase[i].durationMS = 250
	
	shieldWarcryPhase[i].lastPrepare = true
	shieldWarcryPhase[i].canBeBlocked = false
	shieldWarcryPhase[i].canDamage = false
	shieldWarcryPhase[i].attackDamage = 0
	shieldWarcryPhase[i].attackStunChance = 0
	shieldWarcryPhase[i].attackRange = 0
	shieldWarcryPhase[i].attackPush = 0
	shieldWarcryPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	shieldWarcryPhase[i].attackAngle = 90;
	
	shieldWarcryPhase[i].frameStart = 6
	shieldWarcryPhase[i].frameEnd = 11
	shieldWarcryPhase[i].angleStart = 0
	shieldWarcryPhase[i].angleEnd = -90
	shieldWarcryPhase[i].offsetStart = Vector(0, 0)
	shieldWarcryPhase[i].offsetEnd = Vector(-6, -5)
	
	shieldWarcryPhase[i].soundStart = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	
	-- Bash
	i = 2
	shieldWarcryPhase[i] = {}
	shieldWarcryPhase[i].durationMS = 150
	
	shieldWarcryPhase[i].canBeBlocked = false
	shieldWarcryPhase[i].canDamage = false
	shieldWarcryPhase[i].attackDamage = 0
	shieldWarcryPhase[i].attackStunChance = 0
	shieldWarcryPhase[i].attackRange = 0
	shieldWarcryPhase[i].attackPush = 0
	shieldWarcryPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	shieldWarcryPhase[i].attackAngle = 0;
	
	shieldWarcryPhase[i].frameStart = 11
	shieldWarcryPhase[i].frameEnd = 6
	shieldWarcryPhase[i].angleStart = -90
	shieldWarcryPhase[i].angleEnd = -70
	shieldWarcryPhase[i].offsetStart = Vector(-6, -5)
	shieldWarcryPhase[i].offsetEnd = Vector(0, 0)
	
	shieldWarcryPhase[i].soundStart = nil
	shieldWarcryPhase[i].soundStartVariations = 0
	
	shieldWarcryPhase[i].soundEnd = CreateSoundContainer("Blocked Flail Mordhau", "Mordhau.rte");
	shieldWarcryPhase[i].soundEndVariations = 0
	
	-- Recoil
	i = 3
	shieldWarcryPhase[i] = {}
	shieldWarcryPhase[i].durationMS = 250
	
	shieldWarcryPhase[i].canBeBlocked = false
	shieldWarcryPhase[i].canDamage = false
	shieldWarcryPhase[i].attackDamage = 3.4
	shieldWarcryPhase[i].attackStunChance = 0.15
	shieldWarcryPhase[i].attackRange = 20
	shieldWarcryPhase[i].attackPush = 0.8
	shieldWarcryPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	shieldWarcryPhase[i].attackAngle = 0;
	
	shieldWarcryPhase[i].frameStart = 6
	shieldWarcryPhase[i].frameEnd = 11
	shieldWarcryPhase[i].angleStart = -70
	shieldWarcryPhase[i].angleEnd = -90
	shieldWarcryPhase[i].offsetStart = Vector(0, 0)
	shieldWarcryPhase[i].offsetEnd = Vector(-6, -5)
	
	shieldWarcryPhase[i].soundStart = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	
	-- Bash
	i = 4
	shieldWarcryPhase[i] = {}
	shieldWarcryPhase[i].durationMS = 100
	
	shieldWarcryPhase[i].canBeBlocked = false
	shieldWarcryPhase[i].canDamage = false
	shieldWarcryPhase[i].attackDamage = 3.4
	shieldWarcryPhase[i].attackStunChance = 0.15
	shieldWarcryPhase[i].attackRange = 20
	shieldWarcryPhase[i].attackPush = 0.8
	shieldWarcryPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	shieldWarcryPhase[i].attackAngle = 0;
	
	shieldWarcryPhase[i].frameStart = 11
	shieldWarcryPhase[i].frameEnd = 9
	shieldWarcryPhase[i].angleStart = -90
	shieldWarcryPhase[i].angleEnd = -70
	shieldWarcryPhase[i].offsetStart = Vector(-6, -5)
	shieldWarcryPhase[i].offsetEnd = Vector(-2, -2)
	
	shieldWarcryPhase[i].soundStart = nil
	
	shieldWarcryPhase[i].soundEnd = CreateSoundContainer("Blocked Flail Mordhau", "Mordhau.rte");
	
	-- Return
	i = 5
	shieldWarcryPhase[i] = {}
	shieldWarcryPhase[i].durationMS = 300
	
	shieldWarcryPhase[i].canBeBlocked = false
	shieldWarcryPhase[i].canDamage = false
	shieldWarcryPhase[i].attackDamage = 3.4
	shieldWarcryPhase[i].attackStunChance = 0.15
	shieldWarcryPhase[i].attackRange = 20
	shieldWarcryPhase[i].attackPush = 0.8
	shieldWarcryPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	shieldWarcryPhase[i].attackAngle = 0;
	
	shieldWarcryPhase[i].frameStart = 9
	shieldWarcryPhase[i].frameEnd = 6
	shieldWarcryPhase[i].angleStart = -70
	shieldWarcryPhase[i].angleEnd = -15
	shieldWarcryPhase[i].offsetStart = Vector(-2, -2)
	shieldWarcryPhase[i].offsetEnd = Vector(0, 0)
	
	shieldWarcryPhase[i].soundStart = nil
	
	shieldWarcryPhase[i].soundEnd = nil
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[6] = regularAttackSounds
	self.attackAnimationsGFX[6] = regularAttackGFX
	self.attackAnimations[6] = shieldWarcryPhase
	self.attackAnimationsTypes[6] = shieldWarcryPhase.Type
	
	-- Throw
	throwPhase = {}
	throwPhase.Type = "Slash";
	
	-- Windup
	i = 1
	throwPhase[i] = {}
	throwPhase[i].durationMS = 250
	
	throwPhase[i].canBeBlocked = false
	throwPhase[i].canDamage = false
	throwPhase[i].attackDamage = 0
	throwPhase[i].attackStunChance = 0
	throwPhase[i].attackRange = 0
	throwPhase[i].attackPush = 0
	throwPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	throwPhase[i].attackAngle = 90;
	
	throwPhase[i].frameStart = 6
	throwPhase[i].frameEnd = 6
	throwPhase[i].angleStart = 0
	throwPhase[i].angleEnd = 120
	throwPhase[i].offsetStart = Vector(0, 0)
	throwPhase[i].offsetEnd = Vector(-15, -15)

	
	-- Pause
	i = 2
	throwPhase[i] = {}
	throwPhase[i].durationMS = 250
	
	throwPhase[i].lastPrepare = true
	throwPhase[i].canBeBlocked = false
	throwPhase[i].canDamage = false
	throwPhase[i].attackDamage = 0
	throwPhase[i].attackStunChance = 0
	throwPhase[i].attackRange = 0
	throwPhase[i].attackPush = 0
	throwPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	throwPhase[i].attackAngle = 90;
	
	throwPhase[i].frameStart = 6
	throwPhase[i].frameEnd = 6
	throwPhase[i].angleStart = 120
	throwPhase[i].angleEnd = 120
	throwPhase[i].offsetStart = Vector(-15, -15)
	throwPhase[i].offsetEnd = Vector(-15, -15)
	
	
	-- Throw
	i = 3
	throwPhase[i] = {}
	throwPhase[i].durationMS = 100
	
	throwPhase[i].canBeBlocked = true
	throwPhase[i].canDamage = true
	throwPhase[i].attackDamage = 2
	throwPhase[i].attackStunChance = 0
	throwPhase[i].attackRange = 15
	throwPhase[i].attackPush = 0.8
	throwPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	throwPhase[i].attackAngle = 90;
	
	throwPhase[i].frameStart = 6
	throwPhase[i].frameEnd = 6
	throwPhase[i].angleStart = 120
	throwPhase[i].angleEnd = -90
	throwPhase[i].offsetStart = Vector(-15, -15)
	throwPhase[i].offsetEnd = Vector(6, -2)
	
	throwPhase[i].soundStart = CreateSoundContainer("Chain HeavyMovement Flail Mordhau", "Mordhau.rte");
	throwPhase[i].soundStartVariations = 0
	
	throwPhase[i].soundEnd = nil
	throwPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[7] = regularAttackSounds
	self.attackAnimationsGFX[7] = regularAttackGFX
	self.attackAnimations[7] = throwPhase
	self.attackAnimationsTypes[7] = throwPhase.Type
	
	-- Equip anim
	equipPhase = {}
	equipPhase.Type = "Equip";
	
	-- Out
	i = 1
	equipPhase[i] = {}
	equipPhase[i].durationMS = 200
	
	equipPhase[i].canBeBlocked = false
	equipPhase[i].canDamage = false
	equipPhase[i].attackDamage = 0
	equipPhase[i].attackStunChance = 0
	equipPhase[i].attackRange = 0
	equipPhase[i].attackPush = 0
	equipPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	equipPhase[i].attackAngle = 90;
	
	equipPhase[i].frameStart = 8
	equipPhase[i].frameEnd = 8
	equipPhase[i].angleStart = -45
	equipPhase[i].angleEnd = -35
	equipPhase[i].offsetStart = Vector(-4, 15)
	equipPhase[i].offsetEnd = Vector(4, -15)
	
	-- Upright
	i = 2
	equipPhase[i] = {}
	equipPhase[i].durationMS = 160
	
	equipPhase[i].canBeBlocked = false
	equipPhase[i].canDamage = false
	equipPhase[i].attackDamage = 0
	equipPhase[i].attackStunChance = 0
	equipPhase[i].attackRange = 0
	equipPhase[i].attackPush = 0
	equipPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	equipPhase[i].attackAngle = 0;
	
	equipPhase[i].frameStart = 8
	equipPhase[i].frameEnd = 9
	equipPhase[i].angleStart = -35
	equipPhase[i].angleEnd = -15
	equipPhase[i].offsetStart = Vector(4, 0)
	equipPhase[i].offsetEnd = Vector(-5, -10)
	
	equipPhase[i].soundStart = nil
	equipPhase[i].soundStartVariations = 0
	
	equipPhase[i].soundEnd = nil
	equipPhase[i].soundEndVariations = 0
	
	-- Stance
	i = 3
	equipPhase[i] = {}
	equipPhase[i].durationMS = 160
	
	equipPhase[i].canBeBlocked = false
	equipPhase[i].canDamage = false
	equipPhase[i].attackDamage = 3.4
	equipPhase[i].attackStunChance = 0.15
	equipPhase[i].attackRange = 20
	equipPhase[i].attackPush = 0.8
	equipPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	equipPhase[i].attackAngle = 0;
	
	equipPhase[i].frameStart = 9
	equipPhase[i].frameEnd = 6
	equipPhase[i].angleStart = 0
	equipPhase[i].angleEnd = -35
	equipPhase[i].offsetStart = Vector(-5, -5)
	equipPhase[i].offsetEnd = Vector(0, 0)
	
	equipPhase[i].soundEnd = nil
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[10] = regularAttackSounds
	self.attackAnimationsGFX[10] = regularAttackGFX
	self.attackAnimations[10] = equipPhase
	self.attackAnimationsTypes[10] = equipPhase.Type		
	
	self.rotation = 0
	self.rotationInterpolation = 1 -- 0 instant, 1 smooth, 2 wiggly smooth
	self.rotationInterpolationSpeed = 25
	
	self.stance = Vector(0, 0)
	self.stanceInterpolation = 0 -- 0 instant, 1 smooth
	self.stanceInterpolationSpeed = 25
end

function Update(self)

	if UInputMan:KeyPressed(38) then
		self:ReloadScripts();
	end
	
	if not self.chainLoop:IsBeingPlayed() then
		self.chainLoop:Play(self.Pos);
	end
	if not self.chainSwingLoop:IsBeingPlayed() then
		self.chainSwingLoop:Play(self.Pos);
	end
	
	self.chainLoop.Pos = self.Pos;
	self.chainSwingLoop.Pos = self.Pos;
	
	self:RemoveStringValue("Blocked Mordhau")

	local act = self:GetRootParent();
	local actor = IsAHuman(act) and ToAHuman(act) or nil;
	local player = false
	local controller = nil
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		controller = actor:GetController();
		controller:SetState(Controller.AIM_SHARP,false);
		self.parent = actor;
		if actor:IsPlayerControlled() then
			player = true
		end
	end
	
	if self.equipAnim == true then
	
		playAttackAnimation(self, 10)
		self.equipAnim = false;

		local rotationTarget = -45 / 180 * math.pi
		local stanceTarget = Vector(-4, 0);
	
		self.stance = self.stance + stanceTarget
		
		rotationTarget = rotationTarget * self.FlipFactor
		self.rotation = self.rotation + rotationTarget
		
		self.StanceOffset = self.originalStanceOffset + self.stance
		self.RotAngle = self.RotAngle + self.rotation
	
	elseif controller then --          :-)
	
		-- INPUT
		local throw
		local flourish
		local warcry = self:NumberValueExists("Warcried");
		local stab
		local overhead
		local attack
		local activated
		if self.parriedCooldown == false then
			if player then
				throw = (player and UInputMan:KeyPressed(10));
				flourish = (player and (UInputMan:KeyPressed(8) or UInputMan:KeyHeld(8)));
				stab = (player and UInputMan:KeyPressed(2))
				overhead = (player and UInputMan:KeyPressed(22))
				if stab or overhead or throw then
					controller:SetState(Controller.PRESS_PRIMARY, true)
					self:Activate();
				end
				attack = controller:IsState(Controller.PRESS_PRIMARY) and not self.attackCooldown;
				if self:IsActivated() and self.attackCooldown == true then
					self:Deactivate();
				else
					self.attackCooldown = false;
				end
			else
				throw = self:NumberValueExists("AI Throw");
				flourish = self:NumberValueExists("AI Flourish");
				stab = self:NumberValueExists("AI Stab");
				overhead = self:NumberValueExists("AI Overhead");
				attack = self:NumberValueExists("AI Attack");
				if stab or overhead or throw or warcry then
					controller:SetState(Controller.PRESS_PRIMARY, true)
					self:Activate();
				end
			end
			activated = self:IsActivated();
		elseif self.parriedCooldownTimer:IsPastSimMS(self.parriedCooldownDelay) then
			self.parriedCooldown = false;
		end
		
		local attacked = false
		
		-- if player then -- PLAYER INPUT
			-- charge = (self:IsActivated() and not self.isCharged) or (self.isCharging and not self.isCharged)
		-- else -- AI
		attacked = activated and not self.attackAnimationIsPlaying
	
		-- end
		
		-- replace with your own code if you wish
		-- default "regular attack and charged attack behaviour"
		
		-- if charge and not self.attackAnimationIsPlaying then
			-- if not self.startedCharging then
				-- self.startedCharging = true
			-- end
			-- if not self.isCharging and self.chargeStartTimer:IsPastSimMS(self.chargeStartTime) then
				-- self.isCharging = true
				-- if self.chargeSound then
					-- self.chargeSound:Play(self.Pos);
				-- end
			-- end
			
			-- if self.isCharging then
				-- if self.chargeTimer:IsPastSimMS(self.chargeTime) then
					-- if not self.isCharged then
						-- self.isCharged = true
					-- end
				-- end
			-- end
		-- else
			-- self.chargeStartTimer:Reset()
			-- self.chargeTimer:Reset()
			-- if self.isCharging or self.startedCharging then
				-- self.isCharging = false
				-- self.startedCharging = false
				-- if self.chargeEndSound then
					-- self.chargeEndSound:Play(self.Pos);
				-- end
				-- attacked = true
			-- end
		-- end
		
		-- INPUT TO OUTPUT
		
		-- replace with your own code if you wish
		-- default "regular attack and charged attack behaviour"
		if attacked then
		
			self.chargeDecided = false;
		
		
			if self.Blocking == true then
				
				self.Parrying = true;
			
				self.Blocking = false;
				self:RemoveNumberValue("Blocking");
				
				stanceTarget = Vector(0, 0);
				
				self.originalBaseRotation = -15;
				self.baseRotation = -15;
				
			end
			
			if not stab and not overhead and not flourish and not throw and not warcry then
				if self.parent:NumberValueExists("Mordhau Disable Movement") then -- we're probably on a horse if this is set... probably...
					playAttackAnimation(self, 15) -- regular attack
					self:SetNumberValue("Current Attack Type", 2);
					self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 2 Range"));
				else
					playAttackAnimation(self, 1) -- regular attack
					self:SetNumberValue("Current Attack Type", 1);
					self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 1 Range"));
				end
			elseif stab then
				playAttackAnimation(self, 2) -- stab
				self:SetNumberValue("Current Attack Type", 3);
				self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 3 Range"));
			elseif overhead then
				playAttackAnimation(self, 3) -- overhead
				self:SetNumberValue("Current Attack Type", 4);
				self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 4 Range"));
			elseif warcry then
				local BGItem = self.parent.EquippedBGItem;				
				if BGItem and BGItem:IsInGroup("Shields") then
					playAttackAnimation(self, 6)
				else
					playAttackAnimation(self, 5)
				end
			elseif flourish and not self.parent:NumberValueExists("Mordhau Charge Ready") then
				self.parent:SetNumberValue("Block Foley", 1);
				playAttackAnimation(self, 11) -- fancypants shit
			elseif throw then
				self.parent:SetNumberValue("Block Foley", 1);
				self.Throwing = true;
				playAttackAnimation(self, 7) -- throw
			end
			
			-- if self.isCharged then
				-- self.isCharged = false
				-- self.wasCharged = true;
				-- playAttackAnimation(self, 2) -- charged attack
				-- self.parent:SetNumberValue("Medium Attack", 1); --here for extra movement sounds on parent knight
			-- else
				--playAttackAnimation(self, 1) -- regular attack
			-- end
		elseif not self.attackAnimationIsPlaying then
			if flourish then
				self.ignoreUnbuffering = true;
				self.parent:SetNumberValue("Block Foley", 1);
				playAttackAnimation(self, 11) -- fancypants shit
			elseif warcry then
				local BGItem = self.parent.EquippedBGItem;				
				if BGItem and BGItem:IsInGroup("Shields") then
					playAttackAnimation(self, 6)
				else
					playAttackAnimation(self, 5)
				end
			end
		end
		
		self:RemoveNumberValue("Warcried");
		self:RemoveNumberValue("AI Flourish");
		self:RemoveNumberValue("AI Throw");
		self:RemoveNumberValue("AI Stab");
		self:RemoveNumberValue("AI Overhead");
		self:RemoveNumberValue("AI Attack");
		
		-- ANIMATION PLAYER
		local stanceTarget = Vector(0, 0)
		local rotationTarget = 0
		
		local canBeBlocked = false
		local canDamage = false
		local damageVector = Vector(0,0)
		local damageRange = 1
		local damageStun = 0
		local damagePush = 1
		local damage = 0
		
		if self.WoundCount > self.woundCounter then
			self.rotationInterpolationSpeed = 50;
			local mult = 1 * (self.WoundCount - self.woundCounter);
			if math.random(0, 100) > 50 then
				mult = mult * -1;
			end
			self.baseRotation = self.baseRotation - math.random(1, 15) * mult
			if math.random(0, 100) > 85 then
				if self.parent then
					self.parent:SetNumberValue("Blocked Mordhau", 1);
				end
			end
			if math.random(0, 100) > 20 then
				self:RemoveWounds(self.WoundCount - self.woundCounter);
			else
				self.woundCounter = self.WoundCount
				self.breakSound:Play(self.Pos);
			end
		end
	
		if self.attackAnimationIsPlaying and currentAttackAnimation ~= 0 then -- play the animation
		
			self.rotationInterpolationSpeed = 25;
		
			local animation = self.currentAttackAnimation
			local attackPhases = self.attackAnimations[animation]
			local currentPhase = attackPhases[self.currentAttackSequence]
			if self.pseudoPhase then
				currentPhase = self.pseudoPhase;
			end
			local nextPhase = attackPhases[self.currentAttackSequence + 1]
			
			if self.chargeDecided == false and nextPhase and nextPhase.canBeBlocked == true and currentPhase.canBeBlocked == false then
				self.chargeDecided = true;
				if activated or (player == false and math.random(0, 100) < 20) then
					self.wasCharged = true;
					self.parent:SetNumberValue("Large Attack", 1);
				else
					self.wasCharged = false;
					self.parent:SetNumberValue("Medium Attack", 1);				
				end
			elseif currentPhase.firstRecovery == true then
				self.Recovering = true;
			elseif self.chargeDecided == false or self.blockedNullifier == false then
				-- block cancelling
				local keyPress
				if player then
					keyPress = UInputMan:KeyPressed(18) or (self.blockedNullifier == false and UInputMan:KeyHeld(18));
				else
					keyPress = self:NumberValueExists("AI Block");
				end
				
				
				if keyPress then
					self.Throwing = false;
					self.wasCharged = false;
					self.currentAttackAnimation = 0
					self.currentAttackSequence = 0
					self.attackAnimationIsPlaying = false			
					self.parent:SetNumberValue("Block Foley", 1);
				
					self.Blocking = true;
					self:RemoveStringValue("Parrying Type");
					self.Parrying = false;
					
					self:SetNumberValue("Blocking", 1);
					
					self:RemoveNumberValue("Current Attack Type")
					
					stanceTarget = Vector(4, -7);
					
					self.originalBaseRotation = -160;
					self.baseRotation = -145;
				end
			end
			
			local factor = self.attackAnimationTimer.ElapsedSimTimeMS / currentPhase.durationMS
			if factor > 1 then
				factor = 1;
			end
			
			if not self.currentAttackStart then -- Start of the sequence
				self.currentAttackStart = true
				if currentPhase.soundStart then
					currentPhase.soundStart.Pitch = self.wasCharged and 0.9 or 1.0;
					currentPhase.soundStart:Play(self.Pos);
				end
			end
			
			local workingDuration = currentPhase.durationMS
			if self.attackAnimationsTypes[self.currentAttackAnimation] == "ShieldWarcry" then
				workingDuration = workingDuration * (math.random(8, 17) / 10);
			end
			
			canBeBlocked = currentPhase.canBeBlocked or false
			canDamage = currentPhase.canDamage or false
			if self.blockedNullifier == false then
				canDamage = false;
				canBeBlocked = false;
			end
			if canDamage == true then
				self.Attacked = true;
			end
			damage = currentPhase.attackDamage or 0
			damageVector = currentPhase.attackVector or Vector(0,0)
			damageAngle = currentPhase.attackAngle or 0
			damageRange = currentPhase.attackRange or 0
			damageStun = currentPhase.attackStunChance or 0
			damagePush = currentPhase.attackPush or 0
			
			-- if self.wasCharged == true then
				-- damage = damage * 1.3;
				-- damageStun = damageStun * 1.3;
				-- damagePush = damagePush * 1.3;
			-- end
				
			
			rotationTarget = rotationTarget + (currentPhase.angleStart * (1 - factor) + currentPhase.angleEnd * factor) / 180 * math.pi -- interpolate rotation
			stanceTarget = stanceTarget + (currentPhase.offsetStart * (1 - factor) + currentPhase.offsetEnd * factor) -- interpolate stance offset
			local frameChange = currentPhase.frameEnd - currentPhase.frameStart
			self.Frame = math.floor(currentPhase.frameStart + math.floor(frameChange * factor, 0.55))
			
			if ((self.Attacked == true or self.attackAnimationsTypes[self.currentAttackAnimation] == "Twirl" and self.currentAttackAnimation ~= 11) and attack) and not (self.moveBuffered) then
			
				self.moveBuffered = true;
			
				if not stab and not overhead and not throw and not warcry then
					if self.parent:NumberValueExists("Mordhau Disable Movement") then -- we're probably on a horse if this is set... probably...
						self.attackAnimationBuffered = 15;
					else
						self.attackAnimationBuffered = 1;
					end
				elseif stab then
					self.attackAnimationBuffered = 2;
				elseif overhead then
					self.attackAnimationBuffered = 3;
				elseif warcry then
					local BGItem = self.parent.EquippedBGItem;				
					if BGItem and BGItem:IsInGroup("Shields") then
						self.attackAnimationBuffered =  6;
					else
						self.attackAnimationBuffered =  5;
					end
				elseif throw then
					self.attackAnimationBuffered = 7;
				end
				
			elseif self.Attacked == true and flourish and self.attackAnimationsTypes[self.currentAttackAnimation] ~= "Twirl" and not (self.moveBuffered) then
				self.moveBuffered = true;
				self.attackAnimationBuffered = 11;
			end
				
				

			if (self.partiallyRecovered == true or currentPhase.twirlComboPhase == true) and (self.moveBuffered) then
			
				self.chargeDecided = false;
				
				self.moveBuffered = false;
			
				-- construct pseudo phase to get us from where we are now through the first phase of the buffered attack, if we buffered one
				-- doesn't THAT sound scientific
				
				local attackPhases = self.attackAnimations[self.attackAnimationBuffered]
				local phaseToUse
				if currentPhase.twirlComboPhase == true then
					phaseToUse = attackPhases[2]
					self.phaseStart = 2;
				else
					phaseToUse = attackPhases[1]
				end
				
				local duration = self.Twirled and phaseToUse.durationMS or phaseToUse.durationMS * 1.5;
				
				self.pseudoPhase = {}
				self.pseudoPhase.durationMS = (currentPhase.twirlComboPhase == true or self.attackAnimationBuffered == 11) and phaseToUse.durationMS or (duration) or 0
				
				self.pseudoPhase.canBeBlocked = phaseToUse.canBeBlocked or false
				self.pseudoPhase.canDamage = phaseToUse.canDamage or false
				self.pseudoPhase.attackDamage = phaseToUse.attackDamage or 0
				self.pseudoPhase.attackStunChance = phaseToUse.attackStunChance or 0
				self.pseudoPhase.attackRange = phaseToUse.attackRange or 0
				self.pseudoPhase.attackPush = phaseToUse.attackPush or 0
				self.pseudoPhase.attackVector = phaseToUse.attackVector or Vector(0, 0)
				self.pseudoPhase.attackAngle = phaseToUse.attackAngle or 0
				
				self.pseudoPhase.frameStart = self.Frame
				self.pseudoPhase.frameEnd = phaseToUse.frameEnd or 6
				self.pseudoPhase.angleStart = (self.rotation * self.FlipFactor) * (180/math.pi)
				self.pseudoPhase.angleEnd = phaseToUse.angleEnd or 0
				self.pseudoPhase.offsetStart = self.stance
				self.pseudoPhase.offsetEnd = phaseToUse.offsetEnd or Vector(0, 0)
				
				self.pseudoPhase.soundStart = phaseToUse.soundStart or nil
				
				self.pseudoPhase.soundEnd = phaseToUse.soundEnd or nil
				
				playAttackAnimation(self, self.attackAnimationBuffered)
				
				if self.attackAnimationBuffered == 15 then
					self:SetNumberValue("Current Attack Type", 2);
					self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 2 Range"));
				elseif self.attackAnimationBuffered == 1 then
					self:SetNumberValue("Current Attack Type", 1);
					self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 1 Range"));
				elseif self.attackAnimationBuffered == 2 then
					self:SetNumberValue("Current Attack Type", 3);
					self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 3 Range"));
				elseif self.attackAnimationBuffered == 3 then
					self:SetNumberValue("Current Attack Type", 4);
					self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 4 Range"));
				elseif self.attackAnimationBuffered == 5 or self.attackAnimationBuffered == 6 then
					self.parent:SetNumberValue("Block Foley", 1);
				elseif self.attackAnimationBuffered == 11 then
					self.parent:SetNumberValue("Block Foley", 1);
				elseif self.attackAnimationBuffered == 7 then
					self.parent:SetNumberValue("Block Foley", 1);
					self.Throwing = true;
				end
					
			elseif currentPhase.twirlEnd == true and self.attackAnimationsTypes[self.currentAttackAnimation] == "Twirl" and flourish then
				playAttackAnimation(self, 12);
				self.Twirled = true;
				self.ignoreUnbuffering = true;
			end
			
			-- DEBUG
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 40), "animation = "..animation, true, 0);
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "sequence = "..self.currentAttackSequence, true, 0);
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 30), "factor = "..math.floor(factor * 100).."/100", true, 0);
			if self.attackAnimationTimer:IsPastSimMS(workingDuration) then
				if (self.currentAttackSequence+1) <= #attackPhases then
					self.currentAttackSequence = self.currentAttackSequence + 1
				else
					if not self.moveBuffered == true then
						self.attackCooldown = true;
					end
					self:SetNumberValue("Blocked", 0);
					self:SetNumberValue("Current Attack Type", 0);
					self:SetNumberValue("Current Attack Range", 0);
					self:RemoveNumberValue("AI Parry")
					self:RemoveNumberValue("AI Parry Eligible")
					self.wasCharged = false;
					self.currentAttackAnimation = 0
					self.currentAttackSequence = 0
					self.attackAnimationIsPlaying = false
					if self.Throwing == true then
						local throwChargeFactor = self.wasCharged and 0 or 0
						self.Throwing = false;
						self.wasThrown = true;
						self:GetParent():RemoveAttachable(self, true, false);
						self.Vel = self.parent.Vel + Vector((throwChargeFactor + 35)*self.FlipFactor, 0):RadRotate(self.RotAngle);
						self.throwSoundPlayed = false;
						
					end
				end
				
				if currentPhase.soundEnd then
					currentPhase.soundEnd:Play(self.Pos);
					if self.attackAnimationsTypes[self.currentAttackAnimation] == "ShieldWarcry" then
						local BGItem = self.parent.EquippedBGItem;				
						if BGItem and BGItem:IsInGroup("Shields") then
							local woundName = ToMOSRotating(BGItem):GetEntryWoundPresetName();
							local wound = CreateAEmitter(woundName);
							local sound = wound.BurstSound;
							sound:Play(self.Pos);
						end	
					end
				end
				
				self:RemoveStringValue("Parrying Type");
				self.Parrying = false;
				
				self.pseudoPhase = nil;
				
				if self.Recovering == true then
					self.partiallyRecovered = true;
				end
				
				self.currentAttackStart = false
				self.attackAnimationTimer:Reset()
				self.attackAnimationCanHit = true
				canDamage = false
			end
			
			if self:NumberValueExists("Mordhau Flinched") or self.parent:NumberValueExists("Mordhau Flinched") then
				self:RemoveNumberValue("Mordhau Flinched")
				self.parent:RemoveNumberValue("Mordhau Flinched");
				self.parriedCooldown = true;
				self.parriedCooldownTimer:Reset();
				self.parriedCooldownDelay = 600;
				self.wasCharged = false;
				self.currentAttackAnimation = 0
				self.currentAttackSequence = 0
				self.attackAnimationIsPlaying = false
				self.Parrying = false;
				self:RemoveStringValue("Parrying Type");
				
				self:RemoveNumberValue("AI Parry");
				self:RemoveNumberValue("AI Eligible");
				
				self:SetNumberValue("Blocked", 0);
				self:SetNumberValue("Current Attack Type", 0);
				self:SetNumberValue("Current Attack Range", 0);
			end
			
		else -- default behaviour, modify it if you wish
			if self:NumberValueExists("Mordhau Flinched") or self.parent:NumberValueExists("Mordhau Flinched") then
				self:RemoveNumberValue("Mordhau Flinched")
				self.parent:RemoveNumberValue("Mordhau Flinched");
			end		
			if self.baseRotation < self.originalBaseRotation then
				self.baseRotation = self.baseRotation + 1;
			elseif self.baseRotation > self.originalBaseRotation then
				self.baseRotation = self.baseRotation + -1;
			end
			
			rotationTarget = self.baseRotation / 180 * math.pi;
			
			local keyPressed
			local keyReleased
			local keyHeld
			if player then
				local key = UInputMan:KeyHeld(18)
				
				keyPressed = key and not self.Blocking
				keyReleased = key and self.Blocking
				keyHeld = key and self.Blocking
			else
				if self.Parrying then
					self:RemoveNumberValue("AI Block");
				end
				keyPressed = self:NumberValueExists("AI Block") and not self.Blocking
				keyReleased = not self:NumberValueExists("AI Block") and self.Blocking
				keyHeld = self:NumberValueExists("AI Block") and self.Blocking
			end
			
			
			if keyPressed and not (self.attackAnimationIsPlaying) then
				
				self.rotationInterpolationSpeed = 15
			
				self.parent:SetNumberValue("Block Foley", 1);
			
				self.Blocking = true;
				
				self:SetNumberValue("Blocking", 1);
				
				stanceTarget = Vector(2.5, -12);
				
				self.originalBaseRotation = -160;
				self.baseRotation = -145;
			
			elseif keyHeld and not (self.attackAnimationIsPlaying) then
			
				self.originalBaseRotation = -160;
			
				stanceTarget = Vector(2.5, -12);
				
				self:SetNumberValue("Current Attack Type", 0);
				self:SetNumberValue("Current Attack Range", 0);
			
			elseif keyReleased then
			
				self.parent:SetNumberValue("Block Foley", 1);
			
				self.Blocking = false;
				
				self:RemoveNumberValue("Blocking");
				
				self.originalBaseRotation = -15;
				self.baseRotation = -25;
			
			else
			
				self:SetNumberValue("Current Attack Type", 0);
				self:SetNumberValue("Current Attack Range", 0);
				
				self.Blocking = false;
				
				self:RemoveNumberValue("Blocking");
				
				self.originalBaseRotation = -15;
				self.baseRotation = -25;
				
			end
			
			if self.Blocking == false and self.parent:NumberValueExists("Mordhau Charge Ready") then
			
				self.rotationInterpolationSpeed = 5
			
				stanceTarget = Vector(-2, -10);
				
				self.originalBaseRotation = 40;
				self.baseRotation = 40;
				
			end
			
--[[			elseif not self.attackAnimationIsPlaying then
			
				self.Blocking = true;
				
				self:SetNumberValue("Blocking", 1);
				
				stanceTarget = Vector(4, -10);
				
				self.originalBaseRotation = -160;
				self.baseRotation = -160;
				]]
				
			
			if self:IsAttached() then
				self.Frame = 6;
			else
				self.Frame = 1;
			end
		end
		
		if (self:NumberValueExists("AI Parry") and not (self.attackAnimationIsPlaying == true or self.parriedCooldown == true)) then
			self:SetNumberValue("AI Parry Eligible", 1);
		else
			self:RemoveNumberValue("AI Parry Eligible");
		end
		
		if self.Blocking == true or self.Parrying == true or self:NumberValueExists("AI Parry Eligible") then
			
			if self:StringValueExists("Blocked Type") then
			
				if self.parent then
					self.parent:SetNumberValue("Blocked Mordhau", 1);
				end
				self:SetNumberValue("Blocked Mordhau", 1);
			
				self.rotationInterpolationSpeed = 50;
				self.baseRotation = self.baseRotation - (math.random(15, 20) * -1)
				
				self.blockSounds[self:GetStringValue("Blocked Type")]:Play(self.Pos);
				if self:NumberValueExists("Blocked Heavy") then
				
					if self.parent then
						self.parent:SetNumberValue("Blocked Heavy Mordhau", 1);
					end				
				
					self:RemoveNumberValue("Blocked Heavy");
					self.heavyBlockAddSound:Play(self.Pos);
					self.baseRotation = self.baseRotation - (math.random(25, 35) * -1)
				end
				
				if self.Parrying == true or self:NumberValueExists("AI Parry Eligible") and self:GetStringValue("Blocked Type") == "Slash" then
					self.parrySound:Play(self.Pos);
					
					if self:NumberValueExists("AI Parry Eligible") then
						self:RemoveNumberValue("AI Parry Eligible");			
						self:RemoveNumberValue("AI Parry");	
						
						self.Parrying = true;
						
						if math.random(0, 100) < 33 then
							playAttackAnimation(self, 3);
							self:SetNumberValue("Current Attack Type", 4);
							self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 4 Range"));
						elseif math.random(0, 100) < 66 then
							if self.parent:NumberValueExists("Mordhau Disable Movement") then
								playAttackAnimation(self, 15);
								self:SetNumberValue("Current Attack Type", 2);
								self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 2 Range"));
							else
								playAttackAnimation(self, 1);
								self:SetNumberValue("Current Attack Type", 1);
								self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 1 Range"));
							end
						else
							playAttackAnimation(self, 2);
							self:SetNumberValue("Current Attack Type", 3);
							self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 3 Range"));
						end
					
						self.Blocking = false;
						self:RemoveNumberValue("Blocking");
						
						stanceTarget = Vector(0, 0);
						
						self.originalBaseRotation = -15;
						self.baseRotation = -15;
						
					end
					
				end
				
				self:RemoveStringValue("Blocked Type");
				
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
			self.rotation = (self.rotation + rotationTarget * TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed);
		end
		local pushVector = Vector(10 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		
		self.StanceOffset = self.originalStanceOffset + self.stance
		--self.InheritedRotAngleOffset = self.rotation
		self.RotAngle = self.RotAngle + self.rotation
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		self.Pos = self.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-self.rotation);
		
		-- FLAIL PHYSICS!
		FlailHandleChain(self)
		
		if self.chainLoop.Volume < self.chainLoopVolumeTarget then
			self.chainLoop.Volume = self.chainLoop.Volume + 1 * TimerMan.DeltaTimeSecs;
		elseif self.chainLoop.Volume > self.chainLoopVolumeTarget then
			self.chainLoop.Volume = self.chainLoop.Volume - 0.8 * TimerMan.DeltaTimeSecs;
			if self.chainLoop.Volume < 0 then
				self.chainLoop.Volume = 0
			end
		end
		
		self.chainLoopVolumeTarget = math.min(1, self.chainMovementFactor)
		self.chainLoop.Pitch = math.min(1, math.max(0.9, self.chainMovementFactor))
		
		-- FLAIL PHYSICS!
		

		
		-- COLLISION DETECTION
		
		--self.attackAnimationsSounds[1]
		if canBeBlocked and self.attackAnimationCanHit then -- Detect collision
			--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + attackOffset,  13);
			local hit = false
			local hitType = 0
			local team = 0
			if actor then team = actor.Team end
			--local rayVec = Vector(damageRange * self.FlipFactor, 0):RadRotate(self.RotAngle):DegRotate(damageAngle*self.FlipFactor)--damageVector:RadRotate(self.RotAngle) * Vector(self.FlipFactor, 1)
			--local rayOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(damageVector.X * self.FlipFactor, damageVector.Y):RadRotate(self.RotAngle)
			--local rayVec = Vector(self.chainBall.velocity.X, self.chainBall.velocity.Y)
			local rayVec = Vector(self.chainBall.velocity.Magnitude * 1.55 * self.FlipFactor, 0):RadRotate(self.RotAngle):DegRotate(damageAngle*self.FlipFactor)
			local rayOrigin = Vector(self.chainBall.position.X, self.chainBall.position.Y) - Vector(rayVec.X, rayVec.Y) * 0.3
			
			PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
			--PrimitiveMan:DrawCirclePrimitive(self.Pos, 3, 5);
			
			if self.chainSwingLoop.Volume < self.chainSwingLoopVolumeTarget then
				self.chainSwingLoop.Volume = self.chainSwingLoop.Volume + 10 * TimerMan.DeltaTimeSecs;
			elseif self.chainSwingLoop.Volume > self.chainSwingLoopVolumeTarget then
				self.chainSwingLoop.Volume = self.chainSwingLoop.Volume - 0.2 * TimerMan.DeltaTimeSecs;
				if self.chainSwingLoop.Volume < 0 then
					self.chainSwingLoop.Volume = 0
				end
			end
			
			self.chainSwingLoopVolumeTarget = math.min(1, (self.chainBall.velocity.Magnitude - self.Vel.Magnitude)/12)
			self.chainSwingLoop.Pitch = math.min(1, math.max(0.9, (self.chainBall.velocity.Magnitude - self.Vel.Magnitude)/12))
			
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.IDToIgnore or self.ID, self.Team, 0, false, 2); -- Raycast
			if moCheck and moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local MO = MovableMan:GetMOFromID(moCheck)
				if (IsMOSRotating(MO) and canDamage) and not ((MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee"))
				or (MO:IsInGroup("Mordhau Counter Shields") and (ToMOSRotating(MO):StringValueExists("Parrying Type")
				and ToMOSRotating(MO):GetStringValue("Parrying Type") == "Flourish"))) then
					hit = true
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
					
					if MO:IsInGroup("Shields") then
						self.blockedSound:Play(self.Pos);
					end
					
					local woundsToAdd;
					local speedMult = math.max(1, self.Vel.Magnitude / 18);

					woundsToAdd = math.floor((damage*speedMult) + RangeRand(0,0.9))

					
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
						
						if not (IsAHuman(actorHit) and ToAHuman(actorHit).Head and MO.UniqueID == ToAHuman(actorHit).Head.UniqueID) then
							woundsToAdd = math.floor(woundsToAdd * 1.5); -- drastically increase our damage if not hitting the head
						end
						
						if addWounds == true and woundName ~= nil then
							local MOParent = MO:GetRootParent()
							if MOParent and IsAHuman(MOParent) then
								MOParent = ToAHuman(MOParent)
								MOParent:SetNumberValue("Mordhau Flinched", 1);
							end
							MO:SetNumberValue("Mordhau Flinched", 1);
							local flincher = CreateAttachable("Mordhau Flincher", "Mordhau.rte")
							MO:AddAttachable(flincher)
							for i = 1, woundsToAdd do
								MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end
						end
						
						if self.wasCharged then
							-- if crit then
								-- actorHit:GetController():SetState(Controller.BODY_CROUCH,true);
								-- actorHit:GetController():SetState(Controller.WEAPON_CHANGE_NEXT,false);
								-- actorHit:GetController():SetState(Controller.WEAPON_CHANGE_PREV,false);
								-- actorHit:GetController():SetState(Controller.WEAPON_FIRE,false);
								-- actorHit:GetController():SetState(Controller.AIM_SHARP,false);
								-- actorHit:GetController():SetState(Controller.WEAPON_PICKUP,false);
								-- actorHit:GetController():SetState(Controller.WEAPON_DROP,false);
								-- actorHit:GetController():SetState(Controller.BODY_JUMP,false);
								-- actorHit:GetController():SetState(Controller.BODY_JUMPSTART,false);
								-- actorHit:GetController():SetState(Controller.MOVE_LEFT,false);
								-- actorHit:GetController():SetState(Controller.MOVE_RIGHT,false);
								-- actorHit:FlashWhite(150);
								-- if math.random(0, 100) < 30 then
									-- self.parent:SetNumberValue("Attack Success", 1); -- celebration!!
								-- end
							-- end
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
					elseif woundName ~= nil then -- generic wound adding for non-actors
						for i = 1, woundsToAdd do
							MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					end
				elseif (MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee")) or MO:IsInGroup("Mordhau Counter Shields") then
					hit = true;
					MO = ToHeldDevice(MO);
					if (MO:NumberValueExists("Blocking") or (MO:StringValueExists("Parrying Type")
					and (MO:GetStringValue("Parrying Type") == self.attackAnimationsTypes[self.currentAttackAnimation] or MO:GetStringValue("Parrying Type") == "Flourish")))
					or (MO:NumberValueExists("AI Parry Eligible")) then
						self:SetNumberValue("Blocked", 1)
						self.attackCooldown = true;
						if MO:StringValueExists("Parrying Type") or (MO:NumberValueExists("AI Parry Eligible")) then
							self.parriedCooldown = true;
							self.parriedCooldownTimer:Reset();
							self.parriedCooldownDelay = 600;
							self.moveBuffered = false;
							local effect = CreateMOSRotating(self.blockGFX.Parry, "Mordhau.rte");
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
						self.blockedNullifier = false;
						self.attackAnimationCanHit = false;
						self.blockedSound:Play(self.Pos);
						MO:SetStringValue("Blocked Type", self.attackAnimationsTypes[self.currentAttackAnimation]);
						local effect = CreateMOSRotating(self.blockGFX[self.attackAnimationsTypes[self.currentAttackAnimation]], "Mordhau.rte");
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
						-- if self.wasCharged then
							-- local effect = CreateMOSRotating(self.blockGFX.Heavy, "Mordhau.rte");
							-- if effect then
								-- effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								-- MovableMan:AddParticle(effect);
								-- effect:GibThis();
							-- end
							-- MO:SetNumberValue("Blocked Heavy", 1);
						-- end
						
					else
						self.IDToIgnore = MO.ID;
						hit = false; -- keep going and looking
					end
				end
			elseif canDamage then
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
					self.blockedNullifier = false;
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound:Play(self.Pos);
					end
				elseif hitType == 1 then -- Flesh
					self.blockedNullifier = false;
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSound:Play(self.Pos);
					end
				elseif hitType == 2 then -- Metal
					self.blockedNullifier = false;
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSound:Play(self.Pos);
					end
				end
				self.attackAnimationCanHit = false
			end
		else
			if self.attackAnimationsTypes[self.currentAttackAnimation] == "Twirl" and self.attackAnimationIsPlaying then
				if self.chainSwingLoop.Volume < self.chainSwingLoopVolumeTarget then
					self.chainSwingLoop.Volume = self.chainSwingLoop.Volume + 10 * TimerMan.DeltaTimeSecs;
				elseif self.chainSwingLoop.Volume > self.chainSwingLoopVolumeTarget then
					if self.chainSwingLoop.Volume > self.chainSwingLoopVolumeTarget * 1.5 then
						self.chainSwingLoop.Volume = self.chainSwingLoop.Volume - 3 * TimerMan.DeltaTimeSecs;
					else
						self.chainSwingLoop.Volume = self.chainSwingLoop.Volume - 0.2 * TimerMan.DeltaTimeSecs;
					end
					if self.chainSwingLoop.Volume < 0 then
						self.chainSwingLoop.Volume = 0
					end
				end
				
				self.chainSwingLoopVolumeTarget = math.min(1, (self.chainBall.velocity.Magnitude - self.Vel.Magnitude)/24)
				self.chainSwingLoop.Pitch = math.min(1, math.max(0.9, (self.chainBall.velocity.Magnitude - self.Vel.Magnitude)/12))
			else
				self.chainSwingLoop.Volume = self.chainSwingLoop.Volume - 10 * TimerMan.DeltaTimeSecs;
				if self.chainSwingLoop.Volume < 0 then
					self.chainSwingLoop.Volume = 0
				end
				
				self.chainSwingLoopVolumeTarget = math.min(1, (self.chainBall.velocity.Magnitude - self.Vel.Magnitude)/12)
				self.chainSwingLoop.Pitch = math.min(1, math.max(0.9, (self.chainBall.velocity.Magnitude - self.Vel.Magnitude)/12))
			end
		end
	end
	
	self:RemoveNumberValue("AI Block");
end

function Destroy(self)
	self.chainLoop:Stop(-1);
	self.chainSwingLoop:Stop(-1);
end