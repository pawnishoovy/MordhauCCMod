
function Create(self)
	--[[
	local trail = CreateMOPixel("Bow Arrow Trail"); -- Add the coolest thing, custom trail TM
	trail.Team = self.Team -- You can remove it if you wish, the trail used to damage the target
	trail.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.IndividualRadius * 0.9);
	trail.Vel = self.Vel;
	MovableMan:AddParticle(trail);
	
	self.trailID = trail.UniqueID]]
	
	self.soundImpact = CreateSoundContainer("Crossbow Arrow Impact", "Mordhau.rte");
	
	self.soundWiggle = CreateSoundContainer("Crossbow Arrow Wiggle", "Mordhau.rte");
	self.soundWigglePlay = true
	
	self.soundBounce = CreateSoundContainer("Crossbow Arrow Bounce", "Mordhau.rte");
	self.soundBouncePlay = true
	
	self.soundFlyby = CreateSoundContainer("Crossbow Arrow Flyby", "Mordhau.rte");
	self.soundFlyby.Pitch = 1.1
	self.soundFlyby:Play(self.Pos)
	
	self.Frame = math.random(0, self.FrameCount - 1);
	
	self.spawnPoof = true;
	
	self.stuck = false;
	
	self.stickMO = nil;
	self.stickVecX = 0;
	self.stickVecY = 0;
	self.stickRot = 0;
	self.stickDeepness = RangeRand(0.1, 1);
	self.stickWiggle = 0;
	
	self.woundLimitChange = false; -- If changed the wound limit, revert it to default if despawning
	
	self.Vel = self.Vel + Vector(0, -2); -- Don't ask, the flechette has fucked up trajectory
	
	self.decayTimer = nil;
	self.decayTime = RangeRand(1000,4000);--3000;
	self.decayGib = math.random(1,5) >= 2;
	
	self.deleteTimer = Timer()
	
	self.phase = 0;
end

