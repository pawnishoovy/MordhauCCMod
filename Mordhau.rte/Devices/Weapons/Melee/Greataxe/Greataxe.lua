
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
	self.attackBuffered = false;
	self.stabBuffered = false;
	self.overheadBuffered = false;
	
	if self.Parrying == true then
		self:SetStringValue("Parrying Type", self.attackAnimationsTypes[self.currentAttackAnimation]);
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

	if self.wasThrown == true then
	
		self.throwWounds = 20;
		self.throwPitch = 0.7;
	
		self.HUDVisible = false;
		
		self:EnableScript("Mordhau.rte/Devices/Shared/Scripts/TwirlPierceThrow.lua");
		self.thrownTeam = self.Team;
		
		self.stickMO = nil;
		self.stickVecX = 0;
		self.stickVecY = 0;
		self.stickRot = 0;
		self.stickDeepness = RangeRand(0.1, 1);

		self.stuck = false;
		
		self.phase = 0;
	end

	-- self.Frame = 6;
	-- self.unequipSound:Play(self.Pos);
	-- self.unequipAnim = true;
	-- self.equipAnimationTimer:Reset();
	-- self.equipAnim = false;
	
	
end

function Create(self)

	-- throwing stuff
	
	self.bounceSound = CreateSoundContainer("Hafted Thrown Bounce Mordhau", "Mordhau.rte");
	
	self.throwSound = CreateSoundContainer("Throw ThrowingAxe", "Mordhau.rte");
	self.throwSoundPlayed = false;
	
	self.spinSound = CreateSoundContainer("Spin ThrowingAxe", "Mordhau.rte");
	self.spinTimer = Timer();
	self.spinDelay = 145;
	
	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("Impact Concrete Greataxe Mordhau", "Mordhau.rte"),
			[164] = CreateSoundContainer("Impact Concrete Greataxe Mordhau", "Mordhau.rte"),
			[177] = CreateSoundContainer("Impact Concrete Greataxe Mordhau", "Mordhau.rte"),
			[9] = CreateSoundContainer("Impact Dirt Greataxe Mordhau", "Mordhau.rte"),
			[10] = CreateSoundContainer("Impact Dirt Greataxe Mordhau", "Mordhau.rte"),
			[11] = CreateSoundContainer("Impact Dirt Greataxe Mordhau", "Mordhau.rte"),
			[128] = CreateSoundContainer("Impact Dirt Greataxe Mordhau", "Mordhau.rte"),
			[6] = CreateSoundContainer("Impact Sand Greataxe Mordhau", "Mordhau.rte"),
			[8] = CreateSoundContainer("Impact Sand Greataxe Mordhau", "Mordhau.rte"),
			[178] = CreateSoundContainer("Impact SolidMetal Greataxe Mordhau", "Mordhau.rte"),
			[179] = CreateSoundContainer("Impact SolidMetal Greataxe Mordhau", "Mordhau.rte"),
			[180] = CreateSoundContainer("Impact SolidMetal Greataxe Mordhau", "Mordhau.rte"),
			[181] = CreateSoundContainer("Impact SolidMetal Greataxe Mordhau", "Mordhau.rte"),
			[182] = CreateSoundContainer("Impact SolidMetal Greataxe Mordhau", "Mordhau.rte")}}
			
	self.soundHitFlesh = CreateSoundContainer("Impact Flesh Greataxe Mordhau", "Mordhau.rte");
	self.soundHitMetal = CreateSoundContainer("Slash Metal Warhammer Mordhau", "Mordhau.rte");
	
	
	
	self.equipAnimationTimer = Timer();

	self.originalStanceOffset = Vector(self.StanceOffset.X * self.FlipFactor, self.StanceOffset.Y)
	
	self.originalBaseRotation = 25;
	self.baseRotation = 15;
	
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
	
	self.blockedSound = CreateSoundContainer("Blocked Greataxe Mordhau", "Mordhau.rte");
	self.parrySound = CreateSoundContainer("Parry Greataxe Mordhau", "Mordhau.rte");
	self.heavyBlockAddSound = CreateSoundContainer("HeavyBlockAdd Warhammer Mordhau", "Mordhau.rte");
	
	self.blockSounds = {};
	self.blockSounds.Slash = CreateSoundContainer("Slash Block Greataxe Mordhau", "Mordhau.rte");
	self.blockSounds.Stab = CreateSoundContainer("Stab Block Greataxe Mordhau", "Mordhau.rte");
	
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
	
	regularAttackSounds.hitDeflectSound = CreateSoundContainer("Slash Metal Greataxe Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitFleshSound = CreateSoundContainer("Slash Flesh Greataxe Mordhau", "Mordhau.rte");
	
	regularAttackSounds.hitMetalSound = CreateSoundContainer("Slash Metal Greataxe Mordhau", "Mordhau.rte");
	
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
	
	-- Double Slash
	doubleSlashAttackPhase = {}
	doubleSlashAttackPhase.Type = "Slash";
	
	-- Prepare
	i = 1
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 300
	
	doubleSlashAttackPhase[i].canBeBlocked = false
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 0
	doubleSlashAttackPhase[i].attackStunChance = 0
	doubleSlashAttackPhase[i].attackRange = 0
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 6
	doubleSlashAttackPhase[i].frameEnd = 6
	doubleSlashAttackPhase[i].angleStart = 0
	doubleSlashAttackPhase[i].angleEnd = 45
	doubleSlashAttackPhase[i].offsetStart = Vector(0, 0)
	doubleSlashAttackPhase[i].offsetEnd = Vector(-6, -5)
	
	doubleSlashAttackPhase[i].soundStart = nil
	doubleSlashAttackPhase[i].soundStartVariations = 0
	
	doubleSlashAttackPhase[i].soundEnd = nil
	doubleSlashAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 300
	
	doubleSlashAttackPhase[i].lastPrepare = true
	doubleSlashAttackPhase[i].canBeBlocked = false
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 0
	doubleSlashAttackPhase[i].attackStunChance = 0
	doubleSlashAttackPhase[i].attackRange = 0
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 0;
	
	doubleSlashAttackPhase[i].frameStart = 6
	doubleSlashAttackPhase[i].frameEnd = 6
	doubleSlashAttackPhase[i].angleStart = 45
	doubleSlashAttackPhase[i].angleEnd = 45
	doubleSlashAttackPhase[i].offsetStart = Vector(-6, -5)
	doubleSlashAttackPhase[i].offsetEnd = Vector(-6, -5)
	
	doubleSlashAttackPhase[i].soundStart = nil
	doubleSlashAttackPhase[i].soundStartVariations = 0
	
	doubleSlashAttackPhase[i].soundEnd = nil
	doubleSlashAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 160
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 3.4
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 20
	doubleSlashAttackPhase[i].attackPush = 0.8
	doubleSlashAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 0;
	
	doubleSlashAttackPhase[i].frameStart = 7
	doubleSlashAttackPhase[i].frameEnd = 11
	doubleSlashAttackPhase[i].angleStart = 30
	doubleSlashAttackPhase[i].angleEnd = -50
	doubleSlashAttackPhase[i].offsetStart = Vector(-6, -5)
	doubleSlashAttackPhase[i].offsetEnd = Vector(7, -2)
	
	doubleSlashAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	doubleSlashAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 50
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 3.4
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 20
	doubleSlashAttackPhase[i].attackPush = 0.8
	doubleSlashAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 0;
	
	doubleSlashAttackPhase[i].frameStart = 11
	doubleSlashAttackPhase[i].frameEnd = 11
	doubleSlashAttackPhase[i].angleStart = -50
	doubleSlashAttackPhase[i].angleEnd = -90
	doubleSlashAttackPhase[i].offsetStart = Vector(7, -2)
	doubleSlashAttackPhase[i].offsetEnd = Vector(7, -2)
	
	doubleSlashAttackPhase[i].soundStart = nil
	
	doubleSlashAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 160
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = true
	doubleSlashAttackPhase[i].attackDamage = 7
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 15
	doubleSlashAttackPhase[i].attackPush = 0.85
	doubleSlashAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 11
	doubleSlashAttackPhase[i].frameEnd = 6
	doubleSlashAttackPhase[i].angleStart = -90
	doubleSlashAttackPhase[i].angleEnd = -100
	doubleSlashAttackPhase[i].offsetStart = Vector(7 , -2)
	doubleSlashAttackPhase[i].offsetEnd = Vector(15, -4)
	
	doubleSlashAttackPhase[i].soundStart = nil
	
	doubleSlashAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 100
	
	doubleSlashAttackPhase[i].firstRecvoery = true
	doubleSlashAttackPhase[i].canBeBlocked = false
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 0
	doubleSlashAttackPhase[i].attackStunChance = 0
	doubleSlashAttackPhase[i].attackRange = 0
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 6
	doubleSlashAttackPhase[i].frameEnd = 6
	doubleSlashAttackPhase[i].angleStart = -100
	doubleSlashAttackPhase[i].angleEnd = -40
	doubleSlashAttackPhase[i].offsetStart = Vector(15, -4)
	doubleSlashAttackPhase[i].offsetEnd = Vector(8, -4)
	
	doubleSlashAttackPhase[i].soundStart = nil
	doubleSlashAttackPhase[i].soundStartVariations = 0
	
	doubleSlashAttackPhase[i].soundEnd = nil
	doubleSlashAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 100
	
	doubleSlashAttackPhase[i].canBeBlocked = false
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 0
	doubleSlashAttackPhase[i].attackStunChance = 0
	doubleSlashAttackPhase[i].attackRange = 0
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 7
	doubleSlashAttackPhase[i].frameEnd = 10
	doubleSlashAttackPhase[i].angleStart = -40
	doubleSlashAttackPhase[i].angleEnd = 0
	doubleSlashAttackPhase[i].offsetStart = Vector(8, -4)
	doubleSlashAttackPhase[i].offsetEnd = Vector(-2, -4)
	
	doubleSlashAttackPhase[i].soundStart = nil
	doubleSlashAttackPhase[i].soundStartVariations = 0
	
	doubleSlashAttackPhase[i].soundEnd = nil
	doubleSlashAttackPhase[i].soundEndVariations = 0
	
	-- Prepare
	i = 8
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 150
	
	doubleSlashAttackPhase[i].attackReset = true
	doubleSlashAttackPhase[i].canBeBlocked = false
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 0
	doubleSlashAttackPhase[i].attackStunChance = 0
	doubleSlashAttackPhase[i].attackRange = 0
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 9
	doubleSlashAttackPhase[i].frameEnd = 6
	doubleSlashAttackPhase[i].angleStart = 0
	doubleSlashAttackPhase[i].angleEnd = 45
	doubleSlashAttackPhase[i].offsetStart = Vector(0, 0)
	doubleSlashAttackPhase[i].offsetEnd = Vector(-6, -5)
	
	doubleSlashAttackPhase[i].soundStart = nil
	doubleSlashAttackPhase[i].soundStartVariations = 0
	
	doubleSlashAttackPhase[i].soundEnd = nil
	doubleSlashAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 9
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 100
	
	doubleSlashAttackPhase[i].lastPrepare = true
	doubleSlashAttackPhase[i].canBeBlocked = false
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 0
	doubleSlashAttackPhase[i].attackStunChance = 0
	doubleSlashAttackPhase[i].attackRange = 0
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 0;
	
	doubleSlashAttackPhase[i].frameStart = 6
	doubleSlashAttackPhase[i].frameEnd = 6
	doubleSlashAttackPhase[i].angleStart = 45
	doubleSlashAttackPhase[i].angleEnd = 45
	doubleSlashAttackPhase[i].offsetStart = Vector(-6, -5)
	doubleSlashAttackPhase[i].offsetEnd = Vector(-6, -5)
	
	doubleSlashAttackPhase[i].soundStart = nil
	doubleSlashAttackPhase[i].soundStartVariations = 0
	
	doubleSlashAttackPhase[i].soundEnd = nil
	doubleSlashAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 10
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 160
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 3.4
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 20
	doubleSlashAttackPhase[i].attackPush = 0.8
	doubleSlashAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 0;
	
	doubleSlashAttackPhase[i].frameStart = 7
	doubleSlashAttackPhase[i].frameEnd = 11
	doubleSlashAttackPhase[i].angleStart = 30
	doubleSlashAttackPhase[i].angleEnd = -50
	doubleSlashAttackPhase[i].offsetStart = Vector(-6, -5)
	doubleSlashAttackPhase[i].offsetEnd = Vector(7, -2)
	
	doubleSlashAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	doubleSlashAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 11
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 50
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 3.4
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 20
	doubleSlashAttackPhase[i].attackPush = 0.8
	doubleSlashAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 0;
	
	doubleSlashAttackPhase[i].frameStart = 11
	doubleSlashAttackPhase[i].frameEnd = 11
	doubleSlashAttackPhase[i].angleStart = -50
	doubleSlashAttackPhase[i].angleEnd = -90
	doubleSlashAttackPhase[i].offsetStart = Vector(7, -2)
	doubleSlashAttackPhase[i].offsetEnd = Vector(7, -2)
	
	doubleSlashAttackPhase[i].soundStart = nil
	
	doubleSlashAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 12
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 160
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = true
	doubleSlashAttackPhase[i].attackDamage = 6
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 15
	doubleSlashAttackPhase[i].attackPush = 0.85
	doubleSlashAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 11
	doubleSlashAttackPhase[i].frameEnd = 6
	doubleSlashAttackPhase[i].angleStart = -90
	doubleSlashAttackPhase[i].angleEnd = -100
	doubleSlashAttackPhase[i].offsetStart = Vector(7 , -2)
	doubleSlashAttackPhase[i].offsetEnd = Vector(15, -4)
	
	doubleSlashAttackPhase[i].soundStart = nil
	
	doubleSlashAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 13
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 150
	
	doubleSlashAttackPhase[i].firstRecvoery = true
	doubleSlashAttackPhase[i].canBeBlocked = false
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 0
	doubleSlashAttackPhase[i].attackStunChance = 0
	doubleSlashAttackPhase[i].attackRange = 0
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 6
	doubleSlashAttackPhase[i].frameEnd = 7
	doubleSlashAttackPhase[i].angleStart = -90
	doubleSlashAttackPhase[i].angleEnd = -40
	doubleSlashAttackPhase[i].offsetStart = Vector(15, -4)
	doubleSlashAttackPhase[i].offsetEnd = Vector(3, 0)
	
	doubleSlashAttackPhase[i].soundStart = nil
	doubleSlashAttackPhase[i].soundStartVariations = 0
	
	doubleSlashAttackPhase[i].soundEnd = nil
	doubleSlashAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 14
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 150
	
	doubleSlashAttackPhase[i].canBeBlocked = false
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 0
	doubleSlashAttackPhase[i].attackStunChance = 0
	doubleSlashAttackPhase[i].attackRange = 0
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 7
	doubleSlashAttackPhase[i].frameEnd = 6
	doubleSlashAttackPhase[i].angleStart = -40
	doubleSlashAttackPhase[i].angleEnd = 15
	doubleSlashAttackPhase[i].offsetStart = Vector(3, 0)
	doubleSlashAttackPhase[i].offsetEnd = Vector(3, 0)
	
	doubleSlashAttackPhase[i].soundStart = nil
	doubleSlashAttackPhase[i].soundStartVariations = 0
	
	doubleSlashAttackPhase[i].soundEnd = nil
	doubleSlashAttackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[1] = regularAttackSounds
	self.attackAnimationsGFX[1] = regularAttackGFX
	self.attackAnimations[1] = doubleSlashAttackPhase
	self.attackAnimationsTypes[1] = doubleSlashAttackPhase.Type
	
	-- Slash into OH Attack
	slashOverheadAttackPhase = {}
	slashOverheadAttackPhase.Type = "Slash";
	
	-- Prepare
	i = 1
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 300
	
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 90;
	
	slashOverheadAttackPhase[i].frameStart = 6
	slashOverheadAttackPhase[i].frameEnd = 6
	slashOverheadAttackPhase[i].angleStart = 0
	slashOverheadAttackPhase[i].angleEnd = 45
	slashOverheadAttackPhase[i].offsetStart = Vector(0, 0)
	slashOverheadAttackPhase[i].offsetEnd = Vector(-6, -5)
	
	slashOverheadAttackPhase[i].soundStart = nil
	slashOverheadAttackPhase[i].soundStartVariations = 0
	
	slashOverheadAttackPhase[i].soundEnd = nil
	slashOverheadAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 300
	
	slashOverheadAttackPhase[i].lastPrepare = true
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 0;
	
	slashOverheadAttackPhase[i].frameStart = 6
	slashOverheadAttackPhase[i].frameEnd = 6
	slashOverheadAttackPhase[i].angleStart = 45
	slashOverheadAttackPhase[i].angleEnd = 45
	slashOverheadAttackPhase[i].offsetStart = Vector(-6, -5)
	slashOverheadAttackPhase[i].offsetEnd = Vector(-6, -5)
	
	slashOverheadAttackPhase[i].soundStart = nil
	slashOverheadAttackPhase[i].soundStartVariations = 0
	
	slashOverheadAttackPhase[i].soundEnd = nil
	slashOverheadAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 160
	
	slashOverheadAttackPhase[i].canBeBlocked = true
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 3.4
	slashOverheadAttackPhase[i].attackStunChance = 0.15
	slashOverheadAttackPhase[i].attackRange = 20
	slashOverheadAttackPhase[i].attackPush = 0.8
	slashOverheadAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 0;
	
	slashOverheadAttackPhase[i].frameStart = 7
	slashOverheadAttackPhase[i].frameEnd = 11
	slashOverheadAttackPhase[i].angleStart = 30
	slashOverheadAttackPhase[i].angleEnd = -50
	slashOverheadAttackPhase[i].offsetStart = Vector(-6, -5)
	slashOverheadAttackPhase[i].offsetEnd = Vector(7, -2)
	
	slashOverheadAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	slashOverheadAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 50
	
	slashOverheadAttackPhase[i].canBeBlocked = true
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 3.4
	slashOverheadAttackPhase[i].attackStunChance = 0.15
	slashOverheadAttackPhase[i].attackRange = 20
	slashOverheadAttackPhase[i].attackPush = 0.8
	slashOverheadAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 0;
	
	slashOverheadAttackPhase[i].frameStart = 11
	slashOverheadAttackPhase[i].frameEnd = 11
	slashOverheadAttackPhase[i].angleStart = -50
	slashOverheadAttackPhase[i].angleEnd = -90
	slashOverheadAttackPhase[i].offsetStart = Vector(7, -2)
	slashOverheadAttackPhase[i].offsetEnd = Vector(7, -2)
	
	slashOverheadAttackPhase[i].soundStart = nil
	
	slashOverheadAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 160
	
	slashOverheadAttackPhase[i].canBeBlocked = true
	slashOverheadAttackPhase[i].canDamage = true
	slashOverheadAttackPhase[i].attackDamage = 6
	slashOverheadAttackPhase[i].attackStunChance = 0.15
	slashOverheadAttackPhase[i].attackRange = 15
	slashOverheadAttackPhase[i].attackPush = 0.85
	slashOverheadAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 90;
	
	slashOverheadAttackPhase[i].frameStart = 11
	slashOverheadAttackPhase[i].frameEnd = 6
	slashOverheadAttackPhase[i].angleStart = -90
	slashOverheadAttackPhase[i].angleEnd = -100
	slashOverheadAttackPhase[i].offsetStart = Vector(7 , -2)
	slashOverheadAttackPhase[i].offsetEnd = Vector(15, -4)
	
	slashOverheadAttackPhase[i].soundStart = nil
	
	slashOverheadAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 150
	
	slashOverheadAttackPhase[i].firstRecvoery = true
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 90;
	
	slashOverheadAttackPhase[i].frameStart = 6
	slashOverheadAttackPhase[i].frameEnd = 7
	slashOverheadAttackPhase[i].angleStart = -90
	slashOverheadAttackPhase[i].angleEnd = -40
	slashOverheadAttackPhase[i].offsetStart = Vector(15, -4)
	slashOverheadAttackPhase[i].offsetEnd = Vector(8, -4)
	
	slashOverheadAttackPhase[i].soundStart = nil
	slashOverheadAttackPhase[i].soundStartVariations = 0
	
	slashOverheadAttackPhase[i].soundEnd = nil
	slashOverheadAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 300
	
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 90;
	
	slashOverheadAttackPhase[i].frameStart = 7
	slashOverheadAttackPhase[i].frameEnd = 6
	slashOverheadAttackPhase[i].angleStart = -40
	slashOverheadAttackPhase[i].angleEnd = 45
	slashOverheadAttackPhase[i].offsetStart = Vector(8, -4)
	slashOverheadAttackPhase[i].offsetEnd = Vector(-4, -15)
	
	slashOverheadAttackPhase[i].soundStart = nil
	slashOverheadAttackPhase[i].soundStartVariations = 0
	
	slashOverheadAttackPhase[i].soundEnd = nil
	slashOverheadAttackPhase[i].soundEndVariations = 0
	
	-- Prepare
	i = 8
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 300
	
	slashOverheadAttackPhase[i].attackReset = true
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	slashOverheadAttackPhase[i].frameStart = 6
	slashOverheadAttackPhase[i].frameEnd = 6
	slashOverheadAttackPhase[i].angleStart = 45
	slashOverheadAttackPhase[i].angleEnd = 70
	slashOverheadAttackPhase[i].offsetStart = Vector(-4, -15)
	slashOverheadAttackPhase[i].offsetEnd = Vector(-4,-15)
	
	-- Late Prepare
	i = 9
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 100
	
	slashOverheadAttackPhase[i].lastPrepare = true
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	slashOverheadAttackPhase[i].frameStart = 6
	slashOverheadAttackPhase[i].frameEnd = 6
	slashOverheadAttackPhase[i].angleStart = 70
	slashOverheadAttackPhase[i].angleEnd = 76
	slashOverheadAttackPhase[i].offsetStart = Vector(-4, -15)
	slashOverheadAttackPhase[i].offsetEnd = Vector(-4, -15)
	
	slashOverheadAttackPhase[i].soundStart = nil
	slashOverheadAttackPhase[i].soundStartVariations = 0
	
	slashOverheadAttackPhase[i].soundEnd = nil
	slashOverheadAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 10
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 70
	
	slashOverheadAttackPhase[i].canBeBlocked = true
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 5
	slashOverheadAttackPhase[i].attackStunChance = 0.3
	slashOverheadAttackPhase[i].attackRange = 14
	slashOverheadAttackPhase[i].attackPush = 0.8
	slashOverheadAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 55;
	
	slashOverheadAttackPhase[i].frameStart = 6
	slashOverheadAttackPhase[i].frameEnd = 6
	slashOverheadAttackPhase[i].angleStart = 76
	slashOverheadAttackPhase[i].angleEnd = 20
	slashOverheadAttackPhase[i].offsetStart = Vector(0, -15)
	slashOverheadAttackPhase[i].offsetEnd = Vector(3, -10)
	
	slashOverheadAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	slashOverheadAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 11
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 170
	
	slashOverheadAttackPhase[i].canBeBlocked = true
	slashOverheadAttackPhase[i].canDamage = true
	slashOverheadAttackPhase[i].attackDamage = 12
	slashOverheadAttackPhase[i].attackStunChance = 0.4
	slashOverheadAttackPhase[i].attackRange = 14
	slashOverheadAttackPhase[i].attackPush = 1.05
	slashOverheadAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 55;
	
	slashOverheadAttackPhase[i].frameStart = 6
	slashOverheadAttackPhase[i].frameEnd = 6
	slashOverheadAttackPhase[i].angleStart = 20
	slashOverheadAttackPhase[i].angleEnd = -190
	slashOverheadAttackPhase[i].offsetStart = Vector(3, -10)
	slashOverheadAttackPhase[i].offsetEnd = Vector(15, 15)
	
	-- Early Recover
	i = 12
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 100
	
	slashOverheadAttackPhase[i].firstRecvoery = true	
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	slashOverheadAttackPhase[i].frameStart = 6
	slashOverheadAttackPhase[i].frameEnd = 6
	slashOverheadAttackPhase[i].angleStart = -120
	slashOverheadAttackPhase[i].angleEnd = -125
	slashOverheadAttackPhase[i].offsetStart = Vector(15, 15)
	slashOverheadAttackPhase[i].offsetEnd = Vector(10, 15)
	
	-- Recover
	i = 13
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 350
	
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	slashOverheadAttackPhase[i].frameStart = 6
	slashOverheadAttackPhase[i].frameEnd = 10
	slashOverheadAttackPhase[i].angleStart = -125
	slashOverheadAttackPhase[i].angleEnd = -50
	slashOverheadAttackPhase[i].offsetStart = Vector(10, 15)
	slashOverheadAttackPhase[i].offsetEnd = Vector(3, -5)
	
	-- Late Recover
	i = 14
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 350
	
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	slashOverheadAttackPhase[i].frameStart = 10
	slashOverheadAttackPhase[i].frameEnd = 6
	slashOverheadAttackPhase[i].angleStart = -50
	slashOverheadAttackPhase[i].angleEnd = 10
	slashOverheadAttackPhase[i].offsetStart = Vector(10, 15)
	slashOverheadAttackPhase[i].offsetEnd = Vector(3, -5)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[2] = regularAttackSounds
	self.attackAnimationsGFX[2] = regularAttackGFX
	self.attackAnimations[2] = slashOverheadAttackPhase
	self.attackAnimationsTypes[2] = slashOverheadAttackPhase.Type
	
	-- (stab)
	downwardShoveAttackPhase = {}
	downwardShoveAttackPhase.Type = "Stab";
	
	-- Prepare
	i = 1
	downwardShoveAttackPhase[i] = {}
	downwardShoveAttackPhase[i].durationMS = 200
	
	downwardShoveAttackPhase[i].canBeBlocked = false
	downwardShoveAttackPhase[i].canDamage = false
	downwardShoveAttackPhase[i].attackDamage = 1
	downwardShoveAttackPhase[i].attackStunChance = 0.6
	downwardShoveAttackPhase[i].attackRange = 15
	downwardShoveAttackPhase[i].attackPush = 1.3
	downwardShoveAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	downwardShoveAttackPhase[i].attackAngle = -45;
	
	downwardShoveAttackPhase[i].frameStart = 6
	downwardShoveAttackPhase[i].frameEnd = 6
	downwardShoveAttackPhase[i].angleStart = 25
	downwardShoveAttackPhase[i].angleEnd = 35
	downwardShoveAttackPhase[i].offsetStart = Vector(0, 0)
	downwardShoveAttackPhase[i].offsetEnd = Vector(-6, -15)
	
	downwardShoveAttackPhase[i].soundStart = nil
	downwardShoveAttackPhase[i].soundStartVariations = 0
	
	downwardShoveAttackPhase[i].soundEnd = nil
	downwardShoveAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	downwardShoveAttackPhase[i] = {}
	downwardShoveAttackPhase[i].durationMS = 50
	
	downwardShoveAttackPhase[i].lastPrepare = true
	downwardShoveAttackPhase[i].canBeBlocked = false
	downwardShoveAttackPhase[i].canDamage = false
	downwardShoveAttackPhase[i].attackDamage = 1
	downwardShoveAttackPhase[i].attackStunChance = 0.6
	downwardShoveAttackPhase[i].attackRange = 15
	downwardShoveAttackPhase[i].attackPush = 1.3
	downwardShoveAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	downwardShoveAttackPhase[i].attackAngle = -45;
	
	downwardShoveAttackPhase[i].frameStart = 6
	downwardShoveAttackPhase[i].frameEnd = 6
	downwardShoveAttackPhase[i].angleStart = 35
	downwardShoveAttackPhase[i].angleEnd = 35
	downwardShoveAttackPhase[i].offsetStart = Vector(-6, -15)
	downwardShoveAttackPhase[i].offsetEnd = Vector(-6, -15)
	
	downwardShoveAttackPhase[i].soundStart = nil
	downwardShoveAttackPhase[i].soundStartVariations = 0
	
	downwardShoveAttackPhase[i].soundEnd = nil
	downwardShoveAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	downwardShoveAttackPhase[i] = {}
	downwardShoveAttackPhase[i].durationMS = 70
	
	downwardShoveAttackPhase[i].canBeBlocked = true
	downwardShoveAttackPhase[i].canDamage = false
	downwardShoveAttackPhase[i].attackDamage = 1
	downwardShoveAttackPhase[i].attackStunChance = 0.6
	downwardShoveAttackPhase[i].attackRange = 15
	downwardShoveAttackPhase[i].attackPush = 1.3
	downwardShoveAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	downwardShoveAttackPhase[i].attackAngle = -45;
	
	downwardShoveAttackPhase[i].frameStart = 6
	downwardShoveAttackPhase[i].frameEnd = 6
	downwardShoveAttackPhase[i].angleStart = 35
	downwardShoveAttackPhase[i].angleEnd = 35
	downwardShoveAttackPhase[i].offsetStart = Vector(-6, -15)
	downwardShoveAttackPhase[i].offsetEnd = Vector(0, -10)
	
	downwardShoveAttackPhase[i].soundStart = CreateSoundContainer("Stab Greataxe Mordhau", "Mordhau.rte");
	
	downwardShoveAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	downwardShoveAttackPhase[i] = {}
	downwardShoveAttackPhase[i].durationMS = 35
	
	downwardShoveAttackPhase[i].canBeBlocked = true
	downwardShoveAttackPhase[i].canDamage = false
	downwardShoveAttackPhase[i].attackDamage = 1
	downwardShoveAttackPhase[i].attackStunChance = 0.6
	downwardShoveAttackPhase[i].attackRange = 15
	downwardShoveAttackPhase[i].attackPush = 1.3
	downwardShoveAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	downwardShoveAttackPhase[i].attackAngle = -45;
	
	downwardShoveAttackPhase[i].frameStart = 6
	downwardShoveAttackPhase[i].frameEnd = 6
	downwardShoveAttackPhase[i].angleStart = 35
	downwardShoveAttackPhase[i].angleEnd = 35
	downwardShoveAttackPhase[i].offsetStart = Vector(0, -10)
	downwardShoveAttackPhase[i].offsetEnd = Vector(4, -1)
	
	downwardShoveAttackPhase[i].soundStart = nil
	
	downwardShoveAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	downwardShoveAttackPhase[i] = {}
	downwardShoveAttackPhase[i].durationMS = 100
	
	downwardShoveAttackPhase[i].canBeBlocked = true
	downwardShoveAttackPhase[i].canDamage = true
	downwardShoveAttackPhase[i].attackDamage = 1
	downwardShoveAttackPhase[i].attackStunChance = 0.8
	downwardShoveAttackPhase[i].attackRange = 15
	downwardShoveAttackPhase[i].attackPush = 1.3
	downwardShoveAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	downwardShoveAttackPhase[i].attackAngle = -45;
	
	downwardShoveAttackPhase[i].frameStart = 6
	downwardShoveAttackPhase[i].frameEnd = 6
	downwardShoveAttackPhase[i].angleStart = 35
	downwardShoveAttackPhase[i].angleEnd = 35
	downwardShoveAttackPhase[i].offsetStart = Vector(4 , -1)
	downwardShoveAttackPhase[i].offsetEnd = Vector(15, 5)
	
	downwardShoveAttackPhase[i].soundStart = nil
	
	downwardShoveAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	downwardShoveAttackPhase[i] = {}
	downwardShoveAttackPhase[i].durationMS = 90
	
	downwardShoveAttackPhase[i].firstRecvoery = true
	downwardShoveAttackPhase[i].canBeBlocked = false
	downwardShoveAttackPhase[i].canDamage = false
	downwardShoveAttackPhase[i].attackDamage = 1
	downwardShoveAttackPhase[i].attackStunChance = 0.6
	downwardShoveAttackPhase[i].attackRange = 15
	downwardShoveAttackPhase[i].attackPush = 1.3
	downwardShoveAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	downwardShoveAttackPhase[i].attackAngle = -45;
	
	downwardShoveAttackPhase[i].frameStart = 6
	downwardShoveAttackPhase[i].frameEnd = 7
	downwardShoveAttackPhase[i].angleStart = 35
	downwardShoveAttackPhase[i].angleEnd = 30
	downwardShoveAttackPhase[i].offsetStart = Vector(15, -2)
	downwardShoveAttackPhase[i].offsetEnd = Vector(7, -3)
	
	downwardShoveAttackPhase[i].soundStart = nil
	downwardShoveAttackPhase[i].soundStartVariations = 0
	
	downwardShoveAttackPhase[i].soundEnd = nil
	downwardShoveAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
	downwardShoveAttackPhase[i] = {}
	downwardShoveAttackPhase[i].durationMS = 150
	
	downwardShoveAttackPhase[i].canBeBlocked = false
	downwardShoveAttackPhase[i].canDamage = false
	downwardShoveAttackPhase[i].attackDamage = 1
	downwardShoveAttackPhase[i].attackStunChance = 0.6
	downwardShoveAttackPhase[i].attackRange = 15
	downwardShoveAttackPhase[i].attackPush = 1.3
	downwardShoveAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	downwardShoveAttackPhase[i].attackAngle = -45;
	
	downwardShoveAttackPhase[i].frameStart = 7
	downwardShoveAttackPhase[i].frameEnd = 6
	downwardShoveAttackPhase[i].angleStart = 35
	downwardShoveAttackPhase[i].angleEnd = 25
	downwardShoveAttackPhase[i].offsetStart = Vector(7, -3)
	downwardShoveAttackPhase[i].offsetEnd = Vector(3, 0)
	
	downwardShoveAttackPhase[i].soundStart = nil
	downwardShoveAttackPhase[i].soundStartVariations = 0
	
	downwardShoveAttackPhase[i].soundEnd = nil
	downwardShoveAttackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[3] = stabAttackSounds
	self.attackAnimationsGFX[3] = regularAttackGFX
	self.attackAnimations[3] = downwardShoveAttackPhase
	self.attackAnimationsTypes[3] = downwardShoveAttackPhase.Type
	
	-- (stab)
	massiveShoveAttackPhase = {}
	massiveShoveAttackPhase.Type = "Stab";
	
	-- Prepare
	i = 1
	massiveShoveAttackPhase[i] = {}
	massiveShoveAttackPhase[i].durationMS = 400
	
	massiveShoveAttackPhase[i].canBeBlocked = false
	massiveShoveAttackPhase[i].canDamage = false
	massiveShoveAttackPhase[i].attackDamage = 0
	massiveShoveAttackPhase[i].attackStunChance = 0
	massiveShoveAttackPhase[i].attackRange = 0
	massiveShoveAttackPhase[i].attackPush = 0
	massiveShoveAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	massiveShoveAttackPhase[i].attackAngle = 90;
	
	massiveShoveAttackPhase[i].frameStart = 6
	massiveShoveAttackPhase[i].frameEnd = 6
	massiveShoveAttackPhase[i].angleStart = 25
	massiveShoveAttackPhase[i].angleEnd = 0
	massiveShoveAttackPhase[i].offsetStart = Vector(0, 0)
	massiveShoveAttackPhase[i].offsetEnd = Vector(-6, 0)
	
	massiveShoveAttackPhase[i].soundStart = nil
	massiveShoveAttackPhase[i].soundStartVariations = 0
	
	massiveShoveAttackPhase[i].soundEnd = nil
	massiveShoveAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	massiveShoveAttackPhase[i] = {}
	massiveShoveAttackPhase[i].durationMS = 200
	
	massiveShoveAttackPhase[i].lastPrepare = true
	massiveShoveAttackPhase[i].canBeBlocked = false
	massiveShoveAttackPhase[i].canDamage = false
	massiveShoveAttackPhase[i].attackDamage = 0
	massiveShoveAttackPhase[i].attackStunChance = 0
	massiveShoveAttackPhase[i].attackRange = 0
	massiveShoveAttackPhase[i].attackPush = 0
	massiveShoveAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	massiveShoveAttackPhase[i].attackAngle = 90;
	
	massiveShoveAttackPhase[i].frameStart = 6
	massiveShoveAttackPhase[i].frameEnd = 6
	massiveShoveAttackPhase[i].angleStart = 0
	massiveShoveAttackPhase[i].angleEnd = 0
	massiveShoveAttackPhase[i].offsetStart = Vector(-6, 0)
	massiveShoveAttackPhase[i].offsetEnd = Vector(-6, 0)
	
	massiveShoveAttackPhase[i].soundStart = nil
	massiveShoveAttackPhase[i].soundStartVariations = 0
	
	massiveShoveAttackPhase[i].soundEnd = nil
	massiveShoveAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	massiveShoveAttackPhase[i] = {}
	massiveShoveAttackPhase[i].durationMS = 70
	
	massiveShoveAttackPhase[i].canBeBlocked = true
	massiveShoveAttackPhase[i].canDamage = false
	massiveShoveAttackPhase[i].attackDamage = 1
	massiveShoveAttackPhase[i].attackStunChance = 0.6
	massiveShoveAttackPhase[i].attackRange = 15
	massiveShoveAttackPhase[i].attackPush = 1.3
	massiveShoveAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	massiveShoveAttackPhase[i].attackAngle = 0;
	
	massiveShoveAttackPhase[i].frameStart = 6
	massiveShoveAttackPhase[i].frameEnd = 6
	massiveShoveAttackPhase[i].angleStart = 0
	massiveShoveAttackPhase[i].angleEnd = 0
	massiveShoveAttackPhase[i].offsetStart = Vector(-6, 0)
	massiveShoveAttackPhase[i].offsetEnd = Vector(0, 0)
	
	massiveShoveAttackPhase[i].soundStart = CreateSoundContainer("Stab Greataxe Mordhau", "Mordhau.rte");
	
	massiveShoveAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	massiveShoveAttackPhase[i] = {}
	massiveShoveAttackPhase[i].durationMS = 35
	
	massiveShoveAttackPhase[i].canBeBlocked = true
	massiveShoveAttackPhase[i].canDamage = false
	massiveShoveAttackPhase[i].attackDamage = 1
	massiveShoveAttackPhase[i].attackStunChance = 0.6
	massiveShoveAttackPhase[i].attackRange = 15
	massiveShoveAttackPhase[i].attackPush = 1.3
	massiveShoveAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	massiveShoveAttackPhase[i].attackAngle = 0;
	
	massiveShoveAttackPhase[i].frameStart = 6
	massiveShoveAttackPhase[i].frameEnd = 6
	massiveShoveAttackPhase[i].angleStart = 0
	massiveShoveAttackPhase[i].angleEnd = 0
	massiveShoveAttackPhase[i].offsetStart = Vector(0, 0)
	massiveShoveAttackPhase[i].offsetEnd = Vector(4, -1)
	
	massiveShoveAttackPhase[i].soundStart = nil
	
	massiveShoveAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	massiveShoveAttackPhase[i] = {}
	massiveShoveAttackPhase[i].durationMS = 100
	
	massiveShoveAttackPhase[i].canBeBlocked = true
	massiveShoveAttackPhase[i].canDamage = true
	massiveShoveAttackPhase[i].attackDamage = 1
	massiveShoveAttackPhase[i].attackStunChance = 1.0
	massiveShoveAttackPhase[i].attackRange = 15
	massiveShoveAttackPhase[i].attackPush = 1.3
	massiveShoveAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	massiveShoveAttackPhase[i].attackAngle = 0;
	
	massiveShoveAttackPhase[i].frameStart = 6
	massiveShoveAttackPhase[i].frameEnd = 6
	massiveShoveAttackPhase[i].angleStart = 0
	massiveShoveAttackPhase[i].angleEnd = 15
	massiveShoveAttackPhase[i].offsetStart = Vector(4 , -1)
	massiveShoveAttackPhase[i].offsetEnd = Vector(15, -2)
	
	massiveShoveAttackPhase[i].soundStart = nil
	
	massiveShoveAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	massiveShoveAttackPhase[i] = {}
	massiveShoveAttackPhase[i].durationMS = 90
	
	massiveShoveAttackPhase[i].firstRecvoery = true
	massiveShoveAttackPhase[i].canBeBlocked = false
	massiveShoveAttackPhase[i].canDamage = false
	massiveShoveAttackPhase[i].attackDamage = 0
	massiveShoveAttackPhase[i].attackStunChance = 0
	massiveShoveAttackPhase[i].attackRange = 0
	massiveShoveAttackPhase[i].attackPush = 0
	massiveShoveAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	massiveShoveAttackPhase[i].attackAngle = 90;
	
	massiveShoveAttackPhase[i].frameStart = 6
	massiveShoveAttackPhase[i].frameEnd = 7
	massiveShoveAttackPhase[i].angleStart = 15
	massiveShoveAttackPhase[i].angleEnd = 25
	massiveShoveAttackPhase[i].offsetStart = Vector(15, -2)
	massiveShoveAttackPhase[i].offsetEnd = Vector(7, -3)
	
	massiveShoveAttackPhase[i].soundStart = nil
	massiveShoveAttackPhase[i].soundStartVariations = 0
	
	massiveShoveAttackPhase[i].soundEnd = nil
	massiveShoveAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
	massiveShoveAttackPhase[i] = {}
	massiveShoveAttackPhase[i].durationMS = 150
	
	massiveShoveAttackPhase[i].canBeBlocked = false
	massiveShoveAttackPhase[i].canDamage = false
	massiveShoveAttackPhase[i].attackDamage = 0
	massiveShoveAttackPhase[i].attackStunChance = 0
	massiveShoveAttackPhase[i].attackRange = 0
	massiveShoveAttackPhase[i].attackPush = 0
	massiveShoveAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	massiveShoveAttackPhase[i].attackAngle = 90;
	
	massiveShoveAttackPhase[i].frameStart = 7
	massiveShoveAttackPhase[i].frameEnd = 6
	massiveShoveAttackPhase[i].angleStart = 25
	massiveShoveAttackPhase[i].angleEnd = 25
	massiveShoveAttackPhase[i].offsetStart = Vector(7, -3)
	massiveShoveAttackPhase[i].offsetEnd = Vector(3, 0)
	
	massiveShoveAttackPhase[i].soundStart = nil
	massiveShoveAttackPhase[i].soundStartVariations = 0
	
	massiveShoveAttackPhase[i].soundEnd = nil
	massiveShoveAttackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[4] = stabAttackSounds
	self.attackAnimationsGFX[4] = regularAttackGFX
	self.attackAnimations[4] = massiveShoveAttackPhase
	self.attackAnimationsTypes[4] = massiveShoveAttackPhase.Type	
	
	-- Charged Attack

	underhandComboAttackPhase = {}
	underhandComboAttackPhase.Type = "Slash";
	
	i = 1
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 330
	
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = 25
	underhandComboAttackPhase[i].angleEnd = -180
	underhandComboAttackPhase[i].offsetStart = Vector(0, 0)
	underhandComboAttackPhase[i].offsetEnd = Vector(5, 5)
	
	-- Late Prepare
	i = 2
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 350
	
	underhandComboAttackPhase[i].lastPrepare = true
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = -180
	underhandComboAttackPhase[i].angleEnd = -240
	underhandComboAttackPhase[i].offsetStart = Vector(5, 5)
	underhandComboAttackPhase[i].offsetEnd = Vector(0, 15)
	
	underhandComboAttackPhase[i].soundStart = nil
	underhandComboAttackPhase[i].soundStartVariations = 0
	
	underhandComboAttackPhase[i].soundEnd = nil
	underhandComboAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 3
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 70
	
	underhandComboAttackPhase[i].canBeBlocked = true
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 5
	underhandComboAttackPhase[i].attackStunChance = 0.3
	underhandComboAttackPhase[i].attackRange = 14
	underhandComboAttackPhase[i].attackPush = 0.8
	underhandComboAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 55;
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = -240
	underhandComboAttackPhase[i].angleEnd = -180
	underhandComboAttackPhase[i].offsetStart = Vector(0, 15)
	underhandComboAttackPhase[i].offsetEnd = Vector(3, 10)
	
	underhandComboAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	underhandComboAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 4
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 170
	
	underhandComboAttackPhase[i].ignoreTerrain = true
	underhandComboAttackPhase[i].canBeBlocked = true
	underhandComboAttackPhase[i].canDamage = true
	underhandComboAttackPhase[i].attackDamage = 10
	underhandComboAttackPhase[i].attackStunChance = 0.8
	underhandComboAttackPhase[i].attackRange = 14
	underhandComboAttackPhase[i].attackPush = 1.2
	underhandComboAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 55;
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = -180
	underhandComboAttackPhase[i].angleEnd = 25
	underhandComboAttackPhase[i].offsetStart = Vector(3, 10)
	underhandComboAttackPhase[i].offsetEnd = Vector(10, -15)
	
	-- Early Recover
	i = 5
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 100
	
	underhandComboAttackPhase[i].firstRecvoery = true	
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = 25
	underhandComboAttackPhase[i].angleEnd = 70
	underhandComboAttackPhase[i].offsetStart = Vector(10, -15)
	underhandComboAttackPhase[i].offsetEnd = Vector(11, -15)
	
	-- Recover
	i = 6
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 350
	
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = 70
	underhandComboAttackPhase[i].angleEnd = 70
	underhandComboAttackPhase[i].offsetStart = Vector(11, -15)
	underhandComboAttackPhase[i].offsetEnd = Vector(2, -13)
	
	-- Prepare
	i = 7
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 300
	
	underhandComboAttackPhase[i].attackReset = true
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = 70
	underhandComboAttackPhase[i].angleEnd = 80
	underhandComboAttackPhase[i].offsetStart = Vector(2, -13)
	underhandComboAttackPhase[i].offsetEnd = Vector(-4,-15)
	
	-- Late Prepare
	i = 8
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 100
	
	underhandComboAttackPhase[i].lastPrepare = true
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = 80
	underhandComboAttackPhase[i].angleEnd = 80
	underhandComboAttackPhase[i].offsetStart = Vector(-4, -15)
	underhandComboAttackPhase[i].offsetEnd = Vector(-4, -15)
	
	underhandComboAttackPhase[i].soundStart = nil
	underhandComboAttackPhase[i].soundStartVariations = 0
	
	underhandComboAttackPhase[i].soundEnd = nil
	underhandComboAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 9
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 70
	
	underhandComboAttackPhase[i].canBeBlocked = true
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 5
	underhandComboAttackPhase[i].attackStunChance = 0.3
	underhandComboAttackPhase[i].attackRange = 14
	underhandComboAttackPhase[i].attackPush = 0.8
	underhandComboAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 55;
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = 80
	underhandComboAttackPhase[i].angleEnd = 20
	underhandComboAttackPhase[i].offsetStart = Vector(0, -15)
	underhandComboAttackPhase[i].offsetEnd = Vector(3, -10)
	
	underhandComboAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	underhandComboAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 10
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 170
	
	underhandComboAttackPhase[i].canBeBlocked = true
	underhandComboAttackPhase[i].canDamage = true
	underhandComboAttackPhase[i].attackDamage = 15
	underhandComboAttackPhase[i].attackStunChance = 0.5
	underhandComboAttackPhase[i].attackRange = 14
	underhandComboAttackPhase[i].attackPush = 1.1
	underhandComboAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 55;
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = 20
	underhandComboAttackPhase[i].angleEnd = -190
	underhandComboAttackPhase[i].offsetStart = Vector(3, -10)
	underhandComboAttackPhase[i].offsetEnd = Vector(15, 15)
	
	-- Early Recover
	i = 11
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 100
	
	underhandComboAttackPhase[i].firstRecvoery = true	
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = -120
	underhandComboAttackPhase[i].angleEnd = -125
	underhandComboAttackPhase[i].offsetStart = Vector(15, 15)
	underhandComboAttackPhase[i].offsetEnd = Vector(10, 15)
	
	-- Recover
	i = 12
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 350
	
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 6
	underhandComboAttackPhase[i].frameEnd = 10
	underhandComboAttackPhase[i].angleStart = -125
	underhandComboAttackPhase[i].angleEnd = -50
	underhandComboAttackPhase[i].offsetStart = Vector(10, 15)
	underhandComboAttackPhase[i].offsetEnd = Vector(3, -5)
	
	-- Late Recover
	i = 13
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 350
	
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 10
	underhandComboAttackPhase[i].frameEnd = 6
	underhandComboAttackPhase[i].angleStart = -50
	underhandComboAttackPhase[i].angleEnd = 10
	underhandComboAttackPhase[i].offsetStart = Vector(10, 15)
	underhandComboAttackPhase[i].offsetEnd = Vector(3, -5)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[5] = regularAttackSounds
	self.attackAnimationsGFX[5] = regularAttackGFX
	self.attackAnimations[5] = underhandComboAttackPhase
	self.attackAnimationsTypes[5] = underhandComboAttackPhase.Type
	
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
	overheadAttackPhase[i].frameEnd = 10
	overheadAttackPhase[i].angleStart = 25
	overheadAttackPhase[i].angleEnd = -10
	overheadAttackPhase[i].offsetStart = Vector(0, 0)
	overheadAttackPhase[i].offsetEnd = Vector(-4,-15)
	
	-- Late Prepare
	i = 2
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 500
	
	overheadAttackPhase[i].lastPrepare = true
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 10
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = -10
	overheadAttackPhase[i].angleEnd = 90
	overheadAttackPhase[i].offsetStart = Vector(-4, -15)
	overheadAttackPhase[i].offsetEnd = Vector(-4, -15)
	
	overheadAttackPhase[i].soundStart = nil
	overheadAttackPhase[i].soundStartVariations = 0
	
	overheadAttackPhase[i].soundEnd = nil
	overheadAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 3
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 50
	
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
	overheadAttackPhase[i].angleStart = 80
	overheadAttackPhase[i].angleEnd = 20
	overheadAttackPhase[i].offsetStart = Vector(0, -15)
	overheadAttackPhase[i].offsetEnd = Vector(3, -10)
	
	overheadAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	overheadAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 4
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 140
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = true
	overheadAttackPhase[i].attackDamage = 20
	overheadAttackPhase[i].attackStunChance = 1.0
	overheadAttackPhase[i].attackRange = 14
	overheadAttackPhase[i].attackPush = 1.05
	overheadAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = 55;
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = 20
	overheadAttackPhase[i].angleEnd = -190
	overheadAttackPhase[i].offsetStart = Vector(3, -10)
	overheadAttackPhase[i].offsetEnd = Vector(15, 15)
	
	-- Early Recover
	i = 5
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 100
	
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
	overheadAttackPhase[i].angleEnd = -125
	overheadAttackPhase[i].offsetStart = Vector(15, 15)
	overheadAttackPhase[i].offsetEnd = Vector(10, 15)
	
	-- Recover
	i = 6
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 600
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 6
	overheadAttackPhase[i].frameEnd = 11
	overheadAttackPhase[i].angleStart = -125
	overheadAttackPhase[i].angleEnd = -10
	overheadAttackPhase[i].offsetStart = Vector(10, 15)
	overheadAttackPhase[i].offsetEnd = Vector(3, -5)
	
	-- Late Recover
	i = 7
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 600
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 10
	overheadAttackPhase[i].frameEnd = 6
	overheadAttackPhase[i].angleStart = -10
	overheadAttackPhase[i].angleEnd = 10
	overheadAttackPhase[i].offsetStart = Vector(10, 15)
	overheadAttackPhase[i].offsetEnd = Vector(3, -5)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[6] = regularAttackSounds
	self.attackAnimationsGFX[6] = regularAttackGFX
	self.attackAnimations[6] = overheadAttackPhase
	self.attackAnimationsTypes[6] = overheadAttackPhase.Type
	
	-- Flourish... obviously
	flourishPhase = {}
	flourishPhase.Type = "Flourish";
	
	-- Surprise
	i = 1
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 330
	
	flourishPhase[i].canBeBlocked = false
	flourishPhase[i].canDamage = false
	flourishPhase[i].attackDamage = 0
	flourishPhase[i].attackStunChance = 0
	flourishPhase[i].attackRange = 0
	flourishPhase[i].attackPush = 0
	flourishPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	flourishPhase[i].frameStart = 6
	flourishPhase[i].frameEnd = 9
	flourishPhase[i].angleStart = 25
	flourishPhase[i].angleEnd = 0
	flourishPhase[i].offsetStart = Vector(0, 0)
	flourishPhase[i].offsetEnd = Vector(-4,-15)
	
	flourishPhase[i].soundStart = CreateSoundContainer("Flourish Greataxe Mordhau", "Mordhau.rte");
	
	-- Bedazzle
	i = 2
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 300
	
	flourishPhase[i].canBeBlocked = false
	flourishPhase[i].canDamage = false
	flourishPhase[i].attackDamage = 0
	flourishPhase[i].attackStunChance = 0
	flourishPhase[i].attackRange = 0
	flourishPhase[i].attackPush = 0
	flourishPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	flourishPhase[i].attackAngle = 0;
	
	flourishPhase[i].frameStart = 9
	flourishPhase[i].frameEnd = 11
	flourishPhase[i].angleStart = 0
	flourishPhase[i].angleEnd = -45
	flourishPhase[i].offsetStart = Vector(-4, -15)
	flourishPhase[i].offsetEnd = Vector(-6, -5)
	
	flourishPhase[i].soundStart = nil
	flourishPhase[i].soundStartVariations = 0
	
	flourishPhase[i].soundEnd = nil
	flourishPhase[i].soundEndVariations = 0
	
	-- Amaze
	i = 3
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 300
	
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
	flourishPhase[i].angleStart = -45
	flourishPhase[i].angleEnd = -90
	flourishPhase[i].offsetStart = Vector(-6, -5)
	flourishPhase[i].offsetEnd = Vector(7, -2)
	
	flourishPhase[i].soundEnd = nil
	
	-- Bask
	i = 4
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 300
	
	flourishPhase[i].firstRecvoery = true
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
	flourishPhase[i].angleStart = -90
	flourishPhase[i].angleEnd = 25
	flourishPhase[i].offsetStart = Vector(7, -2)
	flourishPhase[i].offsetEnd = Vector(7, -2)
	
	flourishPhase[i].soundStart = nil
	
	flourishPhase[i].soundEnd = nil
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[7] = regularAttackSounds
	self.attackAnimationsGFX[7] = regularAttackGFX
	self.attackAnimations[7] = flourishPhase
	self.attackAnimationsTypes[7] = flourishPhase.Type
	
	-- Throw
	throwPhase = {}
	throwPhase.Type = "Throw";
	
	-- Windup
	i = 1
	throwPhase[i] = {}
	throwPhase[i].durationMS = 1200
	
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
	throwPhase[i].durationMS = 400
	
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
	throwPhase[i].durationMS = 250
	
	throwPhase[i].canBeBlocked = true
	throwPhase[i].canDamage = true
	throwPhase[i].attackDamage = 7
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
	throwPhase[i].offsetEnd = Vector(6, -15)
	
	throwPhase[i].soundStart = nil
	throwPhase[i].soundStartVariations = 0
	
	throwPhase[i].soundEnd = nil
	throwPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[8] = regularAttackSounds
	self.attackAnimationsGFX[8] = regularAttackGFX
	self.attackAnimations[8] = throwPhase
	self.attackAnimationsTypes[8] = throwPhase.Type
	
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

	if controller then --          :-)
	
		-- INPUT
		local throw
		local flourish
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
				if stab or overhead or flourish or throw or self.attackBuffered == true then
					controller:SetState(Controller.PRESS_PRIMARY, true)
					self:Activate();
				end
				attack = controller:IsState(Controller.PRESS_PRIMARY);
				if self:IsActivated() and self.attackCooldown == true then
					self:Deactivate();
				else
					self.attackBuffered = false;
					self.stabBuffered = false;
					self.overheadBuffered = false;
					self.attackCooldown = false;
				end
			else
				-- stab = (math.random(0, 100) < 50) and true;
				-- overhead = true;
				-- if stab or overhead or self.attackBuffered == true then
					-- controller:SetState(Controller.PRESS_PRIMARY, true)
					-- self:Activate();
				-- end
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
				
				-- make our parrying shield counter alongside us
				-- and here i sit and wonder... parrying daggers?
				local BGItem = self.parent.EquippedBGItem;				
				if BGItem and BGItem:IsInGroup("Weapons - Mordhau Melee") then
					ToHeldDevice(BGItem):SetStringValue("Parrying Type", "Flourish");
				end	
			
				self.Blocking = false;
				self:RemoveNumberValue("Blocking");
				
				stanceTarget = Vector(0, 0);
				
				self.originalBaseRotation = 25;
				self.baseRotation = 25;
				
			end
			
			if not stab and not overhead and not flourish and not throw then
				playAttackAnimation(self, math.random(1, 2)) -- regular attack
			elseif stab then
				playAttackAnimation(self, math.random(3, 4)) -- stab
			elseif overhead then
				playAttackAnimation(self, math.random(5, 6)) -- overhead
			elseif flourish then
				self.parent:SetNumberValue("Block Foley", 1);
				playAttackAnimation(self, 7) -- fancypants shit
			elseif throw then
				self.parent:SetNumberValue("Block Foley", 1);
				self.Throwing = true;
				playAttackAnimation(self, 8) -- throw
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
		local ignoreTerrain = false
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
					self.parent:SetNumberValue("Extreme Attack", 1);
				else
					self.wasCharged = false;
					self.parent:SetNumberValue("Large Attack", 1);				
				end
			elseif currentPhase.firstRecvoery == true then
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
						
						stanceTarget = Vector(4, -10);
						
						self.originalBaseRotation = -60;
						self.baseRotation = -60;
					end
				end
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
			ignoreTerrain = currentPhase.ignoreTerrain or false
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
			
			-- DEBUG
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 40), "animation = "..animation, true, 0);
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "sequence = "..self.currentAttackSequence, true, 0);
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 30), "factor = "..math.floor(factor * 100).."/100", true, 0);
			if self.attackAnimationTimer:IsPastSimMS(workingDuration) then
				if (self.currentAttackSequence+1) <= #attackPhases then
					if nextPhase.attackReset == true then
						self.blockedNullifier = true;
						self.wasCharged = false;
						self.chargeDecided = false;
						self.Recovering = false;
					end
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
						local throwChargeFactor = self.wasCharged and 30 or 0
						self.Throwing = false;
						self.wasThrown = true;
						self:GetParent():RemoveAttachable(self, true, false);
						self.Vel = self.parent.Vel + Vector((throwChargeFactor + 45)*self.FlipFactor, 0):RadRotate(self.RotAngle);
						self.throwSoundPlayed = false;
						
					end
				end
				
				if currentPhase.soundEnd then
					currentPhase.soundEnd:Play(self.Pos);
				end
				
				self:RemoveStringValue("Parrying Type");
				self.Parrying = false;
				
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
					
					stanceTarget = Vector(4, -10);
					
					self.originalBaseRotation = -60;
					self.baseRotation = -60;
				
				elseif self.Blocking == true and UInputMan:KeyHeld(18) and not (self.attackAnimationIsPlaying) then
				
					self.originalBaseRotation = -60;
				
					stanceTarget = Vector(4, -10);
				
				elseif UInputMan:KeyReleased(18) then
				
					self.parent:SetNumberValue("Block Foley", 1);
				
					self.Blocking = false;
					
					self:RemoveNumberValue("Blocking");
					
					self.originalBaseRotation = 25;
					self.baseRotation = 15;
				
				else
					
					self.Blocking = false;
					
					self:RemoveNumberValue("Blocking");
					
					self.originalBaseRotation = 25;
					self.baseRotation = 15;
					
				end
			elseif not self.attackAnimationIsPlaying then
			
				self.Blocking = true;
				
				self:SetNumberValue("Blocking", 1);
				
				stanceTarget = Vector(4, -10);
				
				self.originalBaseRotation = -60;
				self.baseRotation = -60;
				
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
						if IsAHuman(actorHit) and self.attackAnimationsTypes[self.currentAttackAnimation] == "Slash" then
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
					else -- generic wound adding for non-actors
						for i = 1, woundsToAdd do
							MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					end
				elseif MO:IsInGroup("Weapons - Mordhau Melee") then
					hit = true;
					MO = ToHeldDevice(MO);
					if MO:NumberValueExists("Blocking") or (MO:StringValueExists("Parrying Type")
					and (MO:GetStringValue("Parrying Type") == self.attackAnimationsTypes[self.currentAttackAnimation] or MO:GetStringValue("Parrying Type") == "Flourish")) then
						self.attackCooldown = true;
						if MO:StringValueExists("Parrying Type") then
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
					if not ignoreTerrain then
						hit = true
						self.attack = false
						self.charged = false
					end
					
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