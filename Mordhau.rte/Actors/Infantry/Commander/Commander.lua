
dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI")  --dofile("Base.rte/AI/NativeHumanAI.lua")
package.path = package.path .. ";Mordhau.rte/?.lua";
require("Actors/Infantry/Commander/CommanderAIBehaviours")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	--You can turn features on and off here
	self.armSway = true;
	self.automaticEquip = false;
	self.alternativeGib = true;
	self.visibleInventory = false;
	
	-- Start modded code --
	
	self.RTE = "Mordhau.rte";
	self.baseRTE = "Mordhau.rte";
	
	-- IDENTITY AND VOICE
	
	self.IdentityPrimary = "Destroyer";
	self:SetStringValue("IdentityPrimary", self.IdentityPrimary);
	
	self.voiceSounds = {
	Hold = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Hold", "Mordhau.rte"),
	killingEnemy = CreateSoundContainer("VO " .. self.IdentityPrimary .. " KillingEnemy", "Mordhau.rte"),
	Archers = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Archers", "Mordhau.rte"),
	gruntLight = CreateSoundContainer("VO " .. self.IdentityPrimary .. " GruntLight", "Mordhau.rte"),
	gruntMedium = CreateSoundContainer("VO " .. self.IdentityPrimary .. " GruntMedium", "Mordhau.rte"),
	recoveryLight = CreateSoundContainer("VO " .. self.IdentityPrimary .. " RecoveryLight", "Mordhau.rte"),
	recoverySerious = CreateSoundContainer("VO " .. self.IdentityPrimary .. " RecoverySerious", "Mordhau.rte"),
	recoveryExtreme = CreateSoundContainer("VO " .. self.IdentityPrimary .. " RecoveryExtreme", "Mordhau.rte"),
	frustratedSerious = CreateSoundContainer("VO " .. self.IdentityPrimary .. " FrustratedSerious", "Mordhau.rte"),
	deathEpic = CreateSoundContainer("VO " .. self.IdentityPrimary .. " DeathEpic", "Mordhau.rte"),
	Incap = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Incap", "Mordhau.rte"),
	painLight = CreateSoundContainer("VO " .. self.IdentityPrimary .. " PainLight", "Mordhau.rte"),
	painMedium = CreateSoundContainer("VO " .. self.IdentityPrimary .. " PainMedium", "Mordhau.rte"),
	Scream = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Scream", "Mordhau.rte"),
	burnScream = CreateSoundContainer("VO " .. self.IdentityPrimary .. " BurnScream", "Mordhau.rte"),
	Spot = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Spot", "Mordhau.rte"),
	suppressedLight = CreateSoundContainer("VO " .. self.IdentityPrimary .. " SuppressedLight", "Mordhau.rte"),
	suppressedMedium = CreateSoundContainer("VO " .. self.IdentityPrimary .. " SuppressedMedium", "Mordhau.rte"),
	suppressedSerious = CreateSoundContainer("VO " .. self.IdentityPrimary .. " SuppressedSerious", "Mordhau.rte"),
	whoaLight = CreateSoundContainer("VO " .. self.IdentityPrimary .. " WhoaLight", "Mordhau.rte"),
	whoaMedium = CreateSoundContainer("VO " .. self.IdentityPrimary .. " WhoaMedium", "Mordhau.rte")};
	
	-- construct atmospheric tables
	
	self.atmosphericVoiceSounds = {};
	self.atmosphericVoiceSounds.gruntSerious = {};
	for i = 1, 15 do
		self.atmosphericVoiceSounds.gruntSerious[i] = CreateSoundContainer("VO " .. self.IdentityPrimary .. " GruntSerious " .. i, "Mordhau.rte");
	end
	self.atmosphericVoiceSounds.painSerious = {};
	for i = 1, 15 do
		self.atmosphericVoiceSounds.painSerious[i] = CreateSoundContainer("VO " .. self.IdentityPrimary .. " PainSerious " .. i, "Mordhau.rte");
	end
	self.atmosphericVoiceSounds.Warcry = {};
	for i = 1, 8 do
		self.atmosphericVoiceSounds.Warcry[i] = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Warcry " .. i, "Mordhau.rte");
	end
	self.atmosphericVoiceSounds.battleScream = {};
	for i = 1, 6 do
		self.atmosphericVoiceSounds.battleScream[i] = CreateSoundContainer("VO " .. self.IdentityPrimary .. " BattleScream " .. i, "Mordhau.rte");
	end
	
	-- TERRAIN SOUNDS
	
	-- have to specify every material ID like this
	-- this way we can cut down on an extra "if" or two which would be needed for the logic of selecting from several tables
	-- trading table beauty for performance... ahhh, smells like coding.	
	
	self.terrainSounds = {
	Crawl = {[12] = CreateSoundContainer("Crawl Concrete", "Mordhau.rte"),
			[164] = CreateSoundContainer("Crawl Concrete", "Mordhau.rte"),
			[177] = CreateSoundContainer("Crawl Concrete", "Mordhau.rte"),
			[9] = CreateSoundContainer("Crawl Dirt", "Mordhau.rte"),
			[10] = CreateSoundContainer("Crawl Dirt", "Mordhau.rte"),
			[11] = CreateSoundContainer("Crawl Dirt", "Mordhau.rte"),
			[128] = CreateSoundContainer("Crawl Dirt", "Mordhau.rte"),
			[6] = CreateSoundContainer("Crawl Sand", "Mordhau.rte"),
			[8] = CreateSoundContainer("Crawl Sand", "Mordhau.rte"),
			[178] = CreateSoundContainer("Crawl SolidMetal", "Mordhau.rte"),
			[179] = CreateSoundContainer("Crawl SolidMetal", "Mordhau.rte"),
			[180] = CreateSoundContainer("Crawl SolidMetal", "Mordhau.rte"),
			[181] = CreateSoundContainer("Crawl SolidMetal", "Mordhau.rte"),
			[182] = CreateSoundContainer("Crawl SolidMetal", "Mordhau.rte")},
	Prone = {[12] = CreateSoundContainer("Prone Concrete", "Mordhau.rte"),
			[164] = CreateSoundContainer("Prone Concrete", "Mordhau.rte"),
			[177] = CreateSoundContainer("Prone Concrete", "Mordhau.rte"),
			[9] = CreateSoundContainer("Prone Dirt", "Mordhau.rte"),
			[10] = CreateSoundContainer("Prone Dirt", "Mordhau.rte"),
			[11] = CreateSoundContainer("Prone Dirt", "Mordhau.rte"),
			[128] = CreateSoundContainer("Prone Dirt", "Mordhau.rte"),
			[6] = CreateSoundContainer("Prone Sand", "Mordhau.rte"),
			[8] = CreateSoundContainer("Prone Sand", "Mordhau.rte"),
			[178] = CreateSoundContainer("Prone SolidMetal", "Mordhau.rte"),
			[179] = CreateSoundContainer("Prone SolidMetal", "Mordhau.rte"),
			[180] = CreateSoundContainer("Prone SolidMetal", "Mordhau.rte"),
			[181] = CreateSoundContainer("Prone SolidMetal", "Mordhau.rte"),
			[182] = CreateSoundContainer("Prone SolidMetal", "Mordhau.rte")},
	TerrainImpactLight = {[12] = CreateSoundContainer("TerrainImpact Light Concrete", "Mordhau.rte"),
			[164] = CreateSoundContainer("TerrainImpact Light Concrete", "Mordhau.rte"),
			[177] = CreateSoundContainer("TerrainImpact Light Concrete", "Mordhau.rte"),
			[9] = CreateSoundContainer("TerrainImpact Light Dirt", "Mordhau.rte"),
			[10] = CreateSoundContainer("TerrainImpact Light Dirt", "Mordhau.rte"),
			[11] = CreateSoundContainer("TerrainImpact Light Dirt", "Mordhau.rte"),
			[128] = CreateSoundContainer("TerrainImpact Light Dirt", "Mordhau.rte"),
			[6] = CreateSoundContainer("TerrainImpact Light Sand", "Mordhau.rte"),
			[8] = CreateSoundContainer("TerrainImpact Light Sand", "Mordhau.rte"),
			[178] = CreateSoundContainer("TerrainImpact Light SolidMetal", "Mordhau.rte"),
			[179] = CreateSoundContainer("TerrainImpact Light SolidMetal", "Mordhau.rte"),
			[180] = CreateSoundContainer("TerrainImpact Light SolidMetal", "Mordhau.rte"),
			[181] = CreateSoundContainer("TerrainImpact Light SolidMetal", "Mordhau.rte"),
			[182] = CreateSoundContainer("TerrainImpact Light SolidMetal", "Mordhau.rte")},
	TerrainImpactHeavy = {[12] = CreateSoundContainer("TerrainImpact Heavy Concrete", "Mordhau.rte"),
			[164] = CreateSoundContainer("TerrainImpact Heavy Concrete", "Mordhau.rte"),
			[177] = CreateSoundContainer("TerrainImpact Heavy Concrete", "Mordhau.rte"),
			[9] = CreateSoundContainer("TerrainImpact Heavy Dirt", "Mordhau.rte"),
			[10] = CreateSoundContainer("TerrainImpact Heavy Dirt", "Mordhau.rte"),
			[11] = CreateSoundContainer("TerrainImpact Heavy Dirt", "Mordhau.rte"),
			[128] = CreateSoundContainer("TerrainImpact Heavy Dirt", "Mordhau.rte"),
			[6] = CreateSoundContainer("TerrainImpact Heavy Sand", "Mordhau.rte"),
			[8] = CreateSoundContainer("TerrainImpact Heavy Sand", "Mordhau.rte"),
			[178] = CreateSoundContainer("TerrainImpact Heavy SolidMetal", "Mordhau.rte"),
			[179] = CreateSoundContainer("TerrainImpact Heavy SolidMetal", "Mordhau.rte"),
			[180] = CreateSoundContainer("TerrainImpact Heavy SolidMetal", "Mordhau.rte"),
			[181] = CreateSoundContainer("TerrainImpact Heavy SolidMetal", "Mordhau.rte"),
			[182] = CreateSoundContainer("TerrainImpact Heavy SolidMetal", "Mordhau.rte")},
	FootstepJump = {[12] = CreateSoundContainer("Footstep Jump Concrete", "Mordhau.rte"),
			[164] = CreateSoundContainer("Footstep Jump Concrete", "Mordhau.rte"),
			[177] = CreateSoundContainer("Footstep Jump Concrete", "Mordhau.rte"),
			[9] = CreateSoundContainer("Footstep Jump Dirt", "Mordhau.rte"),
			[10] = CreateSoundContainer("Footstep Jump Dirt", "Mordhau.rte"),
			[11] = CreateSoundContainer("Footstep Jump Dirt", "Mordhau.rte"),
			[128] = CreateSoundContainer("Footstep Jump Dirt", "Mordhau.rte"),
			[6] = CreateSoundContainer("Footstep Jump Sand", "Mordhau.rte"),
			[8] = CreateSoundContainer("Footstep Jump Sand", "Mordhau.rte"),
			[178] = CreateSoundContainer("Footstep Jump SolidMetal", "Mordhau.rte"),
			[179] = CreateSoundContainer("Footstep Jump SolidMetal", "Mordhau.rte"),
			[180] = CreateSoundContainer("Footstep Jump SolidMetal", "Mordhau.rte"),
			[181] = CreateSoundContainer("Footstep Jump SolidMetal", "Mordhau.rte"),
			[182] = CreateSoundContainer("Footstep Jump SolidMetal", "Mordhau.rte")},
	FootstepLand = {[12] = CreateSoundContainer("Footstep Land Concrete", "Mordhau.rte"),
			[164] = CreateSoundContainer("Footstep Land Concrete", "Mordhau.rte"),
			[177] = CreateSoundContainer("Footstep Land Concrete", "Mordhau.rte"),
			[9] = CreateSoundContainer("Footstep Land Dirt", "Mordhau.rte"),
			[10] = CreateSoundContainer("Footstep Land Dirt", "Mordhau.rte"),
			[11] = CreateSoundContainer("Footstep Land Dirt", "Mordhau.rte"),
			[128] = CreateSoundContainer("Footstep Land Dirt", "Mordhau.rte"),
			[6] = CreateSoundContainer("Footstep Land Sand", "Mordhau.rte"),
			[8] = CreateSoundContainer("Footstep Land Sand", "Mordhau.rte"),
			[178] = CreateSoundContainer("Footstep Land SolidMetal", "Mordhau.rte"),
			[179] = CreateSoundContainer("Footstep Land SolidMetal", "Mordhau.rte"),
			[180] = CreateSoundContainer("Footstep Land SolidMetal", "Mordhau.rte"),
			[181] = CreateSoundContainer("Footstep Land SolidMetal", "Mordhau.rte"),
			[182] = CreateSoundContainer("Footstep Land SolidMetal", "Mordhau.rte")},
	FootstepWalk = {[12] = CreateSoundContainer("Footstep Walk Concrete", "Mordhau.rte"),
			[164] = CreateSoundContainer("Footstep Walk Concrete", "Mordhau.rte"),
			[177] = CreateSoundContainer("Footstep Walk Concrete", "Mordhau.rte"),
			[9] = CreateSoundContainer("Footstep Walk Dirt", "Mordhau.rte"),
			[10] = CreateSoundContainer("Footstep Walk Dirt", "Mordhau.rte"),
			[11] = CreateSoundContainer("Footstep Walk Dirt", "Mordhau.rte"),
			[128] = CreateSoundContainer("Footstep Walk Dirt", "Mordhau.rte"),
			[6] = CreateSoundContainer("Footstep Walk Sand", "Mordhau.rte"),
			[8] = CreateSoundContainer("Footstep Walk Sand", "Mordhau.rte"),
			[178] = CreateSoundContainer("Footstep Walk SolidMetal", "Mordhau.rte"),
			[179] = CreateSoundContainer("Footstep Walk SolidMetal", "Mordhau.rte"),
			[180] = CreateSoundContainer("Footstep Walk SolidMetal", "Mordhau.rte"),
			[181] = CreateSoundContainer("Footstep Walk SolidMetal", "Mordhau.rte"),
			[182] = CreateSoundContainer("Footstep Walk SolidMetal", "Mordhau.rte")},
	FootstepSprint = {[12] = CreateSoundContainer("Footstep Sprint Concrete", "Mordhau.rte"),
			[164] = CreateSoundContainer("Footstep Sprint Concrete", "Mordhau.rte"),
			[177] = CreateSoundContainer("Footstep Sprint Concrete", "Mordhau.rte"),
			[9] = CreateSoundContainer("Footstep Sprint Dirt", "Mordhau.rte"),
			[10] = CreateSoundContainer("Footstep Sprint Dirt", "Mordhau.rte"),
			[11] = CreateSoundContainer("Footstep Sprint Dirt", "Mordhau.rte"),
			[128] = CreateSoundContainer("Footstep Sprint Dirt", "Mordhau.rte"),
			[6] = CreateSoundContainer("Footstep Sprint Sand", "Mordhau.rte"),
			[8] = CreateSoundContainer("Footstep Sprint Sand", "Mordhau.rte"),
			[178] = CreateSoundContainer("Footstep Sprint SolidMetal", "Mordhau.rte"),
			[179] = CreateSoundContainer("Footstep Sprint SolidMetal", "Mordhau.rte"),
			[180] = CreateSoundContainer("Footstep Sprint SolidMetal", "Mordhau.rte"),
			[181] = CreateSoundContainer("Footstep Sprint SolidMetal", "Mordhau.rte"),
			[182] = CreateSoundContainer("Footstep Sprint SolidMetal", "Mordhau.rte")}
	};
	
	-- EVERYTHING ELSE
	
	self.movementSounds = {
	Land = CreateSoundContainer("Knight Gear Land", "Mordhau.rte"),
	Jump = CreateSoundContainer("Knight Gear Jump", "Mordhau.rte"),
	Crouch = CreateSoundContainer("Knight Gear CrouchStand", "Mordhau.rte"),
	Stand = CreateSoundContainer("Knight Gear CrouchStand", "Mordhau.rte"),
	Step = CreateSoundContainer("Knight Gear Move", "Mordhau.rte"),
	StepAdd = CreateSoundContainer("Commander Gear Footstep Add", "Mordhau.rte"),
	Prone = CreateSoundContainer("Knight Gear Move", "Mordhau.rte"),
	Crawl = CreateSoundContainer("Knight Gear Move", "Mordhau.rte"),
	ThrowStart = CreateSoundContainer("Knight Gear Light Move", "Mordhau.rte"),
	Throw = CreateSoundContainer("Knight Gear Move", "Mordhau.rte"),
	AttackLight = CreateSoundContainer("Knight Gear Light Move", "Mordhau.rte"),
	AttackMedium = CreateSoundContainer("Knight Gear Move", "Mordhau.rte"),
	AttackLarge = CreateSoundContainer("Knight Gear Move", "Mordhau.rte"),
	AttackExtreme = CreateSoundContainer("Knight Gear Move", "Mordhau.rte")};

	self.voiceSound = CreateSoundContainer("Knight Gear Move", "Mordhau.rte");
	self.atmosphericVoiceSound = CreateSoundContainer("Knight Gear Move", "Mordhau.rte");
	-- MEANINGLESS! this is just so we can do voiceSound.Pos without an if check first! it will be overwritten first actual VO play
	
	self.altitude = 0;
	self.wasInAir = false;
	
	self.moveSoundTimer = Timer();
	self.moveSoundWalkTimer = Timer();
	self.wasCrouching = false;
	self.wasMoving = false;

	self.healthUpdateTimer = Timer();
	self.oldHealth = self.Health;
	
	self.headWounds = 0;
	
	self.Suppression = 0;
	self.Suppressed = false;	
	
	self.suppressionUpdateTimer = Timer();
	self.suppressedVoicelineTimer = Timer();
	self.suppressedVoicelineDelay = 8000;
	
	self.gunShotCounter = 0;
	self.suppressingVoicelineTimer = Timer();
	self.suppressingVoicelineDelay = 15000;
	
	self.attackSuccessTimer = Timer();
	self.attackSuccessTime = 2000;
	
	self.attackKilledTimer = Timer();
	self.attackKilledTime = 2000;
	
	self.emotionTimer = Timer();
	self.emotionDuration = 0;
	
	-- experimental method for enhanced dying - don't let the actor actually die until we want him to.
	-- reason for this is because when the actor IsDead he will really want to settle and there's not much we can do about it.
	self.allowedToDie = false;	
	
	-- chance upon any non-headshot death to be incapacitated for a while before really dying
	self.incapacitationChance = 10;
	
	self.friendlyDownTimer = Timer();
	self.friendlyDownDelay = 5000;
	
	self.spotVoiceLineTimer = Timer();
	self.spotVoiceLineDelay = 15000;
	
	 -- in pixels
	self.spotDistanceClose = 50;
	self.spotDistanceMid = 520;
	--spotDistanceFar -- anything further than distanceMid
	
	 -- in MS
	self.spotDelayMin = 4000;
	self.spotDelayMax = 8000;
	
	 -- in percent
	self.spotIgnoreDelayChance = 10;
	self.spotNoVoicelineChance = 15;
	
	-- ragdoll
	self.ragdollTerrainImpactTimer = Timer();
	self.ragdollTerrainImpactDelay = math.random(200, 500);
	
	-- extremely epic, 2000-tier combat/idle mode system
	self.inCombat = false;
	self.combatExitTimer = Timer();
	self.combatExitDelay = 10000;
	
	self.passiveSuppressionTimer = Timer();
	self.passiveSuppressionDelay = 1000;
	self.passiveSuppressionAmountLower = 5;
	self.passiveSuppressionAmountUpper = 10;

	
	-- leg Collision Detection system
	self.foot = 0;
    self.feetContact = {false, false}
    self.feetTimers = {Timer(), Timer()}
	self.footstepTime = 100 -- 2 Timers to avoid noise
	
	-- custom Jumping
	self.isJumping = false
	self.jumpStrength = -3.0;
	self.jumpTimer = Timer();
	self.jumpDelay = 500;
	self.jumpStop = Timer();
	self.jumpBoostTimer = Timer();
	
	-- Sprint
	self.isSprinting = false
	self.doubleTapTimer = Timer();
	self.doubleTapState = 0

	self.accelerationFactor = 0.1;
	self.moveMultiplier = 0.8;
	self.walkMultiplier = 0.8;
	self.sprintMultiplier = 1.1;

	self.sprintPushForceDenominator = 1.2 / 0.8
	
	self.limbPathDefaultSpeed0 = self:GetLimbPathSpeed(0)
	self.limbPathDefaultSpeed1 = self:GetLimbPathSpeed(1)
	self.limbPathDefaultSpeed2 = self:GetLimbPathSpeed(2)
	self.limbPathDefaultPushForce = self.LimbPathPushForce
	
	self.lastVel = Vector(0, 0)
	
	-- End modded code
