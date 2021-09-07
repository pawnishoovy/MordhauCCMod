function Create(self)

	self.equipSound = CreateSoundContainer("Shield Equip Mordhau", "Mordhau.rte");
	self.equipSound.Pitch = 0.9;
	
	self.pickUpSound = CreateSoundContainer("Metal Pickup Mordhau", "Mordhau.rte");
	self.pickUpSound.Pitch = 1.0;
	
	self.terrainHitSounds = {
	[12] = CreateSoundContainer("MeleeTerrainHit Concrete Mordhau", "Mordhau.rte"),
	[164] = CreateSoundContainer("MeleeTerrainHit Concrete Mordhau", "Mordhau.rte"),
	[177] = CreateSoundContainer("MeleeTerrainHit Concrete Mordhau", "Mordhau.rte"),
	[9] = CreateSoundContainer("MeleeTerrainHit Dirt Mordhau", "Mordhau.rte"),
	[10] = CreateSoundContainer("MeleeTerrainHit Dirt Mordhau", "Mordhau.rte"),
	[11] = CreateSoundContainer("MeleeTerrainHit Dirt Mordhau", "Mordhau.rte"),
	[128] = CreateSoundContainer("MeleeTerrainHit Dirt Mordhau", "Mordhau.rte"),
	[6] = CreateSoundContainer("MeleeTerrainHit Sand Mordhau", "Mordhau.rte"),
	[8] = CreateSoundContainer("MeleeTerrainHit Sand Mordhau", "Mordhau.rte"),
	[178] = CreateSoundContainer("Skewer Metal Lance Mordhau", "Mordhau.rte"),
	[179] = CreateSoundContainer("Skewer Metal Lance Mordhau", "Mordhau.rte"),
	[180] = CreateSoundContainer("Skewer Metal Lance Mordhau", "Mordhau.rte"),
	[181] = CreateSoundContainer("Skewer Metal Lance Mordhau", "Mordhau.rte"),
	[182] = CreateSoundContainer("Skewer Metal Lance Mordhau", "Mordhau.rte")}
	
	self.blockedSound = CreateSoundContainer("Mordhau LargeShield Metal Blocked", "Mordhau.rte");
	
	self.deviceHitSound = CreateSoundContainer("Mordhau LargeShield Metal Impact", "Mordhau.rte");
	self.tackleImpactSound = CreateSoundContainer("Mordhau LargeShield Metal TackleImpact", "Mordhau.rte");

	if math.random(0, 100) < 50 then
		self.pickUpSound = CreateSoundContainer("Wood Pickup Mordhau", "Mordhau.rte");
		self.pickUpSound.Pitch = 0.9;
		self.deviceHitSound = CreateSoundContainer("Mordhau LargeShield Wood Impact", "Mordhau.rte");
		self.tackleImpactSound = CreateSoundContainer("Mordhau LargeShield Wood TackleImpact", "Mordhau.rte");
		self.blockedSound = CreateSoundContainer("Mordhau LargeShield Wood Blocked", "Mordhau.rte");
		self.Frame = 2;
		self.GibSound = CreateSoundContainer("Mordhau LargeShield Wood Gib", "Mordhau.rte");
		self:SetEntryWound("Mordhau LargeShield Wood Wound", "Mordhau.rte");
		self:SetExitWound("Mordhau LargeShield Wood Wound", "Mordhau.rte");		
		for attachable in self.Attachables do
			attachable.Frame = 1;
			attachable.GibSound = CreateSoundContainer("Mordhau LargeShield Wood PartGib", "Mordhau.rte");
			attachable:SetEntryWound("Mordhau LargeShield Wood Wound", "Mordhau.rte");
			attachable:SetExitWound("Mordhau LargeShield Wood Wound", "Mordhau.rte");
		end
	end
	
	self.blockGFX = {};
	self.blockGFX.Slash = "Slash Block Effect Mordhau";
	self.blockGFX.Stab = "Stab Block Effect Mordhau";
	self.blockGFX.Heavy = "Heavy Block Effect Mordhau";
	self.blockGFX.Parry = "Parry Effect Mordhau";
	
	self.hitMOTable = {};
	self.hitMOTableResetTimer = Timer();
	
	self.startUpTimer = Timer();
	
	self.Cooldown = false;
	self.cooldownTimer = Timer();
	
	self.GFX = {};
	
	self.GFX.hitTerrainSoftGFX = "Melee Terrain Soft Effect Mordhau"
	self.GFX.hitTerrainHardGFX = "Melee Terrain Hard Effect Mordhau"
	self.GFX.hitFleshGFX = "Melee Flesh Effect Mordhau"
	self.GFX.hitMetalGFX = "Melee Terrain Hard Effect Mordhau"
	self.GFX.hitDeflectGFX = "Melee Terrain Hard Effect Mordhau"	
	
	self.originalStanceOffset = self.StanceOffset;
	
	self.stance = Vector(0, 0)
	self.stanceInterpolation = 0 -- 0 instant, 1 smooth
	self.stanceInterpolationSpeed = 50
	
end

