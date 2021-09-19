function Create(self)

	self.tackleImpactSound = CreateSoundContainer("Tackle Impact Mordhau", "Mordhau.rte");
	
	self.blockGFX = {};
	self.blockGFX.Slash = "Slash Block Effect Mordhau";
	self.blockGFX.Stab = "Stab Block Effect Mordhau";
	self.blockGFX.Heavy = "Heavy Block Effect Mordhau";
	self.blockGFX.Parry = "Parry Effect Mordhau";
	
	self.hitMOTable = {};
	self.hitMOTableResetTimer = Timer();
	
	self.GFX = {};
	
	self.GFX.hitTerrainSoftGFX = "Melee Terrain Soft Effect Mordhau"
	self.GFX.hitTerrainHardGFX = "Melee Terrain Hard Effect Mordhau"
	self.GFX.hitFleshGFX = "Melee Flesh Effect Mordhau"
	self.GFX.hitMetalGFX = "Melee Terrain Hard Effect Mordhau"
	self.GFX.hitDeflectGFX = "Melee Terrain Hard Effect Mordhau"
	
	self.chargeTerrainHitSounds = {
	[12] = CreateSoundContainer("TerrainImpact Heavy Concrete", "Mordhau.rte"),
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
	[182] = CreateSoundContainer("TerrainImpact Heavy SolidMetal", "Mordhau.rte")}
	
	self.chargeOriginalSprintMultiplier = self.sprintMultiplier;
	
	self.chargeTimer = Timer();
	
end

