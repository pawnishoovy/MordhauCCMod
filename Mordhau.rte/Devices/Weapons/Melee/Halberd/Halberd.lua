
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
--
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

	self.equipSound = CreateSoundContainer("LargeSword Equip Mordhau", "Mordhau.rte");
	self.equipSound.Pitch = 1.0;
	
	self.pickUpSound = CreateSoundContainer("Blade Pickup Mordhau", "Mordhau.rte");
	self.pickUpSound.Pitch = 0.8;

	-- throwing stuff
	
	self.throwSound = CreateSoundContainer("Throw Javelin", "Mordhau.rte");
	self.throwSoundPlayed = false;
	
	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("Impact Concrete Javelin", "Mordhau.rte"),
			[164] = CreateSoundContainer("Impact Concrete Javelin", "Mordhau.rte"),
			[177] = CreateSoundContainer("Impact Concrete Javelin", "Mordhau.rte"),
			[9] = CreateSoundContainer("Impact Dirt Javelin", "Mordhau.rte"),
			[10] = CreateSoundContainer("Impact Dirt Javelin", "Mordhau.rte"),
			[11] = CreateSoundContainer("Impact Dirt Javelin", "Mordhau.rte"),
			[128] = CreateSoundContainer("Impact Dirt Javelin", "Mordhau.rte"),
			[6] = CreateSoundContainer("Impact Sand Javelin", "Mordhau.rte"),
			[8] = CreateSoundContainer("Impact Sand Javelin", "Mordhau.rte"),
			[178] = CreateSoundContainer("Impact SolidMetal Javelin", "Mordhau.rte"),
			[179] = CreateSoundContainer("Impact SolidMetal Javelin", "Mordhau.rte"),
			[180] = CreateSoundContainer("Impact SolidMetal Javelin", "Mordhau.rte"),
			[181] = CreateSoundContainer("Impact SolidMetal Javelin", "Mordhau.rte"),
			[182] = CreateSoundContainer("Impact SolidMetal Javelin", "Mordhau.rte")}}
			
	self.soundHitFlesh = CreateSoundContainer("Impact Flesh Javelin", "Mordhau.rte");
	self.soundHitMetal = CreateSoundContainer("Impact Metal Javelin", "Mordhau.rte");
	
	
	
	self.equipAnimationTimer = Timer();
	
	self.swingRotationFrames = 1; -- this is the amount of frames it takes us to go from sideways to facing forwards again (after a swing)
								  -- for swords this might just be one, for big axes it could be as high as 4
								  
	self.sweetSpotThreshold = 0.7; -- if our hit position is at least 70% of the range away from the hit origin, we deal max damage. otherwise, linearly decrease towards 25% damage

	self.originalStanceOffset = Vector(self.StanceOffset.X * self.FlipFactor, self.StanceOffset.Y)
	
	self.originalBaseRotation = 0;
	self.baseRotation = 0;
	
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
	
	self.blockedSound = CreateSoundContainer("Blocked Halberd Mordhau", "Mordhau.rte");
	self.parrySound = CreateSoundContainer("Parry Halberd Mordhau", "Mordhau.rte");
	self.heavyBlockAddSound = CreateSoundContainer("HeavyBlockAdd Halberd Mordhau", "Mordhau.rte");
	
	self.blockSounds = {};
	self.blockSounds.Slash = CreateSoundContainer("Slash Block Halberd Mordhau", "Mordhau.rte");
	self.blockSounds.Stab = CreateSoundContainer("Stab Block Halberd Mordhau", "Mordhau.rte");
	
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
	
	regularAttackSounds.hitDeflectSound = CreateSoundContainer("Slash Metal Halberd Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitFleshSound = CreateSoundContainer("Slash Flesh Halberd Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitMetalSound = CreateSoundContainer("Slash Metal Halberd Mordhau", "Mordhau.rte");
	
	local stabAttackSounds = {}
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--stabAttackSounds.hitDefaultSound
	--stabAttackSounds.hitDefaultSoundVariations
	
	stabAttackSounds.hitDeflectSound = CreateSoundContainer("Stab Metal Halberd Mordhau", "Mordhau.rte");
	
	stabAttackSounds.hitFleshSound = CreateSoundContainer("Stab Flesh Halberd Mordhau", "Mordhau.rte");
	
	stabAttackSounds.hitMetalSound = CreateSoundContainer("Stab Metal Halberd Mordhau", "Mordhau.rte");
	
	local regularAttackGFX = {}
	
	regularAttackGFX.hitTerrainSoftGFX = "Melee Terrain Soft Effect Mordhau"
	regularAttackGFX.hitTerrainHardGFX = "Melee Terrain Hard Effect Mordhau"
	regularAttackGFX.hitFleshGFX = "Melee Flesh Effect Mordhau"
	regularAttackGFX.hitMetalGFX = "Melee Terrain Hard Effect Mordhau"
	regularAttackGFX.hitDeflectGFX = "Melee Terrain Hard Effect Mordhau"
	
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
	attackPhase[i].attackRange = 0
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
	attackPhase[i].durationMS = 450
	
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
	attackPhase[i].durationMS = 160
	
	attackPhase[i].canBeBlocked = true
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 3.4
	attackPhase[i].attackStunChance = 0.15
	attackPhase[i].attackRange = 30
	attackPhase[i].attackPush = 0.8
	attackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 0;
	
	attackPhase[i].frameStart = 7
	attackPhase[i].frameEnd = 11
	attackPhase[i].angleStart = 30
	attackPhase[i].angleEnd = -50
	attackPhase[i].offsetStart = Vector(-6, -5)
	attackPhase[i].offsetEnd = Vector(7, -2)
	
	attackPhase[i].soundStart = CreateSoundContainer("Slash Halberd Mordhau", "Mordhau.rte");
	
	attackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	attackPhase[i] = {}
	attackPhase[i].durationMS = 50
	
	attackPhase[i].canBeBlocked = true
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 3.4
	attackPhase[i].attackStunChance = 0.15
	attackPhase[i].attackRange = 30
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
	attackPhase[i].durationMS = 160
	
	attackPhase[i].canBeBlocked = true
	attackPhase[i].canDamage = true
	attackPhase[i].attackDamage = 3.4
	attackPhase[i].attackStunChance = 0.15
	attackPhase[i].attackRange = 30
	attackPhase[i].attackPush = 0.80
	attackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 90;
	
	attackPhase[i].frameStart = 11
	attackPhase[i].frameEnd = 16
	attackPhase[i].angleStart = -90
	attackPhase[i].angleEnd = -100
	attackPhase[i].offsetStart = Vector(7 , -2)
	attackPhase[i].offsetEnd = Vector(15, -4)
	
	attackPhase[i].soundStart = nil
	
	attackPhase[i].soundEnd = nil
	
	-- Early Early Recover
	i = 6
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
	
	attackPhase[i].frameStart = 16
	attackPhase[i].frameEnd = 16
	attackPhase[i].angleStart = -90
	attackPhase[i].angleEnd = -86
	attackPhase[i].offsetStart = Vector(15, -4)
	attackPhase[i].offsetEnd = Vector(8, -2)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Early Recover
	i = 7
	attackPhase[i] = {}
	attackPhase[i].durationMS = 250
	
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
	attackPhase[i].angleStart = -86
	attackPhase[i].angleEnd = -55
	attackPhase[i].offsetStart = Vector(8, -2)
	attackPhase[i].offsetEnd = Vector(3, 0)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 8
	attackPhase[i] = {}
	attackPhase[i].durationMS = 400
	
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
	attackPhase[i].angleStart = -55
	attackPhase[i].angleEnd = 0
	attackPhase[i].offsetStart = Vector(3, 0)
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
	horseAttackPhase[i].durationMS = 300
	
	horseAttackPhase[i].canBeBlocked = false
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 0
	horseAttackPhase[i].attackStunChance = 0
	horseAttackPhase[i].attackRange = 0
	horseAttackPhase[i].attackPush = 0
	horseAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 90;
	
	horseAttackPhase[i].frameStart = 6
	horseAttackPhase[i].frameEnd = 11
	horseAttackPhase[i].angleStart = 0
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
	horseAttackPhase[i].durationMS = 450
	
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
	horseAttackPhase[i].durationMS = 400
	
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
	horseAttackPhase[i].frameEnd = 8
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
	horseAttackPhase[i].durationMS = 180
	
	horseAttackPhase[i].canBeBlocked = true
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 3.4
	horseAttackPhase[i].attackStunChance = 0.15
	horseAttackPhase[i].attackRange = 25
	horseAttackPhase[i].attackPush = 0.80
	horseAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 167;
	
	horseAttackPhase[i].frameStart = 8
	horseAttackPhase[i].frameEnd = 8
	horseAttackPhase[i].angleStart = -300
	horseAttackPhase[i].angleEnd = -220
	horseAttackPhase[i].offsetStart = Vector(-15, -6)
	horseAttackPhase[i].offsetEnd = Vector(-7, 2)
	
	horseAttackPhase[i].soundStart = CreateSoundContainer("Slash Longsword Mordhau", "Mordhau.rte");
	
	horseAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 5
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 60
	
	horseAttackPhase[i].canBeBlocked = true
	horseAttackPhase[i].canDamage = false
	horseAttackPhase[i].attackDamage = 3.4
	horseAttackPhase[i].attackStunChance = 0.15
	horseAttackPhase[i].attackRange = 25
	horseAttackPhase[i].attackPush = 0.80
	horseAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 145;
	
	horseAttackPhase[i].frameStart = 8
	horseAttackPhase[i].frameEnd = 8
	horseAttackPhase[i].angleStart = -220
	horseAttackPhase[i].angleEnd = -200
	horseAttackPhase[i].offsetStart = Vector(-7, 2)
	horseAttackPhase[i].offsetEnd = Vector(0, 3)
	
	horseAttackPhase[i].soundStart = nil
	
	horseAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 6
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 240
	
	horseAttackPhase[i].canBeBlocked = true
	horseAttackPhase[i].canDamage = true
	horseAttackPhase[i].attackDamage = 3.4
	horseAttackPhase[i].attackStunChance = 0.15
	horseAttackPhase[i].attackRange = 25
	horseAttackPhase[i].attackPush = 0.80
	horseAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	horseAttackPhase[i].attackAngle = 110;
	
	horseAttackPhase[i].frameStart = 8
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
	horseAttackPhase[i].durationMS = 70
	
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
	horseAttackPhase[i].durationMS = 70
	
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
	horseAttackPhase[i].durationMS = 350
	
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
	horseAttackPhase[i].angleEnd = 5
	horseAttackPhase[i].offsetStart = Vector(3, 0)
	horseAttackPhase[i].offsetEnd = Vector(0, 0)
	
	horseAttackPhase[i].soundStart = nil
	horseAttackPhase[i].soundStartVariations = 0
	
	horseAttackPhase[i].soundEnd = nil
	horseAttackPhase[i].soundEndVariations = 0
	
	-- Late Recover
	i = 10
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 200
	
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
	horseAttackPhase[i].angleStart = 5
	horseAttackPhase[i].angleEnd = 9
	horseAttackPhase[i].offsetStart = Vector(0, 0)
	horseAttackPhase[i].offsetEnd = Vector(-3, 0)
	
	horseAttackPhase[i].soundStart = nil
	horseAttackPhase[i].soundStartVariations = 0
	
	horseAttackPhase[i].soundEnd = nil
	horseAttackPhase[i].soundEndVariations = 0
	
	-- Late Late Recover
	i = 11
	horseAttackPhase[i] = {}
	horseAttackPhase[i].durationMS = 300
	
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
	horseAttackPhase[i].angleStart = 9
	horseAttackPhase[i].angleEnd = 0
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
	stabAttackPhase[i].attackRange = 0
	stabAttackPhase[i].attackPush = 0
	stabAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = 0
	stabAttackPhase[i].angleEnd = -85
	stabAttackPhase[i].offsetStart = Vector(0, 0)
	stabAttackPhase[i].offsetEnd = Vector(-9, 0)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 450
	
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
	stabAttackPhase[i].offsetStart = Vector(-9, 0)
	stabAttackPhase[i].offsetEnd = Vector(-9, 0)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 160
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 4
	stabAttackPhase[i].attackStunChance = 0.10
	stabAttackPhase[i].attackRange = 32
	stabAttackPhase[i].attackPush = 0.85
	stabAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -90
	stabAttackPhase[i].angleEnd = -90
	stabAttackPhase[i].offsetStart = Vector(-9, 0)
	stabAttackPhase[i].offsetEnd = Vector(0, 0)
	
	stabAttackPhase[i].soundStart = CreateSoundContainer("Stab Halberd Mordhau", "Mordhau.rte");
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 35
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 4
	stabAttackPhase[i].attackStunChance = 0.15
	stabAttackPhase[i].attackRange = 32
	stabAttackPhase[i].attackPush = 0.8
	stabAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -90
	stabAttackPhase[i].angleEnd = -90
	stabAttackPhase[i].offsetStart = Vector(0, 0)
	stabAttackPhase[i].offsetEnd = Vector(4, 0)
	
	stabAttackPhase[i].soundStart = nil
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 130
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = true
	stabAttackPhase[i].attackDamage = 4
	stabAttackPhase[i].attackStunChance = 0.15
	stabAttackPhase[i].attackRange = 30
	stabAttackPhase[i].attackPush = 0.8
	stabAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -90
	stabAttackPhase[i].angleEnd = -90
	stabAttackPhase[i].offsetStart = Vector(4 , 0)
	stabAttackPhase[i].offsetEnd = Vector(15, 0)
	
	stabAttackPhase[i].soundStart = nil
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Pause
	i = 6
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 200
	
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
	stabAttackPhase[i].angleEnd = -90
	stabAttackPhase[i].offsetStart = Vector(15, 0)
	stabAttackPhase[i].offsetEnd = Vector(6, 4)
	
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
	stabAttackPhase[i].angleStart = -90
	stabAttackPhase[i].angleEnd = -85
	stabAttackPhase[i].offsetStart = Vector(6, 4)
	stabAttackPhase[i].offsetEnd = Vector(-6, 0)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Late Recover
	i = 8
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 300
	
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
	stabAttackPhase[i].angleEnd = 0
	stabAttackPhase[i].offsetStart = Vector(-6, 0)
	stabAttackPhase[i].offsetEnd = Vector(0, 0)
	
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
	overheadAttackPhase[i].durationMS = 330
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = 0
	overheadAttackPhase[i].angleEnd = 25
	overheadAttackPhase[i].offsetStart = Vector(0, 0)
	overheadAttackPhase[i].offsetEnd = Vector(-4,-15)
	
	-- Late Prepare
	i = 2
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 450
	
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
	overheadAttackPhase[i].offsetStart = Vector(-4, -15)
	overheadAttackPhase[i].offsetEnd = Vector(-4, -15)
	
	overheadAttackPhase[i].soundStart = nil
	overheadAttackPhase[i].soundStartVariations = 0
	
	overheadAttackPhase[i].soundEnd = nil
	overheadAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 3
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 70
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 5
	overheadAttackPhase[i].attackStunChance = 0.3
	overheadAttackPhase[i].attackRange = 30
	overheadAttackPhase[i].attackPush = 0.8
	overheadAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = 55;
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = 27
	overheadAttackPhase[i].angleEnd = 20
	overheadAttackPhase[i].offsetStart = Vector(0, -15)
	overheadAttackPhase[i].offsetEnd = Vector(3, -10)
	
	overheadAttackPhase[i].soundStart = CreateSoundContainer("Slash Halberd Mordhau", "Mordhau.rte");
	
	overheadAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 4
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 170
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = true
	overheadAttackPhase[i].attackDamage = 6
	overheadAttackPhase[i].attackStunChance = 0.3
	overheadAttackPhase[i].attackRange = 30
	overheadAttackPhase[i].attackPush = 0.9
	overheadAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = 55;
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = 20
	overheadAttackPhase[i].angleEnd = -150
	overheadAttackPhase[i].offsetStart = Vector(3, -10)
	overheadAttackPhase[i].offsetEnd = Vector(15, 15)
	
	-- Early Recover
	i = 5
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 100
	
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
	overheadAttackPhase[i].durationMS = 560
	
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
	overheadAttackPhase[i].angleEnd = 0
	overheadAttackPhase[i].offsetStart = Vector(10, 15)
	overheadAttackPhase[i].offsetEnd = Vector(1, -1)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[3] = regularAttackSounds
	self.attackAnimationsGFX[3] = regularAttackGFX
	self.attackAnimations[3] = overheadAttackPhase
	self.attackAnimationsTypes[3] = overheadAttackPhase.Type
	
	-- Flourish... obviously
	flourishPhase = {}
	flourishPhase.Type = "Flourish";
	
	-- Surprise
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
	flourishPhase[i].frameEnd = 11
	flourishPhase[i].angleStart = 0
	flourishPhase[i].angleEnd = 0
	flourishPhase[i].offsetStart = Vector(0, 0)
	flourishPhase[i].offsetEnd = Vector(-6, -5)
	
	flourishPhase[i].soundStart = CreateSoundContainer("Flourish Halberd Mordhau", "Mordhau.rte");
	
	-- Bedazzle
	i = 2
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
	
	flourishPhase[i].frameStart = 11
	flourishPhase[i].frameEnd = 11
	flourishPhase[i].angleStart = 0
	flourishPhase[i].angleEnd = -30
	flourishPhase[i].offsetStart = Vector(-6, -5)
	flourishPhase[i].offsetEnd = Vector(-6, -5)
	
	flourishPhase[i].soundStart = nil
	flourishPhase[i].soundStartVariations = 0
	
	flourishPhase[i].soundEnd = nil
	flourishPhase[i].soundEndVariations = 0
	
	-- Amaze
	i = 3
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 250
	
	flourishPhase[i].lastPrepare = true
	flourishPhase[i].canBeBlocked = false
	flourishPhase[i].canDamage = false
	flourishPhase[i].attackDamage = 3.4
	flourishPhase[i].attackStunChance = 0.15
	flourishPhase[i].attackRange = 20
	flourishPhase[i].attackPush = 0.8
	flourishPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	flourishPhase[i].attackAngle = 0;
	
	flourishPhase[i].frameStart = 11
	flourishPhase[i].frameEnd = 8
	flourishPhase[i].angleStart = -30
	flourishPhase[i].angleEnd = -30
	flourishPhase[i].offsetStart = Vector(-6, -5)
	flourishPhase[i].offsetEnd = Vector(0, -2)
	
	flourishPhase[i].soundEnd = nil
	
	-- Bask
	i = 4
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 300
	
	flourishPhase[i].firstRecovery = false
	flourishPhase[i].canBeBlocked = false
	flourishPhase[i].canDamage = false
	flourishPhase[i].attackDamage = 3.4
	flourishPhase[i].attackStunChance = 0.15
	flourishPhase[i].attackRange = 20
	flourishPhase[i].attackPush = 0.8
	flourishPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	flourishPhase[i].attackAngle = 0;
	
	flourishPhase[i].frameStart = 8
	flourishPhase[i].frameEnd = 6
	flourishPhase[i].angleStart = -30
	flourishPhase[i].angleEnd = -0
	flourishPhase[i].offsetStart = Vector(0, -2)
	flourishPhase[i].offsetEnd = Vector(0, -1)
	
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
	
	-- Prepare
	i = 1
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 450
	
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
	warcryPhase[i].angleStart = 0
	warcryPhase[i].angleEnd = -15
	warcryPhase[i].offsetStart = Vector(0, 0)
	warcryPhase[i].offsetEnd = Vector(-2, 3)
	
	-- Pump
	i = 2
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
	warcryPhase[i].angleEnd = -15
	warcryPhase[i].offsetStart = Vector(-2, 3)
	warcryPhase[i].offsetEnd = Vector(6, -15)
	
	warcryPhase[i].soundStart = CreateSoundContainer("Stab Halberd Mordhau", "Mordhau.rte");
	
	-- Pause
	i = 3
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 500
	
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
	warcryPhase[i].angleEnd = -15
	warcryPhase[i].offsetStart = Vector(6, -15)
	warcryPhase[i].offsetEnd = Vector(6, -15)
	
	warcryPhase[i].soundStart = nil
	
	-- Lower
	i = 4
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 300
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 0;
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 6
	warcryPhase[i].angleStart = -15
	warcryPhase[i].angleEnd = -60
	warcryPhase[i].offsetStart = Vector(6, -15)
	warcryPhase[i].offsetEnd = Vector(6, -5)
	
	-- Pause
	i = 5
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 450
	
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
	warcryPhase[i].angleStart = -60
	warcryPhase[i].angleEnd = -60
	warcryPhase[i].offsetStart = Vector(6, -5)
	warcryPhase[i].offsetEnd = Vector(6, -5)
	
	-- Return
	i = 6
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
	warcryPhase[i].angleStart = -60
	warcryPhase[i].angleEnd = 0
	warcryPhase[i].offsetStart = Vector(6, -5)
	warcryPhase[i].offsetEnd = Vector(0, 0)
	
	warcryPhase[i].soundStart = nil
	
	warcryPhase[i].soundEnd = nil
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[5] = regularAttackSounds
	self.attackAnimationsGFX[5] = regularAttackGFX
	self.attackAnimations[5] = warcryPhase
	self.attackAnimationsTypes[5] = warcryPhase.Type	
	
	-- Throw
	throwPhase = {}
	throwPhase.Type = "Stab";
	
	-- Windup
	i = 1
	throwPhase[i] = {}
	throwPhase[i].durationMS = 800
	
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
	throwPhase[i].angleEnd = -90
	throwPhase[i].offsetStart = Vector(0, 0)
	throwPhase[i].offsetEnd = Vector(-15, -15)

	
	-- Pause
	i = 2
	throwPhase[i] = {}
	throwPhase[i].durationMS = 500
	
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
	throwPhase[i].angleStart = -90
	throwPhase[i].angleEnd = -90
	throwPhase[i].offsetStart = Vector(-15, -15)
	throwPhase[i].offsetEnd = Vector(-15, -15)
	
	
	-- Throw
	i = 3
	throwPhase[i] = {}
	throwPhase[i].durationMS = 100
	
	throwPhase[i].canBeBlocked = true
	throwPhase[i].canDamage = true
	throwPhase[i].attackDamage = 2.3
	throwPhase[i].attackStunChance = 0
	throwPhase[i].attackRange = 15
	throwPhase[i].attackPush = 0.8
	throwPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	throwPhase[i].attackAngle = 90;
	
	throwPhase[i].frameStart = 6
	throwPhase[i].frameEnd = 6
	throwPhase[i].angleStart = -90
	throwPhase[i].angleEnd = -90
	throwPhase[i].offsetStart = Vector(-15, -15)
	throwPhase[i].offsetEnd = Vector(6, -15)
	
	throwPhase[i].soundStart = nil
	throwPhase[i].soundStartVariations = 0
	
	throwPhase[i].soundEnd = nil
	throwPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[6] = regularAttackSounds
	self.attackAnimationsGFX[6] = regularAttackGFX
	self.attackAnimations[6] = throwPhase
	self.attackAnimationsTypes[6] = throwPhase.Type
	
	-- Equip anim
	equipPhase = {}
	equipPhase.Type = "Equip";
	
	-- Out
	i = 1
	equipPhase[i] = {}
	equipPhase[i].durationMS = 300
	
	equipPhase[i].canBeBlocked = false
	equipPhase[i].canDamage = false
	equipPhase[i].attackDamage = 0
	equipPhase[i].attackStunChance = 0
	equipPhase[i].attackRange = 0
	equipPhase[i].attackPush = 0
	equipPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	equipPhase[i].attackAngle = 90;
	
	equipPhase[i].frameStart = 6
	equipPhase[i].frameEnd = 6
	equipPhase[i].angleStart = 170
	equipPhase[i].angleEnd = 150
	equipPhase[i].offsetStart = Vector(-15, -25)
	equipPhase[i].offsetEnd = Vector(-12, -15)
	
	-- Upright
	i = 2
	equipPhase[i] = {}
	equipPhase[i].durationMS = 200
	
	equipPhase[i].canBeBlocked = false
	equipPhase[i].canDamage = false
	equipPhase[i].attackDamage = 0
	equipPhase[i].attackStunChance = 0
	equipPhase[i].attackRange = 0
	equipPhase[i].attackPush = 0
	equipPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	equipPhase[i].attackAngle = 0;
	
	equipPhase[i].frameStart = 6
	equipPhase[i].frameEnd = 8
	equipPhase[i].angleStart = 150
	equipPhase[i].angleEnd = 0
	equipPhase[i].offsetStart = Vector(-12, -15)
	equipPhase[i].offsetEnd = Vector(-5, -10)
	
	equipPhase[i].soundStart = nil
	equipPhase[i].soundStartVariations = 0
	
	equipPhase[i].soundEnd = nil
	equipPhase[i].soundEndVariations = 0
	
	-- Stance
	i = 3
	equipPhase[i] = {}
	equipPhase[i].durationMS = 200
	
	equipPhase[i].canBeBlocked = false
	equipPhase[i].canDamage = false
	equipPhase[i].attackDamage = 3.4
	equipPhase[i].attackStunChance = 0.15
	equipPhase[i].attackRange = 20
	equipPhase[i].attackPush = 0.8
	equipPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	equipPhase[i].attackAngle = 0;
	
	equipPhase[i].frameStart = 8
	equipPhase[i].frameEnd = 6
	equipPhase[i].angleStart = 0
	equipPhase[i].angleEnd = -15
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
	
	if self.equipAnim == true then
	
		playAttackAnimation(self, 10)
		self.equipAnim = false;

		local rotationTarget = 170 / 180 * math.pi
		local stanceTarget = Vector(-10, -10);
	
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
				stab = (player and UInputMan:KeyPressed(2)) or self.stabBuffered;
				overhead = (player and UInputMan:KeyPressed(22)) or self.overheadBuffered;
				if stab or overhead or flourish or throw or warcry or self.attackBuffered == true  then
					controller:SetState(Controller.PRESS_PRIMARY, true)
					self:Activate();
				end
				attack = controller:IsState(Controller.PRESS_PRIMARY);
				if self:IsActivated() and self.attackCooldown == true then
					self:Deactivate();
					self.attackBuffered = false;
					self.stabBuffered = false;
					self.overheadBuffered = false;
				else
					self.attackBuffered = false;
					self.stabBuffered = false;
					self.overheadBuffered = false;
					self.attackCooldown = false;
				end
			else
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
				
				self.originalBaseRotation = 0;
				self.baseRotation = 0;
				
			end
			
			if not stab and not overhead and not flourish and not throw and not warcry then
				if self.parent:NumberValueExists("Mordhau Disable Movement") then -- we're probably on a horse if this is set... probably...
					playAttackAnimation(self, 15) -- regular attack
				else
					playAttackAnimation(self, 1) -- regular attack
				end
			elseif stab then
				playAttackAnimation(self, 2) -- stab
			elseif overhead then
				playAttackAnimation(self, 3) -- overhead
			elseif warcry then
				self.parent:SetNumberValue("Block Foley", 1);
				playAttackAnimation(self, 5)
			elseif flourish then
				self.parent:SetNumberValue("Block Foley", 1);
				playAttackAnimation(self, 4) -- fancypants shit
			elseif throw then
				self.parent:SetNumberValue("Block Foley", 1);
				self.Throwing = true;
				playAttackAnimation(self, 6) -- throw
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
				if activated then
					self.attackCooldown = true;
					self.wasCharged = true;
					self.parent:SetNumberValue("Large Attack", 1);
				else
					self.wasCharged = false;
					self.parent:SetNumberValue("Medium Attack", 1);				
				end
			elseif currentPhase.firstRecovery == true then
				self.Recovering = true;
			elseif self.chargeDecided == false then
				-- block cancelling
				if player then
					local keyPress = UInputMan:KeyPressed(18);
					if keyPress then
						self.Throwing = false;
						self.wasCharged = false;
						self.currentAttackAnimation = 0
						self.currentAttackSequence = 0
						self.attackAnimationIsPlaying = false			
						self.parent:SetNumberValue("Block Foley", 1);
					
						self.Blocking = true;
						
						self:SetNumberValue("Blocking", 1);
						
						stanceTarget = Vector(4, 0);
						
						self.originalBaseRotation = -60;
						self.baseRotation = -45;
					end
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
					self.attackAnimationBuffered = self.parent:NumberValueExists("Mordhau Disable Movement") and 15 or 1;
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
					if not self.attackBuffered == true and not self.stabBuffered and not self.overheadBuffered then
						self.attackCooldown = true;
					end
					self.wasCharged = false;
					self.currentAttackAnimation = 0
					self.currentAttackSequence = 0
					self.attackAnimationIsPlaying = false
					if self.Throwing == true then
						local throwChargeFactor = self.wasCharged and 10 or 0
						self.Throwing = false;
						self.wasThrown = true;
						self:GetParent():RemoveAttachable(self, true, false);
						self.Vel = self.parent.Vel + Vector((throwChargeFactor + 25)*self.FlipFactor, 0):RadRotate(self.RotAngle);
						self.throwSoundPlayed = false;
						
					end
				end
				
				if currentPhase.soundEnd then
					currentPhase.soundEnd:Play(self.Pos);
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
				self.attackCooldown = true;
				self.wasCharged = false;
				self.currentAttackAnimation = 0
				self.currentAttackSequence = 0
				self.attackAnimationIsPlaying = false
				self.Parrying = false;
				self:RemoveStringValue("Parrying Type");
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
			
			if player then
				local keyPress = UInputMan:KeyPressed(18) or (UInputMan:KeyHeld(18) and self.Blocking == false);
				if keyPress and not (self.attackAnimationIsPlaying) then
				
					self.parent:SetNumberValue("Block Foley", 1);
				
					self.Blocking = true;
					
					self:SetNumberValue("Blocking", 1);
					
					stanceTarget = Vector(4, 0);
					
					self.originalBaseRotation = -60;
					self.baseRotation = -45;
				
				elseif self.Blocking == true and UInputMan:KeyHeld(18) and not (self.attackAnimationIsPlaying) then
				
					self.originalBaseRotation = -60;
				
					stanceTarget = Vector(4, 0);
				
				elseif UInputMan:KeyReleased(18) then
				
					self.parent:SetNumberValue("Block Foley", 1);
				
					self.Blocking = false;
					
					self:RemoveNumberValue("Blocking");
					
					self.originalBaseRotation = 0;
					self.baseRotation = 0;
				
				else
					
					self.Blocking = false;
					
					self:RemoveNumberValue("Blocking");
					
					self.originalBaseRotation = 0;
					self.baseRotation = 0;
					
				end
			elseif not self.attackAnimationIsPlaying then
			
				self.Blocking = true;
				
				self:SetNumberValue("Blocking", 1);
				
				stanceTarget = Vector(4, 0);
				
				self.originalBaseRotation = -60;
				self.baseRotation = -45;
				
			end
				
			
			if self:IsAttached() then
				self.Frame = 6;
			else
				self.Frame = 1;
			end
		end
		
		if self.Blocking == true or self.Parrying == true then
			
			if self:StringValueExists("Blocked Type") then
			
				if self.parent then
					self.parent:SetNumberValue("Blocked Mordhau", 1);
				end
			
				self.rotationInterpolationSpeed = 50;
				self.baseRotation = self.baseRotation - (math.random(15, 20) * -1)
				
				self.blockSounds[self:GetStringValue("Blocked Type")]:Play(self.Pos);
				self:RemoveStringValue("Blocked Type");
				if self:NumberValueExists("Blocked Heavy") then
				
					if self.parent then
						self.parent:SetNumberValue("Blocked Heavy Mordhau", 1);
					end				
				
					self:RemoveNumberValue("Blocked Heavy");
					self.heavyBlockAddSound:Play(self.Pos);
					self.baseRotation = self.baseRotation - (math.random(25, 35) * -1)
				end
				
				if self.Parrying == true then
					self.parrySound:Play(self.Pos);
				end
				
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
			
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
			if moCheck and moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local rayHitPos = Vector(rayHitPos.X, rayHitPos.Y);
				local MO = MovableMan:GetMOFromID(moCheck)
				if (IsMOSRotating(MO) and canDamage) and not ((MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee"))
				or (MO:IsInGroup("Mordhau Counter Shields") and (ToMOSRotating(MO):StringValueExists("Parrying Type")
				and ToMOSRotating(MO):GetStringValue("Parrying Type") == self.attackAnimationsTypes[self.currentAttackAnimation]))) then
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
					
					local hitRange = SceneMan:ShortestDistance(rayOrigin, rayHitPos, SceneMan.SceneWrapsX);
					local minimumRange = damageRange* self.sweetSpotThreshold;
					
					local woundsToAdd;
					local speedMult = math.max(1, self.Vel.Magnitude / 18);
					
					if hitRange.Magnitude > minimumRange then
						woundsToAdd = math.floor((damage*speedMult) + RangeRand(0,0.9))
					else
						local mult = hitRange.Magnitude / minimumRange;
						damage = damage * math.max(0.25, mult);
						woundsToAdd = math.floor((damage*speedMult) + RangeRand(0,0.9))
					end
					
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
						
						if self.attackAnimationsTypes[self.currentAttackAnimation] == "Slash" and IsAttachable(MO) then
							-- two different ways to dismember: 1. if wounds would gib the limb hit, dismember it instead 2. low hp and crit
							if MO.WoundCount + woundsToAdd > MO.GibWoundLimit then
								ToAttachable(MO):RemoveFromParent(true, true);
								addWounds = false;
							elseif ToActor(actorHit).Health < 20 and crit then
								ToAttachable(MO):RemoveFromParent(true, true);
								addWounds = false;
							end
						end
						
						if addWounds == true and woundName then
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
					elseif woundName then -- generic wound adding for non-actors
						for i = 1, woundsToAdd do
							MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					end
				elseif (MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee")) or MO:IsInGroup("Mordhau Counter Shields") then
					hit = true;
					MO = ToHeldDevice(MO);
					if MO:NumberValueExists("Blocking") or (MO:StringValueExists("Parrying Type")
					and (MO:GetStringValue("Parrying Type") == self.attackAnimationsTypes[self.currentAttackAnimation] or MO:GetStringValue("Parrying Type") == "Flourish")) then
						self.attackCooldown = true;
						if MO:StringValueExists("Parrying Type") then
							self.attackBuffered = false;
							self.stabBuffered = false;
							self.overheadBuffered = false;
							self.parriedCooldown = true;
							self.parriedCooldownTimer:Reset();
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