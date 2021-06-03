function Create(self)

	self.parentSet = false;
	
	-- Sounds --
	
	self.preSound = CreateSoundContainer("Pre FlintlockPistol", "Mordhau.rte");
	
	self.noiseOutdoorsSound = CreateSoundContainer("NoiseOutdoors FlintlockPistol", "Mordhau.rte");
	
	self.noiseIndoorsSound = CreateSoundContainer("NoiseIndoors FlintlockPistol", "Mordhau.rte");
	
	self.cockSound = CreateSoundContainer("Cock FlintlockPistol", "Mordhau.rte");
	
	self.paperRipSound = CreateSoundContainer("PaperRip FlintlockPistol", "Mordhau.rte");
	
	self.powderTapSound = CreateSoundContainer("PowderTap FlintlockPistol", "Mordhau.rte");

	self.powderPourSound = CreateSoundContainer("PowderPour FlintlockPistol", "Mordhau.rte");
	
	self.paperInsertSound = CreateSoundContainer("PaperInsert FlintlockPistol", "Mordhau.rte");
	
	self.ramRodTakeSound = CreateSoundContainer("RamRodTake FlintlockPistol", "Mordhau.rte");
	
	self.ramRodInsertSound = CreateSoundContainer("RamRodInsert FlintlockPistol", "Mordhau.rte");
	
	self.ramRodRamSound = CreateSoundContainer("RamRodRam FlintlockPistol", "Mordhau.rte");
	
	self.ramRodRemoveSound = CreateSoundContainer("RamRodRemove FlintlockPistol", "Mordhau.rte");
	
	self.ramRodReplaceSound = CreateSoundContainer("RamRodReplace FlintlockPistol", "Mordhau.rte");
	
	self:SetNumberValue("DelayedFireTimeMS", 70)
	
	self.lastAge = self.Age
	
	self.originalSharpLength = self.SharpLength
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.original2SharpLength = self.SharpLength
	
	self.original2StanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.original2SharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 9
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = self.RotAngle
	
	self.smokeTimer = Timer();
	self.smokeDelayTimer = Timer();
	self.smokeDelay = 120;
	self.canSmoke = false
	
	self.reloadTimer = Timer();
	
	self.cockPrepareDelay = 700;
	self.cockAfterDelay = 450;
	self.paperRipPrepareDelay = 450;
	self.paperRipAfterDelay = 200;
	self.powderTapPrepareDelay = 200;
	self.powderTapAfterDelay = 450;
	self.powderPourPrepareDelay = 700;
	self.powderPourAfterDelay = 450;
	self.paperInsertPrepareDelay = 400;
	self.paperInsertAfterDelay = 450;
	self.ramRodTakePrepareDelay = 300;
	self.ramRodTakeAfterDelay = 350;
	self.ramRodInsertPrepareDelay = 350;
	self.ramRodInsertAfterDelay = 250;
	self.ramRodRamPrepareDelay = 200;
	self.ramRodRamAfterDelay = 200;
	self.ramRodRam2PrepareDelay = 200;
	self.ramRodRam2AfterDelay = 350;
	self.ramRodRemovePrepareDelay = 350;
	self.ramRodRemoveAfterDelay = 600;
	self.ramRodReplacePrepareDelay = 550;
	self.ramRodReplaceAfterDelay = 600;
	
	-- phases:
	-- 0 cock
	-- 1 paperrip
	-- 2 powdertap
	-- 3 powderpour
	-- 4 paperInsert
	-- 5 ramrodtake
	-- 6 ramrodinsert
	-- 7 ramrodram
	-- 8 ramrodram2
	-- 9 ramrodremove
	-- 10 ramrodreplace
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 9999;
	
	-- Progressive Recoil System 
	self.recoilAcc = 0 -- for sinous
	self.recoilStr = 0 -- for accumulator
	self.recoilStrength = 35 -- multiplier for base recoil added to the self.recoilStr when firing
	self.recoilPowStrength = 0.01 -- multiplier for self.recoilStr when firing
	self.recoilRandomUpper = 2 -- upper end of random multiplier (1 is lower)
	self.recoilDamping = 1.0
	
	self.recoilMax = 3 -- in deg.
	self.originalSharpLength = self.SharpLength
	-- Progressive Recoil System 
end

