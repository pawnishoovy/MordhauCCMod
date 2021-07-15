ArcherAIBehaviours = {};

-- function ArcherAIBehaviours.createSoundEffect(self, effectName, variations)
	-- if effectName ~= nil then
		-- self.soundEffect = AudioMan:PlaySound(effectName .. math.random(1, variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 400, false);	
	-- end
-- end

-- no longer needed as of pre3!

function ArcherAIBehaviours.createEmotion(self, emotion, priority, duration, canOverridePriority)
	if canOverridePriority == nil then
		canOverridePriority = false;
	end
	local usingPriority
	if canOverridePriority == false then
		usingPriority = priority - 1;
	else
		usingPriority = priority;
	end
	if emotion then
		
		self.emotionApplied = false; -- applied later in handleheadframes
		self.Emotion = emotion;
		if duration then
			self.emotionTimer:Reset();
			self.emotionDuration = duration;
		else
			self.emotionDuration = 0; -- will follow voiceSound length
		end
		self.lastEmotionPriority = priority;
	end
end

function ArcherAIBehaviours.createVoiceSoundEffect(self, soundContainer, priority, emotion, canOverridePriority)
	if canOverridePriority == nil then
		canOverridePriority = false;
	end
	local usingPriority
	if canOverridePriority == false then
		usingPriority = priority - 1;
	else
		usingPriority = priority;
	end
	if self.Head and soundContainer ~= nil then
		if self.voiceSound then
			if self.voiceSound:IsBeingPlayed() then
				if self.lastPriority <= usingPriority then
					if emotion then
						ArcherAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
					end
					self.voiceSound:Stop();
					self.voiceSound = soundContainer;
					soundContainer:Play(self.Pos)
					self.lastPriority = priority;
					return true;
				end
			else
				if emotion then
					ArcherAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
				end
				self.voiceSound = soundContainer;
				soundContainer:Play(self.Pos)
				self.lastPriority = priority;
				return true;
			end
		else
			if emotion then
				ArcherAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
			end
			self.voiceSound = soundContainer;
			soundContainer:Play(self.Pos)
			self.lastPriority = priority;
			return true;
		end
	end
end

function ArcherAIBehaviours.handleMovement(self)
	
	local crouching = self.controller:IsState(Controller.BODY_CROUCH)
	local moving = self.controller:IsState(Controller.MOVE_LEFT) or self.controller:IsState(Controller.MOVE_RIGHT);
	
	-- Leg Collision Detection system
    --local i = 0
	if self:IsPlayerControlled() then -- AI doesn't update its own foot checking when playercontrolled so we have to do it
		if self.Vel.Y > 10 then
			self.wasInAir = true;
		else
			self.wasInAir = false;
		end
		for i = 1, 2 do
			--local foot = self.feet[i]
			local foot = nil
			--local leg = self.legs[i]
			if i == 1 then
				foot = self.FGFoot 
			else
				foot = self.BGFoot 
			end

			--if foot ~= nil and leg ~= nil and leg.ID ~= rte.NoMOID then
			if foot ~= nil then
				local footPos = foot.Pos				
				local mat = nil
				local pixelPos = footPos + Vector(0, 4)
				self.footPixel = SceneMan:GetTerrMatter(pixelPos.X, pixelPos.Y)
				--PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13)
				if self.footPixel ~= 0 then
					mat = SceneMan:GetMaterialFromID(self.footPixel)
				--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 162);
				--else
				--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13);
				end
				
				local movement = (self.controller:IsState(Controller.MOVE_LEFT) == true or self.controller:IsState(Controller.MOVE_RIGHT) == true or self.Vel.Magnitude > 3)
				if mat ~= nil then
					--PrimitiveMan:DrawTextPrimitive(footPos, mat.PresetName, true, 0);
					if self.feetContact[i] == false then
						self.feetContact[i] = true
						if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then																	
							self.feetTimers[i]:Reset()
						end
					end
				else
					if self.feetContact[i] == true then
						self.feetContact[i] = false
						if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then
							self.feetTimers[i]:Reset()
						end
					end
				end
			end
		end
	else
		if self.AI.flying == true and self.wasInAir == false then
			self.wasInAir = true;
		elseif self.AI.flying == false and self.wasInAir == true then
			self.wasInAir = false;
			self.isJumping = false
			if self.moveSoundTimer:IsPastSimMS(500) then
				self.movementSounds.Land:Play(self.Pos);
				self.moveSoundTimer:Reset();
				
				local pos = Vector(0, 0);
				SceneMan:CastObstacleRay(self.Pos, Vector(0, 45), pos, Vector(0, 0), self.ID, self.Team, 0, 10);				
				local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
				
				if self.terrainSounds.FootstepLand[terrPixel] ~= nil then
					self.terrainSounds.FootstepLand[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.FootstepLand[177]:Play(self.Pos);
				end	
			end
		end
	end
	
	
	
	-- Custom Jump
	if self.controller:IsState(Controller.BODY_JUMPSTART) == true and self.controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
		if (self:IsPlayerControlled() and self.feetContact[1] == true or self.feetContact[2] == true) or self.wasInAir == false then
			local jumpVec = Vector(0,-1.5)
			local jumpWalkX = 3
			if self.controller:IsState(Controller.MOVE_LEFT) == true then
				jumpVec.X = -jumpWalkX
			elseif self.controller:IsState(Controller.MOVE_RIGHT) == true then
				jumpVec.X = jumpWalkX
			end
			self.movementSounds.Jump:Play(self.Pos);
			
			if self.Health < 10 then
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.effortSerious, 2, 0);
			elseif self.Health < 35 then
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.effortMedium, 2, 0);
			else
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.effortLight, 2, 0);
			end

			local pos = Vector(0, 0);
			SceneMan:CastObstacleRay(self.Pos, Vector(0, 45), pos, Vector(0, 0), self.ID, self.Team, 0, 10);				
			local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
			
			if self.terrainSounds.FootstepJump[terrPixel] ~= nil then
				self.terrainSounds.FootstepJump[terrPixel]:Play(self.Pos);
			else -- default to concrete
				self.terrainSounds.FootstepJump[177]:Play(self.Pos);
			end
			
			if math.abs(self.Vel.X) > jumpWalkX * 2.0 then
				self.Vel = Vector(self.Vel.X, self.Vel.Y + jumpVec.Y)
			else
				self.Vel = Vector(self.Vel.X + jumpVec.X, self.Vel.Y + jumpVec.Y)
			end
			self.isJumping = true
			self.jumpTimer:Reset()
			self.jumpStop:Reset()
		end
	elseif self.isJumping or self.wasInAir then
		if (self:IsPlayerControlled() and self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
			self.isJumping = false
			self.wasInAir = false;
			if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
				self.movementSounds.Land:Play(self.Pos);
				self.moveSoundTimer:Reset();
				
				local pos = Vector(0, 0);
				SceneMan:CastObstacleRay(self.Pos, Vector(0, 45), pos, Vector(0, 0), self.ID, self.Team, 0, 10);				
				local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
				
				if self.terrainSounds.FootstepLand[terrPixel] ~= nil then
					self.terrainSounds.FootstepLand[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.FootstepLand[177]:Play(self.Pos);
				end						
				
			end
		end
	end

	if (crouching) then
		if (not self.wasCrouching and self.moveSoundTimer:IsPastSimMS(600)) then
			if (moving) then
				self.movementSounds.Prone:Play(self.Pos);
				if self.Health < 10 then
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.effortSerious, 2, 0);
				elseif self.Health < 35 then
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.effortMedium, 2, 0);
				else
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.effortLight, 2, 0);
				end

			else
				self.movementSounds.Crouch:Play(self.Pos);
			end
		end
		if (moving) then
			if self.terrainCollided == true and self.proneTerrainSoundPlayed ~= true then
				self.proneTerrainSoundPlayed = true;
				
				if self.terrainSounds.Prone[self.terrainCollidedWith] ~= nil then
					self.terrainSounds.Prone[self.terrainCollidedWith]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.Prone[177]:Play(self.Pos);
				end
				
			end
				
			if (self.moveSoundWalkTimer:IsPastSimMS(700)) then
				self.movementSounds.Crawl:Play(self.Pos);
				self.moveSoundWalkTimer:Reset();
				
				local pos = Vector(0, 0);
				SceneMan:CastObstacleRay(self.Pos, Vector(0, 20), pos, Vector(0, 0), self.ID, self.Team, 0, 5);				
				local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
				
				if self.terrainSounds.Crawl[terrPixel] ~= nil then
					self.terrainSounds.Crawl[terrPixel]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.Crawl[177]:Play(self.Pos);
				end		
				
			end
		end
	else
		if (self.wasCrouching and self.moveSoundTimer:IsPastSimMS(600)) then
			self.movementSounds.Stand:Play(self.Pos);
			self.moveSoundTimer:Reset();
		end
		self.proneTerrainSoundPlayed = false;
	end
	
	if not (moving) then
		self.foot = 0
	end

	self.wasCrouching = crouching;
	self.wasMoving = moving;
