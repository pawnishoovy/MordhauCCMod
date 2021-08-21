
function OnScriptEnable(self)

	-- self.Magazine = CreateMagazine("Magazine Melee Null Mordhau", "Mordhau.rte");
	-- self.Magazine.RoundCount = -1;
	self:SetNextMagazineName("Magazine Melee Null Mordhau");
	
	self.stance = Vector(15, 3)
	
end

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

	if self.wasThrown == true then
	
		self.throwWounds = 2;
		self.throwPitch = 1.1;
	
		self.HUDVisible = false;
		
		self:EnableScript("Mordhau.rte/Devices/Shared/Scripts/TwirlBluntThrow.lua");
		self.thrownTeam = self.Team;

	end

	-- self.Frame = 6;
	-- self.unequipSound:Play(self.Pos);
	-- self.unequipAnim = true;
	-- self.equipAnimationTimer:Reset();
	-- self.equipAnim = false;
	
	
end

function Create(self)

	-- throwing stuff
	
	--self.bounceSound = CreateSoundContainer("Bounce Javelin", "Mordhau.rte");

	self.throwSound = CreateSoundContainer("Throw ThrowingAxe", "Mordhau.rte");
	self.throwSoundPlayed = false;
	
	self.spinSound = CreateSoundContainer("Spin ThrowingAxe", "Mordhau.rte");
	self.spinTimer = Timer();
	self.spinDelay = 99999; -- ghetto disable
	
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
			
	self.soundHitFlesh = CreateSoundContainer("Stab Flesh FlintlockPistol Mordhau", "Mordhau.rte");
	self.soundHitMetal = CreateSoundContainer("Stab Metal FlintlockPistol Mordhau", "Mordhau.rte");
	

	
	self.equipAnimationTimer = Timer();

	self.meleeOriginalStanceOffset = Vector(8, 3)
	
	self.originalBaseRotation = -115;
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
	
	self.parriedCooldown = false;
	self.parriedCooldownTimer = Timer();
	self.parriedCooldownDelay = 1200;
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--regularAttackSounds.hitDefaultSound
	--regularAttackSounds.hitDefaultSoundVariations
	
	regularAttackSounds.hitDeflectSound = CreateSoundContainer("Stab Metal FlintlockPistol Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitFleshSound = CreateSoundContainer("Stab Flesh FlintlockPistol Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitMetalSound = CreateSoundContainer("Stab Metal FlintlockPistol Mordhau", "Mordhau.rte");
	
	local stabAttackSounds = {}
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--stabAttackSounds.hitDefaultSound
	--stabAttackSounds.hitDefaultSoundVariations
	
	stabAttackSounds.hitDeflectSound = CreateSoundContainer("Stab Metal FlintlockPistol Mordhau", "Mordhau.rte");
	
	stabAttackSounds.hitFleshSound = CreateSoundContainer("Stab Flesh FlintlockPistol Mordhau", "Mordhau.rte");
	
	stabAttackSounds.hitMetalSound = CreateSoundContainer("Stab Metal FlintlockPistol Mordhau", "Mordhau.rte");
	
	local regularAttackGFX = {}
	
	regularAttackGFX.hitTerrainSoftGFX = "Melee Terrain Soft Effect Mordhau"
	regularAttackGFX.hitTerrainHardGFX = "Melee Terrain Hard Effect Mordhau"
	regularAttackGFX.hitFleshGFX = "Melee Flesh Effect Mordhau"
	regularAttackGFX.hitMetalGFX = "Melee Terrain Hard Effect Mordhau"
	regularAttackGFX.hitDeflectGFX = "Melee Terrain Hard Effect Mordhau"
	
	-- (stab)
	shoveAttackPhase = {}
	shoveAttackPhase.Type = "Stab";
	
	-- Prepare
	i = 1
	shoveAttackPhase[i] = {}
	shoveAttackPhase[i].durationMS = 150
	
	shoveAttackPhase[i].canBeBlocked = false
	shoveAttackPhase[i].canDamage = false
	shoveAttackPhase[i].attackDamage = 0
	shoveAttackPhase[i].attackStunChance = 0
	shoveAttackPhase[i].attackRange = 0
	shoveAttackPhase[i].attackPush = 0
	shoveAttackPhase[i].attackVector = Vector(4, 0) -- local space vector relative to position and rotationself.stance
	shoveAttackPhase[i].attackAngle = 90;
	
	shoveAttackPhase[i].frameStart = 1
	shoveAttackPhase[i].frameEnd = 1
	shoveAttackPhase[i].angleStart = -115
	shoveAttackPhase[i].angleEnd = -90
	shoveAttackPhase[i].offsetStart = Vector(0, 0)
	shoveAttackPhase[i].offsetEnd = Vector(-2, 0)
	
	shoveAttackPhase[i].soundStart = nil
	shoveAttackPhase[i].soundStartVariations = 0
	
	shoveAttackPhase[i].soundEnd = nil
	shoveAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	shoveAttackPhase[i] = {}
	shoveAttackPhase[i].durationMS = 100
	
	shoveAttackPhase[i].lastPrepare = true
	shoveAttackPhase[i].canBeBlocked = false
	shoveAttackPhase[i].canDamage = false
	shoveAttackPhase[i].attackDamage = 0
	shoveAttackPhase[i].attackStunChance = 0
	shoveAttackPhase[i].attackRange = 0
	shoveAttackPhase[i].attackPush = 0
	shoveAttackPhase[i].attackVector = Vector(4, 0) -- local space vector relative to position and rotation
	shoveAttackPhase[i].attackAngle = 90;
	
	shoveAttackPhase[i].frameStart = 1
	shoveAttackPhase[i].frameEnd = 1
	shoveAttackPhase[i].angleStart = -90
	shoveAttackPhase[i].angleEnd = -90
	shoveAttackPhase[i].offsetStart = Vector(-2, 0)
	shoveAttackPhase[i].offsetEnd = Vector(-2, 0)
	
	shoveAttackPhase[i].soundStart = nil
	shoveAttackPhase[i].soundStartVariations = 0
	
	shoveAttackPhase[i].soundEnd = nil
	shoveAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	shoveAttackPhase[i] = {}
	shoveAttackPhase[i].durationMS = 70
	
	shoveAttackPhase[i].canBeBlocked = true
	shoveAttackPhase[i].canDamage = false
	shoveAttackPhase[i].attackDamage = 1
	shoveAttackPhase[i].attackStunChance = 0.2
	shoveAttackPhase[i].attackRange = 13
	shoveAttackPhase[i].attackPush = 0.7
	shoveAttackPhase[i].attackVector = Vector(4, 0) -- local space vector relative to position and rotation
	shoveAttackPhase[i].attackAngle = 90;
	
	shoveAttackPhase[i].frameStart = 1
	shoveAttackPhase[i].frameEnd = 1
	shoveAttackPhase[i].angleStart = -90
	shoveAttackPhase[i].angleEnd = -90
	shoveAttackPhase[i].offsetStart = Vector(-2, 0)
	shoveAttackPhase[i].offsetEnd = Vector(0, 0)
	
	shoveAttackPhase[i].soundStart = CreateSoundContainer("Stab FlintlockPistol Mordhau", "Mordhau.rte");
	
	shoveAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	shoveAttackPhase[i] = {}
	shoveAttackPhase[i].durationMS = 35
	
	shoveAttackPhase[i].canBeBlocked = true
	shoveAttackPhase[i].canDamage = false
	shoveAttackPhase[i].attackDamage = 1
	shoveAttackPhase[i].attackStunChance = 0.15
	shoveAttackPhase[i].attackRange = 10
	shoveAttackPhase[i].attackPush = 0.7
	shoveAttackPhase[i].attackVector = Vector(5, -1) -- local space vector relative to position and rotation
	shoveAttackPhase[i].attackAngle = 90;
	
	shoveAttackPhase[i].frameStart = 1
	shoveAttackPhase[i].frameEnd = 1
	shoveAttackPhase[i].angleStart = -90
	shoveAttackPhase[i].angleEnd = -90
	shoveAttackPhase[i].offsetStart = Vector(0, 0)
	shoveAttackPhase[i].offsetEnd = Vector(4, -1)
	
	shoveAttackPhase[i].soundStart = nil
	
	shoveAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	shoveAttackPhase[i] = {}
	shoveAttackPhase[i].durationMS = 70
	
	shoveAttackPhase[i].canBeBlocked = true
	shoveAttackPhase[i].canDamage = true
	shoveAttackPhase[i].attackDamage = 1
	shoveAttackPhase[i].attackStunChance = 0.15
	shoveAttackPhase[i].attackRange = 10
	shoveAttackPhase[i].attackPush = 0.7
	shoveAttackPhase[i].attackVector = Vector(5, -1) -- local space vector relative to position and rotation
	shoveAttackPhase[i].attackAngle = 90;
	
	shoveAttackPhase[i].frameStart = 1
	shoveAttackPhase[i].frameEnd = 1
	shoveAttackPhase[i].angleStart = -90
	shoveAttackPhase[i].angleEnd = -75
	shoveAttackPhase[i].offsetStart = Vector(4 , -1)
	shoveAttackPhase[i].offsetEnd = Vector(15, -2)
	
	shoveAttackPhase[i].soundStart = nil
	
	shoveAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	shoveAttackPhase[i] = {}
	shoveAttackPhase[i].durationMS = 70
	
	shoveAttackPhase[i].firstRecovery = true
	shoveAttackPhase[i].canBeBlocked = false
	shoveAttackPhase[i].canDamage = false
	shoveAttackPhase[i].attackDamage = 0
	shoveAttackPhase[i].attackStunChance = 0
	shoveAttackPhase[i].attackRange = 0
	shoveAttackPhase[i].attackPush = 0
	shoveAttackPhase[i].attackVector = Vector(4, 0) -- local space vector relative to position and rotation
	shoveAttackPhase[i].attackAngle = 90;
	
	shoveAttackPhase[i].frameStart = 1
	shoveAttackPhase[i].frameEnd = 1
	shoveAttackPhase[i].angleStart = -75
	shoveAttackPhase[i].angleEnd = -90
	shoveAttackPhase[i].offsetStart = Vector(15, -2)
	shoveAttackPhase[i].offsetEnd = Vector(7, -3)
	
	shoveAttackPhase[i].soundStart = nil
	shoveAttackPhase[i].soundStartVariations = 0
	
	shoveAttackPhase[i].soundEnd = nil
	shoveAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
	shoveAttackPhase[i] = {}
	shoveAttackPhase[i].durationMS = 100
	
	shoveAttackPhase[i].canBeBlocked = false
	shoveAttackPhase[i].canDamage = false
	shoveAttackPhase[i].attackDamage = 0
	shoveAttackPhase[i].attackStunChance = 0
	shoveAttackPhase[i].attackRange = 0
	shoveAttackPhase[i].attackPush = 0
	shoveAttackPhase[i].attackVector = Vector(4, 0) -- local space vector relative to position and rotation
	shoveAttackPhase[i].attackAngle = 90;
	
	shoveAttackPhase[i].frameStart = 1
	shoveAttackPhase[i].frameEnd = 1
	shoveAttackPhase[i].angleStart = -90
	shoveAttackPhase[i].angleEnd = -115
	shoveAttackPhase[i].offsetStart = Vector(7, -3)
	shoveAttackPhase[i].offsetEnd = Vector(3, 0)
	
	shoveAttackPhase[i].soundStart = nil
	shoveAttackPhase[i].soundStartVariations = 0
	
	shoveAttackPhase[i].soundEnd = nil
	shoveAttackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[1] = stabAttackSounds
	self.attackAnimationsGFX[1] = regularAttackGFX
	self.attackAnimations[1] = shoveAttackPhase
	self.attackAnimationsTypes[1] = shoveAttackPhase.Type	
	
	-- (stab)
	stabAttackPhase = {}
	stabAttackPhase.Type = "Stab";
	
	-- Prepare
	i = 1
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
	
	stabAttackPhase[i].frameStart = 1
	stabAttackPhase[i].frameEnd = 1
	stabAttackPhase[i].angleStart = -115
	stabAttackPhase[i].angleEnd = -150
	stabAttackPhase[i].offsetStart = Vector(0, 0)
	stabAttackPhase[i].offsetEnd = Vector(-2, -3)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 170
	
	stabAttackPhase[i].lastPrepare = true
	stabAttackPhase[i].canBeBlocked = false
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 0
	stabAttackPhase[i].attackStunChance = 0
	stabAttackPhase[i].attackRange = 0
	stabAttackPhase[i].attackPush = 0
	stabAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 1
	stabAttackPhase[i].frameEnd = 1
	stabAttackPhase[i].angleStart = -150
	stabAttackPhase[i].angleEnd = -185
	stabAttackPhase[i].offsetStart = Vector(-2, -3)
	stabAttackPhase[i].offsetEnd = Vector(-3, -4)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 90
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 1
	stabAttackPhase[i].attackStunChance = 0.10
	stabAttackPhase[i].attackRange = 12
	stabAttackPhase[i].attackPush = 0.2
	stabAttackPhase[i].attackVector = Vector(5, -1) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = -180;
	
	stabAttackPhase[i].frameStart = 1
	stabAttackPhase[i].frameEnd = 1
	stabAttackPhase[i].angleStart = -185
	stabAttackPhase[i].angleEnd = -185
	stabAttackPhase[i].offsetStart = Vector(-3, -4)
	stabAttackPhase[i].offsetEnd = Vector(0, -5)
	
	stabAttackPhase[i].soundStart = CreateSoundContainer("Stab FlintlockPistol Mordhau", "Mordhau.rte");
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 30
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 1
	stabAttackPhase[i].attackStunChance = 0.10
	stabAttackPhase[i].attackRange = 12
	stabAttackPhase[i].attackPush = 0.2
	stabAttackPhase[i].attackVector = Vector(5, -1) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = -180;
	
	stabAttackPhase[i].frameStart = 1
	stabAttackPhase[i].frameEnd = 1
	stabAttackPhase[i].angleStart = -185
	stabAttackPhase[i].angleEnd = -185
	stabAttackPhase[i].offsetStart = Vector(0, -5)
	stabAttackPhase[i].offsetEnd = Vector(4, -6)
	
	stabAttackPhase[i].soundStart = nil
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 80
	
	stabAttackPhase[i].canBeBlocked = true
	stabAttackPhase[i].canDamage = true
	stabAttackPhase[i].attackDamage = 1
	stabAttackPhase[i].attackStunChance = 0.10
	stabAttackPhase[i].attackRange = 12
	stabAttackPhase[i].attackPush = 0.2
	stabAttackPhase[i].attackVector = Vector(5, -1) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = -180;
	
	stabAttackPhase[i].frameStart = 1
	stabAttackPhase[i].frameEnd = 1
	stabAttackPhase[i].angleStart = -185
	stabAttackPhase[i].angleEnd = -185
	stabAttackPhase[i].offsetStart = Vector(4 , -6)
	stabAttackPhase[i].offsetEnd = Vector(15, -6)
	
	stabAttackPhase[i].soundStart = nil
	
	stabAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 90
	
	stabAttackPhase[i].firstRecovery = true
	stabAttackPhase[i].canBeBlocked = false
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 0
	stabAttackPhase[i].attackStunChance = 0
	stabAttackPhase[i].attackRange = 0
	stabAttackPhase[i].attackPush = 0
	stabAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 1
	stabAttackPhase[i].frameEnd = 1
	stabAttackPhase[i].angleStart = -185
	stabAttackPhase[i].angleEnd = -185
	stabAttackPhase[i].offsetStart = Vector(15, -6)
	stabAttackPhase[i].offsetEnd = Vector(7, -3)
	
	stabAttackPhase[i].soundStart = nil
	stabAttackPhase[i].soundStartVariations = 0
	
	stabAttackPhase[i].soundEnd = nil
	stabAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
	stabAttackPhase[i] = {}
	stabAttackPhase[i].durationMS = 90
	
	stabAttackPhase[i].canBeBlocked = false
	stabAttackPhase[i].canDamage = false
	stabAttackPhase[i].attackDamage = 0
	stabAttackPhase[i].attackStunChance = 0
	stabAttackPhase[i].attackRange = 0
	stabAttackPhase[i].attackPush = 0
	stabAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	stabAttackPhase[i].attackAngle = 90;
	
	stabAttackPhase[i].frameStart = 1
	stabAttackPhase[i].frameEnd = 1
	stabAttackPhase[i].angleStart = -185
	stabAttackPhase[i].angleEnd = -115
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
	overheadAttackPhase[i].durationMS = 200
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -115
	overheadAttackPhase[i].angleEnd = -45
	overheadAttackPhase[i].offsetStart = Vector(0, 0)
	overheadAttackPhase[i].offsetEnd = Vector(4,-15)
	
	-- Late Prepare
	i = 2
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 120
	
	overheadAttackPhase[i].lastPrepare = true
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -45
	overheadAttackPhase[i].angleEnd = -43
	overheadAttackPhase[i].offsetStart = Vector(4, -15)
	overheadAttackPhase[i].offsetEnd = Vector(0, -15)
	
	overheadAttackPhase[i].soundStart = nil
	overheadAttackPhase[i].soundStartVariations = 0
	
	overheadAttackPhase[i].soundEnd = nil
	overheadAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 3
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 60
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 2
	overheadAttackPhase[i].attackStunChance = 0.3
	overheadAttackPhase[i].attackRange = 10
	overheadAttackPhase[i].attackPush = 0.5
	overheadAttackPhase[i].attackVector = Vector(5, -1) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = -235;
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -43
	overheadAttackPhase[i].angleEnd = -80
	overheadAttackPhase[i].offsetStart = Vector(0, -15)
	overheadAttackPhase[i].offsetEnd = Vector(6, -10)
	
	overheadAttackPhase[i].soundStart = CreateSoundContainer("Stab FlintlockPistol Mordhau", "Mordhau.rte");
	
	overheadAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 4
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 130
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = true
	overheadAttackPhase[i].attackDamage = 2
	overheadAttackPhase[i].attackStunChance = 0.3
	overheadAttackPhase[i].attackRange = 10
	overheadAttackPhase[i].attackPush = 0.5
	overheadAttackPhase[i].attackVector = Vector(5, -1) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = -205;
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -80
	overheadAttackPhase[i].angleEnd = -200
	overheadAttackPhase[i].offsetStart = Vector(6, -10)
	overheadAttackPhase[i].offsetEnd = Vector(15, 15)
	
	-- Early Recover
	i = 5
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 90
	
	overheadAttackPhase[i].firstRecovery = true	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -200
	overheadAttackPhase[i].angleEnd = -230
	overheadAttackPhase[i].offsetStart = Vector(15, 15)
	overheadAttackPhase[i].offsetEnd = Vector(10, 15)
	
	-- Recover
	i = 6
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 170
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -230
	overheadAttackPhase[i].angleEnd = -115
	overheadAttackPhase[i].offsetStart = Vector(10, 15)
	overheadAttackPhase[i].offsetEnd = Vector(3, -5)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[3] = regularAttackSounds
	self.attackAnimationsGFX[3] = regularAttackGFX
	self.attackAnimations[3] = overheadAttackPhase
	self.attackAnimationsTypes[3] = overheadAttackPhase.Type
	
	-- Throw
	throwPhase = {}
	throwPhase.Type = "Slash";
	
	-- Windup
	i = 1
	throwPhase[i] = {}
	throwPhase[i].durationMS = 200
	
	throwPhase[i].canBeBlocked = false
	throwPhase[i].canDamage = false
	throwPhase[i].attackDamage = 0
	throwPhase[i].attackStunChance = 0
	throwPhase[i].attackRange = 0
	throwPhase[i].attackPush = 0
	throwPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	throwPhase[i].attackAngle = 90;
	
	throwPhase[i].frameStart = 1
	throwPhase[i].frameEnd = 1
	throwPhase[i].angleStart = -115
	throwPhase[i].angleEnd = 20
	throwPhase[i].offsetStart = Vector(0, 0)
	throwPhase[i].offsetEnd = Vector(-15, -15)

	
	-- Pause
	i = 2
	throwPhase[i] = {}
	throwPhase[i].durationMS = 200
	
	throwPhase[i].lastPrepare = true
	throwPhase[i].canBeBlocked = false
	throwPhase[i].canDamage = false
	throwPhase[i].attackDamage = 0
	throwPhase[i].attackStunChance = 0
	throwPhase[i].attackRange = 0
	throwPhase[i].attackPush = 0
	throwPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	throwPhase[i].attackAngle = 90;
	
	throwPhase[i].frameStart = 1
	throwPhase[i].frameEnd = 1
	throwPhase[i].angleStart = 20
	throwPhase[i].angleEnd = 20
	throwPhase[i].offsetStart = Vector(-15, -15)
	throwPhase[i].offsetEnd = Vector(-15, -15)
	
	
	-- Throw
	i = 3
	throwPhase[i] = {}
	throwPhase[i].durationMS = 140
	
	throwPhase[i].canBeBlocked = false
	throwPhase[i].canDamage = false
	throwPhase[i].attackDamage = 2
	throwPhase[i].attackStunChance = 0
	throwPhase[i].attackRange = 15
	throwPhase[i].attackPush = 0.8
	throwPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	throwPhase[i].attackAngle = 90;
	
	throwPhase[i].frameStart = 1
	throwPhase[i].frameEnd = 1
	throwPhase[i].angleStart = 20
	throwPhase[i].angleEnd = -150
	throwPhase[i].offsetStart = Vector(-15, -15)
	throwPhase[i].offsetEnd = Vector(6, -15)
	
	throwPhase[i].soundStart = nil
	throwPhase[i].soundStartVariations = 0
	
	throwPhase[i].soundEnd = nil
	throwPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[7] = regularAttackSounds
	self.attackAnimationsGFX[7] = regularAttackGFX
	self.attackAnimations[7] = throwPhase
	self.attackAnimationsTypes[7] = throwPhase.Type
	
	self.rotation = 0
	self.rotationInterpolation = 1 -- 0 instant, 1 smooth, 2 wiggly smooth
	self.rotationInterpolationSpeed = 25
	
	self.stance = Vector(0, 0)
	self.stanceInterpolation = 0 -- 0 instant, 1 smooth
	self.stanceInterpolationSpeed = 25
	
	self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/FlintlockPistol/MeleeMode.lua");	
	
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

		local rotationTarget = -45 / 180 * math.pi
		local stanceTarget = Vector(-4, 0);
	
		self.stance = self.stance + stanceTarget
		
		rotationTarget = rotationTarget * self.FlipFactor
		self.rotation = self.rotation + rotationTarget
		
		self.StanceOffset = self.meleeOriginalStanceOffset + self.stance
		self.RotAngle = self.RotAngle + self.rotation
	
	elseif controller then --          :-)
	
		if self:NumberValueExists("Switch Mode") then
		
			self:RemoveNumberValue("Weapons - Mordhau Melee");
		
			self.ReloadTime = 50;
			self:Reload();
		
			self.delayedFireDisabled = false;
		
			self.StanceOffset = Vector(3, 5);
			self.SharpStanceOffset = Vector(6, 0);
			self.SharpLength = 130;
			self.JointOffset = Vector(-5, 1);
			self.SupportOffset = Vector(-5, 1);
		
			self:RemoveNumberValue("Switch Mode");
			self.meleeMode = false;
			self.rotation = 0
			self.rotationTarget = 0;
			
			self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/FlintlockPistol/MeleeMode.lua");
			self:EnableScript("Mordhau.rte/Devices/Weapons/Handheld/FlintlockPistol/Chamber.lua");
			
			self.Flash = CreateAttachable("Muzzle Flash Shotgun", "Base.rte");
			self.FireSound = CreateSoundContainer("Fire FlintlockPistol", "Mordhau.rte");
			
			return
			
		end
	
		-- INPUT
		local throw
		local stab
		local overhead
		local attack
		local activated
		if self.parriedCooldown == false then
			if player then
				throw = (player and UInputMan:KeyPressed(10));
				stab = (player and UInputMan:KeyPressed(2)) or self.stabBuffered;
				overhead = (player and UInputMan:KeyPressed(22)) or self.overheadBuffered;
				if stab or overhead or flourish or throw or warcry then
					controller:SetState(Controller.PRESS_PRIMARY, true)
					self:Activate();
				end
				attack = controller:IsState(Controller.PRESS_PRIMARY);
				if self:IsActivated() and self.attackCooldown == true then
					self:Deactivate();
				else
					self.attackCooldown = false;
				end
			else
				-- stab = (math.random(0, 100) < 50) and true;
				-- overhead = true;
				-- if stab or overhead or flourish or throw or warcry then
					-- controller:SetState(Controller.PRESS_PRIMARY, true)
					-- self:Activate();
				-- end
			end
			if stab or overhead or warcry or flourish or throw then
				controller:SetState(Controller.PRESS_PRIMARY, true)
				self:Activate();
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
			
			if not stab and not overhead and not flourish and not throw and not warcry then
				playAttackAnimation(self, 1) -- regular attack
			elseif stab then
				playAttackAnimation(self, 2) -- stab
			elseif overhead then
				playAttackAnimation(self, 3) -- overhead
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
					self.parent:SetNumberValue("Medium Attack", 1);
				else
					self.wasCharged = false;
					self.parent:SetNumberValue("Light Attack", 1);	
				end
			elseif currentPhase.firstRecovery == true then
				self.Recovering = true;
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
			self.rotation = (self.rotation + rotationTarget * TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed);
		end
		local pushVector = Vector(10 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		
		self.StanceOffset = self.meleeOriginalStanceOffset + self.stance
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
			
			PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
			--PrimitiveMan:DrawCirclePrimitive(self.Pos, 3, 5);
			
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
			if moCheck and moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
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