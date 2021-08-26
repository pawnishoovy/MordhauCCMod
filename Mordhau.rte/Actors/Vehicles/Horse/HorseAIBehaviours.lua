HorseAIBehaviours = {};

-- function HorseAIBehaviours.createSoundEffect(self, effectName, variations)
	-- if effectName ~= nil then
		-- self.soundEffect = AudioMan:PlaySound(effectName .. math.random(1, variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 400, false);	
	-- end
-- end

-- no longer needed as of pre3!

function HorseAIBehaviours.createEmotion(self, emotion, priority, duration, canOverridePriority)
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

function HorseAIBehaviours.createVoiceSoundEffect(self, soundContainer, priority, emotion, canOverridePriority)
	if canOverridePriority == nil then
		canOverridePriority = false;
	end
	local usingPriority
	if canOverridePriority == false then
		usingPriority = priority - 1;
	else
		usingPriority = priority;
	end
	if self.head and soundContainer ~= nil then
		if self.voiceSound then
			if self.voiceSound:IsBeingPlayed() then
				if self.lastPriority <= usingPriority then
					if emotion then
						HorseAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
					end
					self.voiceSound:Stop();
					self.voiceSound = soundContainer;
					soundContainer:Play(self.Pos)
					self.lastPriority = priority;
					return true;
				end
			else
				if emotion then
					HorseAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
				end
				self.voiceSound = soundContainer;
				soundContainer:Play(self.Pos)
				self.lastPriority = priority;
				return true;
			end
		else
			if emotion then
				HorseAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
			end
			self.voiceSound = soundContainer;
			soundContainer:Play(self.Pos)
			self.lastPriority = priority;
			return true;
		end
	end
end

function HorseAIBehaviours.handleMovement(self)
	

end

function HorseAIBehaviours.handleHealth(self)

	local healthTimerReady = self.healthUpdateTimer:IsPastSimMS(750);
	local wasLightlyInjured = self.Health < (self.oldHealth - 5);
	local wasInjured = self.Health < (self.oldHealth - 20);
	local wasHeavilyInjured = self.Health < (self.oldHealth - 40);

	if (healthTimerReady or wasLightlyInjured or wasInjured or wasHeavilyInjured) then
	
		if self:NumberValueExists("Death By Fire") then
			self:RemoveNumberValue("Death By Fire");
			HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.neighScared, 16, 5);
		end
	
		self.oldHealth = self.Health;
		self.healthUpdateTimer:Reset();
		
		if wasHeavilyInjured then
			if math.random(0, 100) < 20 then -- just don't be in pain sometimes
				if self.Health < 5 then
					HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.neighScared, 5, 2)
				else
					HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.neighAggressive, 5, 2)
				end
			end
			self.Suppression = self.Suppression + 100;
		elseif wasInjured then
			if math.random(0, 100) < 50 then -- just don't be in pain sometimes
				if self.Health < 25 then
					HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.gruntScared, 5, 2)
				else
					HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.gruntAggressive, 5, 2)
				end
			end
			self.Suppression = self.Suppression + 50;
		elseif wasLightlyInjured then
			if math.random(0, 100) < 70 then -- just don't be in pain sometimes
				HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.gruntAggressive, 5, 2)
			end
			HorseAIBehaviours.createEmotion(self, 2, 1, 500);
			self.Suppression = self.Suppression + math.random(15,25);
		end
		
		if (wasInjured or wasHeavilyInjured) and self.head then
			
			if self.Health > 0 then
			else
				self.deathSoundPlayed = true;
				HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.neighScared, 15, 5)

				self.seriousDeath = true;
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
				if (wasHeavilyInjured) and (self.head.WoundCount > (self.headWounds + 1)) then
					-- insta death only on big headshots
					if (self.voiceSound) and (self.voiceSound:IsBeingPlayed()) then
						self.voiceSound:Stop(-1);
					end
					self.voiceSounds = {};
				end
			end
		end
		if self.head then
			self.headWounds = self.head.WoundCount
		end
	end
	
end