end

function ArcherAIBehaviours.handleHealth(self)

	local healthTimerReady = self.healthUpdateTimer:IsPastSimMS(750);
	local wasLightlyInjured = self.Health < (self.oldHealth - 5);
	local wasInjured = self.Health < (self.oldHealth - 25);
	local wasHeavilyInjured = self.Health < (self.oldHealth - 50);

	if (healthTimerReady or wasLightlyInjured or wasInjured or wasHeavilyInjured) then
	
		if self:NumberValueExists("Death By Fire") then
			self:RemoveNumberValue("Death By Fire");
			KnightAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 16, 5);
		end
	
		self.oldHealth = self.Health;
		self.healthUpdateTimer:Reset();
		
		if not (self.FGArm) and (self.FGArmLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.FGArmLost = true;
			if self.Health < 20 then
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 5, 5);
			else
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.lostArm, 5, 5);
			end
		end
		if not (self.BGArm) and (self.BGArmLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.BGArmLost = true;
			if self.Health < 20 then
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 5, 5);
			else
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.lostArm, 5, 5);
			end
		end
		if not (self.FGLeg) and (self.FGLegLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.FGLegLost = true;
			if self.Health < 20 then
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 5, 5);
			else
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.lostLeg, 5, 5);
			end
		end
		if not (self.BGLeg) and (self.BGLegLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.BGLegLost = true;
			if self.Health < 20 then
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 5, 5);
			else
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.lostLeg, 5, 5);
			end
		end	
		
		if wasHeavilyInjured then
			if math.random(0, 100) < 50 then -- just don't be in pain sometimes
				if self.Health < 5 then
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Disoriented, 5, 2)
				else
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.painSerious, 5, 2)
				end
			end
			self.Suppression = self.Suppression + 100;
		elseif wasInjured then
			if math.random(0, 100) < 50 then -- just don't be in pain sometimes
				if self.Health < 25 then
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.painGasp, 5, 2)
				else
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.painMedium, 5, 2)
				end
			end
			self.Suppression = self.Suppression + 50;
		elseif wasLightlyInjured then
			if math.random(0, 100) < 50 then -- just don't be in pain sometimes
				if self.inCombat == true then
					if math.random(0, 100) < 50 then
						ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.painLight, 5, 2)
					else
						ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.painSpoken, 5, 2)
					end
				else
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.painLight, 2, 2)
				end
			end
			ArcherAIBehaviours.createEmotion(self, 2, 1, 500);
			self.Suppression = self.Suppression + math.random(15,25);
		end
		
		if (wasInjured or wasHeavilyInjured) and self.Head then
			
			if self.Health > 0 then
			else
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.painSerious, 10, 5)

				self.seriousDeath = true;
				self.deathSoundPlayed = true;
				-- for actor in MovableMan.Actors do
					-- if actor.Team == self.Team then
						-- local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
						-- if d < 300 then
							-- local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
							-- if strength < 500 and math.random(1, 100) < 65 then
								-- actor:SetNumberValue("Scrappers Friendly Down", self.Gender)
								-- break;  -- first come first serve
							-- else
								-- if IsAHuman(actor) and actor.Head then -- if it is a human check for head
									-- local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
									-- if strength < 500 and math.random(1, 100) < 65 then		
										-- actor:SetNumberValue("Scrappers Friendly Down", self.Gender)
										-- break; -- first come first serve
									-- end
								-- end
							-- end
						-- end
					-- end
				-- end
				self.Dying = true;
				if (wasHeavilyInjured) and (self.Head.WoundCount > (self.headWounds + 1)) then
					-- insta death only on big headshots
					self.deathSoundPlayed = true;
					self.dyingSoundPlayed = true;
					if (self.voiceSound) and (self.voiceSound:IsBeingPlayed()) then
						self.voiceSound:Stop(-1);
					end
					self.allowedToDie = true;
					self.voiceSounds = {};
				end
			end
		end
		if self.Head then
			self.headWounds = self.Head.WoundCount
		end
	end
	
	if (self.allowedToDie == false and self.Health <= 0) or (self.Dying == true) then
		self.Health = 1;
		self.Dying = true;
		if self.Head then
			local wounds = self.Head.WoundCount;
			self.headWounds = wounds; -- to save variable rather than pointer to WoundCount
		end
		
		-- ??? Free performance ???
		for i = 1, self.InventorySize do
			local item = self:Inventory();
			if item then
				item.ToDelete = true
			end
			self:SwapNextInventory(item, true);
		end
		if math.random(1,2) < 2 then
			self.controller:SetState(Controller.WEAPON_DROP,true);
		end
	end	
	