end

function OnCollideWithTerrain(self, terrainID)
	
	-- if self.impulse.Magnitude > self.ImpulseDamageThreshold then
		-- if self.impactSoundTimer:IsPastSimMS(700) then
			-- print("heavy")
			-- if self.terrainSounds.TerrainImpactHeavy[terrainID] ~= nil then
				-- self.terrainSounds.TerrainImpactHeavy[terrainID]:Play(self.Pos);
			-- else -- default to concrete
				-- self.terrainSounds.TerrainImpactHeavy[177]:Play(self.Pos);
			-- end
			-- self.impactSoundTimer:Reset();
		-- end
	-- elseif self.impulse.Magnitude > self.ImpulseDamageThreshold/5 then
		-- if self.impactSoundTimer:IsPastSimMS(700) then
			-- print("light")
			-- if self.terrainSounds.TerrainImpactLight[terrainID] ~= nil then
				-- self.terrainSounds.TerrainImpactLight[terrainID]:Play(self.Pos);
			-- else -- default to concrete
				-- self.terrainSounds.TerrainImpactLight[177]:Play(self.Pos);
			-- end
			-- self.impactSoundTimer:Reset();
		-- end
	-- end
	
	self.terrainCollided = true;
	self.terrainCollidedWith = terrainID;
end

