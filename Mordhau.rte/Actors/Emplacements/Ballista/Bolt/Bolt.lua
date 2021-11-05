
function Create(self)
	--[[
	local trail = CreateMOPixel("Bow Arrow Trail"); -- Add the coolest thing, custom trail TM
	trail.Team = self.Team -- You can remove it if you wish, the trail used to damage the target
	trail.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.IndividualRadius * 0.9);
	trail.Vel = self.Vel;
	MovableMan:AddParticle(trail);
	
	self.trailID = trail.UniqueID]]
	
	self.hitMOTable = {}
	
	self.soundBounce = CreateSoundContainer("Bounce Ballista", "Mordhau.rte");
	self.soundBouncePlay = true;
	
	self.soundFlyLoop = CreateSoundContainer("Flight Ballista", "Mordhau.rte");
	self.originalPitch = math.random(5, 15) / 100;
	self.soundFlyLoop:Play(self.Pos);

	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("Impact Concrete Ballista", "Mordhau.rte"),
			[164] = CreateSoundContainer("Impact Concrete Ballista", "Mordhau.rte"),
			[177] = CreateSoundContainer("Impact Concrete Ballista", "Mordhau.rte"),
			[9] = CreateSoundContainer("Impact Dirt Ballista", "Mordhau.rte"),
			[10] = CreateSoundContainer("Impact Dirt Ballista", "Mordhau.rte"),
			[11] = CreateSoundContainer("Impact Dirt Ballista", "Mordhau.rte"),
			[128] = CreateSoundContainer("Impact Dirt Ballista", "Mordhau.rte"),
			[6] = CreateSoundContainer("Impact Sand Ballista", "Mordhau.rte"),
			[8] = CreateSoundContainer("Impact Sand Ballista", "Mordhau.rte"),
			[178] = CreateSoundContainer("Impact SolidMetal Ballista", "Mordhau.rte"),
			[179] = CreateSoundContainer("Impact SolidMetal Ballista", "Mordhau.rte"),
			[180] = CreateSoundContainer("Impact SolidMetal Ballista", "Mordhau.rte"),
			[181] = CreateSoundContainer("Impact SolidMetal Ballista", "Mordhau.rte"),
			[182] = CreateSoundContainer("Impact SolidMetal Ballista", "Mordhau.rte")}}
			
	self.soundHitFlesh = CreateSoundContainer("Impact Flesh Ballista", "Mordhau.rte");
	self.soundHitMetal = CreateSoundContainer("Impact SolidMetal Ballista", "Mordhau.rte");
	
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
	
	self.soundFlyLoop.Pos = self.Pos
	
	self.soundFlyLoop.Volume = math.min(self.Vel.Magnitude / 50, 50) + 0.10;
	self.soundFlyLoop.Pitch = (self.Vel.Magnitude / 35) + self.originalPitch;
	
	--- Areodynamics
	if not self.stuck then
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
	
	if self.phase == 0 and self.Vel.Magnitude > 25 then -- Raycast, stick to things
		local rayOrigin = self.Pos
		local rayVec = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + self.IndividualRadius);
		local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
		if moCheck ~= rte.NoMOID then
			local rayHitPos = SceneMan:GetLastRayHitPos()
			local MO = MovableMan:GetMOFromID(moCheck)
			if IsMOSRotating(MO) then
			local hitAllowed = true;
			if self.hitMOTable then -- this shouldn't be needed but it is
				for index, root in pairs(self.hitMOTable) do
					if root == MO:GetRootParent().UniqueID or index == MO.UniqueID then
						hitAllowed = false;
					end
				end
			end
			if hitAllowed == true then
				self.stickMO = ToMOSRotating(MO);
				self.hitMOTable[self.stickMO.UniqueID] = self.stickMO:GetRootParent().UniqueID;
				-- local stickVec = SceneMan:ShortestDistance(self.stickMO.Pos,rayHitPos,SceneMan.SceneWrapsX):RadRotate(-self.stickMO.RotAngle);
				-- self.stickVecX = stickVec.X;
				-- self.stickVecY = stickVec.Y;
				-- self.stickRot = self.RotAngle - self.stickMO.RotAngle;
				-- self.stickWiggle = 2;
				
				local addWounds = true
				
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
				
				local effect = CreateMOSRotating("Ballista Bolt Hit Effect", "Mordhau.rte");
				if effect then
					effect.Pos = rayHitPos
					MovableMan:AddParticle(effect);
					effect:GibThis();
				end
				
				-- local actorHit = MovableMan:GetMOFromID(self.stickMO.RootID)
				-- if (actorHit and IsActor(actorHit)) then
					-- self.hitMOTable[actorHit.UniqueID] = MO.UniqueID;
			
					-- if IsAHuman(actorHit) then
						-- local actorHuman = ToAHuman(actorHit)
						-- if actorHuman.Head and self.stickMO.ID == actorHuman.Head.ID or actorHuman.FGArm and self.stickMO.ID == actorHuman.FGArm.ID or actorHuman.BGArm and self.stickMO.ID == actorHuman.BGArm.ID or actorHuman.FGLeg and self.stickMO.ID == actorHuman.FGLeg.ID or actorHuman.BGLeg and self.stickMO.ID == actorHuman.BGLeg.ID then
							-- -- two different ways to dismember: 1. if wounds would gib the limb hit, dismember it instead 2. low hp
							-- local lessVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude/5);
							-- if self.stickMO.WoundCount + 30 > self.stickMO.GibWoundLimit then
								-- ToMOSRotating(actorHuman):RemoveAttachable(ToAttachable(self.stickMO), true, true);
								-- addWounds = false;
								-- self.stickMO.Vel = self.stickMO.Vel + lessVel
							-- elseif ToActor(actorHit).Health < 10 and math.random(0, 100) < 50 then
								-- ToMOSRotating(actorHuman):RemoveAttachable(ToAttachable(self.stickMO), true, true);
								-- addWounds = false;
								-- self.stickMO.Vel = self.stickMO.Vel + lessVel
							-- end
						-- end
					-- end
				-- end
				
				-- Damage, create a pixel that makes a hole
				-- self.PinStrength = 1000;
				-- self.Vel = Vector()
				-- self.AngularVel = 0;
				
				-- self.stuck = true
				-- self.phase = 1
				local addWounds = true;
				local woundsToAdd = 30 / (self.Vel.Magnitude / 120)
				local actorHit = MovableMan:GetMOFromID(self.stickMO.RootID)
				if (actorHit and IsActor(actorHit)) then
								
					if IsAttachable(self.stickMO) and ToAttachable(self.stickMO):IsAttached() and (IsArm(self.stickMO) or IsLeg(self.stickMO) or (IsAHuman(actorHit) and ToAHuman(actorHit).Head and self.stickMO.UniqueID == ToAHuman(actorHit).Head.UniqueID)) then
						-- if wounds would gib the limb hit, dismember it instead... sometimes gib though
						if self.stickMO.WoundCount + woundsToAdd >= self.stickMO.GibWoundLimit then
							if math.random(0, 100) < 20 then
								self.stickMO:GibThis();
							else
								ToAttachable(self.stickMO):RemoveFromParent(true, true);
								self.stickMO.Vel = self.stickMO.Vel + (self.Vel / 5)
							end
						end
					elseif IsActor(MO) then -- if we hit torso
						self.stickMO.Vel = self.stickMO.Vel + (self.Vel / 10)
					end						
						
				end
				
				if addWounds == true then
					for i = 0, woundsToAdd do
						local pixel = CreateMOPixel("Ballista Bolt Damage", "Mordhau.rte");
						pixel.Vel = self.Vel;
						pixel.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.IndividualRadius * 0.9);
						pixel.Team = self.Team;
						pixel.IgnoresTeamHits = true;
						pixel.WoundDamageMultiplier = 1.1 + pixel.WoundDamageMultiplier * self.Vel.Magnitude / 120;--1.53;
						MovableMan:AddParticle(pixel);
					end
				end
				self.Vel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude * 0.6);
			end
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
		
				local effect = CreateMOSRotating("Ballista Bolt Hit Effect", "Mordhau.rte");
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
		else
			
			self.PinStrength = 0;
			
			self.stickMO = nil;
			self.stuck = false
			self.phase = 3
		end
		
	elseif self.phase == 2 then -- Stuck into terrain
	
		if self.arrowSuppression ~= false then
			self.arrowSuppression = false;
			if math.random(0, 100) < 75 then
				for actor in MovableMan.Actors do
					if actor.Team ~= self.Team then
						local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
						if d < 120 then
							local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
							if strength < 500 then
								actor:SetNumberValue("Blocked Mordhau", 1);
								actor:SetNumberValue("Blocked Heavy Mordhau", 1);
							else
								if IsAHuman(actor) and actor.Head then -- if it is a human check for head
									local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
									if strength < 500 then		
										actor:SetNumberValue("Blocked Mordhau", 1);
										actor:SetNumberValue("Blocked Heavy Mordhau", 1);
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
end