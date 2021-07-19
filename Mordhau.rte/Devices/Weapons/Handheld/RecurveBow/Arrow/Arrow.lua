
function Create(self)
	--[[
	local trail = CreateMOPixel("Bow Arrow Trail"); -- Add the coolest thing, custom trail TM
	trail.Team = self.Team -- You can remove it if you wish, the trail used to damage the target
	trail.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.IndividualRadius * 0.9);
	trail.Vel = self.Vel;
	MovableMan:AddParticle(trail);
	
	self.trailID = trail.UniqueID]]
	
	self.soundBounce = CreateSoundContainer("Longbow Arrow Bounce", "Mordhau.rte");
	self.soundBouncePlay = true;
	
	self.soundFlyLoop = CreateSoundContainer("Longbow Arrow FlyLoop", "Mordhau.rte");
	self.originalPitch = math.random(110, 120) / 100;
	self.soundFlyLoop:Play(self.Pos);

	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("Longbow Arrow Hit Concrete", "Mordhau.rte"),
			[164] = CreateSoundContainer("Longbow Arrow Hit Concrete", "Mordhau.rte"),
			[177] = CreateSoundContainer("Longbow Arrow Hit Concrete", "Mordhau.rte"),
			[9] = CreateSoundContainer("Longbow Arrow Hit Dirt", "Mordhau.rte"),
			[10] = CreateSoundContainer("Longbow Arrow Hit Dirt", "Mordhau.rte"),
			[11] = CreateSoundContainer("Longbow Arrow Hit Dirt", "Mordhau.rte"),
			[128] = CreateSoundContainer("Longbow Arrow Hit Dirt", "Mordhau.rte"),
			[6] = CreateSoundContainer("Longbow Arrow Hit Sand", "Mordhau.rte"),
			[8] = CreateSoundContainer("Longbow Arrow Hit Sand", "Mordhau.rte"),
			[178] = CreateSoundContainer("Longbow Arrow Hit SolidMetal", "Mordhau.rte"),
			[179] = CreateSoundContainer("Longbow Arrow Hit SolidMetal", "Mordhau.rte"),
			[180] = CreateSoundContainer("Longbow Arrow Hit SolidMetal", "Mordhau.rte"),
			[181] = CreateSoundContainer("Longbow Arrow Hit SolidMetal", "Mordhau.rte"),
			[182] = CreateSoundContainer("Longbow Arrow Hit SolidMetal", "Mordhau.rte")}}
			
	self.soundHitFlesh = CreateSoundContainer("Longbow Arrow HitActor Flesh", "Mordhau.rte");
	self.soundHitMetal = CreateSoundContainer("Longbow Arrow HitActor Metal", "Mordhau.rte");
	
	self.soundWhistle = CreateSoundContainer("Longbow Arrow Whistle", "Mordhau.rte");
	if self.Vel.Magnitude > 45 then
		self.soundWhistle.Pitch = math.random(120, 140) / 100;
		self.soundWhistle:Play(self.Pos);
	end
	
	self.soundWiggle = CreateSoundContainer("Longbow Arrow Wiggle", "Mordhau.rte");
	self.soundWigglePlay = true
	
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
	
	self.soundWhistle.Pos = self.Pos
	self.soundFlyLoop.Pos = self.Pos
	
	self.soundFlyLoop.Volume = math.min(self.Vel.Magnitude / 80, 50) + 0.05;
	self.soundFlyLoop.Pitch = (self.Vel.Magnitude / 20) + self.originalPitch;
	
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
			
				self.soundWhistle:Stop(-1)
				self.soundFlyLoop:Stop(-1)
				
				-- Damage, create a pixel that makes a hole
				for i = 0, 2 do
					local pixel = CreateMOPixel("RecurveBow Arrow Damage", "Mordhau.rte");
					pixel.Vel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(math.max(self.Vel.Magnitude, 100)); -- make sure it can pen some stronger stuff
					pixel.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.IndividualRadius * 0.9);
					pixel.Team = self.Team;
					pixel.IgnoresTeamHits = true;
					pixel.WoundDamageMultiplier = 1.1 + pixel.WoundDamageMultiplier * self.Vel.Magnitude / 60;--1.53;
					MovableMan:AddParticle(pixel);
				end
				
				-- Get the material and set damage multiplier
				local material = self.stickMO.Material.PresetName;
				
				-- get wounds to check for dent metal
				local woundName = self.stickMO:GetEntryWoundPresetName()
				local woundNameExit = self.stickMO:GetExitWoundPresetName()
				
				
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
				
				if not MO:IsInGroup("Weapons - Mordhau Melee") then -- deflect coolly off of weapons! 
					self.PinStrength = 1000;
					self.Vel = Vector()
					self.AngularVel = 0;
					
					self.stuck = true
					self.phase = 1
				else
					self.phase = 3
					self.AngularVel = math.random(-15, 15);
					self.Vel = Vector(self.Vel.X, self.Vel.Y - 6):SetMagnitude(self.Vel.Magnitude * 0.5);
					if math.random(0, 100) < 30 and IsAHuman(MO:GetRootParent()) then
						ToAHuman(MO:GetRootParent()):SetNumberValue("Mordhau Arrow Suppression", 1);
					end
					self:GibThis();
				end
				
				self.HitsMOs = false;
			end
			
			self.decayTimer = Timer();
		else
			local terrCheck = SceneMan:CastStrengthSumRay(rayOrigin, rayOrigin + rayVec, 2, 0); -- Raycast
			if terrCheck > 5 then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				self.Pos = rayHitPos - Vector(self.IndividualRadius * self.stickDeepness, 0):RadRotate(self.RotAngle);
				
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
				
				self.soundFlyLoop:Stop(-1)
				self.soundWhistle:Stop(-1);
				
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
	
		if self.arrowSuppression ~= false then
			self.arrowSuppression = false;
			if math.random(0, 100) < 5 then
				for actor in MovableMan.Actors do
					if actor.Team ~= self.Team then
						local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
						if d < 120 then
							local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
							if strength < 300 then
								actor:SetNumberValue("Mordhau Arrow Suppression", 1);
								break;
							else
								if IsAHuman(actor) and actor.Head then -- if it is a human check for head
									local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
									if strength < 300 then		
										actor:SetNumberValue("Mordhau Arrow Suppression", 1);
										break;
									end
								end
							end
						end
					end
				end
			end
		end
	
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
		
		if self.soundBouncePlay == true and self.Vel.Magnitude > 5 then
			self.soundBounce:Play(self.Pos)
			self.soundBouncePlay = false
		end
	end
end

function Destroy(self)
	self.soundFlyLoop:Stop(-1);
	self.soundWhistle:Stop(-1);
end