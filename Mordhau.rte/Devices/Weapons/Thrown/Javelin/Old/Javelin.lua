function Create(self)

	self.equipSound = CreateSoundContainer("Equip Javelin", "Mordhau.rte");
	self.equipSound.Pitch = 1.0;
	
	self.pickUpSound = CreateSoundContainer("Wood Pickup Mordhau", "Mordhau.rte");
	self.pickUpSound.Pitch = 1.0;

	self.origMass = self.Mass;
	self.thrownMassMultiplier = self:NumberValueExists("ThrownMassMultiplier") and self:GetNumberValue("ThrownMassMultiplier") or 5;
	
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
	
	self.stickMO = nil;
	self.stickVecX = 0;
	self.stickVecY = 0;
	self.stickRot = 0;
	self.stickDeepness = RangeRand(0.2, 0.5);

	self.stuck = false;
	
	self.decayTimer = nil;
	self.decayTime = RangeRand(4000,8000);--3000;
	
	self.deleteTimer = Timer()
	
	self.phase = 0;
	
end
function Update(self)
	if self.ID == self.RootID then
		if not self.thrown and self.wasActivated then
			self.Mass = self.origMass * self.thrownMassMultiplier;
			self.thrown = true;
			self.wasActivated = false;
			self.throwSound:Play(self.Pos);
			self.flightLoopSound:Play(self.Pos);
			
		elseif self.thrown == true then

			self.flightLoopSound.Pos = self.Pos;
	
			self.flightLoopSound.Volume = math.min(self.Vel.Magnitude / 35, 35) + 0.05;
			self.flightLoopSound.Pitch = (self.Vel.Magnitude / 35) + 1;
				
			--- Areodynamics
			if not self.stuck then
				local v = self.Vel.Magnitude;
				-- Balance
				
				-- FROTATE
				-- attention: magic below!
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
				
				local a = 5 * v / 60;
				local b = 10 * v / 60;
				
				self.RotAngle = self.RotAngle + result * TimerMan.DeltaTimeSecs * a;
				self.AngularVel = (self.AngularVel) / (1 + TimerMan.DeltaTimeSecs * b)
				--self.GlobalAccScalar = (1 + (1/math.sqrt(1 + math.abs(self.Vel.X)/10))) / 2; -- thank your 4zk!
			end
			
			if self.phase == 0 and self.Vel.Magnitude > 13 then -- Raycast, stick to things
			
				local rayOrigin = self.Pos
				local rayVec = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + self.IndividualRadius);
				local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
				if moCheck ~= rte.NoMOID then
					local rayHitPos = SceneMan:GetLastRayHitPos()
					local MO = MovableMan:GetMOFromID(moCheck)
					if IsMOSRotating(MO) then
						self.stickMO = ToMOSRotating(MO);
						local stickVec = SceneMan:ShortestDistance(self.stickMO.Pos,rayHitPos,SceneMan.SceneWrapsX):RadRotate(-self.stickMO.RotAngle);
						self.stickVecX = stickVec.X;
						self.stickVecY = stickVec.Y;
						self.stickRot = self.RotAngle - self.stickMO.RotAngle;
						
						local addWounds = true;
						
						-- Get the material and set damage multiplier
						local material = self.stickMO.Material.PresetName;
						
						-- get wounds to check for dent metal
						local woundName = self.stickMO:GetEntryWoundPresetName()
						local woundNameExit = self.stickMO:GetExitWoundPresetName()
						local woundOffset = (rayHitPos - self.stickMO.Pos):RadRotate(self.stickMO.RotAngle * -1.0)
						
						
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
						
						local actorHit = MovableMan:GetMOFromID(self.stickMO.RootID)
						if (actorHit and IsActor(actorHit)) then
					
							if IsAHuman(actorHit) then
								local actorHuman = ToAHuman(actorHit)
								if actorHuman.Head and self.stickMO.ID == actorHuman.Head.ID or actorHuman.FGArm and self.stickMO.ID == actorHuman.FGArm.ID or actorHuman.BGArm and self.stickMO.ID == actorHuman.BGArm.ID or actorHuman.FGLeg and self.stickMO.ID == actorHuman.FGLeg.ID or actorHuman.BGLeg and self.stickMO.ID == actorHuman.BGLeg.ID then
									-- two different ways to dismember: 1. if wounds would gib the limb hit, dismember it instead 2. low hp
									local halfVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude/2);
									if self.stickMO.WoundCount + 7 > self.stickMO.GibWoundLimit then
										ToMOSRotating(actorHuman):RemoveAttachable(ToAttachable(self.stickMO), true, true);
										addWounds = false;
										self.stickMO.Vel = self.stickMO.Vel + halfVel
									elseif actorHuman.Health < 10 and math.random(0, 100) < 50 then
										ToMOSRotating(actorHuman):RemoveAttachable(ToAttachable(self.stickMO), true, true);
										addWounds = false;
										self.stickMO.Vel = self.stickMO.Vel + halfVel
									end
								end
							end
						end
						
						if addWounds == true then
							for i = 1, 6 do
								self.stickMO:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end
						end
						
						self.flightLoopSound:Stop(-1);
						
						self.PinStrength = 1000;
						self.Vel = Vector()
						self.AngularVel = 0;
						--[[
						if self.trailID then
							local MO = MovableMan:FindObjectByUniqueID(self.trailID)
							if MO then
								MO.ToDelete = true
								self.trailID = nil
							end
						end]]
						
						--[[
						--(rayHitPos - self.stickMO.Pos)
						local impulseMO = self.stickMO
						if impulseMO.RootID ~= rte.NoMOID then
							local root = ToMOSRotating(MovableMan:GetMOFromID(impulseMO.RootID))
							if not IsAttachable(root) then
								impulseMO = root
							end
						end
						self.stickMO:AddImpulseForce(Vector(self.Vel.X, self.Vel.Y):SetMagnitude(100 / self.stickMO.Mass * 2), Vector())
						]]
						
						self.HitsMOs = false;
						
						self.stuck = true
						self.phase = 1
					end
					
					self.decayTimer = Timer();
				else
					local terrCheck = SceneMan:CastStrengthSumRay(rayOrigin, rayOrigin + rayVec, 2, 0); -- Raycast
					if terrCheck > 5 then
						local rayHitPos = SceneMan:GetLastRayHitPos()
						self.Pos = rayHitPos - Vector(self.IndividualRadius * self.stickDeepness, 0):RadRotate(self.RotAngle + math.pi * (-self.FlipFactor + 1) * 0.5);
						
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
						--[[
						if self.trailID then
							local MO = MovableMan:FindObjectByUniqueID(self.trailID)
							if MO then
								MO.ToDelete = true
								self.trailID = nil
							end
						end
						]]
				
						local effect = CreateMOSRotating("Longbow Arrow Hit Effect", "Mordhau.rte");
						if effect then
							effect.Pos = self.Pos + SceneMan:ShortestDistance(self.Pos,rayHitPos,SceneMan.SceneWrapsX) * 0.5
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
						
						self.flightLoopSound:Stop(-1);
						
						self.stuck = true
						self.phase = 2
						
						self.decayTime = self.decayTime * 0.5;
						
						self.decayTimer = Timer()
					end
				end
				
				--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec, 5);
				
			elseif self.phase == 1 then -- Stuck into MO
			
				if self.stickMO.ID ~= rte.NoMOID and not self.decayTimer:IsPastSimMS(self.decayTime) and self.PinStrength > 10 then
					--self.Pos = self.stickMO.Pos + Vector(self.stickVec.X, self.stickVec.Y):RadRotate(self.stickMO.RotAngle)
					self.RotAngle = self.stickMO.RotAngle + self.stickRot * 0.1
					self.Pos = self.stickMO.Pos + Vector(self.stickVecX, self.stickVecY):RadRotate(self.stickMO.RotAngle) - Vector(self.IndividualRadius * self.stickDeepness, 0):RadRotate(self.RotAngle);
					self.PinStrength = 1000;
					self.AngularVel = 0;
					
				else
					
					self.PinStrength = 0;
					
					self.decayGib = true;
					
					self.stickMO = nil;
					self.stuck = false
					self.phase = 3
				end
				
			elseif self.phase == 2 then -- Stuck into terrain
			
				self.HUDVisible = false;
			
				self.PinStrength = 1000;
				self.AngularVel = 0;
				
				if self.decayTimer:IsPastSimMS(self.decayTime) then
					self.ToSettle = true;
				end
			elseif self.phase == 3 then -- Fell from MO
			
				if self.decayGib then
					self.HUDVisible = false;
				else
					self.HUDVisible = true;
				end
				
			end
		end
	else
		if self:IsActivated() then
			self.wasActivated = true;
		end
		if self.thrown == true then
		
			-- this wouldn't be a throwable without the ability to pick it up and throw it back, now would it?
			
			self.PinStrength = 0;
			
			self.stickMO = nil;
			self.stickVecX = 0;
			self.stickVecY = 0;
			self.stickRot = 0;
			self.stickDeepness = RangeRand(0.2, 0.5);

			self.stuck = false;
			
			self.decayTimer = nil;
			self.decayTime = RangeRand(4000,8000);--3000;
			self.phase = 0;
			
		else
			local parent = ToMOSRotating(self):GetParent()
			
			if parent then
				parent = ToMOSRotating(parent)
				self.RotAngle = parent.RotAngle + math.pi
			end
		end
		self.thrown = false;
		self.Mass = self.origMass;
	end
end

function OnCollideWithTerrain(self, terrainID) -- delet
	self.flightLoopSound:Stop();
	
	if self.phase == 3 and self.decayGib then
		self.ToSettle = true;
	end

	if self.bounceSoundPlay == true and self.Vel.Magnitude > 5 then
		self.bounceSound:Play(self.Pos)
		self.bounceSoundPlay = false
	end
	
end
function Destroy(self) -- delet
	self.flightLoopSound:Stop();
end

function OnDetach(self)

	if self.wasActivated == true then
		self.HUDVisible = false;
	end
end