function Update(self)

	if UInputMan:KeyPressed(38) then
		self:ReloadScripts();
	end

	local act = self:GetRootParent();
	local actor = IsAHuman(act) and ToAHuman(act) or nil;
	local player = false
	local controller = nil
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		controller = actor:GetController();
		self.parent = actor;
		if actor:IsPlayerControlled() then
			player = true
		end
	end
	
	if controller then
		
			-- ANIMATION PLAYER
		local stanceTarget = Vector(0, 0)
		
		if self.Vel.Magnitude > 3 and self.Cooldown == false then
			self:RemoveNumberValue("Tackle Sprint Cooldown");
			if self.startUpTimer:IsPastSimMS(1000) then
				self.startUpDone = true;
				stanceTarget = Vector(5, -2);
			else
				self.startUpDone = false;
				stanceTarget = Vector(0, 0);
			end
			if self.hitMOTableResetTimer:IsPastSimMS(1000) then
				self.hitMOTableResetTimer:Reset();
				self.hitMOTable = {};
			end
		else
			stanceTarget = Vector(0, 0);
			self.startUpDone = false;
			self.startUpTimer:Reset();
			self.hitMOTable = {};
			if self.Cooldown == true then
				stanceTarget = Vector(-6, 1);
				self:SetNumberValue("Tackle Sprint Cooldown", 1);
				if self.cooldownTimer:IsPastSimMS(1800) then
					self.Cooldown = false;
				end
			else
				self:RemoveNumberValue("Tackle Sprint Cooldown");
			end
		end
		
		self.stance = (self.stance + stanceTarget * TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed);
		self.StanceOffset = self.originalStanceOffset + self.stance

		if self.Vel.Magnitude > 3 and self.Cooldown == false and self.startUpDone then -- Detect collision
			--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + attackOffset,  13);
			local hit = false
			local hitType = 0
			local team = 0
			if actor then team = actor.Team end
			local rayVec = Vector(15*self.FlipFactor, 0):RadRotate(self.RotAngle)
			local rayOrigin = self.Pos
			
			--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
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
				elseif self.Vel.Magnitude - MO.Vel.Magnitude < 3 then -- check that we're going reasonably fast to hit them
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
								self.Cooldown = true;
								--print("RANDOM DEVICE SET")
								self.cooldownTimer:Reset();
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
							self.Cooldown = true;
							self.cooldownTimer:Reset();
							self.blockedSound:Play(self.Pos);
						end	
						
						local damage = 2;
						
						local addWounds = true;
						
						local woundsToAdd;
						local speedMult = math.max(1, self.Vel.Magnitude / 18);
						
						woundsToAdd = math.floor((damage*speedMult))
						
						-- Hurt the actor, add extra damage
						local actorHit = MovableMan:GetMOFromID(MO.RootID)
						if (actorHit and IsActor(actorHit)) then-- and (MO.RootID == moCheck or (not IsAttachable(MO) or string.find(MO.PresetName,"Arm") or string.find(MO,"Leg") or string.find(MO,"Head"))) then -- Apply addational damage
						
							self.tackleImpactSound:Play(self.Pos);
						
							actorHit = ToActor(actorHit)
							
							actorHit.Status = 1;
							actorHit.Vel = actorHit.Vel + (self.Vel);
							
							if self.Vel.Magnitude < 18 then
								if math.random(0, 100) > 10 then
									--print("RANDOM ACTOR SET")
									self.Cooldown = true;
									--print(self.cooldownTimer.ElapsedSimTimeMS)
									self.cooldownTimer:Reset();
									--print(self.cooldownTimer.ElapsedSimTimeMS)
								end
							else
								if math.random(0, 100) > 50 then
									--print("RANDOM ACTOR SET FAST")
									self.Cooldown = true;
									self.cooldownTimer:Reset();
								end
							end
							
							if (actorHit.Health - (damage * 10)) < 0 then -- bad estimation, but...
								if math.random(0, 100) < 15 then
									self.parent:SetNumberValue("Attack Killed", 1); -- celebration!!
								end
							elseif math.random(0, 100) < 30 then
								self.parent:SetNumberValue("Attack Success", 1); -- celebration!!
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
						--print(self.Cooldown)
					end
				elseif (MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee")) or MO:IsInGroup("Mordhau Counter Shields") then
					hit = true;
					MO = ToHeldDevice(MO);
					if MO:NumberValueExists("Blocking") or (MO:StringValueExists("Parrying Type")
					and (MO:GetStringValue("Parrying Type") == "Stab" or MO:GetStringValue("Parrying Type") == "Flourish")) then
						--print("MELEE BLOCKED SET")
						self.Cooldown = true;
						self.cooldownTimer:Reset();
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
					self.Cooldown = true;
					self.cooldownTimer:Reset();
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
						if self.terrainHitSounds[terrPixel] ~= nil then
							self.terrainHitSounds[terrPixel]:Play(self.Pos);
						else -- default to concrete
							self.terrainHitSounds[177]:Play(self.Pos);
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
			self.IDToIgnore = nil;
		end
	end

end

function Destroy(self)
	if self.Frame == 2 then
		-- wood gib
	else
		-- metal gib
	end
end