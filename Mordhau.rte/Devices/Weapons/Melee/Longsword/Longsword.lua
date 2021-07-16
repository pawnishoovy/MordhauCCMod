
function stringInsert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end


function playAttackAnimation(self, animation)
	self.attackAnimationIsPlaying = true
	self.currentAttackSequence = 1
	self.currentAttackAnimation = animation
	self.attackAnimationTimer:Reset()
	self.attackAnimationCanHit = true
	self.blockedNullifier = true;
	self.Recovering = false;
	self.attackBuffered = false;
	self.stabBuffered = false;
	self.overheadBuffered = false;
	
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
	
	self.originalBaseRotation = -35;
	self.baseRotation = -35;
	
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
	self.breakSound = CreateSoundContainer("Sword Wound Sound Mordhau", "Mordhau.rte");
	
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
	
	self.blockedSound = CreateSoundContainer("Blocked Longsword Mordhau", "Mordhau.rte");
	self.heavyBlockAddSound = CreateSoundContainer("HeavyBlockAdd Longsword Mordhau", "Mordhau.rte");
	
	self.blockSounds = {};
	self.blockSounds.Slash = CreateSoundContainer("Slash Block Longsword Mordhau", "Mordhau.rte");
	self.blockSounds.Stab = CreateSoundContainer("Stab Block Longsword Mordhau", "Mordhau.rte");
	
	self.blockGFX = {};
	self.blockGFX.Slash = "Slash Block Effect Mordhau";
	self.blockGFX.Stab = "Stab Block Effect Mordhau";
	self.blockGFX.Heavy = "Heavy Block Effect Mordhau";
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--regularAttackSounds.hitDefaultSound
	--regularAttackSounds.hitDefaultSoundVariations
	
	regularAttackSounds.hitDeflectSound = CreateSoundContainer("Slash Metal Longsword Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitFleshSound = CreateSoundContainer("Slash Flesh Longsword Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitMetalSound = CreateSoundContainer("Slash Metal Longsword Mordhau", "Mordhau.rte");
	
	local stabAttackSounds = {}
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--stabAttackSounds.hitDefaultSound
	--stabAttackSounds.hitDefaultSoundVariations
	
	stabAttackSounds.hitDeflectSound = CreateSoundContainer("Stab Metal Longsword Mordhau", "Mordhau.rte");
	
	stabAttackSounds.hitFleshSound = CreateSoundContainer("Stab Flesh Longsword Mordhau", "Mordhau.rte");
	
	stabAttackSounds.hitMetalSound = CreateSoundContainer("Stab Metal Longsword Mordhau", "Mordhau.rte");
	
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
	attackPhase[i].attackDamage = 3.4
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
	
	attackPhase[i].soundStart = CreateSoundContainer("Slash Longsword Mordhau", "Mordhau.rte");
	
	attackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	attackPhase[i] = {}
	attackPhase[i].durationMS = 30
	
	attackPhase[i].canBeBlocked = true
	attackPhase[i].canDamage = false
	attackPhase[i].attackDamage = 3.4
	attackPhase[i].attackStunChance = 0.15
	attackPhase[i].attackRange = 20
	attackPhase[i].attackPush = 0.8
	attackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	attackPhase[i].attackAngle = 0;
	
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
	attackPhase[i].attackDamage = 3.4
	attackPhase[i].attackStunChance = 0.15
	attackPhase[i].attackRange = 15
	attackPhase[i].attackPush = 0.8
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
	attackPhase[i].durationMS = 100
	
	attackPhase[i].firstRecvoery = true
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
	attackPhase[i].angleStart = -90
	attackPhase[i].angleEnd = -40
	attackPhase[i].offsetStart = Vector(15, -4)
	attackPhase[i].offsetEnd = Vector(3, 0)
	
	attackPhase[i].soundStart = nil
	attackPhase[i].soundStartVariations = 0
	
	attackPhase[i].soundEnd = nil
	attackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
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
	
	attackPhase[i].frameStart = 7
	attackPhase[i].frameEnd = 6
	attackPhase[i].angleStart = -40
	attackPhase[i].angleEnd = -45
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
	self.attackAnimationsTypes[1] = attackPhase.Type
	
	-- (stab)
	stabAttackPhase = {}
	stabAttackPhase.Type = "Stab";
	
	-- Prepare
	i = 1
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
	stabAttackPhase[i].angleStart = -45
	stabAttackPhase[i].angleEnd = -60
	stabAttackPhase[i].offsetStart = Vector(0, 0)
	stabAttackPhase[i].offsetEnd = Vector(-2, -3)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 350
	
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
	stabAttackPhase[i].angleStart = -60
	stabAttackPhase[i].angleEnd = -70
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
	stabAttackPhase[i].attackDamage = 4
	stabAttackPhase[i].attackStunChance = 0.15
	stabAttackPhase[i].attackRange = 20
	stabAttackPhase[i].attackPush = 0.8
	stabAttackPhase[i].attackVector = Vector(-4, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 6
	stabAttackPhase[i].frameEnd = 6
	stabAttackPhase[i].angleStart = -70
	stabAttackPhase[i].angleEnd = -80
	stabAttackPhase[i].offsetStart = Vector(-3, -4)
	stabAttackPhase[i].offsetEnd = Vector(0, -5)
	
	stabAttackPhase[i].soundStart = CreateSoundContainer("Stab Longsword Mordhau", "Mordhau.rte");
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 30
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 4
	stabAttackPhase[i].attackStunChance = 0.15
	stabAttackPhase[i].attackRange = 20
	stabAttackPhase[i].attackPush = 0.8
	stabAttackPhase[i].attackVector = Vector(-4, -4) -- local space vector relative to position and rotation
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
	stabAttackPhase[i].attackDamage = 4
	stabAttackPhase[i].attackStunChance = 0.15
	stabAttackPhase[i].attackRange = 15
	stabAttackPhase[i].attackPush = 0.8
	stabAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
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
	
	stabAttackPhase[i].firstRecvoery = true
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
	stabAttackPhase[i].angleEnd = -45
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
	overheadAttackPhase[i].durationMS = 150
	
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
	overheadAttackPhase[i].offsetEnd = Vector(4,-13)
	
	-- Late Prepare
	i = 2
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 350
	
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
	overheadAttackPhase[i].attackDamage = 5
	overheadAttackPhase[i].attackStunChance = 0.3
	overheadAttackPhase[i].attackRange = 14
	overheadAttackPhase[i].attackPush = 0.8
	overheadAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = 55;
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = 27
	overheadAttackPhase[i].angleEnd = 20
	overheadAttackPhase[i].offsetStart = Vector(4, -13)
	overheadAttackPhase[i].offsetEnd = Vector(6, -10)
	
	overheadAttackPhase[i].soundStart = CreateSoundContainer("Slash Longsword Mordhau", "Mordhau.rte");
	
	overheadAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 4
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 120
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = true
	overheadAttackPhase[i].attackDamage = 5
	overheadAttackPhase[i].attackStunChance = 0.3
	overheadAttackPhase[i].attackRange = 14
	overheadAttackPhase[i].attackPush = 0.8
	overheadAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
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
	
	overheadAttackPhase[i].firstRecvoery = true	
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
	overheadAttackPhase[i].angleEnd = -50
	overheadAttackPhase[i].offsetStart = Vector(10, 15)
	overheadAttackPhase[i].offsetEnd = Vector(3, -5)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[3] = regularAttackSounds
	self.attackAnimationsGFX[3] = regularAttackGFX
	self.attackAnimations[3] = overheadAttackPhase
	self.attackAnimationsTypes[3] = overheadAttackPhase.Type
	
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
	local actor = MovableMan:IsActor(act) and ToActor(act) or nil;
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
		local stab = (player and UInputMan:KeyPressed(3)) or self.stabBuffered;
		local overhead = (player and UInputMan:KeyPressed(22)) or self.overheadBuffered;
		if stab or overhead or self.attackBuffered == true then
			controller:SetState(Controller.PRESS_PRIMARY, true)
			self:Activate();
		end
		local attack = controller:IsState(Controller.PRESS_PRIMARY);
		if self:IsActivated() and self.attackCooldown == true then
			self:Deactivate();
		else
			self.attackBuffered = false;
			self.attackCooldown = false;
		end
		local activated = self:IsActivated();
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
		
			self.Blocking = false;
			
			stanceTarget = Vector(0, 0);
			
			self.originalBaseRotation = -35;
			self.baseRotation = -35;
			
			if not stab and not overhead then
				playAttackAnimation(self, 1) -- regular attack
			elseif stab then
				playAttackAnimation(self, 2) -- stab
			elseif overhead then
				playAttackAnimation(self, 3) -- overhead
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
			elseif currentPhase.firstRecvoery == true then
				self.Recovering = true;
			end
			
			if self.Recovering == true and attack and not self.attackBuffered then
				self.attackBuffered = true;
				if stab then
					self.stabBuffered = true;
				elseif overhead then
					self.overheadBuffered = true;
				end
			end
			
			local factor = self.attackAnimationTimer.ElapsedSimTimeMS / currentPhase.durationMS
			
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
			if self.attackAnimationTimer:IsPastSimMS(workingDuration) then
				if (self.currentAttackSequence+1) <= #attackPhases then
					self.currentAttackSequence = self.currentAttackSequence + 1
				else
					if not self.attackBuffered == true then
						self.attackCooldown = true;
					end
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
					
					stanceTarget = Vector(4, -10);
					
					self.originalBaseRotation = -160;
					self.baseRotation = -145;
				
				elseif self.Blocking == true and UInputMan:KeyHeld(18) and not (self.attackAnimationIsPlaying) then
				
					self.originalBaseRotation = -160;
				
					stanceTarget = Vector(4, -10);
				
				elseif UInputMan:KeyReleased(18) then
				
					self.parent:SetNumberValue("Block Foley", 1);
				
					self.Blocking = false;
					
					self:RemoveNumberValue("Blocking");
					
					self.originalBaseRotation = -35;
					self.baseRotation = -45;
				
				else
					
					self.Blocking = false;
					
					self:RemoveNumberValue("Blocking");
					
					self.originalBaseRotation = -35;
					self.baseRotation = -45;
					
				end
			else
			
				self.Blocking = true;
				
				self:SetNumberValue("Blocking", 1);
				
				stanceTarget = Vector(4, -10);
				
				self.originalBaseRotation = -160;
				self.baseRotation = -160;
				
			end
				
			
			if self:IsAttached() then
				self.Frame = 6;
			else
				self.Frame = 1;
			end
		end
		
		if self.Blocking == true then
			
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
			
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, -3, 0, false, 2); -- Raycast
			if moCheck and moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local MO = MovableMan:GetMOFromID(moCheck)
				if (IsMOSRotating(MO) and canDamage) and not MO:IsInGroup("Weapons - Mordhau Melee") then
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
				elseif MO:IsInGroup("Weapons - Mordhau Melee") then
					hit = true;
					MO = ToHeldDevice(MO);
					if MO:NumberValueExists("Blocking") then
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