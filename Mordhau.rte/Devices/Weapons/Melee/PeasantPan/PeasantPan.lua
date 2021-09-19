
function stringInsert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end


function playAttackAnimation(self, animation)
	self.attackAnimationIsPlaying = true
	self.currentAttackStart = false;
	self.currentAttackSequence = 1
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
	
	self.attackBuffered = false;
	self.stabBuffered = false;
	self.overheadBuffered = false;
	
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

function Create(self)

	self.equipSound = CreateSoundContainer("HaftedSmall Equip Mordhau", "Mordhau.rte");
	self.equipSound.Pitch = 1.0;
	
	self.pickUpSound = CreateSoundContainer("Metal Pickup Mordhau", "Mordhau.rte");
	self.pickUpSound.Pitch = 1.0;

	-- throwing stuff

	self.throwSound = CreateSoundContainer("Throw ThrowingAxe", "Mordhau.rte");
	self.throwSoundPlayed = false;
	
	self.spinSound = CreateSoundContainer("Spin ThrowingAxe", "Mordhau.rte");
	self.spinTimer = Timer();
	self.spinDelay = 135;
	
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
			
	self.soundHitFlesh = CreateSoundContainer("Basic Melee Metal Flesh Mordhau", "Mordhau.rte");
	self.soundHitMetal = CreateSoundContainer("Basic Melee Metal Metal Mordhau", "Mordhau.rte");
	

	
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
	self.heavyBlockAddSound = CreateSoundContainer("Basic Melee Metal HeavyBlockAdd Mordhau", "Mordhau.rte");
	
	self.blockSounds = {};
	self.blockSounds.Slash = CreateSoundContainer("Basic Melee Metal Block Mordhau", "Mordhau.rte");
	self.blockSounds.Stab = CreateSoundContainer("Basic Melee Metal Block Mordhau", "Mordhau.rte");
	
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
	
	regularAttackSounds.hitDeflectSound = CreateSoundContainer("Basic Melee Pan Metal Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitFleshSound = CreateSoundContainer("Basic Melee Pan Flesh Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitMetalSound = CreateSoundContainer("Basic Melee Pan Metal Mordhau", "Mordhau.rte");
	
	local stabAttackSounds = {}
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--stabAttackSounds.hitDefaultSound
	--stabAttackSounds.hitDefaultSoundVariations
	
	stabAttackSounds.hitDeflectSound = CreateSoundContainer("Basic Melee Pan Metal Mordhau", "Mordhau.rte");
	
	stabAttackSounds.hitFleshSound = CreateSoundContainer("Basic Melee Pan Flesh Mordhau", "Mordhau.rte");
	
	stabAttackSounds.hitMetalSound = CreateSoundContainer("Basic Melee Pan Metal Mordhau", "Mordhau.rte");
	
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
	attackPhase[i].furthestReach = 15 -- for AI calculation number value setting later
	attackPhase[i].attackRange = 20
	self:SetNumberValue("Attack 1 Range", attackPhase[i].furthestReach + attackPhase[i].attackRange)
	self:SetStringValue("Attack 1 Name", "Swing");
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 90;
	
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
	attackPhase[i].durationMS = 100
	
	attackPhase[i].lastPrepare = true
	attackPhase[i].canBeBlocked = false
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 0
	attackPhase[i].attackStunChance = 0
	attackPhase[i].attackRange = 0
	attackPhase[i].attackPush = 0
	attackPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 0;
	
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
	attackPhase[i].durationMS = 110
	
	attackPhase[i].canBeBlocked = true
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 1
	attackPhase[i].attackStunChance = 0.15
	attackPhase[i].attackRange = 20
	attackPhase[i].attackPush = 0.8
	attackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 0;
	
	attackPhase[i].frameStart = 7
	attackPhase[i].frameEnd = 11
	attackPhase[i].angleStart = 30
	attackPhase[i].angleEnd = -50
	attackPhase[i].offsetStart = Vector(-6, -5)
	attackPhase[i].offsetEnd = Vector(7, -2)
	
	attackPhase[i].soundStart = CreateSoundContainer("Basic Melee Slash Mordhau", "Mordhau.rte");
	
	attackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	attackPhase[i] = {}
	attackPhase[i].durationMS = 30
	
	attackPhase[i].canBeBlocked = true
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 1
	attackPhase[i].attackStunChance = 0.15
	attackPhase[i].attackRange = 20
	attackPhase[i].attackPush = 0.8
	attackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 70;
	
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
	attackPhase[i].durationMS = 110
	
	attackPhase[i].canBeBlocked = true
	attackPhase[i].canDamage = true
	attackPhase[i].attackDamage = 1
	attackPhase[i].attackStunChance = 0.05
	attackPhase[i].attackRange = 20
	attackPhase[i].attackPush = 0.8
	attackPhase[i].attackVector = Vector(0, 5) -- local space vector relative to position and rotation
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
	horseAttackPhase[i].furthestReach = 10 -- for AI calculation number value setting later
	horseAttackPhase[i].attackRange = 20
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
	
	horseAttackPhase[i].soundStart = nil
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
	
	horseAttackPhase[i].soundEnd = nil
	horseAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 4
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 110
	
	horseAttackPhase[i].canBeBlocked = true
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 3.4
	horseAttackPhase[i].attackStunChance = 0.05
	horseAttackPhase[i].attackRange = 20
	horseAttackPhase[i].attackPush = 0.8
	horseAttackPhase[i].attackVector = Vector(0, 5) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 167;
	
	horseAttackPhase[i].frameStart = 9
	horseAttackPhase[i].frameEnd = 6
	horseAttackPhase[i].angleStart = -300
	horseAttackPhase[i].angleEnd = -220
	horseAttackPhase[i].offsetStart = Vector(-15, -6)
	horseAttackPhase[i].offsetEnd = Vector(-7, 2)
	
	horseAttackPhase[i].soundStart = CreateSoundContainer("Slash Longsword Mordhau", "Mordhau.rte");
	
	horseAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 5
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 30
	
	horseAttackPhase[i].canBeBlocked = true
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 3.4
	horseAttackPhase[i].attackStunChance = 0.05
	horseAttackPhase[i].attackRange = 20
	horseAttackPhase[i].attackPush = 0.8
	horseAttackPhase[i].attackVector = Vector(0, 5) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 145;
	
	horseAttackPhase[i].frameStart = 6
	horseAttackPhase[i].frameEnd = 6
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
	horseAttackPhase[i].attackRange = 20
	horseAttackPhase[i].attackPush = 0.8
	horseAttackPhase[i].attackVector = Vector(0, 5) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 110;
	
	horseAttackPhase[i].frameStart = 6
	horseAttackPhase[i].frameEnd = 6
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
	
	horseAttackPhase[i].frameStart = 16 + self.swingRotationFrames
	horseAttackPhase[i].frameEnd = 15 -- goes towards it, will never reach 15
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
	
	horseAttackPhase[i].frameStart = 16
	horseAttackPhase[i].frameEnd = (16 + 1 + self.swingRotationFrames); -- + 1 because the actual end frame is never reached, code just goes TOWARDS it 
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
	
	horseAttackPhase[i].frameStart = 6
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
	
	-- (stab)
	stabAttackPhase = {}
	stabAttackPhase.Type = "Stab";
	
	-- Prepare
	i = 1
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 200
	
	stabAttackPhase[i].canBeBlocked = false
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 0
	stabAttackPhase[i].attackStunChance = 0
	stabAttackPhase[i].furthestReach = 15 -- for AI calculation number value setting later
	stabAttackPhase[i].attackRange = 20
	self:SetNumberValue("Attack 3 Range", stabAttackPhase[i].furthestReach + stabAttackPhase[i].attackRange)
	self:SetStringValue("Attack 3 Name", "Stab");
	stabAttackPhase[i].attackPush = 0
	stabAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -45
	stabAttackPhase[i].angleEnd = -85
	stabAttackPhase[i].offsetStart = Vector(0, 0)
	stabAttackPhase[i].offsetEnd = Vector(-2, -3)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 200
	
	stabAttackPhase[i].lastPrepare = true
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
	stabAttackPhase[i].angleStart = -85
	stabAttackPhase[i].angleEnd = -90
	stabAttackPhase[i].offsetStart = Vector(-2, -3)
	stabAttackPhase[i].offsetEnd = Vector(-3, -4)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 110
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 1
	stabAttackPhase[i].attackStunChance = 0.15
	stabAttackPhase[i].attackRange = 22
	stabAttackPhase[i].attackPush = 0.8
	stabAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -70
	stabAttackPhase[i].angleEnd = -80
	stabAttackPhase[i].offsetStart = Vector(-3, -4)
	stabAttackPhase[i].offsetEnd = Vector(0, -5)
	
	stabAttackPhase[i].soundStart = CreateSoundContainer("Basic Melee Stab Mordhau", "Mordhau.rte");
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 30
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 1
	stabAttackPhase[i].attackStunChance = 0.15
	stabAttackPhase[i].attackRange = 22
	stabAttackPhase[i].attackPush = 0.8
	stabAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -80
	stabAttackPhase[i].angleEnd = -90
	stabAttackPhase[i].offsetStart = Vector(0, -5)
	stabAttackPhase[i].offsetEnd = Vector(4, -6)
	
	stabAttackPhase[i].soundStart = nil
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 110
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = true
	stabAttackPhase[i].attackDamage = 1
	stabAttackPhase[i].attackStunChance = 0.05
	stabAttackPhase[i].attackRange = 20
	stabAttackPhase[i].attackPush = 0.8
	stabAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -90
	stabAttackPhase[i].angleEnd = -90
	stabAttackPhase[i].offsetStart = Vector(4 , -6)
	stabAttackPhase[i].offsetEnd = Vector(15, -6)
	
	stabAttackPhase[i].soundStart = nil
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 100
	
	stabAttackPhase[i].firstRecovery = true
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
	stabAttackPhase[i].angleStart = -90
	stabAttackPhase[i].angleEnd = -60
	stabAttackPhase[i].offsetStart = Vector(15, -6)
	stabAttackPhase[i].offsetEnd = Vector(7, -3)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
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
	
	stabAttackPhase[i].frameStart = 7
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -60
	stabAttackPhase[i].angleEnd = -15
	stabAttackPhase[i].offsetStart = Vector(7, -3)
	stabAttackPhase[i].offsetEnd = Vector(3, 0)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[2] = stabAttackSounds
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
	overheadAttackPhase[i].furthestReach = 15 -- for AI calculation number value setting later
	overheadAttackPhase[i].attackRange = 20
	self:SetNumberValue("Attack 4 Range", overheadAttackPhase[i].furthestReach + overheadAttackPhase[i].attackRange)
	self:SetStringValue("Attack 4 Name", "Overhead");
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = -15
	overheadAttackPhase[i].angleEnd = 25
	overheadAttackPhase[i].offsetStart = Vector(0, 0)
	overheadAttackPhase[i].offsetEnd = Vector(4,-13)
	
	-- Late Prepare
	i = 2
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 200
	
	overheadAttackPhase[i].lastPrepare = true
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = 25
	overheadAttackPhase[i].angleEnd = 27
	overheadAttackPhase[i].offsetStart = Vector(4, -13)
	overheadAttackPhase[i].offsetEnd = Vector(4, -13)
	
	overheadAttackPhase[i].soundStart = nil
	overheadAttackPhase[i].soundStartVariations = 0
	
	overheadAttackPhase[i].soundEnd = nil
	overheadAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 3
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 40
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 1
	overheadAttackPhase[i].attackStunChance = 0.3
	overheadAttackPhase[i].attackRange = 20
	overheadAttackPhase[i].attackPush = 0.8
	overheadAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = 55;
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = 27
	overheadAttackPhase[i].angleEnd = 20
	overheadAttackPhase[i].offsetStart = Vector(4, -13)
	overheadAttackPhase[i].offsetEnd = Vector(6, -10)
	
	overheadAttackPhase[i].soundStart = CreateSoundContainer("Basic Melee Slash Mordhau", "Mordhau.rte");
	
	overheadAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 4
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 120
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = true
	overheadAttackPhase[i].attackDamage = 1
	overheadAttackPhase[i].attackStunChance = 0.3
	overheadAttackPhase[i].attackRange = 19
	overheadAttackPhase[i].attackPush = 1.0
	overheadAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = 55;
	
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

	-- Flourish... obviously
	flourishPhase = {}
	flourishPhase.Type = "Flourish";
	
	-- Go Away
	i = 1
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 300
	
	flourishPhase[i].canBeBlocked = false
	flourishPhase[i].canDamage = false
	flourishPhase[i].attackDamage = 0
	flourishPhase[i].attackStunChance = 0
	flourishPhase[i].attackRange = 0
	flourishPhase[i].attackPush = 0
	flourishPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	flourishPhase[i].attackAngle = 90;
	
	flourishPhase[i].frameStart = 6
	flourishPhase[i].frameEnd = 6
	flourishPhase[i].angleStart = -15
	flourishPhase[i].angleEnd = -45
	flourishPhase[i].offsetStart = Vector(0, 0)
	flourishPhase[i].offsetEnd = Vector(6, -5)
	
	flourishPhase[i].soundStart = CreateSoundContainer("Basic Melee Stab Mordhau", "Mordhau.rte");
	
	-- Wild Flail
	i = 2
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 200
	
	flourishPhase[i].canBeBlocked = false
	flourishPhase[i].canDamage = false
	flourishPhase[i].attackDamage = 0
	flourishPhase[i].attackStunChance = 0
	flourishPhase[i].attackRange = 0
	flourishPhase[i].attackPush = 0
	flourishPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	flourishPhase[i].attackAngle = 0;
	
	flourishPhase[i].frameStart = 6
	flourishPhase[i].frameEnd = 6
	flourishPhase[i].angleStart = -45
	flourishPhase[i].angleEnd = -90
	flourishPhase[i].offsetStart = Vector(6, -5)
	flourishPhase[i].offsetEnd = Vector(6, 5)
	
	flourishPhase[i].soundStart = CreateSoundContainer("Basic Melee Slash Mordhau", "Mordhau.rte");
	
	-- Please Leave
	i = 3
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 100
	
	flourishPhase[i].canBeBlocked = false
	flourishPhase[i].canDamage = false
	flourishPhase[i].attackDamage = 0
	flourishPhase[i].attackStunChance = 0
	flourishPhase[i].attackRange = 0
	flourishPhase[i].attackPush = 0
	flourishPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	flourishPhase[i].attackAngle = 0;
	
	flourishPhase[i].frameStart = 6
	flourishPhase[i].frameEnd = 6
	flourishPhase[i].angleStart = -90
	flourishPhase[i].angleEnd = -95
	flourishPhase[i].offsetStart = Vector(6, 5)
	flourishPhase[i].offsetEnd = Vector(6, 6)
	
	-- Panic
	i = 4
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 200
	
	flourishPhase[i].lastPrepare = true
	flourishPhase[i].canBeBlocked = false
	flourishPhase[i].canDamage = false
	flourishPhase[i].attackDamage = 3.4
	flourishPhase[i].attackStunChance = 0.15
	flourishPhase[i].attackRange = 20
	flourishPhase[i].attackPush = 0.8
	flourishPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	flourishPhase[i].attackAngle = 0;
	
	flourishPhase[i].frameStart = 6
	flourishPhase[i].frameEnd = 6
	flourishPhase[i].angleStart = -95
	flourishPhase[i].angleEnd = -45
	flourishPhase[i].offsetStart = Vector(6, 6)
	flourishPhase[i].offsetEnd = Vector(6, -5)
	
	flourishPhase[i].soundStart = CreateSoundContainer("Basic Melee Stab Mordhau", "Mordhau.rte");
	
	-- Ahhhh
	i = 5
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 100
	
	flourishPhase[i].lastPrepare = true
	flourishPhase[i].canBeBlocked = false
	flourishPhase[i].canDamage = false
	flourishPhase[i].attackDamage = 3.4
	flourishPhase[i].attackStunChance = 0.15
	flourishPhase[i].attackRange = 20
	flourishPhase[i].attackPush = 0.8
	flourishPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	flourishPhase[i].attackAngle = 0;
	
	flourishPhase[i].frameStart = 6
	flourishPhase[i].frameEnd = 6
	flourishPhase[i].angleStart = -45
	flourishPhase[i].angleEnd = -40
	flourishPhase[i].offsetStart = Vector(6, -5)
	flourishPhase[i].offsetEnd = Vector(6, -6)
	
	-- Regain Control
	i = 6
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 250
	
	flourishPhase[i].firstRecovery = false
	flourishPhase[i].canBeBlocked = false
	flourishPhase[i].canDamage = false
	flourishPhase[i].attackDamage = 3.4
	flourishPhase[i].attackStunChance = 0.15
	flourishPhase[i].attackRange = 20
	flourishPhase[i].attackPush = 0.8
	flourishPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	flourishPhase[i].attackAngle = 0;
	
	flourishPhase[i].frameStart = 6
	flourishPhase[i].frameEnd = 6
	flourishPhase[i].angleStart = -45
	flourishPhase[i].angleEnd = -15
	flourishPhase[i].offsetStart = Vector(6, 0)
	flourishPhase[i].offsetEnd = Vector(0, 0)
	
	flourishPhase[i].soundStart = nil
	
	flourishPhase[i].soundEnd = nil
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[4] = regularAttackSounds
	self.attackAnimationsGFX[4] = regularAttackGFX
	self.attackAnimations[4] = flourishPhase
	self.attackAnimationsTypes[4] = flourishPhase.Type
	
	-- warcry
	warcryPhase = {}
	warcryPhase.Type = "Warcry";
	
	-- Pump
	i = 1
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 250
	
	warcryPhase[i].lastPrepare = true
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
	warcryPhase[i].angleStart = -15
	warcryPhase[i].angleEnd = 45
	warcryPhase[i].offsetStart = Vector(0, 0)
	warcryPhase[i].offsetEnd = Vector(0, -15)
	
	warcryPhase[i].soundStart = nil
	
	-- Pause
	i = 2
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 700
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 3.4
	warcryPhase[i].attackStunChance = 0.15
	warcryPhase[i].attackRange = 20
	warcryPhase[i].attackPush = 0.8
	warcryPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 0;
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 6
	warcryPhase[i].angleStart = 45
	warcryPhase[i].angleEnd = 45
	warcryPhase[i].offsetStart = Vector(0, -15)
	warcryPhase[i].offsetEnd = Vector(0, -15)
	
	-- Return
	i = 3
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 300
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 3.4
	warcryPhase[i].attackStunChance = 0.15
	warcryPhase[i].attackRange = 20
	warcryPhase[i].attackPush = 0.8
	warcryPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 0;
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 6
	warcryPhase[i].angleStart = 45
	warcryPhase[i].angleEnd = -15
	warcryPhase[i].offsetStart = Vector(0, -15)
	warcryPhase[i].offsetEnd = Vector(0, 0)
	
	warcryPhase[i].soundStart = nil
	
	warcryPhase[i].soundEnd = nil
	
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
	
	shieldWarcryPhase[i].soundStart = nil
	
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
	
	shieldWarcryPhase[i].soundStart = CreateSoundContainer("Basic Melee Slash Mordhau", "Mordhau.rte");
	
	shieldWarcryPhase[i].soundEnd = CreateSoundContainer("Basic Melee Metal Blocked Mordhau", "Mordhau.rte");
	
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
	
	shieldWarcryPhase[i].soundEnd = nil
	
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
	
	shieldWarcryPhase[i].soundStart = CreateSoundContainer("Basic Melee Slash Mordhau", "Mordhau.rte");
	
	shieldWarcryPhase[i].soundEnd = CreateSoundContainer("Basic Melee Metal Blocked Mordhau", "Mordhau.rte");
	
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
	
	throwPhase[i].soundStart = nil
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
	
	self:RemoveStringValue("Blocked Mordhau")
	
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
				flourish = (player and UInputMan:KeyPressed(8));
				stab = (player and UInputMan:KeyPressed(2))
				overhead = (player and UInputMan:KeyPressed(22))
				if stab or overhead or flourish or throw or warcry then
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
				if stab or overhead or flourish or throw or warcry then
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
				self.parent:SetNumberValue("Block Foley", 1);
				playAttackAnimation(self, 5)
			elseif flourish and not self.parent:NumberValueExists("Mordhau Charge Ready") then
				self.parent:SetNumberValue("Block Foley", 1);
				playAttackAnimation(self, 4) -- fancypants shit
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
			self.woundCounter = self.WoundCount
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
				if activated then
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
			
			local heavyAttackFactor = (self.wasCharged and currentPhase.lastPrepare == true) and (currentPhase.durationMS * 2) or 0;
			local workingDuration = currentPhase.durationMS + heavyAttackFactor;
			if self.attackAnimationsTypes[self.currentAttackAnimation] == "ShieldWarcry" then
				workingDuration = workingDuration * (math.random(8, 17) / 10);
			end
			
			canBeBlocked = currentPhase.canBeBlocked or false
			canDamage = currentPhase.canDamage or false
			if canDamage == true then
				self.Attacked = true;
			end
			if self.blockedNullifier == false then
				canDamage = false;
				canBeBlocked = false;
			end
			damage = currentPhase.attackDamage or 0
			damageVector = currentPhase.attackVector or Vector(0,0)
			damageAngle = currentPhase.attackAngle or 0
			damageRange = currentPhase.attackRange or 0
			damageStun = currentPhase.attackStunChance or 0
			damagePush = currentPhase.attackPush or 0
			
			if self.wasCharged == true then
				damage = damage * 1.3;
				damageStun = damageStun * 1.3;
				damagePush = damagePush * 1.3;
			end
				
			
			rotationTarget = rotationTarget + (currentPhase.angleStart * (1 - factor) + currentPhase.angleEnd * factor) / 180 * math.pi -- interpolate rotation
			stanceTarget = stanceTarget + (currentPhase.offsetStart * (1 - factor) + currentPhase.offsetEnd * factor) -- interpolate stance offset
			local frameChange = currentPhase.frameEnd - currentPhase.frameStart
			self.Frame = math.floor(currentPhase.frameStart + math.floor(frameChange * factor, 0.55))
			
			if (self.Attacked == true and attack) and not (self.attackBuffered or self.stabBuffered or self.overheadBuffered) then
				if not stab and not overhead then
					self.attackBuffered = true;
					self.attackAnimationBuffered = 1;
				elseif stab then
					self.stabBuffered = true;
					self.attackAnimationBuffered = 2;
				elseif overhead then
					self.overheadBuffered = true;
					self.attackAnimationBuffered = 3;
				end
				
			end	

			if self.partiallyRecovered == true and (self.attackBuffered or self.stabBuffered or self.overheadBuffered) then
			
				self.chargeDecided = false;
				playAttackAnimation(self, self.attackAnimationBuffered)
				
				self.attackBuffered = false;
				self.stabBuffered = false;
				self.overheadBuffered = false;
			
				-- construct pseudo phase to get us from where we are now through the first phase of the buffered attack, if we buffered one
				-- doesn't THAT sound scientific
				
				local attackPhases = self.attackAnimations[self.attackAnimationBuffered]
				local currentPhase = attackPhases[1]
				
				self.pseudoPhase = {}
				self.pseudoPhase.durationMS = (currentPhase.durationMS * 1.8) or 0
				
				self.pseudoPhase.canBeBlocked = currentPhase.canBeBlocked or false
				self.pseudoPhase.canDamage = currentPhase.canDamage or false
				self.pseudoPhase.attackDamage = currentPhase.attackDamage or 0
				self.pseudoPhase.attackStunChance = currentPhase.attackStunChance or 0
				self.pseudoPhase.attackRange = currentPhase.attackRange or 0
				self.pseudoPhase.attackPush = currentPhase.attackPush or 0
				self.pseudoPhase.attackVector = currentPhase.attackVector or Vector(0, 0)
				self.pseudoPhase.attackAngle = currentPhase.attackAngle or 0
				
				self.pseudoPhase.frameStart = self.Frame
				self.pseudoPhase.frameEnd = currentPhase.frameEnd or 6
				self.pseudoPhase.angleStart = (self.rotation * self.FlipFactor) * (180/math.pi)
				self.pseudoPhase.angleEnd = currentPhase.angleEnd or 0
				self.pseudoPhase.offsetStart = self.stance
				self.pseudoPhase.offsetEnd = currentPhase.offsetEnd or Vector(0, 0)
				
				self.pseudoPhase.soundStart = currentPhase.soundStart or nil
				
				self.pseudoPhase.soundEnd = currentPhase.soundEnd or nil
					
				
			end			
			
			-- DEBUG
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 40), "animation = "..animation, true, 0);
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "sequence = "..self.currentAttackSequence, true, 0);
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 30), "factor = "..math.floor(factor * 100).."/100", true, 0);
			if self.attackAnimationTimer:IsPastSimMS(workingDuration) then
				if (self.currentAttackSequence+1) <= #attackPhases then
					self.currentAttackSequence = self.currentAttackSequence + 1
				else
					if not self.attackBuffered == true then
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
						local throwChargeFactor = self.wasCharged and 15 or 0
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
				
				self.rotationInterpolationSpeed = 13
			
				self.parent:SetNumberValue("Block Foley", 1);
			
				self.Blocking = true;
				
				self:SetNumberValue("Blocking", 1);
				
				stanceTarget = Vector(4, -7);
				
				self.originalBaseRotation = -160;
				self.baseRotation = -145;
			
			elseif keyHeld and not (self.attackAnimationIsPlaying) then
			
				self.originalBaseRotation = -160;
			
				stanceTarget = Vector(4, -7);
				
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
				
				if self.parent:NumberValueExists("Mordhau Charging") then
				
					stanceTarget = Vector(12, 0);
					
					self.originalBaseRotation = 50;
					self.baseRotation = 50;
				end
				
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
				
				if self.Parrying == true or self:NumberValueExists("AI Parry Eligible") then
					self.parrySound:Play(self.Pos);
					
					if self:NumberValueExists("AI Parry Eligible") then
						self:RemoveNumberValue("AI Parry Eligible");			
						self:RemoveNumberValue("AI Parry");	
						
						self.Parrying = true;
						
						if self:GetStringValue("Blocked Type") == "Slash" then
							if math.random(0, 100) < 50 then
								playAttackAnimation(self, 4);
								self:SetNumberValue("Current Attack Type", 4);
								self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 4 Range"));
							elseif self.parent:NumberValueExists("Mordhau Disable Movement") then
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
		
		-- COLLISION DETECTION
		
		--self.attackAnimationsSounds[1]
		if canBeBlocked and self.attackAnimationCanHit then -- Detect collision
			--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + attackOffset,  13);
			local hit = false
			local hitType = 0
			local team = 0
			if actor then team = actor.Team end
			local rayVec = Vector(damageRange * self.FlipFactor, 0):RadRotate(self.RotAngle):DegRotate(damageAngle*self.FlipFactor)--damageVector:RadRotate(self.RotAngle) * Vector(self.FlipFactor, 1)
			local rayOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(damageVector.X * self.FlipFactor, damageVector.Y):RadRotate(self.RotAngle)
			
			--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
			--PrimitiveMan:DrawCirclePrimitive(self.Pos, 3, 5);
			
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
							self.attackBuffered = false;
							self.stabBuffered = false;
							self.overheadBuffered = false;
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
						if self.wasCharged then
							local effect = CreateMOSRotating(self.blockGFX.Heavy, "Mordhau.rte");
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
							MO:SetNumberValue("Blocked Heavy", 1);
						end
						
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
		end
	end
	
	self:RemoveNumberValue("AI Block");
end