function Update(self)

	if (not self.Charging) and (self.moveMultiplier == self.sprintMultiplier and UInputMan:KeyPressed(8) and self:IsPlayerControlled()) then
		
		self:SetNumberValue("Mordhau Charge", 1);
		self.Charging = true;
		self.chargeTimer:Reset();
		self.sprintMultiplier = self.chargeOriginalSprintMultiplier * 1.3;
		self:SetNumberValue("Mordhau Charging", 1);
		
	elseif self.Charging == true then
	
		if self.chargeTimer:IsPastSimMS(3000) or self.moveMultiplier < self.chargeOriginalSprintMultiplier then
			self.Charging = false;
			self.moveMultiplier = self.walkMultiplier;
			self.isSprinting = false;
		end
	
		--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + attackOffset,  13);
		local hit = false
		local hitType = 0
		local team = 0
		if actor then team = actor.Team end
		local aimAngle = self:GetAimAngle(false) / 4;
		local rayVec = Vector(18*self.FlipFactor, 0):RadRotate(self.RotAngle):RadRotate(aimAngle*self.FlipFactor);
		local rayOrigin = self.Pos + Vector(0, -7);
		
		PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
		--PrimitiveMan:DrawCirclePrimitive(self.Pos, 3, 5);
		
		local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.IDToIgnore or self.ID, self.Team, 0, false, 2); -- Raycast		
		
		if moCheck and moCheck ~= rte.NoMOID then
			local rayHitPos = SceneMan:GetLastRayHitPos()
			local rayHitPos = Vector(rayHitPos.X, rayHitPos.Y);
			local MO = MovableMan:GetMOFromID(moCheck)
			
			local dist = SceneMan:ShortestDistance(self.Pos, rayHitPos, SceneMan.SceneWrapsX)
			
			local eligible = true;
			
			if (self.Vel.X < 0 and dist.X > 0) or (self.Vel.X > 0 and dist.X < 0) then -- check that we're facing the right way
				eligible = false;
			elseif self.Vel.Magnitude - MO.Vel.Magnitude < 2 then -- check that we're going reasonably fast to hit them
				eligible = false;
			end
				
			
			
			if eligible and ((IsMOSRotating(MO)) and not ((MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee"))
			or (MO:IsInGroup("Mordhau Counter Shields") and (ToMOSRotating(MO):StringValueExists("Parrying Type")
			and ToMOSRotating(MO):GetStringValue("Parrying Type") == "Stab")))) then
				--print("HIT BEGIN")
				local hitAllowed = true;
				if self.hitMOTable then -- this shouldn't be needed but it is
					--print("CHECKING")
					for index, root in pairs(self.hitMOTable) do
						--print(MO)
						--print(MO.UniqueID)
						--print(MO:GetRootParent())
						--print(MO:GetRootParent().UniqueID)
						if root == MO:GetRootParent().UniqueID or index == MO.UniqueID then
							hitAllowed = false;
						end
					end
					--print("CHECK END")
				end
				if hitAllowed == true then
					hit = true
					MO = ToMOSRotating(MO)
					self.hitMOTable[MO.UniqueID] = MO:GetRootParent().UniqueID;
					--print("HIT THE FOLLOWING")
					--print(MO)
					--print(MO.UniqueID)
					--print(MO:GetRootParent())
					--print(MO:GetRootParent().UniqueID)
					--print("TABLE NOW CONTAINS")
					for index, root in pairs(self.hitMOTable) do
						--print(index)
						--print(root)
					end
					self.hitMOTableResetTimer:Reset();
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
						if self.GFX.hitFleshGFX then
							local effect = CreateMOSRotating(self.GFX.hitFleshGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
					elseif string.find(material,"Metal") or string.find(woundName,"Metal") or string.find(woundNameExit,"Metal") or string.find(material,"Stuff") or string.find(woundName,"Dent") or string.find(woundNameExit,"Dent") then
						if self.GFX.hitMetalGFX then
							local effect = CreateMOSRotating(self.GFX.hitMetalGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
					end
					
					if MO:IsDevice() and math.random(1,3) >= 2 then
						self.deviceHitSound:Play(self.Pos);
						if math.random(0, 100) > 50 then
							if math.random(0, 100) > 60 then
								ToAttachable(MO):RemoveFromParent(true, true);
							end								
						end
						if self.GFX.hitDeflectGFX then
							local effect = CreateMOSRotating(self.GFX.hitDeflectGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
					end
					
					if MO:IsInGroup("Shields") then
						--print("SHIELD")
						self.blockedSound:Play(self.Pos);
					end	
					
					local damage = 4 + (math.max(1, (self.Mass-130) / 20)); -- for every 20 mass above 130, add one damage
					
					local addWounds = true;
					
					local woundsToAdd;
					local speedMult = math.max(1, self.Vel.Magnitude / 18);
					
					woundsToAdd = math.floor((damage*speedMult))
					
					-- Hurt the actor, add extra damage
					local actorHit = MovableMan:GetMOFromID(MO.RootID)
					if (actorHit and IsActor(actorHit)) then-- and (MO.RootID == moCheck or (not IsAttachable(MO) or string.find(MO.PresetName,"Arm") or string.find(MO,"Leg") or string.find(MO,"Head"))) then -- Apply addational damage
					
						self.tackleImpactSound:Play(self.Pos);
					
						actorHit = ToActor(actorHit)
						
						if actorHit.BodyHitSound then
							actorHit.BodyHitSound:Play(actorHit.Pos)
						end
						
						actorHit.Status = 1;
						actorHit.Vel = actorHit.Vel + (self.Vel) * math.min(math.max(1, (self.Mass-130) / 50), 3); -- for every 50 mass above 130, multiply throwing distance to a max of 3 times
						
						if self.Vel.Magnitude < 18 then
							if math.random(0, 100) > 10 then
							end
						else
							if math.random(0, 100) > 50 then
							end
						end
						
						if (actorHit.Health - (damage * 10)) < 0 then -- bad estimation, but...
							if math.random(0, 100) < 15 then
								self:SetNumberValue("Attack Killed", 1); -- celebration!!
							end
						elseif math.random(0, 100) < 30 then
							self:SetNumberValue("Attack Success", 1); -- celebration!!
						end
						
						if IsAttachable(MO) and ToAttachable(MO):IsAttached() and (IsArm(MO) or IsLeg(MO) or (IsAHuman(actorHit) and ToAHuman(actorHit).Head and MO.UniqueID == ToAHuman(actorHit).Head.UniqueID)) then
							-- if wounds would gib the limb hit, dismember it instead... sometimes gib though
							if MO.WoundCount + woundsToAdd >= MO.GibWoundLimit and math.random(0, 100) < 80 then
								if math.random(0, 100) < 50 then -- stick
									ToAttachable(MO):RemoveFromParent(true, true);
									MO.Vel = MO.Vel + self.Vel;
								else
									MO:GibThis();
								end
								addWounds = false;
							end
						elseif IsActor(MO) then -- if we hit torso
							if self.BodyHitSound then
								self.BodyHitSound:Play(self.Pos);
							end
							if ToActor(MO).BodyHitSound then
								ToActor(MO).BodyHitSound:Play(self.Pos)
							end
							MO.Vel = MO.Vel + self.Vel;
							if MO.WoundCount + woundsToAdd >= MO.GibWoundLimit and math.random(0, 100) < 95 then
								addWounds = false;
								addSingleWound = true;
								ToActor(MO).Health = 0;
							end
						end
						
						if addWounds == true and woundName then
							MO:SetNumberValue("Mordhau Flinched", 1);
							local flincher = CreateAttachable("Mordhau Flincher", "Mordhau.rte")
							MO:AddAttachable(flincher)
							for i = 1, woundsToAdd do
								MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end
						elseif addSingleWound == true and woundName then
							MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end

					elseif woundName then -- generic wound adding for non-actors
						for i = 1, woundsToAdd do
							MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					end
					--print("HIT END")
				end
			elseif (MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee")) or MO:IsInGroup("Mordhau Counter Shields") then
				hit = true;
				MO = ToHeldDevice(MO);
				if MO:NumberValueExists("Blocking") or (MO:StringValueExists("Parrying Type")
				and (MO:GetStringValue("Parrying Type") == "Stab" or MO:GetStringValue("Parrying Type") == "Flourish")) then
					--print("MELEE BLOCKED SET")
					if MO:StringValueExists("Parrying Type") then
						local effect = CreateMOSRotating(self.blockGFX.Parry, "Mordhau.rte");
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
					self.blockedSound:Play(self.Pos);
					MO:SetStringValue("Blocked Type", "Stab");
					local effect = CreateMOSRotating(self.blockGFX.Stab, "Mordhau.rte");
					if effect then
						effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
						MovableMan:AddParticle(effect);
						effect:GibThis();
					end
					local effect = CreateMOSRotating(self.blockGFX.Heavy, "Mordhau.rte");
					if effect then
						effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
						MovableMan:AddParticle(effect);
						effect:GibThis();
					end
					MO:SetNumberValue("Blocked Heavy", 1);
					
				else
					self.IDToIgnore = MO.ID;
					hit = false; -- keep going and looking
				end
			end
		else
			local terrCheck = SceneMan:CastMaxStrengthRay(rayOrigin, rayOrigin + rayVec, 2); -- Raycast
			if terrCheck > 5 then
				if math.random(0, 100) < 20 then
					local woundName = self:GetEntryWoundPresetName()
					self:AddWound(CreateAEmitter(woundName), Vector(0, 0), true)
				end
				local rayHitPos = SceneMan:GetLastRayHitPos()
				hit = true
				self.attack = false
				self.charged = false
				
				local terrPixel = SceneMan:GetTerrMatter(rayHitPos.X, rayHitPos.Y)
		
				if terrPixel ~= 0 then -- 0 = air
					if self.chargeTerrainHitSounds[terrPixel] ~= nil then
						self.chargeTerrainHitSounds[terrPixel]:Play(self.Pos);
					else -- default to concrete
						self.chargeTerrainHitSounds[177]:Play(self.Pos);
					end
				end
				
				if terrCheck >= 100 then
					if self.GFX.hitTerrainHardGFX then
						local effect = CreateMOSRotating(self.GFX.hitTerrainHardGFX);
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
					end
					
					if self.BodyHitSound then
						self.BodyHitSound:Play(self.Pos);
					end
					hitType = 4 -- Hard
				else
					if self.GFX.hitTerrainSoftGFX then
						local effect = CreateMOSRotating(self.GFX.hitTerrainHardGFX);
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
			self:RemoveNumberValue("Mordhau Charge Ready");
			self.Charging = false;
			self.moveMultiplier = self.walkMultiplier;
			self.isSprinting = false;
			if hitType == 0 then -- Default
			elseif hitType == 1 then -- Flesh
				if math.random(0, 100) < 10 then
					local woundName = self:GetEntryWoundPresetName()
					self:AddWound(CreateAEmitter(woundName), Vector(0, 0), true)
				end
					
			elseif hitType == 2 then -- Metal
				if math.random(0, 100) < 20 then
					local woundName = self:GetEntryWoundPresetName()
					self:AddWound(CreateAEmitter(woundName), Vector(0, 0), true)
				end
			end
		end
	else
		self:RemoveNumberValue("Mordhau Charging");
		self.IDToIgnore = nil;
		self.sprintMultiplier = self.chargeOriginalSprintMultiplier;
		if self.moveMultiplier == self.sprintMultiplier then
			self:SetNumberValue("Mordhau Charge Ready", 1);
		else
			self:RemoveNumberValue("Mordhau Charge Ready");
		end
	end		
	
end