function Update(self)
	self.Frame = 0;
	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!
	
	if self.ID == self.RootID then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
	end
	
    -- Smoothing
    local min_value = -math.pi;
    local max_value = math.pi;
    local value = self.RotAngle - self.lastRotAngle
    local result;
    local ret = 0
    
    local range = max_value - min_value;
    if range <= 0 then
        result = min_value;
    else
        ret = (value - min_value) % range;
        if ret < 0 then ret = ret + range end
        result = ret + min_value;
    end
    
    self.lastRotAngle = self.RotAngle
    self.angVel = (result / TimerMan.DeltaTimeSecs) * self.FlipFactor
    
    if self.lastHFlipped ~= nil then
        if self.lastHFlipped ~= self.HFlipped then
            self.lastHFlipped = self.HFlipped
            self.angVel = 0
        end
    else
        self.lastHFlipped = self.HFlipped
    end
	
	-- PAWNIS RELOAD ANIMATION HERE
	if self:IsReloading() then

		if self.reloadPhase == 0 then
			self.reloadDelay = self.cockPrepareDelay;
			self.afterDelay = self.cockAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.cockSound;
	
			self.SharpLength = 0	
			
			self.originalSharpLength = 0
			
			self.rotationTarget = 15;
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.paperRipPrepareDelay;
			self.afterDelay = self.paperRipAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.paperRipSound;
			
			self.rotationTarget = 15;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.powderTapPrepareDelay;
			self.afterDelay = self.powderTapAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.powderTapSound;
			
			self.StanceOffset = Vector(4, 5)	
			self.SharpStanceOffset = Vector(4, 5)		
			
			self.originalStanceOffset = Vector(4, 5)	
			self.originalSharpStanceOffset = Vector(4, 5)	
			
			self.rotationTarget = 5;
			self.rotationSpeed = 9;
		
		elseif self.reloadPhase == 3 then
			self.reloadDelay = self.powderPourPrepareDelay;
			self.afterDelay = self.powderPourAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.powderPourSound;
			
			self.StanceOffset = Vector(7, 7)	
			self.SharpStanceOffset = Vector(7, 7)		
					
			self.originalStanceOffset = Vector(7, 7)	
			self.originalSharpStanceOffset = Vector(7, 7)
			
			self.rotationTarget = 50;
			
		elseif self.reloadPhase == 4 then
			self.reloadDelay = self.paperInsertPrepareDelay;
			self.afterDelay = self.paperInsertAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.paperInsertSound;
			
			self.StanceOffset = Vector(6, 7)	
			self.SharpStanceOffset = Vector(6, 7)		
			
			self.originalStanceOffset = Vector(6, 7)	
			self.originalSharpStanceOffset = Vector(6, 7)	
			
			self.rotationTarget = 60;
			self.rotationSpeed = 5;
			
		elseif self.reloadPhase == 5 then
			self.reloadDelay = self.ramRodTakePrepareDelay;
			self.afterDelay = self.ramRodTakeAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.ramRodTakeSound;
			
			self.StanceOffset = Vector(7, 8)	
			self.SharpStanceOffset = Vector(7, 8)		
			
			self.originalStanceOffset = Vector(7, 8)	
			self.originalSharpStanceOffset = Vector(7, 8)	
			
			self.rotationTarget = 60;
			
		elseif self.reloadPhase == 6 then
			self.reloadDelay = self.ramRodInsertPrepareDelay;
			self.afterDelay = self.ramRodInsertAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.ramRodInsertSound;
			
			self.StanceOffset = Vector(8, 9)	
			self.SharpStanceOffset = Vector(8, 9)		
			
			self.originalStanceOffset = Vector(8, 9)	
			self.originalSharpStanceOffset = Vector(8, 9)
			
			self.rotationTarget = 75;
			
		elseif self.reloadPhase == 7 then
			self.reloadDelay = self.ramRodRamPrepareDelay;
			self.afterDelay = self.ramRodRamAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.ramRodRamSound;
			
			self.rotationTarget = 75;
			
		elseif self.reloadPhase == 8 then
			self.reloadDelay = self.ramRodRam2PrepareDelay;
			self.afterDelay = self.ramRodRam2AfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.ramRodRamSound;
			
			self.rotationTarget = 75;
			
		elseif self.reloadPhase == 9 then
			self.reloadDelay = self.ramRodRemovePrepareDelay;
			self.afterDelay = self.ramRodRemoveAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.ramRodRemoveSound;
			
			self.rotationTarget = 75;
			
		elseif self.reloadPhase == 10 then
			self.reloadDelay = self.ramRodReplacePrepareDelay;
			self.afterDelay = self.ramRodReplaceAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.ramRodReplaceSound;
			
			self.StanceOffset = Vector(6, 7)	
			self.SharpStanceOffset = Vector(6, 7)		
			
			self.originalStanceOffset = Vector(6, 7)	
			self.originalSharpStanceOffset = Vector(6, 7)
			
			self.rotationTarget = 40;
			
		end
		
		if self.prepareSoundPlayed ~= true then
			self.prepareSoundPlayed = true;
			if self.prepareSound then
				self.prepareSound:Play(self.Pos);
			end
		end
	
		if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
			
			if self.afterSoundPlayed ~= true then
			
				if self.reloadPhase == 0 then
					self.phaseOnStop = 1;
					
					self.horizontalAnim = self.horizontalAnim - 3
					self.angVel = self.angVel - 5;
					
				elseif self.reloadPhase == 1 then
					self.phaseOnStop = 1;
					
				elseif self.reloadPhase == 2 then
					self.phaseOnStop = 1;
					
				elseif self.reloadPhase == 3 then
					self.phaseOnStop = 3;
					
				elseif self.reloadPhase == 4 then
					self.phaseOnStop = 4;
					
				elseif self.reloadPhase == 5 then
					self.phaseOnStop = 5;
		
				elseif self.reloadPhase == 6 then
					self.phaseOnStop = 6;
				
				elseif self.reloadPhase == 7 then
					self.phaseOnStop = 7;
					
					self.verticalAnim = self.verticalAnim + 1
				
				elseif self.reloadPhase == 8 then
					self.phaseOnStop = 8;
					
					self.verticalAnim = self.verticalAnim + 1
					
				elseif self.reloadPhase == 9 then
					self.phaseOnStop = 9;
					
				elseif self.reloadPhase == 10 then
					self.phaseOnStop = 10;
				
				else
					self.phaseOnStop = nil;
				end
			
				self.afterSoundPlayed = true;
				if self.afterSound then
					self.afterSound:Play(self.Pos);
				end
			end
			if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
				self.reloadTimer:Reset();
				self.afterSoundPlayed = false;
				self.prepareSoundPlayed = false;
				
				if self.reloadPhase == 10 then
					self.ReloadTime = 0;
					self.reloadPhase = 0;
					self.phaseOnStop = nil;
					
					self.SharpLength = self.original2SharpLength
					
					self.StanceOffset = self.original2StanceOffset
					self.SharpStanceOffset = self.original2SharpStanceOffset
					
					self.originalSharpLength = self.original2SharpLength
					
					self.originalStanceOffset = self.original2StanceOffset
					self.originalSharpStanceOffset = self.original2SharpStanceOffset
					
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		end		
	else
		
		self.reloadTimer:Reset();
		self.afterSoundPlayed = false;
		self.prepareSoundPlayed = false;
		
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop;
			self.phaseOnStop = nil;
		end
		
		self.ReloadTime = 15000;
		
	end
	
	if self.FiredFrame then
		self.Frame = 0;
		self.angVel = self.angVel - RangeRand(0.7,1.1) * 7
		
		self.smokeDelay = 120
		self.canSmoke = true
		self.smokeTimer:Reset()
		
		local xSpread = 0
		
		local smokeAmount = 75
		local particleSpread = 25
		
		local smokeLingering = math.sqrt(smokeAmount / 8) * 4
		local smokeVelocity = (1 + math.sqrt(smokeAmount / 8) ) * 0.5
		
		-- Muzzle main smoke
		for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
			local spread = math.pi * RangeRand(-1, 1) * 0.05
			local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
			
			local xSpreadVec = Vector(xSpread * self.FlipFactor * math.random() * -1, 0):RadRotate(self.RotAngle)
			
			local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
			particle.Pos = self.MuzzlePos + xSpreadVec
			particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end
		
		-- Muzzle musket smoke
		for i = 1, 60 do -- my God
			local spread = math.pi * RangeRand(-1, 1) * 0.05
			local velocity = 50 * RangeRand(0.1, 0.9) * 0.4;
			
			local xSpreadVec = Vector(xSpread * self.FlipFactor * math.random() * -1, 0):RadRotate(self.RotAngle)
			
			local particle = CreateMOSParticle("Tiny Smoke Ball 1");
			particle.Pos = self.MuzzlePos + xSpreadVec
			particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * (smokeVelocity * 0.2)
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.9 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = -0.0001
			MovableMan:AddParticle(particle);
		end		
		
		-- Muzzle side smoke
		for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
			local vel = Vector(110 * self.FlipFactor,0):RadRotate(self.RotAngle)
			
			local xSpreadVec = Vector(xSpread * self.FlipFactor * math.random() * -1, 0):RadRotate(self.RotAngle)
			
			local particle = CreateMOSParticle("Tiny Smoke Ball 1");
			particle.Pos = self.MuzzlePos + xSpreadVec
			-- oh LORD
			particle.Vel = self.Vel + ((Vector(vel.X, vel.Y):RadRotate(math.pi * (math.random(0,1) * 2.0 - 1.0) * 0.5 + math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.3 + Vector(vel.X, vel.Y):RadRotate(math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.2) * 0.5) * smokeVelocity;
			-- have mercy
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end
		
		-- Muzzle flash-smoke
		particleSpread = 25
		for i = 1, math.ceil(smokeAmount / (math.random(5,10) * 0.5)) do
			local spread = RangeRand(-math.rad(particleSpread), math.rad(particleSpread)) * (1 + math.random(0,3) * 0.3)
			local velocity = 110 * 0.6 * RangeRand(0.9,1.1)
			
			local xSpreadVec = Vector(xSpread * self.FlipFactor * math.random() * -1, 0):RadRotate(self.RotAngle)
			
			local particle = CreateMOSParticle("Flame Smoke 1 Micro")
			particle.Pos = self.MuzzlePos + xSpreadVec
			particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
			particle.Team = self.Team
			particle.Lifetime = particle.Lifetime * RangeRand(0.9,1.2) * 0.75 * smokeLingering
			particle.AirResistance = particle.AirResistance * 2.5 * RangeRand(0.9,1.1)
			particle.IgnoresTeamHits = true
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end
		--
	
		local outdoorRays = 0;

		if self.parent and self.parent:IsPlayerControlled() then
			self.rayThreshold = 2; -- this is the first ray check to decide whether we play outdoors
			local Vector2 = Vector(0,-700); -- straight up
			local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
			local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
			local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
			local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
			local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

			self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
			self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft};
		else
			self.rayThreshold = 1; -- has to be different for AI
			local Vector2 = Vector(0,-700); -- straight up
			local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			local Vector4 = Vector(0,0); -- dont need this but is needed as an arg		
			self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			self.rayTable = {self.ray};
		end
		
		for _, rayLength in ipairs(self.rayTable) do
			if rayLength < 0 then
				outdoorRays = outdoorRays + 1;
			end
		end
		
		if outdoorRays >= self.rayThreshold then
			self.noiseOutdoorsSound:Play(self.Pos);
		else
			self.noiseIndoorsSound:Play(self.Pos);
		end
	end
	
	-- Animation
	if self.parent then
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 15.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-1,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,5) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 4)
		
		-- Progressive Recoil Update
		if self.FiredFrame then
			self.recoilStr = self.recoilStr + ((math.random(10, self.recoilRandomUpper * 10) / 10) * 0.5 * self.recoilStrength) + (self.recoilStr * 0.6 * self.recoilPowStrength)
			self:SetNumberValue("recoilStrengthBase", self.recoilStrength * (1 + self.recoilPowStrength) / self.recoilDamping)
		end
		self:SetNumberValue("recoilStrengthCurrent", self.recoilStr)
		
		self.recoilStr = math.floor(self.recoilStr / (1 + TimerMan.DeltaTimeSecs * 8.0 * self.recoilDamping) * 1000) / 1000
		self.recoilAcc = (self.recoilAcc + self.recoilStr * TimerMan.DeltaTimeSecs) % (math.pi * 4)
		
		local recoilA = (math.sin(self.recoilAcc) * self.recoilStr) * 0.05 * self.recoilStr
		local recoilB = (math.sin(self.recoilAcc * 0.5) * self.recoilStr) * 0.01 * self.recoilStr
		local recoilC = (math.sin(self.recoilAcc * 0.25) * self.recoilStr) * 0.05 * self.recoilStr
		
		local recoilFinal = math.max(math.min(recoilA + recoilB + recoilC, self.recoilMax), -self.recoilMax)
		
		self.SharpLength = math.max(self.originalSharpLength - (self.recoilStr * 3 + math.abs(recoilFinal)), 0)
		
		self.rotationTarget = self.rotationTarget + recoilFinal -- apply the recoil
		-- Progressive Recoil Update		
		
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation) * self.FlipFactor
		
		self.InheritedRotAngleOffset = total * self.FlipFactor;
		-- self.RotAngle = self.RotAngle + total;
		-- self:SetNumberValue("MagRotation", total);
		
		-- local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		-- local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		-- self.Pos = self.Pos + offsetTotal;
		-- self:SetNumberValue("MagOffsetX", offsetTotal.X);
		-- self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
		self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
		
	end
	
	if self.canSmoke and not self.smokeTimer:IsPastSimMS(6700) then

		if self.smokeDelayTimer:IsPastSimMS(self.smokeDelay) then
			
			self.smokeDelay = self.smokeDelay + 5;
			local poof = CreateMOSParticle("Tiny Smoke Ball 1");
			poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle);
			poof.Lifetime = poof.Lifetime * RangeRand(0.3, 1.3) * 0.9;
			poof.Vel = self.Vel * 0.1
			poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
			MovableMan:AddParticle(poof);
			self.smokeDelayTimer:Reset()
		end
	end
end