end

function ArcherAIBehaviours.handleSuppression(self)

	-- local blinkTimerReady = self.blinkTimer:IsPastSimMS(self.blinkDelay);
	local suppressionTimerReady = self.suppressionUpdateTimer:IsPastSimMS(1500);
	
	-- if (blinkTimerReady) and (not self.Suppressed) and self.Head then
		-- if self.Head.Frame == self.baseHeadFrame then
			-- ArcherAIBehaviours.createEmotion(self, 1, 0, 100);
			-- self.blinkTimer:Reset();
			-- self.blinkDelay = math.random(5000, 11000);
		-- end
	-- end	
	
	if (suppressionTimerReady) then
		if self.inCombat == true then
			if self.Suppression < 35 then
				self.Suppression = self.Suppression + math.random(self.passiveSuppressionAmountLower, self.passiveSuppressionAmountUpper);
			end
		end
		if self.Suppression > 25 then

			if self.inCombat == true then
				if self.suppressedVoicelineTimer:IsPastSimMS(self.suppressedVoicelineDelay) and (not self.voiceSound:IsBeingPlayed()) then
					local chance = math.random(0, 100);
					if self.Suppression > 99 then
						-- keep playing voicelines if we keep being suppressed
							ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedSerious, 6, 4);
						self.suppressedVoicelineTimer:Reset();
						self.suppressionUpdates = 0;
					elseif self.Suppression > 55 then
						if self.Health < 20 and math.random(0, 100) < 20 then
							ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Losing, 5, 4);
						else
							ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedMedium, 5, 4);
						end
						self.suppressedVoicelineTimer:Reset();
						self.suppressionUpdates = 0;
					end
					if self.Suppressed == false then -- initial voiceline
						if self.Suppression > 55 then
							if self.Health < 20 and math.random(0, 100) < 20 then
								ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Losing, 5, 4);
							else
								ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedMedium, 5, 4);
							end
						else
							ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedLight, 5, 4);
						end
						self.suppressedVoicelineTimer:Reset();
					end
				end
			end
			self.Suppressed = true;
		else
			self.Suppressed = false;
		end
		self.Suppression = math.min(self.Suppression, 100)
		if self.Suppression > 0 then
			self.Suppression = self.Suppression - 2.5;
		end
		self.Suppression = math.max(self.Suppression, 0);
		self.suppressionUpdateTimer:Reset();
	end
