
function stringInsert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end


function playAttackAnimation(self, animation)
	self.allowBlockCancelling = false;
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
	
	self.wasParried = false;
	
	self.Hits = 0;
	self.hitMOTable = {};
	
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

	self.equipSound = CreateSoundContainer("HaftedLarge Equip Mordhau", "Mordhau.rte");
	self.equipSound.Pitch = 0.7;
	
	self.pickUpSound = CreateSoundContainer("Metal Pickup Mordhau", "Mordhau.rte");
	self.pickUpSound.Pitch = 0.7;

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
	
	self.Hits = 0;
	
	self.swingRotationFrames = 1; -- this is the amount of frames it takes us to go from sideways to facing forwards again (after a swing)
								  -- for swords this might just be one, for big axes it could be as high as 4

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
	self.parriedCooldownDelay = 1400;
	
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
	
	self:SetNumberValue("Attack Types", 4)
	
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
	doubleSlashAttackPhase[i].furthestReach = 15
	doubleSlashAttackPhase[i].attackRange = 20
	self:SetNumberValue("Attack 1 Range", doubleSlashAttackPhase[i].furthestReach + doubleSlashAttackPhase[i].attackRange)
	self:SetStringValue("Attack 1 Name", "Swing");
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 0
	doubleSlashAttackPhase[i].frameEnd = 0
	doubleSlashAttackPhase[i].angleStart = 25
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
	doubleSlashAttackPhase[i].durationMS = 200
	
	doubleSlashAttackPhase[i].lastPrepare = true
	doubleSlashAttackPhase[i].canBeBlocked = false
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 0
	doubleSlashAttackPhase[i].attackStunChance = 0
	doubleSlashAttackPhase[i].attackRange = 0
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 0;
	
	doubleSlashAttackPhase[i].frameStart = 0
	doubleSlashAttackPhase[i].frameEnd = 0
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
	doubleSlashAttackPhase[i].durationMS = 80
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 3.4
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 20
	doubleSlashAttackPhase[i].attackPush = 0.8
	doubleSlashAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 0;
	
	doubleSlashAttackPhase[i].frameStart = 1
	doubleSlashAttackPhase[i].frameEnd = 3
	doubleSlashAttackPhase[i].angleStart = 30
	doubleSlashAttackPhase[i].angleEnd = -45
	doubleSlashAttackPhase[i].offsetStart = Vector(-6, -5)
	doubleSlashAttackPhase[i].offsetEnd = Vector(7, -2)
	
	doubleSlashAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	doubleSlashAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 80
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 3.4
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 20
	doubleSlashAttackPhase[i].attackPush = 0.8
	doubleSlashAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 70;
	
	doubleSlashAttackPhase[i].frameStart = 3
	doubleSlashAttackPhase[i].frameEnd = 5
	doubleSlashAttackPhase[i].angleStart = -45
	doubleSlashAttackPhase[i].angleEnd = -100
	doubleSlashAttackPhase[i].offsetStart = Vector(7, -2)
	doubleSlashAttackPhase[i].offsetEnd = Vector(7, -2)
	
	doubleSlashAttackPhase[i].soundStart = nil
	
	doubleSlashAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 130
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = true
	doubleSlashAttackPhase[i].attackDamage = 10
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 20
	doubleSlashAttackPhase[i].attackPush = 0.85
	doubleSlashAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 5
	doubleSlashAttackPhase[i].frameEnd = 11
	doubleSlashAttackPhase[i].angleStart = -100
	doubleSlashAttackPhase[i].angleEnd = -90
	doubleSlashAttackPhase[i].offsetStart = Vector(7 , -2)
	doubleSlashAttackPhase[i].offsetEnd = Vector(15, -4)
	
	doubleSlashAttackPhase[i].soundStart = nil
	
	doubleSlashAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 100
	
	doubleSlashAttackPhase[i].firstRecovery = true
	doubleSlashAttackPhase[i].canBeBlocked = false
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 0
	doubleSlashAttackPhase[i].attackStunChance = 0
	doubleSlashAttackPhase[i].attackRange = 0
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 11
	doubleSlashAttackPhase[i].frameEnd = (11 + 1 + self.swingRotationFrames); -- + 1 because the actual end frame is never reached, code just goes TOWARDS it
	doubleSlashAttackPhase[i].angleStart = -90
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
	
	doubleSlashAttackPhase[i].frameStart = 0
	doubleSlashAttackPhase[i].frameEnd = 1
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
	
	doubleSlashAttackPhase[i].frameStart = 1
	doubleSlashAttackPhase[i].frameEnd = 1
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
	
	doubleSlashAttackPhase[i].frameStart = 1
	doubleSlashAttackPhase[i].frameEnd = 0
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
	doubleSlashAttackPhase[i].durationMS = 80
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 3.4
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 20
	doubleSlashAttackPhase[i].attackPush = 0.8
	doubleSlashAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 0;
	
	doubleSlashAttackPhase[i].frameStart = 1
	doubleSlashAttackPhase[i].frameEnd = 3
	doubleSlashAttackPhase[i].angleStart = 45
	doubleSlashAttackPhase[i].angleEnd = -45
	doubleSlashAttackPhase[i].offsetStart = Vector(-6, -5)
	doubleSlashAttackPhase[i].offsetEnd = Vector(7, -2)
	
	doubleSlashAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	doubleSlashAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 11
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 80
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 3.4
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 20
	doubleSlashAttackPhase[i].attackPush = 0.8
	doubleSlashAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 70;
	
	doubleSlashAttackPhase[i].frameStart = 3
	doubleSlashAttackPhase[i].frameEnd = 5
	doubleSlashAttackPhase[i].angleStart = -45
	doubleSlashAttackPhase[i].angleEnd = -90
	doubleSlashAttackPhase[i].offsetStart = Vector(7, -2)
	doubleSlashAttackPhase[i].offsetEnd = Vector(7, -2)
	
	doubleSlashAttackPhase[i].soundStart = nil
	
	doubleSlashAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 12
	doubleSlashAttackPhase[i] = {}
	doubleSlashAttackPhase[i].durationMS = 140
	
	doubleSlashAttackPhase[i].canBeBlocked = true
	doubleSlashAttackPhase[i].canDamage = true
	doubleSlashAttackPhase[i].attackDamage = 9
	doubleSlashAttackPhase[i].attackStunChance = 0.15
	doubleSlashAttackPhase[i].attackRange = 20
	doubleSlashAttackPhase[i].attackPush = 0.85
	doubleSlashAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 5
	doubleSlashAttackPhase[i].frameEnd = 11
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
	
	doubleSlashAttackPhase[i].firstRecovery = true
	doubleSlashAttackPhase[i].canBeBlocked = false
	doubleSlashAttackPhase[i].canDamage = false
	doubleSlashAttackPhase[i].attackDamage = 0
	doubleSlashAttackPhase[i].attackStunChance = 0
	doubleSlashAttackPhase[i].attackRange = 0
	doubleSlashAttackPhase[i].attackPush = 0
	doubleSlashAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	doubleSlashAttackPhase[i].attackAngle = 90;
	
	doubleSlashAttackPhase[i].frameStart = 11
	doubleSlashAttackPhase[i].frameEnd = (11 + 1 + self.swingRotationFrames); -- + 1 because the actual end frame is never reached, code just goes TOWARDS it
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
	
	doubleSlashAttackPhase[i].frameStart = 0
	doubleSlashAttackPhase[i].frameEnd = 0
	doubleSlashAttackPhase[i].angleStart = -40
	doubleSlashAttackPhase[i].angleEnd = 25
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
	
	slashOverheadAttackPhase[i].frameStart = 0
	slashOverheadAttackPhase[i].frameEnd = 0
	slashOverheadAttackPhase[i].angleStart = 25
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
	slashOverheadAttackPhase[i].durationMS = 200
	
	slashOverheadAttackPhase[i].lastPrepare = true
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 0;
	
	slashOverheadAttackPhase[i].frameStart = 0
	slashOverheadAttackPhase[i].frameEnd = 0
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
	slashOverheadAttackPhase[i].durationMS = 80
	
	slashOverheadAttackPhase[i].canBeBlocked = true
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 3.4
	slashOverheadAttackPhase[i].attackStunChance = 0.15
	slashOverheadAttackPhase[i].attackRange = 20
	slashOverheadAttackPhase[i].attackPush = 0.8
	slashOverheadAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 0;
	
	slashOverheadAttackPhase[i].frameStart = 1
	slashOverheadAttackPhase[i].frameEnd = 3
	slashOverheadAttackPhase[i].angleStart = 45
	slashOverheadAttackPhase[i].angleEnd = -45
	slashOverheadAttackPhase[i].offsetStart = Vector(-6, -5)
	slashOverheadAttackPhase[i].offsetEnd = Vector(7, -2)
	
	slashOverheadAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	slashOverheadAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 80
	
	slashOverheadAttackPhase[i].canBeBlocked = true
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 3.4
	slashOverheadAttackPhase[i].attackStunChance = 0.15
	slashOverheadAttackPhase[i].attackRange = 20
	slashOverheadAttackPhase[i].attackPush = 0.8
	slashOverheadAttackPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 70;
	
	slashOverheadAttackPhase[i].frameStart = 3
	slashOverheadAttackPhase[i].frameEnd = 5
	slashOverheadAttackPhase[i].angleStart = -45
	slashOverheadAttackPhase[i].angleEnd = -100
	slashOverheadAttackPhase[i].offsetStart = Vector(7, -2)
	slashOverheadAttackPhase[i].offsetEnd = Vector(7, -2)
	
	slashOverheadAttackPhase[i].soundStart = nil
	
	slashOverheadAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 130
	
	slashOverheadAttackPhase[i].canBeBlocked = true
	slashOverheadAttackPhase[i].canDamage = true
	slashOverheadAttackPhase[i].attackDamage = 10
	slashOverheadAttackPhase[i].attackStunChance = 0.15
	slashOverheadAttackPhase[i].attackRange = 20
	slashOverheadAttackPhase[i].attackPush = 0.85
	slashOverheadAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 90;
	
	slashOverheadAttackPhase[i].frameStart = 5
	slashOverheadAttackPhase[i].frameEnd = 11
	slashOverheadAttackPhase[i].angleStart = -100
	slashOverheadAttackPhase[i].angleEnd = -90
	slashOverheadAttackPhase[i].offsetStart = Vector(7 , -2)
	slashOverheadAttackPhase[i].offsetEnd = Vector(15, -4)
	
	slashOverheadAttackPhase[i].soundStart = nil
	
	slashOverheadAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 150
	
	slashOverheadAttackPhase[i].firstRecovery = true
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 90;
	
	slashOverheadAttackPhase[i].frameStart = 11
	slashOverheadAttackPhase[i].frameEnd = (11 + 1 + self.swingRotationFrames); -- + 1 because the actual end frame is never reached, code just goes TOWARDS it
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
	
	slashOverheadAttackPhase[i].frameStart = 0
	slashOverheadAttackPhase[i].frameEnd = 0
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
	
	slashOverheadAttackPhase[i].frameStart = 0
	slashOverheadAttackPhase[i].frameEnd = 0
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
	
	slashOverheadAttackPhase[i].frameStart = 0
	slashOverheadAttackPhase[i].frameEnd = 0
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
	slashOverheadAttackPhase[i].attackRange = 25
	slashOverheadAttackPhase[i].attackPush = 0.8
	slashOverheadAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 55;
	
	slashOverheadAttackPhase[i].frameStart = 0
	slashOverheadAttackPhase[i].frameEnd = 0
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
	slashOverheadAttackPhase[i].attackRange = 25
	slashOverheadAttackPhase[i].attackPush = 1.05
	slashOverheadAttackPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	slashOverheadAttackPhase[i].attackAngle = 55;
	
	slashOverheadAttackPhase[i].frameStart = 0
	slashOverheadAttackPhase[i].frameEnd = 0
	slashOverheadAttackPhase[i].angleStart = 20
	slashOverheadAttackPhase[i].angleEnd = -190
	slashOverheadAttackPhase[i].offsetStart = Vector(3, -10)
	slashOverheadAttackPhase[i].offsetEnd = Vector(15, 15)
	
	-- Early Recover
	i = 12
	slashOverheadAttackPhase[i] = {}
	slashOverheadAttackPhase[i].durationMS = 100
	
	slashOverheadAttackPhase[i].firstRecovery = true	
	slashOverheadAttackPhase[i].canBeBlocked = false
	slashOverheadAttackPhase[i].canDamage = false
	slashOverheadAttackPhase[i].attackDamage = 0
	slashOverheadAttackPhase[i].attackStunChance = 0
	slashOverheadAttackPhase[i].attackRange = 0
	slashOverheadAttackPhase[i].attackPush = 0
	slashOverheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	slashOverheadAttackPhase[i].frameStart = 0
	slashOverheadAttackPhase[i].frameEnd = 0
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
	
	slashOverheadAttackPhase[i].frameStart = 0
	slashOverheadAttackPhase[i].frameEnd = 4
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
	
	slashOverheadAttackPhase[i].frameStart = 4
	slashOverheadAttackPhase[i].frameEnd = 0
	slashOverheadAttackPhase[i].angleStart = -50
	slashOverheadAttackPhase[i].angleEnd = 25
	slashOverheadAttackPhase[i].offsetStart = Vector(10, 15)
	slashOverheadAttackPhase[i].offsetEnd = Vector(3, -5)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[2] = regularAttackSounds
	self.attackAnimationsGFX[2] = regularAttackGFX
	self.attackAnimations[2] = slashOverheadAttackPhase
	self.attackAnimationsTypes[2] = slashOverheadAttackPhase.Type
	
	-- (stab)
	stabLaunchAttackPhase = {}
	stabLaunchAttackPhase.Type = "Stab";
	
	-- Prepare
	i = 1
	stabLaunchAttackPhase[i] = {}
	stabLaunchAttackPhase[i].durationMS = 300
	
	stabLaunchAttackPhase[i].canBeBlocked = false
	stabLaunchAttackPhase[i].canDamage = false
	stabLaunchAttackPhase[i].attackDamage = 1
	stabLaunchAttackPhase[i].attackStunChance = 0.6
	stabLaunchAttackPhase[i].furthestReach = 10
	stabLaunchAttackPhase[i].attackRange = 25
	self:SetNumberValue("Attack 3 Range", stabLaunchAttackPhase[i].furthestReach + stabLaunchAttackPhase[i].attackRange)
	self:SetStringValue("Attack 3 Name", "Stab");
	stabLaunchAttackPhase[i].attackPush = 1.3
	stabLaunchAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	stabLaunchAttackPhase[i].attackAngle = -45;
	
	stabLaunchAttackPhase[i].frameStart = 0
	stabLaunchAttackPhase[i].frameEnd = 3
	stabLaunchAttackPhase[i].angleStart = 25
	stabLaunchAttackPhase[i].angleEnd = -40
	stabLaunchAttackPhase[i].offsetStart = Vector(0, 0)
	stabLaunchAttackPhase[i].offsetEnd = Vector(-2, 15)
	
	stabLaunchAttackPhase[i].soundStart = nil
	stabLaunchAttackPhase[i].soundStartVariations = 0
	
	stabLaunchAttackPhase[i].soundEnd = nil
	stabLaunchAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	stabLaunchAttackPhase[i] = {}
	stabLaunchAttackPhase[i].durationMS = 200
	
	stabLaunchAttackPhase[i].lastPrepare = true
	stabLaunchAttackPhase[i].canBeBlocked = false
	stabLaunchAttackPhase[i].canDamage = false
	stabLaunchAttackPhase[i].attackDamage = 1
	stabLaunchAttackPhase[i].attackStunChance = 0.6
	stabLaunchAttackPhase[i].attackRange = 25
	stabLaunchAttackPhase[i].attackPush = 1.3
	stabLaunchAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	stabLaunchAttackPhase[i].attackAngle = -45;
	
	stabLaunchAttackPhase[i].frameStart = 3
	stabLaunchAttackPhase[i].frameEnd = 0
	stabLaunchAttackPhase[i].angleStart = -40
	stabLaunchAttackPhase[i].angleEnd = -60
	stabLaunchAttackPhase[i].offsetStart = Vector(-2, 15)
	stabLaunchAttackPhase[i].offsetEnd = Vector(-15, 15)
	
	stabLaunchAttackPhase[i].soundStart = nil
	stabLaunchAttackPhase[i].soundStartVariations = 0
	
	stabLaunchAttackPhase[i].soundEnd = nil
	stabLaunchAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	stabLaunchAttackPhase[i] = {}
	stabLaunchAttackPhase[i].durationMS = 70
	
	stabLaunchAttackPhase[i].canBeBlocked = true
	stabLaunchAttackPhase[i].canDamage = false
	stabLaunchAttackPhase[i].attackDamage = 1
	stabLaunchAttackPhase[i].attackStunChance = 0.6
	stabLaunchAttackPhase[i].attackRange = 25
	stabLaunchAttackPhase[i].attackPush = 1.3
	stabLaunchAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	stabLaunchAttackPhase[i].attackAngle = 73;
	
	stabLaunchAttackPhase[i].frameStart = 0
	stabLaunchAttackPhase[i].frameEnd = 0
	stabLaunchAttackPhase[i].angleStart = -60
	stabLaunchAttackPhase[i].angleEnd = -60
	stabLaunchAttackPhase[i].offsetStart = Vector(-15, 15)
	stabLaunchAttackPhase[i].offsetEnd = Vector(-6, 12)
	
	stabLaunchAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	stabLaunchAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	stabLaunchAttackPhase[i] = {}
	stabLaunchAttackPhase[i].durationMS = 35
	
	stabLaunchAttackPhase[i].canBeBlocked = true
	stabLaunchAttackPhase[i].canDamage = false
	stabLaunchAttackPhase[i].attackDamage = 1
	stabLaunchAttackPhase[i].attackStunChance = 0.6
	stabLaunchAttackPhase[i].attackRange = 25
	stabLaunchAttackPhase[i].attackPush = 1.3
	stabLaunchAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	stabLaunchAttackPhase[i].attackAngle = 73;
	
	stabLaunchAttackPhase[i].frameStart = 0
	stabLaunchAttackPhase[i].frameEnd = 0
	stabLaunchAttackPhase[i].angleStart = -60
	stabLaunchAttackPhase[i].angleEnd = -55
	stabLaunchAttackPhase[i].offsetStart = Vector(-6, 12)
	stabLaunchAttackPhase[i].offsetEnd = Vector(7, 6)
	
	stabLaunchAttackPhase[i].soundStart = nil
	
	stabLaunchAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	stabLaunchAttackPhase[i] = {}
	stabLaunchAttackPhase[i].durationMS = 100
	
	stabLaunchAttackPhase[i].canBeBlocked = true
	stabLaunchAttackPhase[i].canDamage = true
	stabLaunchAttackPhase[i].attackDamage = 4
	stabLaunchAttackPhase[i].attackStunChance = 0.8
	stabLaunchAttackPhase[i].attackRange = 25
	stabLaunchAttackPhase[i].attackPush = 1.5
	stabLaunchAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	stabLaunchAttackPhase[i].attackAngle = 73;
	
	stabLaunchAttackPhase[i].frameStart = 0
	stabLaunchAttackPhase[i].frameEnd = 0
	stabLaunchAttackPhase[i].angleStart = -55
	stabLaunchAttackPhase[i].angleEnd = -55
	stabLaunchAttackPhase[i].offsetStart = Vector(7 , 6)
	stabLaunchAttackPhase[i].offsetEnd = Vector(15, -2)
	
	stabLaunchAttackPhase[i].soundStart = nil
	
	stabLaunchAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	stabLaunchAttackPhase[i] = {}
	stabLaunchAttackPhase[i].durationMS = 400
	
	stabLaunchAttackPhase[i].firstRecovery = true
	stabLaunchAttackPhase[i].canBeBlocked = false
	stabLaunchAttackPhase[i].canDamage = false
	stabLaunchAttackPhase[i].attackDamage = 1
	stabLaunchAttackPhase[i].attackStunChance = 0.6
	stabLaunchAttackPhase[i].attackRange = 15
	stabLaunchAttackPhase[i].attackPush = 1.3
	stabLaunchAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	stabLaunchAttackPhase[i].attackAngle = -45;
	
	stabLaunchAttackPhase[i].frameStart = 0
	stabLaunchAttackPhase[i].frameEnd = 1
	stabLaunchAttackPhase[i].angleStart = -55
	stabLaunchAttackPhase[i].angleEnd = -50
	stabLaunchAttackPhase[i].offsetStart = Vector(15, -2)
	stabLaunchAttackPhase[i].offsetEnd = Vector(7, -3)
	
	stabLaunchAttackPhase[i].soundStart = nil
	stabLaunchAttackPhase[i].soundStartVariations = 0
	
	stabLaunchAttackPhase[i].soundEnd = nil
	stabLaunchAttackPhase[i].soundEndVariations = 0
	
	-- Recover
	i = 7
	stabLaunchAttackPhase[i] = {}
	stabLaunchAttackPhase[i].durationMS = 350
	
	stabLaunchAttackPhase[i].canBeBlocked = false
	stabLaunchAttackPhase[i].canDamage = false
	stabLaunchAttackPhase[i].attackDamage = 1
	stabLaunchAttackPhase[i].attackStunChance = 0.6
	stabLaunchAttackPhase[i].attackRange = 15
	stabLaunchAttackPhase[i].attackPush = 1.3
	stabLaunchAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	stabLaunchAttackPhase[i].attackAngle = -45;
	
	stabLaunchAttackPhase[i].frameStart = 1
	stabLaunchAttackPhase[i].frameEnd = 0
	stabLaunchAttackPhase[i].angleStart = -50
	stabLaunchAttackPhase[i].angleEnd = 25
	stabLaunchAttackPhase[i].offsetStart = Vector(7, -3)
	stabLaunchAttackPhase[i].offsetEnd = Vector(3, 0)
	
	stabLaunchAttackPhase[i].soundStart = nil
	stabLaunchAttackPhase[i].soundStartVariations = 0
	
	stabLaunchAttackPhase[i].soundEnd = nil
	stabLaunchAttackPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[3] = stabAttackSounds
	self.attackAnimationsGFX[3] = regularAttackGFX
	self.attackAnimations[3] = stabLaunchAttackPhase
	self.attackAnimationsTypes[3] = stabLaunchAttackPhase.Type
	
	-- (stab)
	getOverHereAttackPhase = {}
	getOverHereAttackPhase.Type = "Stab";
	
	-- Prepare
	i = 1
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 500
	
	getOverHereAttackPhase[i].canBeBlocked = false
	getOverHereAttackPhase[i].canDamage = false
	getOverHereAttackPhase[i].attackDamage = 0
	getOverHereAttackPhase[i].attackStunChance = 0
	getOverHereAttackPhase[i].attackRange = 0
	getOverHereAttackPhase[i].attackPush = 0
	getOverHereAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = 90;
	
	getOverHereAttackPhase[i].frameStart = 12
	getOverHereAttackPhase[i].frameEnd = 11
	getOverHereAttackPhase[i].angleStart = 25
	getOverHereAttackPhase[i].angleEnd = -80
	getOverHereAttackPhase[i].offsetStart = Vector(0, 0)
	getOverHereAttackPhase[i].offsetEnd = Vector(-6, -5)
	
	getOverHereAttackPhase[i].soundStart = nil
	getOverHereAttackPhase[i].soundStartVariations = 0
	
	getOverHereAttackPhase[i].soundEnd = nil
	getOverHereAttackPhase[i].soundEndVariations = 0
	
	-- Late Prepare
	i = 2
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 200
	
	getOverHereAttackPhase[i].lastPrepare = true
	getOverHereAttackPhase[i].canBeBlocked = false
	getOverHereAttackPhase[i].canDamage = false
	getOverHereAttackPhase[i].attackDamage = 0
	getOverHereAttackPhase[i].attackStunChance = 0
	getOverHereAttackPhase[i].attackRange = 0
	getOverHereAttackPhase[i].attackPush = 0
	getOverHereAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = 90;
	
	getOverHereAttackPhase[i].frameStart = 11
	getOverHereAttackPhase[i].frameEnd = 11
	getOverHereAttackPhase[i].angleStart = -80
	getOverHereAttackPhase[i].angleEnd = -90
	getOverHereAttackPhase[i].offsetStart = Vector(-6, -5)
	getOverHereAttackPhase[i].offsetEnd = Vector(-15, -9)
	
	getOverHereAttackPhase[i].soundStart = nil
	getOverHereAttackPhase[i].soundStartVariations = 0
	
	getOverHereAttackPhase[i].soundEnd = nil
	getOverHereAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 3
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 70
	
	getOverHereAttackPhase[i].canBeBlocked = true
	getOverHereAttackPhase[i].canDamage = false
	getOverHereAttackPhase[i].attackDamage = 1
	getOverHereAttackPhase[i].attackStunChance = 0.6
	getOverHereAttackPhase[i].attackRange = 25
	getOverHereAttackPhase[i].attackPush = 1.3
	getOverHereAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = 90;
	
	getOverHereAttackPhase[i].frameStart = 11
	getOverHereAttackPhase[i].frameEnd = 11
	getOverHereAttackPhase[i].angleStart = -90
	getOverHereAttackPhase[i].angleEnd = -90
	getOverHereAttackPhase[i].offsetStart = Vector(-15, -9)
	getOverHereAttackPhase[i].offsetEnd = Vector(-5, -9)
	
	getOverHereAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	getOverHereAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 4
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 35
	
	getOverHereAttackPhase[i].canBeBlocked = true
	getOverHereAttackPhase[i].canDamage = false
	getOverHereAttackPhase[i].attackDamage = 1
	getOverHereAttackPhase[i].attackStunChance = 0.6
	getOverHereAttackPhase[i].attackRange = 25
	getOverHereAttackPhase[i].attackPush = 1.3
	getOverHereAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = 90;
	
	getOverHereAttackPhase[i].frameStart = 11
	getOverHereAttackPhase[i].frameEnd = 11
	getOverHereAttackPhase[i].angleStart = -90
	getOverHereAttackPhase[i].angleEnd = -90
	getOverHereAttackPhase[i].offsetStart = Vector(-5, -9)
	getOverHereAttackPhase[i].offsetEnd = Vector(5, -9)
	
	getOverHereAttackPhase[i].soundStart = nil
	
	getOverHereAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 5
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 100
	
	getOverHereAttackPhase[i].canBeBlocked = true
	getOverHereAttackPhase[i].canDamage = true
	getOverHereAttackPhase[i].attackDamage = 6
	getOverHereAttackPhase[i].attackStunChance = 1.0
	getOverHereAttackPhase[i].attackRange = 25
	getOverHereAttackPhase[i].attackPush = 1.3
	getOverHereAttackPhase[i].attackVector = Vector(0, 7) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = 90;
	
	getOverHereAttackPhase[i].frameStart = 11
	getOverHereAttackPhase[i].frameEnd = 11
	getOverHereAttackPhase[i].angleStart = -90
	getOverHereAttackPhase[i].angleEnd = -90
	getOverHereAttackPhase[i].offsetStart = Vector(5 , -9)
	getOverHereAttackPhase[i].offsetEnd = Vector(15, -7)
	
	getOverHereAttackPhase[i].soundStart = nil
	
	getOverHereAttackPhase[i].soundEnd = nil
	
	-- Early Recover
	i = 6
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 300
	
	getOverHereAttackPhase[i].firstRecovery = true
	getOverHereAttackPhase[i].canBeBlocked = false
	getOverHereAttackPhase[i].canDamage = false
	getOverHereAttackPhase[i].attackDamage = 0
	getOverHereAttackPhase[i].attackStunChance = 0
	getOverHereAttackPhase[i].attackRange = 0
	getOverHereAttackPhase[i].attackPush = 0
	getOverHereAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = 90;
	
	getOverHereAttackPhase[i].frameStart = 11
	getOverHereAttackPhase[i].frameEnd = 11
	getOverHereAttackPhase[i].angleStart = -90
	getOverHereAttackPhase[i].angleEnd = -90
	getOverHereAttackPhase[i].offsetStart = Vector(15, -7)
	getOverHereAttackPhase[i].offsetEnd = Vector(16, -6)
	
	getOverHereAttackPhase[i].soundStart = nil
	getOverHereAttackPhase[i].soundStartVariations = 0
	
	getOverHereAttackPhase[i].soundEnd = nil
	getOverHereAttackPhase[i].soundEndVariations = 0
	
	-- Recover Prepare
	i = 7
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 200
	
	getOverHereAttackPhase[i].attackReset = true
	getOverHereAttackPhase[i].lastPrepare = true
	getOverHereAttackPhase[i].canBeBlocked = false
	getOverHereAttackPhase[i].canDamage = false
	getOverHereAttackPhase[i].attackDamage = 0
	getOverHereAttackPhase[i].attackStunChance = 0
	getOverHereAttackPhase[i].attackRange = 0
	getOverHereAttackPhase[i].attackPush = 0
	getOverHereAttackPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = 90;
	
	getOverHereAttackPhase[i].frameStart = 11
	getOverHereAttackPhase[i].frameEnd = 11
	getOverHereAttackPhase[i].angleStart = -90
	getOverHereAttackPhase[i].angleEnd = -90
	getOverHereAttackPhase[i].offsetStart = Vector(16, -6)
	getOverHereAttackPhase[i].offsetEnd = Vector(16, -7)
	
	getOverHereAttackPhase[i].soundStart = nil
	getOverHereAttackPhase[i].soundStartVariations = 0
	
	getOverHereAttackPhase[i].soundEnd = nil
	getOverHereAttackPhase[i].soundEndVariations = 0
	
	-- Early Early Attack
	i = 8
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 70
	
	getOverHereAttackPhase[i].canBeBlocked = true
	getOverHereAttackPhase[i].canDamage = false
	getOverHereAttackPhase[i].attackDamage = 1
	getOverHereAttackPhase[i].attackStunChance = 1.0
	getOverHereAttackPhase[i].attackRange = 10
	getOverHereAttackPhase[i].attackPush = 1.3
	getOverHereAttackPhase[i].attackVector = Vector(0, -19) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = -90;
	
	getOverHereAttackPhase[i].frameStart = 11
	getOverHereAttackPhase[i].frameEnd = 11
	getOverHereAttackPhase[i].angleStart = -90
	getOverHereAttackPhase[i].angleEnd = -90
	getOverHereAttackPhase[i].offsetStart = Vector(16, -7)
	getOverHereAttackPhase[i].offsetEnd = Vector(10, -6)
	
	getOverHereAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	getOverHereAttackPhase[i].soundEnd = nil
	
	-- Early Attack
	i = 9
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 35
	
	getOverHereAttackPhase[i].canBeBlocked = true
	getOverHereAttackPhase[i].canDamage = false
	getOverHereAttackPhase[i].attackDamage = 1
	getOverHereAttackPhase[i].attackStunChance = 1.0
	getOverHereAttackPhase[i].attackRange = 10
	getOverHereAttackPhase[i].attackPush = 1.3
	getOverHereAttackPhase[i].attackVector = Vector(0, -19) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = -90;
	
	getOverHereAttackPhase[i].frameStart = 11
	getOverHereAttackPhase[i].frameEnd = 11
	getOverHereAttackPhase[i].angleStart = -90
	getOverHereAttackPhase[i].angleEnd = -90
	getOverHereAttackPhase[i].offsetStart = Vector(10, -6)
	getOverHereAttackPhase[i].offsetEnd = Vector(0, -6)
	
	-- Attack
	i = 10
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 150
	
	getOverHereAttackPhase[i].canBeBlocked = true
	getOverHereAttackPhase[i].canDamage = true
	getOverHereAttackPhase[i].attackDamage = 6
	getOverHereAttackPhase[i].attackStunChance = 1.0
	getOverHereAttackPhase[i].attackRange = 10
	getOverHereAttackPhase[i].attackPush = 1.3
	getOverHereAttackPhase[i].attackVector = Vector(0, -19) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = -90;
	
	getOverHereAttackPhase[i].frameStart = 11
	getOverHereAttackPhase[i].frameEnd = 11
	getOverHereAttackPhase[i].angleStart = -90
	getOverHereAttackPhase[i].angleEnd = -90
	getOverHereAttackPhase[i].offsetStart = Vector(10, -6)
	getOverHereAttackPhase[i].offsetEnd = Vector(-15, -6)
	
	-- Early Recover
	i = 11
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 400
	
	getOverHereAttackPhase[i].firstRecovery = true
	getOverHereAttackPhase[i].canBeBlocked = false
	getOverHereAttackPhase[i].canDamage = false
	getOverHereAttackPhase[i].attackDamage = 1
	getOverHereAttackPhase[i].attackStunChance = 1.0
	getOverHereAttackPhase[i].attackRange = 10
	getOverHereAttackPhase[i].attackPush = 1.3
	getOverHereAttackPhase[i].attackVector = Vector(0, -19) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = -90;
	
	getOverHereAttackPhase[i].frameStart = 12
	getOverHereAttackPhase[i].frameEnd = 12
	getOverHereAttackPhase[i].angleStart = -90
	getOverHereAttackPhase[i].angleEnd = -85
	getOverHereAttackPhase[i].offsetStart = Vector(-15, -6)
	getOverHereAttackPhase[i].offsetEnd = Vector(-16, -8)
	
	-- Recover
	i = 12
	getOverHereAttackPhase[i] = {}
	getOverHereAttackPhase[i].durationMS = 500
	
	getOverHereAttackPhase[i].canBeBlocked = false
	getOverHereAttackPhase[i].canDamage = false
	getOverHereAttackPhase[i].attackDamage = 1
	getOverHereAttackPhase[i].attackStunChance = 1.0
	getOverHereAttackPhase[i].attackRange = 10
	getOverHereAttackPhase[i].attackPush = 1.3
	getOverHereAttackPhase[i].attackVector = Vector(0, -19) -- local space vector relative to position and rotation
	getOverHereAttackPhase[i].attackAngle = -90;
	
	getOverHereAttackPhase[i].frameStart = 0
	getOverHereAttackPhase[i].frameEnd = 0
	getOverHereAttackPhase[i].angleStart = -90
	getOverHereAttackPhase[i].angleEnd = 25
	getOverHereAttackPhase[i].offsetStart = Vector(-16, -8)
	getOverHereAttackPhase[i].offsetEnd = Vector(0, 0)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[4] = stabAttackSounds
	self.attackAnimationsGFX[4] = regularAttackGFX
	self.attackAnimations[4] = getOverHereAttackPhase
	self.attackAnimationsTypes[4] = getOverHereAttackPhase.Type	
	
	-- insane shit

	underhandComboAttackPhase = {}
	underhandComboAttackPhase.Type = "Slash";
	
	-- Prepare
	
	i = 1
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 330

	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 8
	underhandComboAttackPhase[i].attackStunChance = 1.0
	underhandComboAttackPhase[i].furthestReach = 12
	underhandComboAttackPhase[i].attackRange = 25
	self:SetNumberValue("Attack 4 Range", underhandComboAttackPhase[i].furthestReach + underhandComboAttackPhase[i].attackRange)
	self:SetStringValue("Attack 4 Name", "Overhead");
	underhandComboAttackPhase[i].attackPush = 0.6
	underhandComboAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 55;
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 2
	underhandComboAttackPhase[i].angleStart = 25
	underhandComboAttackPhase[i].angleEnd = 85
	underhandComboAttackPhase[i].offsetStart = Vector(0, 0)
	underhandComboAttackPhase[i].offsetEnd = Vector(-10, -15)
	
	-- Late Prepare
	
	i = 2
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 330
	
	underhandComboAttackPhase[i].lastPrepare = true
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 8
	underhandComboAttackPhase[i].attackStunChance = 1.0
	underhandComboAttackPhase[i].attackRange = 25
	underhandComboAttackPhase[i].attackPush = 0.6
	underhandComboAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 55;
	
	underhandComboAttackPhase[i].frameStart = 2
	underhandComboAttackPhase[i].frameEnd = 1
	underhandComboAttackPhase[i].angleStart = 85
	underhandComboAttackPhase[i].angleEnd = 90
	underhandComboAttackPhase[i].offsetStart = Vector(-10, -15)
	underhandComboAttackPhase[i].offsetEnd = Vector(-11, -15)
	
	-- Late Prepare Attack
	i = 3
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 350
	
	underhandComboAttackPhase[i].ignoreTerrain = true
	underhandComboAttackPhase[i].canBeBlocked = true
	underhandComboAttackPhase[i].canDamage = true
	underhandComboAttackPhase[i].attackDamage = 8
	underhandComboAttackPhase[i].attackStunChance = 1.0
	underhandComboAttackPhase[i].attackRange = 25
	underhandComboAttackPhase[i].attackPush = 0.6
	underhandComboAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 55;
	
	underhandComboAttackPhase[i].frameStart = 1
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = 90
	underhandComboAttackPhase[i].angleEnd = -125
	underhandComboAttackPhase[i].offsetStart = Vector(-11, -15)
	underhandComboAttackPhase[i].offsetEnd = Vector(2, 11)
	
	underhandComboAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	underhandComboAttackPhase[i].soundEnd = nil
	underhandComboAttackPhase[i].soundEndVariations = 0
	
	-- Late Late Prepare Not Attack
	i = 4
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 350
	
	underhandComboAttackPhase[i].attackReset = true
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 8
	underhandComboAttackPhase[i].attackStunChance = 1.0
	underhandComboAttackPhase[i].attackRange = 25
	underhandComboAttackPhase[i].attackPush = 0.6
	underhandComboAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 55;
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = -125
	underhandComboAttackPhase[i].angleEnd = -130
	underhandComboAttackPhase[i].offsetStart = Vector(2, 11)
	underhandComboAttackPhase[i].offsetEnd = Vector(2, 15)
	
	underhandComboAttackPhase[i].soundEnd = nil
	underhandComboAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 5
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 70
	
	underhandComboAttackPhase[i].canBeBlocked = true
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 5
	underhandComboAttackPhase[i].attackStunChance = 0.3
	underhandComboAttackPhase[i].attackRange = 25
	underhandComboAttackPhase[i].attackPush = 0.8
	underhandComboAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 110;
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = -130
	underhandComboAttackPhase[i].angleEnd = -125
	underhandComboAttackPhase[i].offsetStart = Vector(2, 15)
	underhandComboAttackPhase[i].offsetEnd = Vector(3, 10)
	
	underhandComboAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	underhandComboAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 6
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 259
	
	underhandComboAttackPhase[i].attackReset = true
	underhandComboAttackPhase[i].ignoreTerrain = true
	underhandComboAttackPhase[i].canBeBlocked = true
	underhandComboAttackPhase[i].canDamage = true
	underhandComboAttackPhase[i].attackDamage = 8
	underhandComboAttackPhase[i].attackStunChance = 0.8
	underhandComboAttackPhase[i].attackRange = 25
	underhandComboAttackPhase[i].attackPush = 1.2
	underhandComboAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 110;
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = -125
	underhandComboAttackPhase[i].angleEnd = 25
	underhandComboAttackPhase[i].offsetStart = Vector(3, 10)
	underhandComboAttackPhase[i].offsetEnd = Vector(10, -15)
	
	-- Early Recover
	i = 7
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 100
	
	underhandComboAttackPhase[i].firstRecovery = true	
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = 25
	underhandComboAttackPhase[i].angleEnd = 70
	underhandComboAttackPhase[i].offsetStart = Vector(10, -15)
	underhandComboAttackPhase[i].offsetEnd = Vector(11, -15)
	
	-- Recover
	i = 8
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 350
	
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = 70
	underhandComboAttackPhase[i].angleEnd = 70
	underhandComboAttackPhase[i].offsetStart = Vector(11, -15)
	underhandComboAttackPhase[i].offsetEnd = Vector(2, -13)
	
	-- Prepare
	i = 9
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
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = 70
	underhandComboAttackPhase[i].angleEnd = 80
	underhandComboAttackPhase[i].offsetStart = Vector(2, -13)
	underhandComboAttackPhase[i].offsetEnd = Vector(-4,-15)
	
	-- Late Prepare
	i = 10
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
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = 80
	underhandComboAttackPhase[i].angleEnd = 80
	underhandComboAttackPhase[i].offsetStart = Vector(-4, -15)
	underhandComboAttackPhase[i].offsetEnd = Vector(-4, -15)
	
	underhandComboAttackPhase[i].soundStart = nil
	underhandComboAttackPhase[i].soundStartVariations = 0
	
	underhandComboAttackPhase[i].soundEnd = nil
	underhandComboAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 11
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 70
	
	underhandComboAttackPhase[i].canBeBlocked = true
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 5
	underhandComboAttackPhase[i].attackStunChance = 0.3
	underhandComboAttackPhase[i].attackRange = 25
	underhandComboAttackPhase[i].attackPush = 0.8
	underhandComboAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 55;
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = 80
	underhandComboAttackPhase[i].angleEnd = 20
	underhandComboAttackPhase[i].offsetStart = Vector(0, -15)
	underhandComboAttackPhase[i].offsetEnd = Vector(3, -10)
	
	underhandComboAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	underhandComboAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 12
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 170
	
	underhandComboAttackPhase[i].canBeBlocked = true
	underhandComboAttackPhase[i].canDamage = true
	underhandComboAttackPhase[i].attackDamage = 16
	underhandComboAttackPhase[i].attackStunChance = 0.5
	underhandComboAttackPhase[i].attackRange = 25
	underhandComboAttackPhase[i].attackPush = 1.1
	underhandComboAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	underhandComboAttackPhase[i].attackAngle = 55;
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = 20
	underhandComboAttackPhase[i].angleEnd = -190
	underhandComboAttackPhase[i].offsetStart = Vector(3, -10)
	underhandComboAttackPhase[i].offsetEnd = Vector(15, 15)
	
	-- Early Recover
	i = 13
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 100
	
	underhandComboAttackPhase[i].firstRecovery = true	
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = -120
	underhandComboAttackPhase[i].angleEnd = -125
	underhandComboAttackPhase[i].offsetStart = Vector(15, 15)
	underhandComboAttackPhase[i].offsetEnd = Vector(10, 15)
	
	-- Recover
	i = 14
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 350
	
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 0
	underhandComboAttackPhase[i].frameEnd = 4
	underhandComboAttackPhase[i].angleStart = -125
	underhandComboAttackPhase[i].angleEnd = -50
	underhandComboAttackPhase[i].offsetStart = Vector(10, 15)
	underhandComboAttackPhase[i].offsetEnd = Vector(3, -5)
	
	-- Late Recover
	i = 15
	underhandComboAttackPhase[i] = {}
	underhandComboAttackPhase[i].durationMS = 350
	
	underhandComboAttackPhase[i].canBeBlocked = false
	underhandComboAttackPhase[i].canDamage = false
	underhandComboAttackPhase[i].attackDamage = 0
	underhandComboAttackPhase[i].attackStunChance = 0
	underhandComboAttackPhase[i].attackRange = 0
	underhandComboAttackPhase[i].attackPush = 0
	underhandComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	underhandComboAttackPhase[i].frameStart = 4
	underhandComboAttackPhase[i].frameEnd = 0
	underhandComboAttackPhase[i].angleStart = -50
	underhandComboAttackPhase[i].angleEnd = 25
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
	
	-- insane shit

	horseComboAttackPhase = {}
	horseComboAttackPhase.Type = "Slash";
	
	-- Prepare
	
	i = 1
	horseComboAttackPhase[i] = {}
	horseComboAttackPhase[i].durationMS = 330

	horseComboAttackPhase[i].canBeBlocked = false
	horseComboAttackPhase[i].canDamage = false
	horseComboAttackPhase[i].attackDamage = 8
	horseComboAttackPhase[i].attackStunChance = 1.0
	horseComboAttackPhase[i].furthestReach = 10
	horseComboAttackPhase[i].attackRange = 23
	self:SetNumberValue("Attack 2 Range", horseComboAttackPhase[i].furthestReach + horseComboAttackPhase[i].attackRange)
	self:SetStringValue("Attack 2 Name", "Horse Swing");
	horseComboAttackPhase[i].attackPush = 0.6
	horseComboAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	horseComboAttackPhase[i].attackAngle = 55;
	
	horseComboAttackPhase[i].frameStart = 0
	horseComboAttackPhase[i].frameEnd = 2
	horseComboAttackPhase[i].angleStart = 25
	horseComboAttackPhase[i].angleEnd = 25
	horseComboAttackPhase[i].offsetStart = Vector(0, 0)
	horseComboAttackPhase[i].offsetEnd = Vector(2, -6)
	
	-- Late Prepare
	
	i = 2
	horseComboAttackPhase[i] = {}
	horseComboAttackPhase[i].durationMS = 330
	
	horseComboAttackPhase[i].lastPrepare = true
	horseComboAttackPhase[i].canBeBlocked = false
	horseComboAttackPhase[i].canDamage = false
	horseComboAttackPhase[i].attackDamage = 8
	horseComboAttackPhase[i].attackStunChance = 1.0
	horseComboAttackPhase[i].attackRange = 14
	horseComboAttackPhase[i].attackPush = 0.6
	horseComboAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	horseComboAttackPhase[i].attackAngle = 55;
	
	horseComboAttackPhase[i].frameStart = 2
	horseComboAttackPhase[i].frameEnd = 0
	horseComboAttackPhase[i].angleStart = 25
	horseComboAttackPhase[i].angleEnd = 15
	horseComboAttackPhase[i].offsetStart = Vector(2, -6)
	horseComboAttackPhase[i].offsetEnd = Vector(6, -8)
	
	-- Late Prepare Attack
	i = 3
	horseComboAttackPhase[i] = {}
	horseComboAttackPhase[i].durationMS = 350
	
	horseComboAttackPhase[i].ignoreTerrain = true
	horseComboAttackPhase[i].canBeBlocked = true
	horseComboAttackPhase[i].canDamage = true
	horseComboAttackPhase[i].attackDamage = 8
	horseComboAttackPhase[i].attackStunChance = 1.0
	horseComboAttackPhase[i].attackRange = 23
	horseComboAttackPhase[i].attackPush = 0.6
	horseComboAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	horseComboAttackPhase[i].attackAngle = 55;
	
	horseComboAttackPhase[i].frameStart = 0
	horseComboAttackPhase[i].frameEnd = 0
	horseComboAttackPhase[i].angleStart = 15
	horseComboAttackPhase[i].angleEnd = -240
	horseComboAttackPhase[i].offsetStart = Vector(6, -8)
	horseComboAttackPhase[i].offsetEnd = Vector(-15, 11)
	
	horseComboAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	horseComboAttackPhase[i].soundEnd = nil
	horseComboAttackPhase[i].soundEndVariations = 0
	
	-- Late Late Prepare Not Attack
	i = 4
	horseComboAttackPhase[i] = {}
	horseComboAttackPhase[i].durationMS = 350
	
	horseComboAttackPhase[i].attackReset = true
	horseComboAttackPhase[i].canBeBlocked = false
	horseComboAttackPhase[i].canDamage = false
	horseComboAttackPhase[i].attackDamage = 8
	horseComboAttackPhase[i].attackStunChance = 1.0
	horseComboAttackPhase[i].attackRange = 23
	horseComboAttackPhase[i].attackPush = 0.6
	horseComboAttackPhase[i].attackVector = Vector(0, 0) -- local space vector relative to position and rotation
	horseComboAttackPhase[i].attackAngle = 55;
	
	horseComboAttackPhase[i].frameStart = 0
	horseComboAttackPhase[i].frameEnd = 0
	horseComboAttackPhase[i].angleStart = -240
	horseComboAttackPhase[i].angleEnd = -280
	horseComboAttackPhase[i].offsetStart = Vector(-15, 11)
	horseComboAttackPhase[i].offsetEnd = Vector(-16, 15)
	
	horseComboAttackPhase[i].soundEnd = nil
	horseComboAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 5
	horseComboAttackPhase[i] = {}
	horseComboAttackPhase[i].durationMS = 70
	
	horseComboAttackPhase[i].canBeBlocked = true
	horseComboAttackPhase[i].canDamage = false
	horseComboAttackPhase[i].attackDamage = 5
	horseComboAttackPhase[i].attackStunChance = 0.3
	horseComboAttackPhase[i].attackRange = 23
	horseComboAttackPhase[i].attackPush = 0.8
	horseComboAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	horseComboAttackPhase[i].attackAngle = 125;
	
	horseComboAttackPhase[i].frameStart = 0
	horseComboAttackPhase[i].frameEnd = 0
	horseComboAttackPhase[i].angleStart = -280
	horseComboAttackPhase[i].angleEnd = -240
	horseComboAttackPhase[i].offsetStart = Vector(-15, 15)
	horseComboAttackPhase[i].offsetEnd = Vector(-12, 14)
	
	horseComboAttackPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	horseComboAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 6
	horseComboAttackPhase[i] = {}
	horseComboAttackPhase[i].durationMS = 259
	
	horseComboAttackPhase[i].attackReset = true
	horseComboAttackPhase[i].ignoreTerrain = true
	horseComboAttackPhase[i].canBeBlocked = true
	horseComboAttackPhase[i].canDamage = true
	horseComboAttackPhase[i].attackDamage = 8
	horseComboAttackPhase[i].attackStunChance = 0.8
	horseComboAttackPhase[i].attackRange = 23
	horseComboAttackPhase[i].attackPush = 1.2
	horseComboAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	horseComboAttackPhase[i].attackAngle = 125;
	
	horseComboAttackPhase[i].frameStart = 0
	horseComboAttackPhase[i].frameEnd = 0
	horseComboAttackPhase[i].angleStart = -240
	horseComboAttackPhase[i].angleEnd = -90
	horseComboAttackPhase[i].offsetStart = Vector(-12, 14)
	horseComboAttackPhase[i].offsetEnd = Vector(0, 12)
	
	-- Early Recover
	i = 7
	horseComboAttackPhase[i] = {}
	horseComboAttackPhase[i].durationMS = 100
	
	horseComboAttackPhase[i].firstRecovery = true	
	horseComboAttackPhase[i].canBeBlocked = false
	horseComboAttackPhase[i].canDamage = false
	horseComboAttackPhase[i].attackDamage = 0
	horseComboAttackPhase[i].attackStunChance = 0
	horseComboAttackPhase[i].attackRange = 0
	horseComboAttackPhase[i].attackPush = 0
	horseComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	horseComboAttackPhase[i].frameStart = 0
	horseComboAttackPhase[i].frameEnd = 0
	horseComboAttackPhase[i].angleStart = -90
	horseComboAttackPhase[i].angleEnd = -45
	horseComboAttackPhase[i].offsetStart = Vector(0, 12)
	horseComboAttackPhase[i].offsetEnd = Vector(15, 0)
	
	-- Recover
	i = 8
	horseComboAttackPhase[i] = {}
	horseComboAttackPhase[i].durationMS = 350
	
	horseComboAttackPhase[i].canBeBlocked = false
	horseComboAttackPhase[i].canDamage = false
	horseComboAttackPhase[i].attackDamage = 0
	horseComboAttackPhase[i].attackStunChance = 0
	horseComboAttackPhase[i].attackRange = 0
	horseComboAttackPhase[i].attackPush = 0
	horseComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	horseComboAttackPhase[i].frameStart = 0
	horseComboAttackPhase[i].frameEnd = 0
	horseComboAttackPhase[i].angleStart = -45
	horseComboAttackPhase[i].angleEnd = 40
	horseComboAttackPhase[i].offsetStart = Vector(15, 0)
	horseComboAttackPhase[i].offsetEnd = Vector(13, -7)
	
	-- Recover
	i = 9
	horseComboAttackPhase[i] = {}
	horseComboAttackPhase[i].durationMS = 250
	
	horseComboAttackPhase[i].canBeBlocked = false
	horseComboAttackPhase[i].canDamage = false
	horseComboAttackPhase[i].attackDamage = 0
	horseComboAttackPhase[i].attackStunChance = 0
	horseComboAttackPhase[i].attackRange = 0
	horseComboAttackPhase[i].attackPush = 0
	horseComboAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	horseComboAttackPhase[i].frameStart = 0
	horseComboAttackPhase[i].frameEnd = 0
	horseComboAttackPhase[i].angleStart = 40
	horseComboAttackPhase[i].angleEnd = 25
	horseComboAttackPhase[i].offsetStart = Vector(13, -7)
	horseComboAttackPhase[i].offsetEnd = Vector(0, 0)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[15] = regularAttackSounds
	self.attackAnimationsGFX[15] = regularAttackGFX
	self.attackAnimations[15] = horseComboAttackPhase
	self.attackAnimationsTypes[15] = horseComboAttackPhase.Type
	
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
	
	overheadAttackPhase[i].frameStart = 0
	overheadAttackPhase[i].frameEnd = 4
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
	
	overheadAttackPhase[i].frameStart = 4
	overheadAttackPhase[i].frameEnd = 0
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
	overheadAttackPhase[i].attackRange = 24
	overheadAttackPhase[i].attackPush = 0.8
	overheadAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = 55;
	
	overheadAttackPhase[i].frameStart = 0
	overheadAttackPhase[i].frameEnd = 0
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
	overheadAttackPhase[i].attackRange = 24
	overheadAttackPhase[i].attackPush = 1.05
	overheadAttackPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = 55;
	
	overheadAttackPhase[i].frameStart = 0
	overheadAttackPhase[i].frameEnd = 0
	overheadAttackPhase[i].angleStart = 20
	overheadAttackPhase[i].angleEnd = -190
	overheadAttackPhase[i].offsetStart = Vector(3, -10)
	overheadAttackPhase[i].offsetEnd = Vector(15, 15)
	
	-- Early Recover
	i = 5
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 300
	
	overheadAttackPhase[i].firstRecovery = true	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 0
	overheadAttackPhase[i].frameEnd = 0
	overheadAttackPhase[i].angleStart = -120
	overheadAttackPhase[i].angleEnd = -125
	overheadAttackPhase[i].offsetStart = Vector(15, 15)
	overheadAttackPhase[i].offsetEnd = Vector(10, 15)
	
	-- Recover
	i = 6
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 900
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 0
	overheadAttackPhase[i].frameEnd = 5
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
	
	overheadAttackPhase[i].frameStart = 4
	overheadAttackPhase[i].frameEnd = 0
	overheadAttackPhase[i].angleStart = -10
	overheadAttackPhase[i].angleEnd = 25
	overheadAttackPhase[i].offsetStart = Vector(10, 15)
	overheadAttackPhase[i].offsetEnd = Vector(0, 0)
	
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
	
	flourishPhase[i].frameStart = 0
	flourishPhase[i].frameEnd = 5
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
	
	flourishPhase[i].frameStart = 5
	flourishPhase[i].frameEnd = 5
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
	
	flourishPhase[i].frameStart = 5
	flourishPhase[i].frameEnd = 3
	flourishPhase[i].angleStart = -45
	flourishPhase[i].angleEnd = -90
	flourishPhase[i].offsetStart = Vector(-6, -5)
	flourishPhase[i].offsetEnd = Vector(7, -2)
	
	flourishPhase[i].soundEnd = nil
	
	-- Bask
	i = 4
	flourishPhase[i] = {}
	flourishPhase[i].durationMS = 300
	
	flourishPhase[i].firstRecovery = true
	flourishPhase[i].canBeBlocked = false
	flourishPhase[i].canDamage = false
	flourishPhase[i].attackDamage = 3.4
	flourishPhase[i].attackStunChance = 0.15
	flourishPhase[i].attackRange = 20
	flourishPhase[i].attackPush = 0.8
	flourishPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	flourishPhase[i].attackAngle = 0;
	
	flourishPhase[i].frameStart = 3
	flourishPhase[i].frameEnd = 0
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
	
	-- warcry
	warcryPhase = {}
	warcryPhase.Type = "Slash";
	
	-- Prepare
	i = 1
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 250
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 90;
	
	warcryPhase[i].frameStart = 0
	warcryPhase[i].frameEnd = 2
	warcryPhase[i].angleStart = 25
	warcryPhase[i].angleEnd = 45
	warcryPhase[i].offsetStart = Vector(0, 0)
	warcryPhase[i].offsetEnd = Vector(-3, -2)
	
	-- Endreaden
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
	
	warcryPhase[i].frameStart = 2
	warcryPhase[i].frameEnd = 2
	warcryPhase[i].angleStart = 45
	warcryPhase[i].angleEnd = 45
	warcryPhase[i].offsetStart = Vector(-3, -2)
	warcryPhase[i].offsetEnd = Vector(-6, -5)
	
	-- Early Early Terrify
	i = 3
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 160
	
	warcryPhase[i].canBeBlocked = true
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 3.4
	warcryPhase[i].attackStunChance = 0.15
	warcryPhase[i].attackRange = 20
	warcryPhase[i].attackPush = 0.8
	warcryPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 0;
	
	warcryPhase[i].frameStart = 2
	warcryPhase[i].frameEnd = 6
	warcryPhase[i].angleStart = 45
	warcryPhase[i].angleEnd = -50
	warcryPhase[i].offsetStart = Vector(-6, -5)
	warcryPhase[i].offsetEnd = Vector(7, -2)
	
	warcryPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	warcryPhase[i].soundEnd = nil
	
	-- Early Terrify
	i = 4
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 50
	
	warcryPhase[i].canBeBlocked = true
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 3.4
	warcryPhase[i].attackStunChance = 0.15
	warcryPhase[i].attackRange = 20
	warcryPhase[i].attackPush = 0.8
	warcryPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 70;
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 6
	warcryPhase[i].angleStart = -50
	warcryPhase[i].angleEnd = -90
	warcryPhase[i].offsetStart = Vector(7, -2)
	warcryPhase[i].offsetEnd = Vector(7, -2)
	
	warcryPhase[i].soundStart = nil
	
	warcryPhase[i].soundEnd = nil
	
	-- Terrify
	i = 5
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 160
	
	warcryPhase[i].canBeBlocked = true
	warcryPhase[i].canDamage = true
	warcryPhase[i].attackDamage = 10
	warcryPhase[i].attackStunChance = 0.15
	warcryPhase[i].attackRange = 20
	warcryPhase[i].attackPush = 0.85
	warcryPhase[i].attackVector = Vector(0, 4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 90;
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 0
	warcryPhase[i].angleStart = -90
	warcryPhase[i].angleEnd = -100
	warcryPhase[i].offsetStart = Vector(7 , -2)
	warcryPhase[i].offsetEnd = Vector(15, -4)
	
	warcryPhase[i].soundStart = nil
	
	warcryPhase[i].soundEnd = nil
	
	-- Threaten
	i = 6
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 600
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 3.4
	warcryPhase[i].attackStunChance = 0.15
	warcryPhase[i].attackRange = 20
	warcryPhase[i].attackPush = 0.8
	warcryPhase[i].attackVector = Vector(4, 4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 0;
	
	warcryPhase[i].frameStart = 0
	warcryPhase[i].frameEnd = 0
	warcryPhase[i].angleStart = -90
	warcryPhase[i].angleEnd = -90
	warcryPhase[i].offsetStart = Vector(5, -5)
	warcryPhase[i].offsetEnd = Vector(5, -5)
	
	warcryPhase[i].soundStart = nil
	
	warcryPhase[i].soundEnd = nil
	
	-- Prepare
	i = 7
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 250
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 90;
	
	warcryPhase[i].frameStart = 0
	warcryPhase[i].frameEnd = 0
	warcryPhase[i].angleStart = -90
	warcryPhase[i].angleEnd = -75
	warcryPhase[i].offsetStart = Vector(7, -2)
	warcryPhase[i].offsetEnd = Vector(9, -2)
	
	-- Late Prepare
	i = 8
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 250
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 90;
	
	warcryPhase[i].frameStart = 0
	warcryPhase[i].frameEnd = 0
	warcryPhase[i].angleStart = -75
	warcryPhase[i].angleEnd = 25
	warcryPhase[i].offsetStart = Vector(9, -2)
	warcryPhase[i].offsetEnd = Vector(4, 0)
	
	-- Command
	i = 9
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
	
	warcryPhase[i].frameStart = 0
	warcryPhase[i].frameEnd = 5
	warcryPhase[i].angleStart = 25
	warcryPhase[i].angleEnd = 25
	warcryPhase[i].offsetStart = Vector(4, 0)
	warcryPhase[i].offsetEnd = Vector(0, -15)
	
	warcryPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	-- Pause
	i = 10
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 500
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 0;
	
	warcryPhase[i].frameStart = 5
	warcryPhase[i].frameEnd = 5
	warcryPhase[i].angleStart = 25
	warcryPhase[i].angleEnd = 25
	warcryPhase[i].offsetStart = Vector(0, -15)
	warcryPhase[i].offsetEnd = Vector(0, -15)
	
	-- Prepare
	i = 11
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 330
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	warcryPhase[i].frameStart = 5
	warcryPhase[i].frameEnd = 6
	warcryPhase[i].angleStart = 25
	warcryPhase[i].angleEnd = 25
	warcryPhase[i].offsetStart = Vector(0, -15)
	warcryPhase[i].offsetEnd = Vector(-4,-15)
	
	-- Late Prepare
	i = 12
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 700
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 2
	warcryPhase[i].angleStart = 25
	warcryPhase[i].angleEnd = 90
	warcryPhase[i].offsetStart = Vector(-4, -15)
	warcryPhase[i].offsetEnd = Vector(-4, -15)
	
	warcryPhase[i].soundStart = nil
	warcryPhase[i].soundStartVariations = 0
	
	warcryPhase[i].soundEnd = nil
	warcryPhase[i].soundEndVariations = 0
	
	-- Early Pummel
	i = 13
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 50
	
	warcryPhase[i].canBeBlocked = true
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 5
	warcryPhase[i].attackStunChance = 0.3
	warcryPhase[i].attackRange = 20
	warcryPhase[i].attackPush = 0.8
	warcryPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 55;
	
	warcryPhase[i].frameStart = 2
	warcryPhase[i].frameEnd = 2
	warcryPhase[i].angleStart = 80
	warcryPhase[i].angleEnd = 20
	warcryPhase[i].offsetStart = Vector(0, -15)
	warcryPhase[i].offsetEnd = Vector(3, -10)
	
	warcryPhase[i].soundStart = CreateSoundContainer("Slash Greataxe Mordhau", "Mordhau.rte");
	
	warcryPhase[i].soundEnd = nil
	
	-- Pummel
	i = 14
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 140
	
	warcryPhase[i].canBeBlocked = true
	warcryPhase[i].canDamage = true
	warcryPhase[i].attackDamage = 25
	warcryPhase[i].attackStunChance = 1.0
	warcryPhase[i].attackRange = 19
	warcryPhase[i].attackPush = 2
	warcryPhase[i].attackVector = Vector(0, 3) -- local space vector relative to position and rotation
	warcryPhase[i].attackAngle = 55;
	
	warcryPhase[i].frameStart = 2
	warcryPhase[i].frameEnd = 0
	warcryPhase[i].angleStart = 20
	warcryPhase[i].angleEnd = -190
	warcryPhase[i].offsetStart = Vector(3, -10)
	warcryPhase[i].offsetEnd = Vector(15, 15)
	
	-- Early Recover
	i = 15
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 300
	
	warcryPhase[i].firstRecovery = true	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	warcryPhase[i].frameStart = 0
	warcryPhase[i].frameEnd = 0
	warcryPhase[i].angleStart = -120
	warcryPhase[i].angleEnd = -125
	warcryPhase[i].offsetStart = Vector(15, 15)
	warcryPhase[i].offsetEnd = Vector(10, 15)
	
	-- Recover
	i = 16
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 900
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	warcryPhase[i].frameStart = 0
	warcryPhase[i].frameEnd = 6
	warcryPhase[i].angleStart = -125
	warcryPhase[i].angleEnd = -10
	warcryPhase[i].offsetStart = Vector(10, 15)
	warcryPhase[i].offsetEnd = Vector(3, -5)
	
	-- Late Recover
	i = 17
	warcryPhase[i] = {}
	warcryPhase[i].durationMS = 600
	
	warcryPhase[i].canBeBlocked = false
	warcryPhase[i].canDamage = false
	warcryPhase[i].attackDamage = 0
	warcryPhase[i].attackStunChance = 0
	warcryPhase[i].attackRange = 0
	warcryPhase[i].attackPush = 0
	warcryPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	warcryPhase[i].frameStart = 6
	warcryPhase[i].frameEnd = 0
	warcryPhase[i].angleStart = -10
	warcryPhase[i].angleEnd = 25
	warcryPhase[i].offsetStart = Vector(10, 15)
	warcryPhase[i].offsetEnd = Vector(0, 0)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[8] = regularAttackSounds
	self.attackAnimationsGFX[8] = regularAttackGFX
	self.attackAnimations[8] = warcryPhase
	self.attackAnimationsTypes[8] = warcryPhase.Type
	
	-- Throw
	throwPhase = {}
	throwPhase.Type = "Slash";
	
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
	
	throwPhase[i].frameStart = 0
	throwPhase[i].frameEnd = 0
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
	
	throwPhase[i].frameStart = 0
	throwPhase[i].frameEnd = 0
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
	
	throwPhase[i].frameStart = 0
	throwPhase[i].frameEnd = 0
	throwPhase[i].angleStart = 120
	throwPhase[i].angleEnd = -90
	throwPhase[i].offsetStart = Vector(-15, -15)
	throwPhase[i].offsetEnd = Vector(6, -15)
	
	throwPhase[i].soundStart = nil
	throwPhase[i].soundStartVariations = 0
	
	throwPhase[i].soundEnd = nil
	throwPhase[i].soundEndVariations = 0
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[9] = regularAttackSounds
	self.attackAnimationsGFX[9] = regularAttackGFX
	self.attackAnimations[9] = throwPhase
	self.attackAnimationsTypes[9] = throwPhase.Type
	
	-- Equip anim
	equipPhase = {}
	equipPhase.Type = "Equip";
	
	-- Out
	i = 1
	equipPhase[i] = {}
	equipPhase[i].durationMS = 450
	
	equipPhase[i].canBeBlocked = false
	equipPhase[i].canDamage = false
	equipPhase[i].attackDamage = 0
	equipPhase[i].attackStunChance = 0
	equipPhase[i].attackRange = 0
	equipPhase[i].attackPush = 0
	equipPhase[i].attackVector = Vector(0, -4) -- local space vector relative to position and rotation
	equipPhase[i].attackAngle = 90;
	
	equipPhase[i].frameStart = 0
	equipPhase[i].frameEnd = 0
	equipPhase[i].angleStart = 170
	equipPhase[i].angleEnd = 150
	equipPhase[i].offsetStart = Vector(-15, -25)
	equipPhase[i].offsetEnd = Vector(-12, -15)
	
	-- Upright
	i = 2
	equipPhase[i] = {}
	equipPhase[i].durationMS = 450
	
	equipPhase[i].canBeBlocked = false
	equipPhase[i].canDamage = false
	equipPhase[i].attackDamage = 0
	equipPhase[i].attackStunChance = 0
	equipPhase[i].attackRange = 0
	equipPhase[i].attackPush = 0
	equipPhase[i].attackVector = Vector(4, -4) -- local space vector relative to position and rotation
	equipPhase[i].attackAngle = 0;
	
	equipPhase[i].frameStart = 0
	equipPhase[i].frameEnd = 2
	equipPhase[i].angleStart = 150
	equipPhase[i].angleEnd = 15
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
	
	equipPhase[i].frameStart = 2
	equipPhase[i].frameEnd = 0
	equipPhase[i].angleStart = 15
	equipPhase[i].angleEnd = 15
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

		-- local rotationTarget = 170 / 180 * math.pi
		-- local stanceTarget = Vector(-15, -25);
	
		-- self.stance = self.stance + stanceTarget
		
		-- rotationTarget = rotationTarget * self.FlipFactor
		-- self.rotation = self.rotation + rotationTarget
		
		-- self.StanceOffset = self.originalStanceOffset + self.stance
		-- self.RotAngle = self.RotAngle + self.rotation
		
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
				
				self.originalBaseRotation = 25;
				self.baseRotation = 25;
				
			end
			
			if not stab and not overhead and not flourish and not throw and not warcry then
				if self.parent:NumberValueExists("Mordhau Disable Movement") then -- we're probably on a horse if this is set... probably...
					playAttackAnimation(self, 15) -- regular attack
					self:SetNumberValue("Current Attack Type", 2);
					self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 2 Range"));
				else
					playAttackAnimation(self, math.random(1, 2)) -- regular attack
					self:SetNumberValue("Current Attack Type", 1);
					self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 1 Range"));
				end
			elseif stab then
				playAttackAnimation(self, math.random(3, 4)) -- stab
				self:SetNumberValue("Current Attack Type", 3);
				self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 3 Range"));
			elseif overhead then
				playAttackAnimation(self, math.random(5, 6)) -- overhead				
				self:SetNumberValue("Current Attack Type", 4);
				self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 4 Range"));
			elseif warcry then
				self.parent:SetNumberValue("Block Foley", 1);
				playAttackAnimation(self, 8)
			elseif flourish and not self.parent:NumberValueExists("Mordhau Charge Ready") then
				self.parent:SetNumberValue("Block Foley", 1);
				playAttackAnimation(self, 7) -- fancypants shit
			elseif throw then
				self.parent:SetNumberValue("Block Foley", 1);
				self.Throwing = true;
				playAttackAnimation(self, 9) -- throw
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
			if self.pseudoPhase then
				currentPhase = self.pseudoPhase;
			end
			local nextPhase = attackPhases[self.currentAttackSequence + 1]
			
			if self.chargeDecided == false and nextPhase and nextPhase.canBeBlocked == true and currentPhase.canBeBlocked == false then
				self.chargeDecided = true;
				if activated then
					self.wasCharged = true;
					self.hitMax = 4;
					self.parent:SetNumberValue("Extreme Attack", 1);
				else
					self.wasCharged = false;
					self.hitMax = 3;
					self.parent:SetNumberValue("Large Attack", 1);				
				end
			elseif currentPhase.firstRecovery == true then
				self.Recovering = true;
			elseif self.chargeDecided == false or self.blockedNullifier == false or self.allowBlockCancelling == true then
				-- block, getting parried cancelling
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
					
					stanceTarget = Vector(4, -10);
					
					self.originalBaseRotation = -160;
					self.baseRotation = -145;
				end
				if self.wasParried then
					self.wasParried = false;
					self.Throwing = false;
					self.wasCharged = false;
					self.currentAttackAnimation = 0
					self.currentAttackSequence = 0
					self.attackAnimationIsPlaying = false
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
					self.attackAnimationBuffered = self.parent:NumberValueExists("Mordhau Disable Movement") and 15 or math.random(1, 2) ;
				elseif stab then
					self.stabBuffered = true;
					self.attackAnimationBuffered = math.random(3, 4) 
				elseif overhead then
					self.overheadBuffered = true;
					self.attackAnimationBuffered = math.random(5, 6) 
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
				self.pseudoPhase.durationMS = ((currentPhase.durationMS * 1.8) + (self.blockedNullifier == false and 300 or 0)) or 0
				
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
				self.pseudoPhase.offsetStart = self.originalStanceOffset + self.stance
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
					if nextPhase.attackReset == true then
						self.Hits = 0;
						self.hitMOTable = {};
						self.blockedNullifier = true;
						self.wasCharged = false;
						self.chargeDecided = false;
						self.Recovering = false;
						self.partiallyRecovered = false;
					end
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
						local throwChargeFactor = self.wasCharged and 25 or 0
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
			
				self.rotationInterpolationSpeed = 5;
			
				self.parent:SetNumberValue("Block Foley", 1);
			
				self.Blocking = true;
				
				self:SetNumberValue("Blocking", 1);
				
				stanceTarget = Vector(4, -10);
				
				self.originalBaseRotation = -160;
				self.baseRotation = -145;
			
			elseif keyHeld and not (self.attackAnimationIsPlaying) then
			
				self.originalBaseRotation = -160;
			
				stanceTarget = Vector(4, -10);
				
				self:SetNumberValue("Current Attack Type", 0);
				self:SetNumberValue("Current Attack Range", 0);
			
			elseif keyReleased then
			
				self.parent:SetNumberValue("Block Foley", 1);
			
				self.Blocking = false;
				
				self:RemoveNumberValue("Blocking");
				
				self.originalBaseRotation = 25;
				self.baseRotation = 15;
			
			else
			
				self:SetNumberValue("Current Attack Type", 0);
				self:SetNumberValue("Current Attack Range", 0);
				
				self.Blocking = false;
				
				self:RemoveNumberValue("Blocking");
				
				self.originalBaseRotation = 25;
				self.baseRotation = 15;
				
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
				
			self.Frame = 0;
				
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
								playAttackAnimation(self, math.random(5, 6));
								self:SetNumberValue("Current Attack Type", 4);
								self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 4 Range"));
							elseif self.parent:NumberValueExists("Mordhau Disable Movement") then
								playAttackAnimation(self, 15);
								self:SetNumberValue("Current Attack Type", 2);
								self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 2 Range"));
							else
								playAttackAnimation(self, math.random(1, 2));
								self:SetNumberValue("Current Attack Type", 1);
								self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 1 Range"));
							end
						else
							playAttackAnimation(self, math.random(3, 4));
							self:SetNumberValue("Current Attack Type", 3);
							self:SetNumberValue("Current Attack Range", self:GetNumberValue("Attack 3 Range"));
						end
					
						self.Blocking = false;
						self:RemoveNumberValue("Blocking");
						
						stanceTarget = Vector(0, 0);
						
						self.originalBaseRotation = 25;
						self.baseRotation = 15;
						
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
			local hitTerrain = false;
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
					MO = ToMOSRotating(MO)
					local hitAllowed = true;
					if self.hitMOTable then -- this shouldn't be needed but it is
						for index, root in pairs(self.hitMOTable) do
							if root == MO:GetRootParent().UniqueID or index == MO.UniqueID then
								hitAllowed = false;
							end
						end
					end
					if hitAllowed == true then
						self.Hits = self.Hits + 1;
						hit = true
						self.hitMOTable[MO.UniqueID] = MO:GetRootParent().UniqueID;
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
						
						local speedMult = math.max(1, self.Vel.Magnitude / 18);
						local woundsToAdd = math.floor((damage*speedMult) + RangeRand(0,0.9))
						
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
							
							if self.attackAnimationsTypes[self.currentAttackAnimation] == "Slash" and IsAttachable(MO) and ToAttachable(MO):IsAttached() and (IsArm(MO) or IsLeg(MO) or (IsAHuman(actorHit) and ToAHuman(actorHit).Head and MO.UniqueID == ToAHuman(actorHit).Head.UniqueID)) then
								-- two different ways to dismember: 1. if wounds would gib the limb hit, dismember it instead 2. low hp and crit
								if MO.WoundCount + woundsToAdd >= MO.GibWoundLimit then
									ToAttachable(MO):RemoveFromParent(true, true);
									addWounds = false;
								elseif ToActor(actorHit).Health < 20 and crit then
									ToAttachable(MO):RemoveFromParent(true, true);
									addWounds = false;
								end
							end
							
							-- this doesn't need wound doubling on non-head hits. strong enough, lol
							
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
							self.wasParried = true;
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
					if not ignoreTerrain then
						hitTerrain = true
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
					self.allowBlockCancelling = true;
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound:Play(self.Pos);
					end
				elseif hitType == 1 then -- Flesh
					self.allowBlockCancelling = true;
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSound:Play(self.Pos);
					end
				elseif hitType == 2 then -- Metal
					self.allowBlockCancelling = true;
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSound:Play(self.Pos);
					end
				end
				if self.Hits == self.hitMax or hitTerrain then
					self.attackAnimationCanHit = false
				end
			end
		end
	end
	self:RemoveNumberValue("AI Block");
end