function OnStride(self)

	local sound = self.isSprinting and self.terrainSounds.FootstepSprint or self.terrainSounds.FootstepWalk

	if self.BGFoot and self.FGFoot then
	
		-- if math.random(0, 100) < 30 then
			-- if self.EquippedItem and IsHDFirearm(self.EquippedItem) then
				-- local gun = ToHDFirearm(self.EquippedItem)
				-- if gun:NumberValueExists("Gun Rattle Type") then
					-- if self.gunRattles[gun:GetNumberValue("Gun Rattle Type")] then
						-- self.gunRattles[gun:GetNumberValue("Gun Rattle Type")]:Play(gun.Pos);
					-- end
				-- end
			-- end	
		-- end

		local startPos = self.foot == 0 and self.BGFoot.Pos or self.FGFoot.Pos
		self.foot = (self.foot + 1) % 2
		
		local pos = Vector(0, 0);
		SceneMan:CastObstacleRay(startPos, Vector(0, 9), pos, Vector(0, 0), self.ID, self.Team, 0, 3);				
		local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
		
		if terrPixel ~= 0 then -- 0 = air
			self.movementSounds.StepAdd:Play(self.Pos);
			if sound[terrPixel] ~= nil then
				sound[terrPixel]:Play(self.Pos);
			else -- default to concrete
				sound[177]:Play(self.Pos);
			end
		end
		
	elseif self.BGFoot then
	
		-- if math.random(0, 100) < 30 then
			-- if self.EquippedItem and IsHDFirearm(self.EquippedItem) then
				-- local gun = ToHDFirearm(self.EquippedItem)
				-- if gun:NumberValueExists("Gun Rattle Type") then
					-- if self.gunRattles[gun:GetNumberValue("Gun Rattle Type")] then
						-- self.gunRattles[gun:GetNumberValue("Gun Rattle Type")]:Play(gun.Pos);
					-- end
				-- end
			-- end	
		-- end
	
		local startPos = self.BGFoot.Pos
		
		local pos = Vector(0, 0);
		SceneMan:CastObstacleRay(startPos, Vector(0, 9), pos, Vector(0, 0), self.ID, self.Team, 0, 3);				
		local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
		
		if terrPixel ~= 0 then -- 0 = air
			self.movementSounds.StepAdd:Play(self.Pos);
			if sound[terrPixel] ~= nil then
				sound[terrPixel]:Play(self.Pos);
			else -- default to concrete
				sound[177]:Play(self.Pos);
			end
		end
		
	elseif self.FGFoot then
	
		-- if math.random(0, 100) < 30 then
			-- if self.EquippedItem and IsHDFirearm(self.EquippedItem) then
				-- local gun = ToHDFirearm(self.EquippedItem)
				-- if gun:NumberValueExists("Gun Rattle Type") then
					-- if self.gunRattles[gun:GetNumberValue("Gun Rattle Type")] then
						-- self.gunRattles[gun:GetNumberValue("Gun Rattle Type")]:Play(gun.Pos);
					-- end
				-- end
			-- end	
		-- end
	
		local startPos = self.FGFoot.Pos
		
		local pos = Vector(0, 0);
		SceneMan:CastObstacleRay(startPos, Vector(0, 9), pos, Vector(0, 0), self.ID, self.Team, 0, 3);				
		local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
		
		if terrPixel ~= 0 then -- 0 = air
			self.movementSounds.StepAdd:Play(self.Pos);
			if sound[terrPixel] ~= nil then
				sound[terrPixel]:Play(self.Pos);
			else -- default to concrete
				sound[177]:Play(self.Pos);
			end
		end
		
	end
	