end

function ArcherAIBehaviours.handleAITargetLogic(self)
	-- SPOT ENEMY REACTION
	-- works off of the native AI's target
	
	if not self.LastTargetID then
		self.LastTargetID = -1
	end
	
	--spotEnemy
	--spotEnemyFar
	--spotEnemyClose
	
	if (not self:IsPlayerControlled()) and self.AI.Target and IsAHuman(self.AI.Target) then
	
		self.inCombat = true;
		self:SetNumberValue("InCombat", 1)
		self.combatExitTimer:Reset();
	
		self.spotVoiceLineTimer:Reset();
		
		local posDifference = SceneMan:ShortestDistance(self.Pos,self.AI.Target.Pos,SceneMan.SceneWrapsX)
		local distance = posDifference.Magnitude
		
		local isClose = distance < self.spotDistanceClose
		local isMid = distance < self.spotDistanceMid 
		local isFar = distance > self.spotDistanceMid 
		
		-- DEBUG spot distance
		--[[
		local maxi = math.floor(distance / 10)
		for i = 1, maxi do
			local vec = posDifference * i / maxi
			local pos = self.Pos + vec
			local color = 162
			if vec.Magnitude < self.spotDistanceClose then
				color = 13
			elseif vec.Magnitude < self.spotDistanceMid then
				color = 122
			end
			PrimitiveMan:DrawLinePrimitive(pos, pos, color);
		end]]
		
		if self.spotAllowed ~= false then
			
			if self.LastTargetID == -1 then
				self.LastTargetID = self.AI.Target.UniqueID
				-- Target spotted
				--local posDifference = SceneMan:ShortestDistance(self.Pos,self.AI.Target.Pos,SceneMan.SceneWrapsX)
				
				if not self.AI.Target:NumberValueExists("Scrappers Enemy Spotted Age") or -- If no timer exists
				self.AI.Target:GetNumberValue("Scrappers Enemy Spotted Age") < (self.AI.Target.Age - self.AI.Target:GetNumberValue("Scrappers Enemy Spotted Delay")) or -- If the timer runs out of time limit
				math.random(0, 100) < self.spotIgnoreDelayChance -- Small chance to ignore timers, to spice things up
				then
					-- Setup the delay timer
					self.AI.Target:SetNumberValue("Scrappers Enemy Spotted Age", self.AI.Target.Age)
					self.AI.Target:SetNumberValue("Scrappers Enemy Spotted Delay", math.random(self.spotDelayMin, self.spotDelayMax))
					
					self.spotAllowed = false;
				
					if isClose then
						if self.Suppressed then
							ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.frustratedSerious, 4, 2);
						else
							if self.Health < 50 then
								ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.whoaMedium, 4, 2);
							else
								ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.frustratedMedium, 4, 2);
							end
						end
					else
						ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Spot, 3, 2);
					end
					
				end
			else
				-- Refresh the delay timer
				if self.AI.Target:NumberValueExists("Scrappers Enemy Spotted Age") then
					self.AI.Target:SetNumberValue("Scrappers Enemy Spotted Age", self.AI.Target.Age)
				end
			end
		end
	else
		if self.spotVoiceLineTimer:IsPastSimMS(self.spotVoiceLineDelay) then
			self.spotAllowed = true;
		end
		if self.combatExitTimer:IsPastSimMS(self.combatExitDelay) and self.inCombat == true then
			self.inCombat = false;
			self:RemoveNumberValue("InCombat")
			if self.Health < 10 then
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.recoveryExtreme, 2, 0);
			elseif self.Health < 35 then
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.recoverySerious, 2, 0);
			elseif self.Health < 60 then
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.recoveryMedium, 2, 0);
			elseif self.Health < 90 and math.random(0, 100) < 50 then
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.recoveryLight, 2, 0);
			end
		end
		if self.LastTargetID ~= -1 then
			self.LastTargetID = -1
			-- Target lost
			--print("TARGET LOST!")
		end
	end
