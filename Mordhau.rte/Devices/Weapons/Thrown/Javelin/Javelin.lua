function Create(self)

	self.equipSound = CreateSoundContainer("Equip Javelin", "Mordhau.rte");
	self.equipSound.Pitch = 1.0;
	
	self.pickUpSound = CreateSoundContainer("Wood Pickup Mordhau", "Mordhau.rte");
	self.pickUpSound.Pitch = 1.0;
	
	self.bounceSound = CreateSoundContainer("Bounce Javelin", "Mordhau.rte");
	self.bounceSoundPlay = true;
	
	self.throwSound = CreateSoundContainer("Throw Javelin", "Mordhau.rte");
	
	self.flightLoopSound = CreateSoundContainer("FlightLoop Javelin", "Mordhau.rte");
	
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
	
	self.states = {Held = 0, Thrown = 1, StuckMO = 2, StuckTerrain = 3, Dropped = 4}
	
	self.stickMOUID = -1
	self.stickOffset = Vector()
	self.stickRotation = 0
	
	self.activateTimer = Timer()
	
	self.activated = false
	
	self.heldAngleOffset = math.pi * 0.5
	self.InheritedRotAngleOffset = self.heldAngleOffset
	
	self.settleTimer = Timer()
	self.forceSettle = false
	
	if self:GetParent() then
		self.state = self.states.Held
	else
		self.state = self.states.Dropped
	end
end

function OnAttach(self)
	self.activated = false
	
	if self.state == self.states.Dropped or self.state == self.states.StuckTerrain or self.state == self.states.StuckMO then
		self.state = self.states.Held
		self.stickMOUID = -1
		self.PinStrength = 0
	end
	
	self.HUDVisible = true
end