function Update(self)
	-- Avoid stupid situations
	if self.deleteTimer:IsPastSimMS(10000) then
		self:GibThis();
	end
	
	self.soundFlyby.Pos = self.Pos
	
	--- Areodynamics
	if not self.stuck then
		local v = self.Vel.Magnitude;
		-- Balance
		
		-- FROTATE
		-- attention: magic below!
		local min_value = -math.pi;
		local max_value = math.pi;
		local value = self.RotAngle - self.Vel.AbsRadAngle;
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
	
	--self.ToDelete = false; -- no, stop, no delete plz
	
	--[[
	if self.trailID then
		local MO = MovableMan:FindObjectByUniqueID(self.trailID)
		if MO then
			MO = ToMOPixel(MO)
			if self.stuck then
				MO.ToDelete = true;
			else
				MO.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.IndividualRadius * 0.9);
				MO.Vel = self.Vel;
				MO.ToDelete = false;
				MO.ToSettle = false;
			end
		end
	end]]
	
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
				self.stickWiggle = 2;
				
				self.soundImpact:Play(self.Pos)
				self.soundFlyby:Stop(-1)
				
				-- Damage, create a pixel that makes a hole
				for i = 0, 3 do
					local pixel = CreateMOPixel("Crossbow Arrow Damage", "Mordhau.rte");
					pixel.Vel = self.Vel;
					pixel.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.IndividualRadius * 0.9);
					pixel.Team = self.Team;
					pixel.IgnoresTeamHits = true;
					pixel.WoundDamageMultiplier = 1 + pixel.WoundDamageMultiplier * self.Vel.Magnitude / 100;--1.53;
					MovableMan:AddParticle(pixel);
				end
				
				-- Get the material and set damage multiplier
				local material = self.stickMO.Material.PresetName;
				
				
				-- Add extra effects based on the material
				if string.find(material,"Flesh") then
					local blood = CreateMOSParticle("Blood Spray Particle");
					blood.Pos = rayHitPos - Vector(self.Vel.X,self.Vel.Y) * rte.PxTravelledPerFrame * 0.1;
					blood.Vel = Vector(self.Vel.X,self.Vel.Y):RadRotate(math.pi * RangeRand(-0.1, 0.1)) * RangeRand(0.05, 0.1) * -1.0;
					MovableMan:AddParticle(blood);
				else
					for i = 1, 3 do
						local bloofm = CreateMOSParticle("Tiny Smoke Trail 1");
						bloofm.Pos = rayHitPos - Vector(self.Vel.X,self.Vel.Y) * rte.PxTravelledPerFrame * 0.1;
						bloofm.Vel = Vector(self.Vel.X,self.Vel.Y):RadRotate(math.pi * RangeRand(-0.2, 0.2)) * RangeRand(0.1, 0.4) * -1.0;
						MovableMan:AddParticle(bloofm);
					end
				end
				
				local effect = CreateMOSRotating("Crossbow Arrow Hit Effect", "Mordhau.rte");
				if effect then
					effect.Pos = rayHitPos
					MovableMan:AddParticle(effect);
					effect:GibThis();
				end
				
				
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
				self.Pos = rayHitPos - Vector(self.IndividualRadius * self.stickDeepness, 0):RadRotate(self.RotAngle);
				
				self.PinStrength = 1000;
				self.Vel = Vector()
				self.AngularVel = 0;
				
				self.soundFlyby:Stop(-1)
				
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
		
				local effect = CreateMOSRotating("Crossbow Arrow Hit Effect", "Mordhau.rte");
				if effect then
					effect.Pos = self.Pos + SceneMan:ShortestDistance(self.Pos,rayHitPos,SceneMan.SceneWrapsX) * 0.5
					MovableMan:AddParticle(effect);
					effect:GibThis();
				end
				
				self.stuck = true
				self.phase = 2
				
				self.soundImpact:Play(self.Pos)
				
				self.decayTime = self.decayTime * 0.5;
				
				self.decayTimer = Timer()
			end
		end
		
		--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec, 5);
		
	elseif self.phase == 1 then -- Stuck into MO
		if self.stickMO.ID ~= rte.NoMOID and not self.decayTimer:IsPastSimMS(self.decayTime) and self.PinStrength > 10 then
			--self.Pos = self.stickMO.Pos + Vector(self.stickVec.X, self.stickVec.Y):RadRotate(self.stickMO.RotAngle)
			self.RotAngle = self.stickMO.RotAngle + self.stickRot + math.sin(self.stickWiggle * math.pi * 4.0) * self.stickWiggle * 0.3 + math.sin(self.stickWiggle * math.pi * 8.0) * 0.1
			self.Pos = self.stickMO.Pos + Vector(self.stickVecX, self.stickVecY):RadRotate(self.stickMO.RotAngle) - Vector(self.IndividualRadius * self.stickDeepness, 0):RadRotate(self.RotAngle);
			self.PinStrength = 1000;
			self.AngularVel = 0;
			
			--self.stickWiggle = (self.stickWiggle) / (1 + TimerMan.DeltaTimeSecs * 5)
			self.stickWiggle = math.max(0, self.stickWiggle - TimerMan.DeltaTimeSecs * 4)
			if self.soundWigglePlay then
				self.soundWiggle:Play(self.Pos)
				self.soundWigglePlay = false
			end
		else
			
			self.PinStrength = 0;
			
			self.stickMO = nil;
			self.stuck = false
			self.phase = 3
		end
		
	elseif self.phase == 2 then -- Stuck into terrain
		self.PinStrength = 1000;
		self.AngularVel = 0;
		
		if self.decayTimer:IsPastSimMS(self.decayTime) then
			self.ToSettle = true;
		end
	elseif self.phase == 3 then -- Fell from MO
		
	end
	
end

function OnCollideWithTerrain(self, terrainID) -- delet
	if self.phase == 3 and self.decayGib then
		self:GibThis();
		--self.ToDelete = true;
	else
		self.ToSettle = true;
		self.phase = 3
		
		if self.soundBouncePlay and self.Vel.Magnitude > 5 then
			self.soundBounce:Play(self.Pos)
			self.soundBouncePlay = false
		end
	end
end

function Destroy(self)
	self.soundFlyby:Stop(-1)
end