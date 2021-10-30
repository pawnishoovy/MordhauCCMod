package.loaded.Constants = nil; require("Constants");

-----------------------------------------------------------------------------------------
-- Start Activity
-----------------------------------------------------------------------------------------

function MedievalDuel:StartActivity()
	print("START! -- MedievalDuel:StartActivity()!");
	
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if self:PlayerActive(player) and self:PlayerHuman(player) then
			-- Check if we already have a brain assigned
			if not self:GetPlayerBrain(player) then
				local foundBrain = MovableMan:GetUnassignedBrain(self:GetTeamOfPlayer(player))
				-- If we can't find an unassigned brain in the scene to give each player, then force to go into editing mode to place one
				if not foundBrain then
					self.ActivityState = Activity.EDITING
					-- Open all doors so we can do pathfinding through them with the brain placement
					MovableMan:OpenAllDoors(true, Activity.NOTEAM)
					AudioMan:ClearMusicQueue()
					AudioMan:PlayMusic("Base.rte/Music/dBSoundworks/ccambient4.ogg", -1, -1)
					self:SetLandingZone(Vector(player*SceneMan.SceneWidth/4, 0), player)
				else
					-- Set the found brain to be the selected actor at start
					self:SetPlayerBrain(foundBrain, player)
					self:SwitchToActor(foundBrain, player, self:GetTeamOfPlayer(player))
					self:SetLandingZone(self:GetPlayerBrain(player).Pos, player)
					-- Set the observation target to the brain, so that if/when it dies, the view flies to it in observation mode
					self:SetObservationTarget(self:GetPlayerBrain(player).Pos, player)
				end
			end
		end
	end
	
	self.windAmbienceSound = CreateSoundContainer("Cave Combat Ambience", "Mordhau.rte");
	self.windAmbienceSound:Play(Vector(0, 0));
	
	self.windInteriorAmbienceSound = CreateSoundContainer("Cave Combat Interior Ambience", "Mordhau.rte");
	self.windInteriorAmbienceSound.Volume = 0;
	self.windInteriorAmbienceSound:Play(Vector(0, 0));
	
	self.ambienceSoundFinal = self.windAmbienceSound
	self.ambienceTimer = Timer();
	self.ambienceDelay = 3000;
	
	self.interiorAmbienceTimer = Timer();
	self.interiorAmbienceDelay = 1489;
	
end

-----------------------------------------------------------------------------------------
-- Pause Activity
-----------------------------------------------------------------------------------------

function MedievalDuel:PauseActivity(pause)
	print("PAUSE! -- MedievalDuel:PauseActivity()!");
end

-----------------------------------------------------------------------------------------
-- End Activity
-----------------------------------------------------------------------------------------

function MedievalDuel:EndActivity()
	print("END! -- MedievalDuel:EndActivity()!");
end

-----------------------------------------------------------------------------------------
-- Update Activity
-----------------------------------------------------------------------------------------

function MedievalDuel:UpdateActivity()

	if self:PlayerActive(Activity.PLAYER_1) and self:PlayerHuman(Activity.PLAYER_1) then
		local cursorPos = SceneMan:GetScrollTarget(Activity.PLAYER_1)
		
		if SceneMan.Scene:WithinArea("Interior", cursorPos) then
			self.interiorAmbience = true;
		else
			self.interiorAmbience = false;
		end	
	end
	
	if self.interiorAmbience == false and self.windInteriorAmbienceSound.Volume > 0 then
		self.windInteriorAmbienceSound.Volume = self.windInteriorAmbienceSound.Volume - 0.5 * TimerMan.DeltaTimeSecs;
		if self.windInteriorAmbienceSound.Volume < 0 then
			self.windInteriorAmbienceSound.Volume = 0;
		end
	elseif self.interiorAmbience == true and self.windInteriorAmbienceSound.Volume < 0.5 then
		self.windInteriorAmbienceSound.Volume = self.windInteriorAmbienceSound.Volume + 0.5 * TimerMan.DeltaTimeSecs;
		if self.windInteriorAmbienceSound.Volume > 0.5 then
			self.windInteriorAmbienceSound.Volume = 0.5;
		end
	end
	
	if self.interiorAmbience == true and self.windAmbienceSound.Volume > 0 then
		self.windAmbienceSound.Volume = self.windAmbienceSound.Volume - 0.5 * TimerMan.DeltaTimeSecs;
		if self.windAmbienceSound.Volume < 0 then
			self.windAmbienceSound.Volume = 0;
		end
	elseif self.interiorAmbience == false and self.windAmbienceSound.Volume < 0.5 then
		self.windAmbienceSound.Volume = self.windAmbienceSound.Volume + 0.5 * TimerMan.DeltaTimeSecs;
		if self.windAmbienceSound.Volume > 0.5 then
			self.windAmbienceSound.Volume = 0.5;
		end
	end
	
	if self.ambienceTimer:IsPastSimMS(self.ambienceDelay) then
		self.windAmbienceSound:Play(Vector(0, 0));
		self.ambienceTimer:Reset();
	end
	
	if self.interiorAmbienceTimer:IsPastSimMS(self.interiorAmbienceDelay) then
		self.windInteriorAmbienceSound:Play(Vector(0, 0));
		self.interiorAmbienceTimer:Reset();
	end

	if self.ActivityState == Activity.EDITING then
		-- Game is in editing or other modes, so open all does and reset the game running timer
		MovableMan:OpenAllDoors(true, Activity.NOTEAM)
		-- self.StartTimer:Reset()
	end
end