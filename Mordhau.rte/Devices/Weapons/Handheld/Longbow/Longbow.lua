

function Create(self)
	self.parentSet = false;
	
	self.soundFire = CreateSoundContainer("Longbow Fire", "Mordhau.rte");
	self.soundDraw = CreateSoundContainer("Longbow Draw", "Mordhau.rte");
	self.soundDrop = CreateSoundContainer("Longbow Arrow Bounce", "Mordhau.rte");
	
	
	self.pastReloadTimer = Timer()
	
	self.chargeTimer = Timer()
	self.chargeTime = 2600
	self.lastChargeFactor = 0
	self.charging = false
	
	self.arrowVelocityMax = 65
	self.arrowVelocityMin = 15
	
	self.shoot = false
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	
	self.chargingStanceOffset = Vector(math.abs(self.SharpStanceOffset.X), self.SharpStanceOffset.Y)
	
	self.originalJointOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
	
	self.lastAge = self.Age + 0
	
	self.laserTimer = Timer();
	self.guideTable = {};

	self.projectileVel = 100;
	if self.Magazine ~= null and self.Magazine.RoundCount ~= 0 then
		self.projectileVel = self.Magazine.NextRound.FireVel;
	end

	self.maxTrajectoryPars = 120;
end

function Update(self)
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
	
	local sharpaiming = false
	local stanceOffset = Vector()
	
	-- Check if switched weapons/hide in the inventory, etc.
	if self.Age > (self.lastAge + TimerMan.DeltaTimeSecs * 2000) then
		--
		self.chargeTimer:Reset()
		self.charging = false
		self.shoot = false
		self.lastChargeFactor = 0
	end
	self.lastAge = self.Age + 0
	
	if self.parent then
		sharpaiming = self.parent:GetController():IsState(Controller.AIM_SHARP) == true and self.parent:GetController():IsState(Controller.MOVE_LEFT) == false and self.parent:GetController():IsState(Controller.MOVE_RIGHT) == false
		
		if self:DoneReloading() then
			--
			self.chargeTimer:Reset()
			self.charging = false
			self.shoot = false
			
			self.pastReloadTimer:Reset()
			
			self.JointOffset = self.originalJointOffset
			
			self.Frame = 0
		elseif self:IsReloading() then
			--
			self.chargeTimer:Reset()
			self.charging = false
			self.shoot = false
			
			self.pastReloadTimer:Reset()
			
			--self.JointOffset = self.originalJointOffset
			self.JointOffset = (self.JointOffset + self.originalJointOffset * TimerMan.DeltaTimeSecs * 15) / (1 + TimerMan.DeltaTimeSecs * 15)
			
			self.Frame = 0
		else
			local active = self:IsActivated()
			self:Deactivate()
			
			local chargeFactor = math.min(self.chargeTimer.ElapsedSimTimeMS / self.chargeTime, 1)
			if self.Magazine then
				self.Magazine.JointOffset.X = chargeFactor * 8 - 5
				
				--self.JointOffset = Vector(self.Magazine.JointOffset.X * -0.5 - 6, self.Magazine.JointOffset.Y)
				
				self.JointOffset = (self.JointOffset + Vector(self.Magazine.JointOffset.X * -0.5 - 6, self.Magazine.JointOffset.Y) * TimerMan.DeltaTimeSecs * 15) / (1 + TimerMan.DeltaTimeSecs * 15)
				
				--self.StanceOffset = Vector((1 - chargeFactor) * 2 + 1, self.originalStanceOffset.Y)
				--self.StanceOffset = self.originalStanceOffset + Vector(chargeFactor * -5, 0) - Vector(-self.Magazine.JointOffset.X - 8, self.Magazine.JointOffset.Y)
				
				stanceOffset = Vector((1 - chargeFactor) * 3 + 2, self.originalStanceOffset.Y)
				
				self.Frame = math.floor(chargeFactor * 2 + 0.5)
				
				--self.lastChargeFactor = chargeFactor
			else
				self.JointOffset = self.originalJointOffset
				self.Frame = 0
			end
			
			if active and self.Magazine then
				if not self.charging then
					if not self.parent:IsPlayerControlled() then
						self.AICharging = true;
					end
					self.charging = true
					self.chargeTimer:Reset()
					self.soundDraw:Play(self.Pos)
				else
					stanceOffset = Vector((2 - chargeFactor) * 5 + 2, self.chargingStanceOffset.Y)				

					-- bring it in an extreme angles to avoid issues
					if math.abs(self.RotAngle) > 0.85 then	
						stanceOffset = Vector((1 - chargeFactor) * 5 + -1, self.chargingStanceOffset.Y)
					end
					
					self.shakeMult = 0
					
					-- arghhhh hard to keep bow arghh shakey
					if (self.chargeTimer.ElapsedSimTimeMS) > (self.chargeTime * 2) then
						self.shakeMult = ((self.chargeTimer.ElapsedSimTimeMS-(self.chargeTime*2)) / self.chargeTime) * 3;
						
						if self.shakeMult > 6 then
							self:Deactivate();
							self.charging = false
							self.shoot = true
							self.lastChargeFactor = chargeFactor
							self.chargeTimer:Reset()
						end
						
						self.RotAngle = self.RotAngle + (math.rad(math.random((self.shakeMult*-100), (self.shakeMult*100))/100)*self.FlipFactor)
					end
				
				end
			elseif self.parent:IsPlayerControlled() then
				if self.charging then
					self.soundDraw:FadeOut(50);
					self.charging = false
					self.lastChargeFactor = chargeFactor
					if self.lastChargeFactor > 0.25 then
						self.shoot = true
					end
				end
				self.chargeTimer:Reset()
			elseif self.charging and self.AICharging then
				if self.chargeTimer:IsPastSimMS(self.chargeTime) then
					self.soundDraw:FadeOut(50);
					self.charging = false
					self.lastChargeFactor = chargeFactor
					self.shoot = true
					self.AICharging = false;
				end
			end
			
			self.projectileVel = self.arrowVelocityMin + (self.arrowVelocityMax - self.arrowVelocityMin) * chargeFactor
			
			if self.shoot then
				self:Activate()
			end
			
			if self.pastReloadTimer:IsPastSimMS(60) then
				if self.FiredFrame then
					self.RotAngle = self.RotAngle + (math.rad(math.random((self.shakeMult*-100), (self.shakeMult*100))/100)*self.FlipFactor)
					
					--
					local arrow = CreateMOSRotating("Longbow Arrow", "Mordhau.rte");
					arrow.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle + RangeRand(-0.1,0.1));
					arrow.Vel = self.Vel + Vector(1 * self.FlipFactor,0):RadRotate(self.RotAngle) * (self.arrowVelocityMin + (self.arrowVelocityMax - self.arrowVelocityMin) * self.lastChargeFactor) * RangeRand(0.95, 1.05);
					arrow.RotAngle = self.RotAngle + (math.pi * (-self.FlipFactor + 1) / 2)
					
					arrow.Team = self.parent.Team;
					arrow.IgnoresTeamHits = true;
					
					MovableMan:AddParticle(arrow);
					
					self.soundFire.Pitch = math.min(1.3, (2 - self.lastChargeFactor))
					self.soundFire.Volume = math.max(self.lastChargeFactor, 0.75);
					self.soundFire:Play(self.Pos)
					
					self.lastChargeFactor = 0
					
					self.soundDraw:Stop()
					
					self.shoot = false
					self.chargeTimer:Reset()
				end
			elseif self.Magazine and self.Magazine.RoundCount < 1 then
				self.Magazine.RoundCount = 1
			end
		end
	else
		self.AICharging = false;
	end
	
	local stringMode = 0
	
	if self.Magazine then
		if self.Magazine.RoundCount < 1 then
			self.Magazine.Scale = 0
			if self:IsActivated() then
				self:Reload();
			end
		else		
			self.Magazine.Scale = 1
			
			stringMode = 1
		end
	elseif self:IsActivated() then
		self:Reload();
	end
	
	local stringStartPosA = self.Pos + Vector((-2 - self.Frame) * self.FlipFactor, -14):RadRotate(self.RotAngle)
	local stringStartPosB = self.Pos + Vector((-2 - self.Frame) * self.FlipFactor, 14):RadRotate(self.RotAngle)
	local stringMiddlePos = self.Pos + Vector((-2 - self.Frame) * self.FlipFactor, 0):RadRotate(self.RotAngle)
	local stringColor = 168
	
	if stringMode == 1 then
		local arrowPos = self.Magazine.Pos + Vector(-6 * self.Magazine.FlipFactor, 0):RadRotate(self.Magazine.RotAngle)
		arrowPos = SceneMan:ShortestDistance(stringMiddlePos,arrowPos,SceneMan.SceneWrapsX)
		--arrowPos:RadRotate(-self.Magazine.RotAngle)
		--arrowPos.X = math.min(arrowPos.X, 0)
		--arrowPos:RadRotate(self.Magazine.RotAngle)
		arrowPos = arrowPos + stringMiddlePos
		
		PrimitiveMan:DrawLinePrimitive(stringStartPosA, stringStartPosA + SceneMan:ShortestDistance(stringStartPosA,arrowPos,SceneMan.SceneWrapsX), stringColor)
		PrimitiveMan:DrawLinePrimitive(stringStartPosB, stringStartPosB + SceneMan:ShortestDistance(stringStartPosB,arrowPos,SceneMan.SceneWrapsX), stringColor)
	else
		PrimitiveMan:DrawLinePrimitive(stringStartPosA, stringStartPosA + SceneMan:ShortestDistance(stringStartPosA,stringStartPosB,SceneMan.SceneWrapsX), stringColor)
	end
	
	if self:IsReloading() or not self.Magazine then
		self.SharpStanceOffset = Vector(10,4)
		self.StanceOffset = Vector(10,4)
	else
		self.SharpStanceOffset = stanceOffset + Vector(1, -2)
		self.StanceOffset = stanceOffset
	end
	
	
	--
	--[[
	local actor = self.parent
	if self.charging and not self:IsReloading() and MovableMan:IsActor(actor) and ToActor(actor):IsPlayerControlled() and ToActor(actor):GetController():IsState(Controller.AIM_SHARP) then
		if self.laserTimer:IsPastSimMS(25) then
			self.laserTimer:Reset();

			self.guideTable = {};
			self.guideTable[1] = Vector(self.MuzzlePos.X,self.MuzzlePos.Y);

			local actor = ToActor(actor);
			local guideParPos = self.MuzzlePos;
			local guideParVel = Vector(self.projectileVel * self.FlipFactor,0):RadRotate(self.RotAngle)
			--local guideParVel = Vector(self.projectileVel,0):RadRotate(actor:GetAimAngle(true));
			for i = 1, self.maxTrajectoryPars do
				guideParVel = guideParVel + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs;
				guideParPos = guideParPos + guideParVel * rte.PxTravelledPerFrame;
				-- No need to wrap the seam manually, primitives can handle out-of-scene coordinates correctly
				--if SceneMan.SceneWrapsX == true then
				--	if guideParPos.X > SceneMan.SceneWidth then
				--		guideParPos = Vector(guideParPos.X - SceneMan.SceneWidth,guideParPos.Y);
				--	elseif guideParPos.X < 0 then
				--		guideParPos = Vector(SceneMan.SceneWidth + guideParPos.X,guideParPos.Y);
				--	end
				--end
				if SceneMan:GetTerrMatter(guideParPos.X,guideParPos.Y) == 0 then
					self.guideTable[#self.guideTable+1] = guideParPos;
				else
					local hitPos = Vector(self.guideTable[#self.guideTable].X,self.guideTable[#self.guideTable].Y);
					SceneMan:CastStrengthRay(self.guideTable[#self.guideTable],SceneMan:ShortestDistance(self.guideTable[#self.guideTable],guideParPos,false),0,hitPos,3,0,false);
					self.guideTable[#self.guideTable+1] = hitPos;
					break;
				end
			end
		end
	else
		self.guideTable = {};
	end

	if #self.guideTable > 1 then
		for i = 1, #self.guideTable do
			PrimitiveMan:DrawLinePrimitive(self.guideTable[i],self.guideTable[i],120);
		end
		--PrimitiveMan:DrawCirclePrimitive(self.guideTable[#self.guideTable],4,120);
	end
	]]
end

function OnDetach(self)
	self.playDrop = true;
end

function OnCollideWithTerrain(self, terrainID) -- delet
	if self.Magazine and self.playDrop == true then
		--self.Magazine.JointStrength = -5
		self:RemoveAttachable(self.Magazine, true, false)
		self.playDrop = false;
		self.soundDrop:Play(self.Pos)
	end
end