end

function ArcherAIBehaviours.handleVoicelines(self)

	if self:NumberValueExists("Death By Fire") then
		self:RemoveNumberValue("Death By Fire");
		ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 16, 5);
	end
	
	if self:NumberValueExists("Blocked Bullet Mordhau") then
		self:RemoveNumberValue("Blocked Bullet Mordhau");
		self.Suppression = self.Suppression + 3;
		ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.frustratedLight, 2, 0);
	end

	-- DEVICE RELATED VOICELINES
	
	if (self.attackSuccess == true) and (not self.voiceSound:IsBeingPlayed() or self.attackSuccessTimer:IsPastSimMS(self.attackSuccessTime)) then
		self.attackSuccess = false;
		ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Happy, 3, 3);
	end
	
	if (self.attackKilled == true) and (not self.voiceSound:IsBeingPlayed() or self.attackKilledTimer:IsPastSimMS(self.attackKilledTime)) then
		self.attackKilled = false;
		ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.killingEnemy, 5, 4);
	end
	
	if self.EquippedItem then	
		-- SUPPRESSING
		if (IsHDFirearm(self.EquippedItem)) then
			local gun = ToHDFirearm(self.EquippedItem);
			local gunMag = gun.Magazine
			local reloading = gun:IsReloading();
			
			if self.EquippedItem:IsInGroup("Weapons - Primary") then
				
				if gun.FullAuto == true and gunMag and gunMag.Capacity > 40  and gun:IsActivated() then
					if gun.FiredFrame then
						self.gunShotCounter = self.gunShotCounter + 1;
					end
					if self.gunShotCounter > (gunMag.Capacity*0.7) and self.suppressingVoicelineTimer:IsPastSimMS(self.suppressingVoicelineDelay) then
						ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Suppressing, 3, 3);
						self.suppressingVoicelineTimer:Reset();
					end
				else
					self.gunShotCounter = 0;
				end			
				
			elseif self.EquippedItem:IsInGroup("Weapons - Melee") then
				if self:NumberValueExists("Light Attack") then
					self:RemoveNumberValue("Light Attack");
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.attackLight, 3, 3);
					self.movementSounds.AttackLight:Play(self.Pos);
				elseif self:NumberValueExists("Medium Attack") then
					self:RemoveNumberValue("Medium Attack");
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.attackMedium, 3, 3);
					self.movementSounds.AttackMedium:Play(self.Pos);
				elseif self:NumberValueExists("Large Attack") then
					self:RemoveNumberValue("Large Attack");
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.attackLarge, 3, 3);
					self.movementSounds.AttackLarge:Play(self.Pos);
				elseif self:NumberValueExists("Extreme Attack") then
					self:RemoveNumberValue("Extreme Attack");
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.attackExtreme, 3, 3);
					self.movementSounds.AttackExtreme:Play(self.Pos);
					
				elseif self:NumberValueExists("Attack Success") then
					self.attackSuccess = true;
					self:RemoveNumberValue("Attack Success");
					self.attackSuccessTimer:Reset();
					
				elseif self:NumberValueExists("Attack Killed") then
					self.attackKilled = true;
					self:RemoveNumberValue("Attack Killed");
					self.attackKilledTimer:Reset();
					
				end
				
			end
			
			
			if (reloading) then
				if (self.reloadVoicelinePlayed ~= true) then
					if (self.Suppressed) then
						if (math.random(1, 100) < 10) then
							ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.frustratedMedium, 3, 3);
						end
					elseif (math.random(1, 100) < 5) and gunMag and gunMag.Capacity > 10 then
						ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Reload, 3, 3);
					end
					self.reloadVoicelinePlayed = true;
				end
			else
				self.reloadVoicelinePlayed = false;
			end
		end
		
		-- THROWING GRENADES
	
		if IsThrownDevice(self.EquippedItem) then
			local activated = self.controller:IsState(Controller.WEAPON_FIRE)
			if (activated) then

				if self.activatedExplosive ~= true then
					self.activatedExplosive = true;
					self.movementSounds.ThrowStart:Play(self.Pos);
				end

				-- if (self.throwGrenadeVoicelinePlayed ~= true) then
					-- --ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.throwGrenade, 3, 4);
					-- self.throwGrenadeVoicelinePlayed = true;
				-- end
			else
				-- self.throwGrenadeVoicelinePlayed = false;
				if self.activatedExplosive then
					self.activatedExplosive = false;
					self.movementSounds.Throw:Play(self.Pos);
					ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.attackLight, 3, 3);

				end
			end
		end
	end

	-- DEATH REACTIONS
	-- the dying actor actually lets us know whether to play a voiceline through 1-time detection and value-setting.
	-- 0 = male, 1 = female
	
	-- if self:NumberValueExists("Scrappers Friendly Down") then
		-- self.Suppression = self.Suppression + 25;
		-- if self.friendlyDownTimer:IsPastSimMS(self.friendlyDownDelay) then
			-- local Sounds = self:GetNumberValue("Scrappers Friendly Down") == 0 and self.voiceSounds.maleDown or self.voiceSounds.femaleDown;
			
			-- ArcherAIBehaviours.createVoiceSoundEffect(self, Sounds, 4, 4, true);		
			-- self.friendlyDownTimer:Reset();
		-- end
		-- self:RemoveNumberValue("Scrappers Friendly Down")
	-- end	
