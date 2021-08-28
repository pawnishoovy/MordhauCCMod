function Create(self)

	self.equipSound = CreateSoundContainer("Generic Equip Mordhau", "Mordhau.rte");
	self.equipSound.Pitch = 1.0;
	
	self.pickUpSound = CreateSoundContainer("Wood Pickup Mordhau", "Mordhau.rte");
	self.pickUpSound.Pitch = 0.8;
	
	self.originalStanceOffset = self.StanceOffset;
	
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
	
	self.blockedSound = CreateSoundContainer("Blocked Lance Mordhau", "Mordhau.rte");
	
	self.blockGFX = {};
	self.blockGFX.Slash = "Slash Block Effect Mordhau";
	self.blockGFX.Stab = "Stab Block Effect Mordhau";
	self.blockGFX.Heavy = "Heavy Block Effect Mordhau";
	self.blockGFX.Parry = "Parry Effect Mordhau";
	
	self.hitMOTableResetTimer = Timer();
	
	self.Cooldown = false;
	self.cooldownTimer = Timer();
	self.cooldownDelay = 600;
	
	self.attackAnimationsSounds = {};
	
	self.attackAnimationsSounds.hitDeflectSound = CreateSoundContainer("Skewer Metal Lance Mordhau", "Mordhau.rte");	
	self.attackAnimationsSounds.hitFleshSound = CreateSoundContainer("Skewer Flesh Lance Mordhau", "Mordhau.rte");
	self.attackAnimationsSounds.hitMetalSound = CreateSoundContainer("Skewer Metal Lance Mordhau", "Mordhau.rte");
	
	self.attackAnimationsGFX = {};
	
	self.attackAnimationsGFX.hitTerrainSoftGFX = "Melee Terrain Soft Effect Mordhau"
	self.attackAnimationsGFX.hitTerrainHardGFX = "Melee Terrain Hard Effect Mordhau"
	self.attackAnimationsGFX.hitFleshGFX = "Melee Flesh Effect Mordhau"
	self.attackAnimationsGFX.hitMetalGFX = "Melee Terrain Hard Effect Mordhau"
	self.attackAnimationsGFX.hitDeflectGFX = "Melee Terrain Hard Effect Mordhau"
	
	self.rotation = 0
	self.rotationInterpolation = 1 -- 0 instant, 1 smooth, 2 wiggly smooth
	self.rotationInterpolationSpeed = 5
	
	self.stance = Vector(0, 0)
	self.stanceInterpolation = 0 -- 0 instant, 1 smooth
	self.stanceInterpolationSpeed = 25
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
		controller:SetState(Controller.AIM_SHARP,false);
		self.parent = actor;
		if actor:IsPlayerControlled() then
			player = true
		end
	end
	
	if controller then --          :-)

		-- ANIMATION PLAYER
		local stanceTarget = Vector(0, 0)
		local rotationTarget = 0
		
		if self.Vel.Magnitude > 10 and self.Cooldown == false then		
			if self.hitMOTableResetTimer:IsPastSimMS(1000) then
				self.hitMOTableResetTimer:Reset();
				self.hitMOTable = {};
			end
			stanceTarget = Vector(4, 4);			
			rotationTarget = -90 / 180 * math.pi;
		else
			self.hitMOTable = {};
			if self.Cooldown then
				stanceTarget = Vector(-7, 4);
				if self.cooldownTimer:IsPastSimMS(self.cooldownDelay) then
					self.Cooldown = false;
				end
				rotationTarget = -75 / 180 * math.pi;
			else
				stanceTarget = Vector(0, 0);
			end
			rotationTarget = 0;				
		end
		
		self.stance = (self.stance + stanceTarget * TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed);
		
		rotationTarget = rotationTarget * self.FlipFactor
		
		self.rotation = (self.rotation + rotationTarget * TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed);
		
		self.StanceOffset = self.originalStanceOffset + self.stance
		--self.InheritedRotAngleOffset = self.rotation
		self.RotAngle = self.RotAngle + self.rotation
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		self.Pos = self.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-self.rotation);
		
		-- COLLISION DETECTION
		
		--self.attackAnimationsSounds[1]
		if math.abs(self.rotation) > 1.5 then -- Detect collision
			--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + attackOffset,  13);
			local hit = false
			local hitType = 0
			local team = 0
			if actor then team = actor.Team end
			local rayVec = Vector(0, -25):RadRotate(self.RotAngle)
			local rayOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(0, -25):RadRotate(self.RotAngle)
			
			PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
			--PrimitiveMan:DrawCirclePrimitive(self.Pos, 3, 5);
			
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, 4, 0, false, 2); -- Raycast		
			
			if moCheck and moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local rayHitPos = Vector(rayHitPos.X, rayHitPos.Y);
				local MO = MovableMan:GetMOFromID(moCheck)
				
				local dist = SceneMan:ShortestDistance(self.Pos, rayHitPos, SceneMan.SceneWrapsX)
				
				local rightWay = true;
				
				if (self.Vel.X < 0 and dist.X > 0) or (self.Vel.X > 0 and dist.X < 0) then
					rightWay = false;
				end
				
				
				if rightWay and ((IsMOSRotating(MO)) and not ((MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee"))
				or (MO:IsInGroup("Mordhau Counter Shields") and (ToMOSRotating(MO):StringValueExists("Parrying Type")
				and ToMOSRotating(MO):GetStringValue("Parrying Type") == "Stab")))) then
					local hitAllowed = true;
					if self.hitMOTable then -- this shouldn't be needed but it is
						for index, root in pairs(self.hitMOTable) do
							if root == MO:GetRootParent().UniqueID or index == MO.UniqueID then
								hitAllowed = false;
							end
						end
					end
					if hitAllowed == true then
						self.hitMOTable[MO.UniqueID] = MO:GetRootParent().UniqueID;
						self.hitMOTableResetTimer:Reset();
						hit = true
						MO = ToMOSRotating(MO)
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
							if self.attackAnimationsGFX.hitFleshGFX then
								local effect = CreateMOSRotating(self.attackAnimationsGFX.hitFleshGFX);
								if effect then
									effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
									MovableMan:AddParticle(effect);
									effect:GibThis();
								end
							end
						elseif string.find(material,"Metal") or string.find(woundName,"Metal") or string.find(woundNameExit,"Metal") or string.find(material,"Stuff") or string.find(woundName,"Dent") or string.find(woundNameExit,"Dent") then
							if self.attackAnimationsGFX.hitMetalGFX then
								local effect = CreateMOSRotating(self.attackAnimationsGFX.hitMetalGFX);
								if effect then
									effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
									MovableMan:AddParticle(effect);
									effect:GibThis();
								end
							end
						end
						
						if MO:IsDevice() and math.random(1,3) >= 2 then
							if self.attackAnimationsGFX.hitDeflectGFX then
								local effect = CreateMOSRotating(self.attackAnimationsGFX.hitDeflectGFX);
								if effect then
									effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
									MovableMan:AddParticle(effect);
									effect:GibThis();
								end
							end
						end
						
						if MO:IsInGroup("Shields") then
							self.blockedSound:Play(self.Pos);
						end	
						
						local damage = 30;
						
						local woundsToAdd;
						local speedMult = math.max(1, self.Vel.Magnitude / 18);
						
						woundsToAdd = math.floor((damage*speedMult) + RangeRand(0,0.9))
						
						-- Hurt the actor, add extra damage
						local actorHit = MovableMan:GetMOFromID(MO.RootID)
						if (actorHit and IsActor(actorHit)) then-- and (MO.RootID == moCheck or (not IsAttachable(MO) or string.find(MO.PresetName,"Arm") or string.find(MO,"Leg") or string.find(MO,"Head"))) then -- Apply addational damage
						
							actorHit = ToActor(actorHit)
							
							if self.Vel.Magnitude < 18 then
								if math.random(0, 100) > 10 then
									self.Cooldown = true;
									self.cooldownTimer:Reset();
								end
							else
								if math.random(0, 100) > 50 then
									self.Cooldown = true;
									self.cooldownTimer:Reset();
								end
							end
							
							--print(actorHit.Material.StructuralIntegrity)
							--actor.Health = actor.Health - 8 * damageMulti;
							
							local addWounds = true;
							local addSingleWound = false;
							
							if (actorHit.Health - (damage * 10)) < 0 then -- bad estimation, but...
								if math.random(0, 100) < 15 then
									self.parent:SetNumberValue("Attack Killed", 1); -- celebration!!
								end
							elseif math.random(0, 100) < 30 then
								self.parent:SetNumberValue("Attack Success", 1); -- celebration!!
							end
							if IsAHuman(actorHit) then
								local actorHuman = ToAHuman(actorHit)
								local lessVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude/1);
								local torsoLessVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude/1);
								if (actorHuman.Head and MO.UniqueID == actorHuman.Head.UniqueID)
								or (actorHuman.FGArm and MO.UniqueID == actorHuman.FGArm.UniqueID)
								or (actorHuman.BGArm and MO.UniqueID == actorHuman.BGArm.UniqueID)
								or (actorHuman.FGLeg and MO.UniqueID == actorHuman.FGLeg.UniqueID)
								or (actorHuman.BGLeg and MO.UniqueID == actorHuman.BGLeg.UniqueID) then
									-- if wounds would gib the limb hit, dismember it instead... sometimes gib
									if MO.WoundCount + woundsToAdd > MO.GibWoundLimit then
										if math.random(0, 100) < 20 then
											MO:GibThis();
										else
											ToMOSRotating(actorHuman):RemoveAttachable(ToAttachable(MO), true, true);
											MO.Vel = MO.Vel + lessVel
										end
										addWounds = false;
									end
								elseif actorHuman.UniqueID == MO.UniqueID then -- if we hit torso
									MO.Vel = MO.Vel + torsoLessVel
									if MO.WoundCount + woundsToAdd > MO.GibWoundLimit and math.random(0, 100) < 50 then
										addWounds = false;
										actorHit.Health = 0;
									end
								elseif (actorHuman.EquippedItem and MO.UniqueID == actorHuman.EquippedItem.UniqueID) then -- if we hit device
									ToMOSRotating(MO:GetParent()):RemoveAttachable(ToAttachable(MO), true, true);
									MO.Vel = MO.Vel + torsoLessVel
								end
							end
							
							if addWounds == true and woundName then
								MO:SetNumberValue("Mordhau Flinched", 1);
								local flincher = CreateAttachable("Mordhau Flincher", "Mordhau.rte")
								MO:AddAttachable(flincher)
								for i = 1, woundsToAdd do
									MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
								end
							elseif addSingleWound and woundName then
								MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end

						elseif woundName then -- generic wound adding for non-actors
							for i = 1, woundsToAdd do
								MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end
						end
					end
				elseif (MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee")) or MO:IsInGroup("Mordhau Counter Shields") then
					hit = true;
					self.Cooldown = true;
					self.cooldownTimer:Reset();
					MO = ToHeldDevice(MO);
					if MO:NumberValueExists("Blocking") or (MO:StringValueExists("Parrying Type")
					and (MO:GetStringValue("Parrying Type") == "Stab" or MO:GetStringValue("Parrying Type") == "Flourish")) then
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
						if self.attackAnimationsGFX.hitTerrainHardGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX.hitTerrainHardGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
						
						hitType = 4 -- Hard
					else
						if self.attackAnimationsGFX.hitTerrainSoftGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX.hitTerrainHardGFX);
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
					if self.attackAnimationsSounds.hitDefaultSound then
						self.attackAnimationsSounds.hitDefaultSound:Play(self.Pos);
					end
				elseif hitType == 1 then -- Flesh
					if self.attackAnimationsSounds.hitFleshSound then
						self.attackAnimationsSounds.hitFleshSound:Play(self.Pos);
					end
					if math.random(0, 100) < 20 then
						local woundName = self:GetEntryWoundPresetName()
						self:AddWound(CreateAEmitter(woundName), Vector(0, 0), true)
					end
						
				elseif hitType == 2 then -- Metal
					if self.attackAnimationsSounds.hitMetalSound then
						self.attackAnimationsSounds.hitMetalSound:Play(self.Pos);
					end
					if math.random(0, 100) < 40 then
						local woundName = self:GetEntryWoundPresetName()
						self:AddWound(CreateAEmitter(woundName), Vector(0, 0), true)
					end
				end
				self.attackAnimationCanHit = false
			end
		end
	end
end