function Update(self)
	
	if self.state == self.states.Held then
		self.bounceSoundPlay = true
		
		self.PinStrength = 0
		
		local parent = self:GetRootParent()
		if parent and IsAHuman(parent) then
			parent = ToAHuman(parent)
			
			-- Throw animations, etc
			if self:IsActivated() then
				if not self.activated then
					self.activated = true
					self.activateTimer:Reset()
				end
				local factor = math.min(self.activateTimer.ElapsedSimTimeMS / 500, 1)
				--self.InheritedRotAngleOffset = self.heldAngleOffset + math.pi * factor * 0.5
				--self.StartThrowOffset = Vector(-6, -1) + Vector(-6, -7) * factor
				
				local value = -ToArm(self:GetParent()).RotAngle + parent:GetAimAngle(true) - self.heldAngleOffset;
				local ret = (value + math.pi) % (math.pi * 2);
				if ret < 0 then ret = ret + (math.pi * 2) end
				local result = ret - math.pi;
				
				self.InheritedRotAngleOffset = self.heldAngleOffset + result * factor * self.FlipFactor
			else
				self.InheritedRotAngleOffset = self.heldAngleOffset
				self.activateTimer:Reset()
			end
		else
			
			if self.activated then
				self.state = self.states.Thrown
				self.throwSound:Play(self.Pos)
				self.flightLoopSound:Play(self.Pos)
				
				self.HUDVisible = false
			else
				self.state = self.states.Dropped
				
				self.HUDVisible = true
			end
		end
	elseif self.state == self.states.Thrown then
	
		self.PinStrength = 0
		
		self.flightLoopSound.Pos = self.Pos;

		self.flightLoopSound.Volume = math.min(self.Vel.Magnitude / 35, 35) + 0.05;
		self.flightLoopSound.Pitch = (self.Vel.Magnitude / 35) + 1;
		
		-- Rotate + areodynamics
		local v = self.Vel.Magnitude;
		
		local min_value = -math.pi;
		local max_value = math.pi;
		local value = self.RotAngle - self.Vel.AbsRadAngle + math.pi * (self.FlipFactor + 1) * 0.5;
		local result;
		
		local range = max_value - min_value;
		if range <= 0 then
			result = min_value;
		else
			local ret = (value - min_value) % range;
			if ret < 0 then ret = ret + range end
			result = ret + min_value;
		end
		
		local a = 1.5 * v / 60;
		local b = 1 * v / 60;
		
		self.RotAngle = self.RotAngle + result * TimerMan.DeltaTimeSecs * a * 0.5;
		self.AngularVel = self.AngularVel + result * TimerMan.DeltaTimeSecs * a * 25;
		self.AngularVel = (self.AngularVel) / (1 + TimerMan.DeltaTimeSecs * b)
		
		self.Vel = (self.Vel) / (1 + TimerMan.DeltaTimeSecs * b * 0.6)
		
		-- Stick to things!
		if self.Vel.Magnitude > 6 then
			
			local rayOrigin = self.Pos
			local rayVec = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + self.IndividualRadius);
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
			if moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local MO = MovableMan:GetMOFromID(moCheck)
				if IsMOSRotating(MO) then
					-- self.stickMO = ToMOSRotating(MO);
					-- local stickVec = SceneMan:ShortestDistance(self.stickMO.Pos,rayHitPos,SceneMan.SceneWrapsX):RadRotate(-self.stickMO.RotAngle);
					-- self.stickVecX = stickVec.X;
					-- self.stickVecY = stickVec.Y;
					-- self.stickRot = self.RotAngle - self.stickMO.RotAngle;
					
					self.state = self.states.StuckMO
					local stickMO = ToMOSRotating(MO)
					local stickVec = SceneMan:ShortestDistance(stickMO.Pos,rayHitPos,SceneMan.SceneWrapsX):RadRotate(-stickMO.RotAngle);
					self.stickMOUID = stickMO.UniqueID
					self.stickOffset = Vector(stickVec.X, stickVec.Y)
					self.stickRotation = self.RotAngle - stickMO.RotAngle
					
					self.settleTimer:Reset()
					
					local addWounds = true;
					
					-- Get the material and set damage multiplier
					local material = stickMO.Material.PresetName;
					
					-- get wounds to check for dent metal
					local woundName = stickMO:GetEntryWoundPresetName()
					local woundNameExit = stickMO:GetExitWoundPresetName()
					local woundOffset = (rayHitPos - stickMO.Pos):RadRotate(stickMO.RotAngle * -1.0)
					
					
					-- Add extra effects based on the material
					if string.find(material,"Flesh") then
						local blood = CreateMOSParticle("Blood Spray Particle");
						blood.Pos = rayHitPos - Vector(self.Vel.X,self.Vel.Y) * rte.PxTravelledPerFrame * 0.1;
						blood.Vel = Vector(self.Vel.X,self.Vel.Y):RadRotate(math.pi * RangeRand(-0.1, 0.1)) * RangeRand(0.05, 0.1) * -1.0;
						MovableMan:AddParticle(blood);
						self.soundHitFlesh:Play(self.Pos);
					else
						for i = 1, 3 do
							local bloofm = CreateMOSParticle("Tiny Smoke Trail 1");
							bloofm.Pos = rayHitPos - Vector(self.Vel.X,self.Vel.Y) * rte.PxTravelledPerFrame * 0.1;
							bloofm.Vel = Vector(self.Vel.X,self.Vel.Y):RadRotate(math.pi * RangeRand(-0.2, 0.2)) * RangeRand(0.1, 0.4) * -1.0;
							MovableMan:AddParticle(bloofm);
						end
						if string.find(material,"Metal") or string.find(woundName,"Dent") or string.find(woundNameExit,"Dent") then
							self.soundHitMetal:Play(self.Pos);
						end
					end
					
					local effect = CreateMOSRotating("Longbow Arrow Hit Effect", "Mordhau.rte");
					if effect then
						effect.Pos = rayHitPos
						MovableMan:AddParticle(effect);
						effect:GibThis();
					end
					
					local actorHit = stickMO:GetRootParent()
					local damage = math.min(math.max((self.Vel.Magnitude - 6) / 30, 0), 2)
					
					if (actorHit and IsActor(actorHit)) then
						
						if IsAttachable(stickMO) then
							-- two different ways to dismember: 1. if wounds would gib the limb hit, dismember it instead 2. low hp
							if stickMO.WoundCount + damage >= stickMO.GibWoundLimit then
								ToAttachable(stickMO):RemoveFromParent(true, true);
								addWounds = false;
								stickMO.Vel = self.Vel * 0.5
								
								self.flightLoopSound:Stop(-1);
							elseif ToActor(actorHit).Health < 10 and math.random(0, 100) < 50 then
								ToAttachable(stickMO):RemoveFromParent(true, true);
								addWounds = false;
								stickMO.Vel = self.Vel * 0.5
								
								self.flightLoopSound:Stop(-1);
							end
						end							
						
					end
					
					if addWounds == true then
						local damage = math.min(math.max((self.Vel.Magnitude - 6) / 30, 0), 2)
						for i = 1, math.max(6 * damage, 1) do
							stickMO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					end
					
					self.flightLoopSound:Stop(-1);
					
					self.PinStrength = 1000;
					self.Vel = Vector()
					self.AngularVel = 0;
					
					self.HitsMOs = false;
					
					self.HUDVisible = false
				end
				
				self.decayTimer = Timer();
			elseif self.Vel.Magnitude > 12 then
				local terrCheck = SceneMan:CastStrengthSumRay(rayOrigin, rayOrigin + rayVec, 2, 0); -- Raycast
				if terrCheck > 5 then
					local rayHitPos = SceneMan:GetLastRayHitPos()
					local stickDeepness = 0.1 + ((math.floor(self.UniqueID * 1.5) % 6) / 6)
					
					self.Pos = rayHitPos - Vector(self.IndividualRadius * stickDeepness, 0):RadRotate(self.RotAngle + math.pi * (-self.FlipFactor + 1) * 0.5);
					
					self.state = self.states.StuckTerrain
					self.settleTimer:Reset()
					
					local terrPixel = SceneMan:GetTerrMatter(rayHitPos.X, rayHitPos.Y)
					if terrPixel ~= 0 then -- 0 = air
						if self.terrainSounds.Impact[terrPixel] ~= nil then
							self.terrainSounds.Impact[terrPixel]:Play(self.Pos);
						else -- default to concrete
							self.terrainSounds.Impact[177]:Play(self.Pos);
						end
					end
					
					self.PinStrength = 1000;
					self.Vel = Vector()
					self.AngularVel = 0;
					
					self.HitsMOs = false;
					
					self.HUDVisible = true
			
					local effect = CreateMOSRotating("Longbow Arrow Hit Effect", "Mordhau.rte");
					if effect then
						effect.Pos = self.Pos + SceneMan:ShortestDistance(self.Pos,rayHitPos,SceneMan.SceneWrapsX) * 0.5
						MovableMan:AddParticle(effect);
						effect:GibThis();
					end
					
					self.flightLoopSound:Stop(-1);
				end
			end
		end
		
	elseif self.state == self.states.StuckMO then
	
		-- Follow stick mo
		local stickMO = MovableMan:FindObjectByUniqueID(self.stickMOUID)
		if stickMO then
			stickMO = ToMOSRotating(stickMO)
			
			local stickDeepness = 0.5-- + ((math.floor(self.UniqueID * 1.5) % 6) / 6)
			
			self.RotAngle = stickMO.RotAngle + self.stickRotation-- + math.pi * (self.FlipFactor + 1) * 0.5
			self.Pos = stickMO.Pos + Vector(self.stickOffset.X, self.stickOffset.Y):RadRotate(stickMO.RotAngle) - Vector(self.IndividualRadius * stickDeepness * self.FlipFactor, 0):RadRotate(self.RotAngle);
			self.PinStrength = 1000;
			self.AngularVel = 0;
			
			if self.settleTimer:IsPastSimMS(5000) and math.random() < 0.01 then
				self.stickMOUID = -1
			end
		else
			self.forceSettle = true
			self.state = self.states.Dropped
			self.flightLoopSound:Stop();
			
			self.settleTimer:Reset()
		end
		
	elseif self.state == self.states.StuckTerrain then
	
		if self.settleTimer:IsPastSimMS(5000) then
			self.ToSettle = true
		end
	elseif self.state == self.states.Dropped then
		-- Do nothing B
		
		if self.forceSettle and self.Vel.Magnitude < 1 then
			self.ToSettle = true
		end
		
		self.PinStrength = 0
	end
end

function OnCollideWithTerrain(self, terrainID) -- delet
	self.flightLoopSound:Stop();

	if self.bounceSoundPlay == true and self.Vel.Magnitude > 5 then
		self.bounceSound:Play(self.Pos)
		self.bounceSoundPlay = false
		
		self.state = self.states.Dropped
		
		self.stickMOUID = -1
		self.PinStrength = 0
	end
	
end
function Destroy(self) -- delet
	self.flightLoopSound:Stop();
end

function OnDetach(self)
	--self.activated = false
	self.AngularVel = 0
end