end

function ArcherAIBehaviours.handleDying(self)

	self.controller.Disabled = true;
	self.HUDVisible = false
	if self.allowedToDie == false then
		self.Health = 1;
		self.Status = 3;
	else
		-- if self.Head then
			-- self.Head.Frame = self.baseHeadFrame + 1; -- (+1: eyes closed. rest in peace grunt)
		-- end
		self.Health = -1;
		self.Status = 4;
	end


	if self.Head then
		--self.Head.CollidesWithTerrainWhenAttached = false
		
		if self.Head.WoundCount > self.headWounds then
			self.deathSoundPlayed = true;
			self.dyingSoundPlayed = true;
			if (self.voiceSound) and (self.voiceSound:IsBeingPlayed()) then
				self.voiceSound:Stop(-1);
			end
			self.allowedToDie = true;
		end
		if self.deathSoundPlayed ~= true then
			-- Addational Velocity
			self.Vel = self.Vel + Vector(RangeRand(-2, 2), RangeRand(-2.0, 0.5))
			self.AngularVel = self.AngularVel + RangeRand(4,12) * (math.random(0,1) * 2.0 - 1.0)
			--self.AngularVel = self.AngularVel + RangeRand(-5,5)
			
			self.deathSoundPlayed = true;
			if math.random(1, 100) < 80 then
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.painSerious, 15, 5)
			else
				ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.deathEpic, 15, 5)
			end
			-- for actor in MovableMan.Actors do
				-- if actor.Team == self.Team then
					-- local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
					-- if d < 300 then
						-- local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
						-- if strength < 500 and math.random(1, 100) < 65 then
							-- actor:SetNumberValue("Scrappers Friendly Down", self.Gender)
							-- break;  -- first come first serve
						-- else
							-- if IsAHuman(actor) and actor.Head then -- if it is a human check for head
								-- local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
								-- if strength < 500 and math.random(1, 100) < 65 then		
									-- actor:SetNumberValue("Scrappers Friendly Down", self.Gender)
									-- break; -- first come first serve
								-- end
							-- end
						-- end
					-- end
				-- end
			-- end
		end
		if self.dyingSoundPlayed ~= true then
			if not (self.voiceSound) or (not self.voiceSound:IsBeingPlayed()) then
				self:NotResting();
				local attachable
				for attachable in self.Attachables do
					attachable:NotResting();
				end
				self.ToSettle = false;
				self.RestThreshold = -1;
				self.dyingSoundPlayed = true;
				if self.inCombat == true and (math.random(1, 100) < self.incapacitationChance) then
					if self.seriousDeath == true then
						ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Incap, 14, 2)
					else
						ArcherAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.incapSpoken, 14, 2)
					end
					self.incapacitated = true
				end
			end
		end
		if self.incapacitated and (self.dyingSoundPlayed and self.Vel.Magnitude < 1) then
			self.Vel = self.Vel + Vector(RangeRand(-2, 2), RangeRand(-0.5, 0.5)) * TimerMan.DeltaTimeSecs * 62.5
		end
		
		if self.voiceSound:IsBeingPlayed() then
			self:NotResting();
			local attachable
			for attachable in self.Attachables do
				attachable:NotResting();
			end
			self.ToSettle = false;
			self.RestThreshold = -1;
		elseif self.dyingSoundPlayed == true then
			self.allowedToDie = true;
		end
	end