function HorseAIBehaviours.handleSuppression(self)

	-- local blinkTimerReady = self.blinkTimer:IsPastSimMS(self.blinkDelay);
	local suppressionTimerReady = self.suppressionUpdateTimer:IsPastSimMS(1500);
	
	-- if (blinkTimerReady) and (not self.Suppressed) and self.head then
		-- if self.head.Frame == self.baseHeadFrame then
			-- HorseAIBehaviours.createEmotion(self, 1, 0, 100);
			-- self.blinkTimer:Reset();
			-- self.blinkDelay = math.random(5000, 11000);
		-- end
	-- end	
	
	if (suppressionTimerReady) then
		if self.Suppression > 25 then

			if self.suppressedVoicelineTimer:IsPastSimMS(self.suppressedVoicelineDelay) and (not self.voiceSound:IsBeingPlayed()) then
				local chance = math.random(0, 100);
				if self.Suppression > 99 then
					-- keep playing voicelines if we keep being suppressed
					HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.neighScared, 6, 4);
					if self.rider and math.random(0, 100) < 50 then
						self.rider:SetNumberValue("Horse Response", 1)
					end	
					self.suppressedVoicelineTimer:Reset();
					self.suppressionUpdates = 0;
				elseif self.Suppression > 55 then
					HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.gruntScared, 5, 4);
					if self.rider and math.random(0, 100) < 50 then
						self.rider:SetNumberValue("Horse Response", 6)
					end	
					self.suppressedVoicelineTimer:Reset();
					self.suppressionUpdates = 0;
				end
				if self.Suppressed == false then -- initial voiceline
					if self.Suppression > 55 then
						if self.Health < 20 and math.random(0, 100) < 20 then
							HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.neighAggressive, 5, 4);
							if self.rider and math.random(0, 100) < 50 then
								self.rider:SetNumberValue("Horse Response", 1)
							end	
						else
							HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.gruntAggressive, 5, 4);
							if self.rider then
								if math.random(0, 100) < 30 then
									self.rider:SetNumberValue("Horse Response", 6)
								elseif math.random(0, 100) < 60 then
									self.rider:SetNumberValue("Horse Response", 1)
								end
							end
						end
					else
						HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.gruntAggressive, 5, 4);
						if self.rider then
							if math.random(0, 100) < 30 then
								self.rider:SetNumberValue("Horse Response", 6)
							elseif math.random(0, 100) < 60 then
								self.rider:SetNumberValue("Horse Response", 1)
							end
						end
					end
					self.suppressedVoicelineTimer:Reset();
				end
			end
			self.Suppressed = true;
		else
			if self.suppressedVoicelineTimer:IsPastSimMS(self.suppressedVoicelineDelay) and (not self.voiceSound:IsBeingPlayed()) then
				if not self.Moving and math.random(0, 100) < 35 then
					HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.breathIdle, 2);
				elseif self.Moving and math.random(0, 100) < 15 then -- TODO: GAIT DEPENDENCE
					HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.snortSlow, 2);
				end
				self.suppressedVoicelineTimer:Reset();
			end
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

function HorseAIBehaviours.handleVoicelines(self)

	if self:NumberValueExists("Death By Fire") then
		self:RemoveNumberValue("Death By Fire");
		HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.neighScared, 16, 5);
	end

end

function HorseAIBehaviours.handleDying(self)


	if self.head then
		--self.head.CollidesWithTerrainWhenAttached = false
		
		if self.head.WoundCount > self.headWounds then
			if (self.voiceSound) and (self.voiceSound:IsBeingPlayed()) then
				self.voiceSound:Stop(-1);
			end
		end
		if self.deathSoundPlayed ~= true then
			
			self.deathSoundPlayed = true;
			if math.random(1, 100) < 80 then
				HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.gruntScared, 15, 5)
			else
				HorseAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.neighScared, 15, 5)
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
	end
end

function HorseAIBehaviours.handleHeadFrames(self)
	if not self.head then return end
	if self.Emotion and self.emotionApplied ~= true and self.head then
		self.head.Frame = self.baseHeadFrame + self.Emotion;
		self.emotionApplied = true;
	end
		
		
	if self.emotionDuration > 0 and self.emotionTimer:IsPastSimMS(self.emotionDuration) then
		if (self.Suppressed or self.Suppressing) and (self.inCombat == true) then
			self.head.Frame = self.baseHeadFrame + 2;
		else
			self.head.Frame = self.baseHeadFrame;
		end
	elseif (self.emotionDuration == 0) and ((not self.voiceSound or not self.voiceSound:IsBeingPlayed())) then
		-- if suppressed OR suppressing when in combat base emotion is angry
		if (self.Suppressed or self.Suppressing) and (self.inCombat == true) then
			self.head.Frame = self.baseHeadFrame + 2;
		else
			self.head.Frame = self.baseHeadFrame;
		end
	end

end

function HorseAIBehaviours.handleHeadLoss(self)
	if not (self.head) then
		self.voiceSounds = {};
		self.voiceSound:Stop(-1);
	end
end