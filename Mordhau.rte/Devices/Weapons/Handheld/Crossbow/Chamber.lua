function Create(self)

	self.parentSet = false;
	
	-- Sounds --
	
	self.twangSweetenerSound = CreateSoundContainer("TwangSweetener Crossbow", "Mordhau.rte");
	
	self.pullBackSound = CreateSoundContainer("PullBack Crossbow", "Mordhau.rte");
	
	self.lockSound = CreateSoundContainer("Lock Crossbow", "Mordhau.rte");
	
	self.boltLoadSound = CreateSoundContainer("BoltLoad Crossbow", "Mordhau.rte");
	
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
	
	self.reloadTimer = Timer();
	
	self.pullBackPrepareDelay = 1300;
	self.pullBackAfterDelay = 350;
	self.lockPrepareDelay = 350;
	self.lockAfterDelay = 400;
	self.boltLoadPrepareDelay = 400;
	self.boltLoadAfterDelay = 400;
	
	-- phases:
	-- 0 pullBack
	-- 1 Lock
	-- 2 boltLoad
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 9999;
	
	-- Progressive Recoil System 
	self.recoilAcc = 0 -- for sinous
	self.recoilStr = 0 -- for accumulator
	self.recoilStrength = 10 -- multiplier for base recoil added to the self.recoilStr when firing
	self.recoilPowStrength = 0.01 -- multiplier for self.recoilStr when firing
	self.recoilRandomUpper = 2 -- upper end of random multiplier (1 is lower)
	self.recoilDamping = 1.0
	
	self.recoilMax = 2 -- in deg.
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
			self.reloadDelay = self.pullBackPrepareDelay;
			self.afterDelay = self.pullBackAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.pullBackSound;
			
			if self.reloadTimer:IsPastSimMS(self.pullBackPrepareDelay/2) then
			
				self.SharpLength = 0	
				
				self.originalSharpLength = 0
				
				self.StanceOffset = Vector(4, 7)	
				self.SharpStanceOffset = Vector(4, 7)		
				
				self.originalStanceOffset = Vector(4, 7)	
				self.originalSharpStanceOffset = Vector(4, 7)			
			
				self.rotationTarget = -60;
				
			end
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.lockPrepareDelay;
			self.afterDelay = self.lockAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.lockSound;
			
			self.rotationTarget = -40;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.boltLoadPrepareDelay;
			self.afterDelay = self.boltLoadAfterDelay;			
			self.prepareSound = nil;
			self.afterSound = self.boltLoadSound;
			
			self.StanceOffset = Vector(4, 5)	
			self.SharpStanceOffset = Vector(4, 5)		
			
			self.originalStanceOffset = Vector(4, 5)	
			self.originalSharpStanceOffset = Vector(4, 5)	
			
			self.rotationTarget = 5;
			
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
					self.phaseOnStop = 0;
					
				elseif self.reloadPhase == 1 then
					self.phaseOnStop = 1;
					
				elseif self.reloadPhase == 2 then
					self.phaseOnStop = 2;
					
					self.verticalAnim = self.verticalAnim + 1;
				
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
				
				if self.reloadPhase == 2 then
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
		
		self.twangSweetenerSound.Pitch = math.random(95, 105) / 100;
		self.twangSweetenerSound:Play(self.Pos);

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
end