end

function Update(self)

	self.controller = self:GetController();
	
	if self.alternativeGib then
		HumanFunctions.DoAlternativeGib(self);
	end
	if self.automaticEquip then
		HumanFunctions.DoAutomaticEquip(self);
	end
	if self.armSway then
		HumanFunctions.DoArmSway(self, (self.Health/self.MaxHealth));	--Argument: shove strength
	end
	if self.visibleInventory then
		HumanFunctions.DoVisibleInventory(self, false);	--Argument: whether to show all items
	end
	
	-- Start modded code--
	
	if UInputMan:KeyPressed(39) then
		self.Health = self.Health - 70;
	end
	
	self.impulse = (self.Vel - self.lastVel) / TimerMan.DeltaTimeSecs * self.Vel.Magnitude * 0.1
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)
	
	self.voiceSound.Pos = self.Pos;
	
	if (self.Dying ~= true) then
		
		CommanderAIBehaviours.handleMovement(self);
		
		CommanderAIBehaviours.handleHealth(self);
		
		CommanderAIBehaviours.handleSuppression(self);
		
		CommanderAIBehaviours.handleAITargetLogic(self);
		
		CommanderAIBehaviours.handleVoicelines(self);
		
		--CommanderAIBehaviours.handleHeadFrames(self);

	else
	
		CommanderAIBehaviours.handleDying(self);
	
		CommanderAIBehaviours.handleHeadLoss(self);
	
		CommanderAIBehaviours.handleMovement(self);
		
	end

	if self.Status == 1 or self.Dying then
		CommanderAIBehaviours.handleRagdoll(self)
	end

	-- clear terrain stuff after we did everything that used em
	
	self.terrainCollided = false;
	self.terrainCollidedWith = nil;

end
-- End modded code --

function UpdateAI(self)
	self.AI:Update(self)

end

function Destroy(self)
	self.AI:Destroy(self)
	
	-- Start modded code --

	if not self.ToSettle then -- we have been gibbed
		self.voiceSound:Stop(-1);
		self.atmosphericVoiceSound:Stop(-1);
	end
	
	-- End modded code --
	
end