end

function ArcherAIBehaviours.handleRagdoll(self)
	-- EXPERIMENTAL BETTER RAGDOLL
	local radius = self.IndividualRadius * 0.9
	
	local min_value = -math.pi;
	local max_value = math.pi;
	local value = self.RotAngle
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
	
	local str = math.max(1 - math.abs(result / math.pi * 2.0), 0)
	--local normal = Vector(0,0)
	--local slide = false
	
	-- Trip on the ground
	for j = 0, 1 do
		local pos = self.Pos + Vector(0, -3):RadRotate(self.RotAngle)
		if self.Head and math.random(1,2) < 2 then
			pos = self.Head.Pos
		end
		
		local maxi = 6
		for i = 0, maxi do
			local checkVec = Vector(radius * (0.7 - 0.2 * j),0):RadRotate(math.pi * 2 / maxi * i + self.RotAngle)
			local checkOrigin = Vector(pos.X, pos.Y) + checkVec + Vector(self.Vel.X, self.Vel.Y) * rte.PxTravelledPerFrame * 0.3
			local checkPix = SceneMan:GetTerrMatter(checkOrigin.X, checkOrigin.Y)
			
			if checkPix > 0 then
				self.Vel = self.Vel - Vector(checkVec.X, checkVec.Y):SetMagnitude(30 * str) * TimerMan.DeltaTimeSecs
				self.AngularVel = self.AngularVel + (self.AngularVel / math.abs(self.AngularVel)) * str * 20 * TimerMan.DeltaTimeSecs
				
				--normal = normal + checkVec
				--slide = true
			end
		end
		
	end
	--[[
	normal = (normal / 12):SetMagnitude(1)
	if slide then
		local slideAngle = normal.AbsRadAngle + math.pi * 0.5
		
		local newVel = Vector(self.Vel.X, self.Vel.Y)
		newVel:RadRotate(slideAngle)
		newVel = Vector(newVel.X, -math.abs(-newVel.Y))
		newVel:RadRotate(-slideAngle)
		self.Vel = self.Vel * str + newVel * (1 - str)
	end]]
	-- SOUNDS
	
	local mat = self.HitWhatTerrMaterial
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + self.TravelImpulse * 0.1, 5);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + self.Vel, 13);
	--self.TravelImpulse.Magnitude
	if mat ~= 0 then
		if self.TravelImpulse.Magnitude > self.ImpulseDamageThreshold and self.ragdollTerrainImpactTimer:IsPastSimMS(self.ragdollTerrainImpactDelay) then
			if self.terrainSounds.TerrainImpactHeavy[self.terrainCollidedWith] ~= nil then
				self.terrainSounds.TerrainImpactHeavy[self.terrainCollidedWith]:Play(self.Pos);
			else -- default to concrete
				self.terrainSounds.TerrainImpactHeavy[177]:Play(self.Pos);
			end
			self.ragdollTerrainImpactDelay = math.random(200, 500)
			self.ragdollTerrainImpactTimer:Reset()
		elseif self.TravelImpulse.Magnitude > 400 and self.ragdollTerrainImpactTimer:IsPastSimMS(self.ragdollTerrainImpactDelay) then
			if self.terrainSounds.TerrainImpactLight[self.terrainCollidedWith] ~= nil then
				self.terrainSounds.TerrainImpactLight[self.terrainCollidedWith]:Play(self.Pos);
			else -- default to concrete
				self.terrainSounds.TerrainImpactLight[177]:Play(self.Pos);
			end
			self.ragdollTerrainImpactDelay = math.random(200, 500)
			self.ragdollTerrainImpactTimer:Reset()
		elseif self.TravelImpulse.Magnitude > 230 then
			self.movementSounds.Crawl:Play(self.Pos);
		end
	end
end

function ArcherAIBehaviours.handleHeadFrames(self)
	if not self.Head then return end
	if self.Emotion and self.emotionApplied ~= true and self.Head then
		self.Head.Frame = self.baseHeadFrame + self.Emotion;
		self.emotionApplied = true;
	end
		
		
	if self.emotionDuration > 0 and self.emotionTimer:IsPastSimMS(self.emotionDuration) then
		if (self.Suppressed or self.Suppressing) and (self.inCombat == true) then
			self.Head.Frame = self.baseHeadFrame + 2;
		else
			self.Head.Frame = self.baseHeadFrame;
		end
	elseif (self.emotionDuration == 0) and ((not self.voiceSound or not self.voiceSound:IsBeingPlayed())) then
		-- if suppressed OR suppressing when in combat base emotion is angry
		if (self.Suppressed or self.Suppressing) and (self.inCombat == true) then
			self.Head.Frame = self.baseHeadFrame + 2;
		else
			self.Head.Frame = self.baseHeadFrame;
		end
	end

end

function ArcherAIBehaviours.handleHeadLoss(self)
	if not (self.Head) then
		self.allowedToDie = true;
		self.voiceSounds = {};
		self.voiceSound:Stop(-1);
	end
end