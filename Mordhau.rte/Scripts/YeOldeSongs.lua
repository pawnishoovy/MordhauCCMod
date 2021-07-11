function YeOldeSongsScript:StartScript()
	self.activity = ToGameActivity(ActivityMan:GetActivity())
	
	AudioMan:ClearMusicQueue();
	AudioMan:StopMusic();
	
	self.MUSIC_STATE = "Intro";
	
	self.componentTimer = Timer();
	self.restTimer = Timer();
	
	self.loopNumber = 0;
	self.totalLoopNumber = 0;
	self.tuneMaxLoops = 64;
	
	self.desiredIntensity = 1;
	self.Intensity = 1;
	
	self.intensityCheckTimer = Timer();
	self.intensityCheckDelay = 10000;
	
	self.lowIntensity = 0.7;
	self.lowIntensityActorThreshold = 6;
	self.mediumIntensity = 1;
	self.mediumIntensityActorThreshold = 10;
	self.highIntensity = 1.5;
	self.highIntensityActorThreshold = 12;
	self.totalIntensity = 2;
	self.totalIntensityActorThreshold = 16;

	self.Tunes = {};
	
	self.Tunes.combatA = {};
	self.Tunes.combatA.Components = {};
	self.Tunes.combatA.Components[1] = {};
	self.Tunes.combatA.Components[1].Container = CreateSoundContainer("Combat A 01 10", "Mordhau.rte");
	self.Tunes.combatA.Components[1].preLength = 2025;
	self.Tunes.combatA.Components[1].totalPost = 19767;
	self.Tunes.combatA.Components[1].Type = "Intro";
	
	self.Tunes.combatA.Components[2] = {};
	self.Tunes.combatA.Components[2].Container = CreateSoundContainer("Combat A 02 20", "Mordhau.rte");
	self.Tunes.combatA.Components[2].preLength = 2025;
	self.Tunes.combatA.Components[2].totalPost = 19767;
	self.Tunes.combatA.Components[2].canLinkTo = {3};
	
	self.Tunes.combatA.Components[3] = {};
	self.Tunes.combatA.Components[3].Container = CreateSoundContainer("Combat A 03 20", "Mordhau.rte");
	self.Tunes.combatA.Components[3].preLength = 2025;
	self.Tunes.combatA.Components[3].totalPost = 19767;
	self.Tunes.combatA.Components[3].canLinkTo = {2, 4};
	
	self.Tunes.combatA.Components[4] = {};
	self.Tunes.combatA.Components[4].Container = CreateSoundContainer("Combat A 04 30", "Mordhau.rte");
	self.Tunes.combatA.Components[4].preLength = 2025;
	self.Tunes.combatA.Components[4].totalPost = 19767;
	self.Tunes.combatA.Components[4].canLinkTo = {5};
	
	self.Tunes.combatA.Components[5] = {};
	self.Tunes.combatA.Components[5].Container = CreateSoundContainer("Combat A 05 30", "Mordhau.rte");
	self.Tunes.combatA.Components[5].preLength = 2025;
	self.Tunes.combatA.Components[5].totalPost = 19767;
	self.Tunes.combatA.Components[5].canLinkTo = {2, 4};
	
	self.Tunes.combatA.Components[6] = {};
	self.Tunes.combatA.Components[6].Container = CreateSoundContainer("Combat A 06 40", "Mordhau.rte");
	self.Tunes.combatA.Components[6].preLength = 2025;
	self.Tunes.combatA.Components[6].totalPost = 19767;
	self.Tunes.combatA.Components[6].Type = "Transitional";
	
	self.Tunes.combatA.Components[7] = {};
	self.Tunes.combatA.Components[7].Container = CreateSoundContainer("Combat A 07 50", "Mordhau.rte");
	self.Tunes.combatA.Components[7].preLength = 2025;
	self.Tunes.combatA.Components[7].totalPost = 19767;
	self.Tunes.combatA.Components[7].canLinkTo = {8};
	
	self.Tunes.combatA.Components[8] = {};
	self.Tunes.combatA.Components[8].Container = CreateSoundContainer("Combat A 08 30", "Mordhau.rte");
	self.Tunes.combatA.Components[8].preLength = 2025;
	self.Tunes.combatA.Components[8].totalPost = 19767;
	self.Tunes.combatA.Components[8].canLinkTo = {9};
	
	self.Tunes.combatA.Components[9] = {};
	self.Tunes.combatA.Components[9].Container = CreateSoundContainer("Combat A 09 30", "Mordhau.rte");
	self.Tunes.combatA.Components[9].preLength = 2025;
	self.Tunes.combatA.Components[9].totalPost = 19767;
	self.Tunes.combatA.Components[9].canLinkTo = {7};
	
	self.Tunes.combatA.Components[10] = {};
	self.Tunes.combatA.Components[10].Container = CreateSoundContainer("Combat A 10 40", "Mordhau.rte");
	self.Tunes.combatA.Components[10].preLength = 2025;
	self.Tunes.combatA.Components[10].totalPost = 19767;
	self.Tunes.combatA.Components[10].Type = "Transitional";
	
	self.Tunes.combatA.Components[11] = {};
	self.Tunes.combatA.Components[11].Container = CreateSoundContainer("Combat A 11 60", "Mordhau.rte");
	self.Tunes.combatA.Components[11].preLength = 2025;
	self.Tunes.combatA.Components[11].totalPost = 19767;
	self.Tunes.combatA.Components[11].canLinkTo = {12};
	
	self.Tunes.combatA.Components[12] = {};
	self.Tunes.combatA.Components[12].Container = CreateSoundContainer("Combat A 12 70", "Mordhau.rte");
	self.Tunes.combatA.Components[12].preLength = 2025;
	self.Tunes.combatA.Components[12].totalPost = 19301;
	self.Tunes.combatA.Components[12].canLinkTo = {11};
	
	self.Tunes.combatA.Components[13] = {};
	self.Tunes.combatA.Components[13].Container = CreateSoundContainer("Combat A 13 80", "Mordhau.rte");
	self.Tunes.combatA.Components[13].preLength = 2025;
	self.Tunes.combatA.Components[13].totalPost = 19136;
	self.Tunes.combatA.Components[13].Type = "Transitional";
	
	self.Tunes.combatA.Components[14] = {};
	self.Tunes.combatA.Components[14].Container = CreateSoundContainer("Combat A 14 90", "Mordhau.rte");
	self.Tunes.combatA.Components[14].preLength = 2025;
	self.Tunes.combatA.Components[14].totalPost = 10521;
	self.Tunes.combatA.Components[14].canLinkTo = {15};

	self.Tunes.combatA.Components[15] = {};
	self.Tunes.combatA.Components[15].Container = CreateSoundContainer("Combat A 15 70", "Mordhau.rte");
	self.Tunes.combatA.Components[15].preLength = 2025;
	self.Tunes.combatA.Components[15].totalPost = 10586;
	self.Tunes.combatA.Components[15].canLinkTo = {16};	
	
	self.Tunes.combatA.Components[16] = {};
	self.Tunes.combatA.Components[16].Container = CreateSoundContainer("Combat A 16 100", "Mordhau.rte");
	self.Tunes.combatA.Components[16].preLength = 2025;
	self.Tunes.combatA.Components[16].totalPost = 8474;
	self.Tunes.combatA.Components[16].canLinkTo = {7};	
	
	self.Tunes.combatA.intensityTables = {};
	self.Tunes.combatA.intensityTables[1] = {};
	self.Tunes.combatA.intensityTables[1].Loops = {1};
	self.Tunes.combatA.intensityTables[1].Transitional = 1;
	
	self.Tunes.combatA.intensityTables[2] = {};
	self.Tunes.combatA.intensityTables[2].Loops = {2, 3, 4, 5};
	self.Tunes.combatA.intensityTables[2].Transitional = 6;
	
	self.Tunes.combatA.intensityTables[3] = {};
	self.Tunes.combatA.intensityTables[3].Loops = {7, 8, 9};
	self.Tunes.combatA.intensityTables[3].Transitional = 10;
	
	self.Tunes.combatA.intensityTables[4] = {};
	self.Tunes.combatA.intensityTables[4].Loops = {11, 12};
	self.Tunes.combatA.intensityTables[4].Transitional = 13;
	
	self.Tunes.combatA.intensityTables[5] = {};
	self.Tunes.combatA.intensityTables[5].Loops = {14, 15, 16};
	self.Tunes.combatA.intensityTables[5].Transitional = {7, 3};
	
	self.Tunes.paganCombat = {};
	self.Tunes.paganCombat.Components = {};
	self.Tunes.paganCombat.Components[1] = {};
	self.Tunes.paganCombat.Components[1].Container = CreateSoundContainer("Pagan Combat 01 10", "Mordhau.rte");
	self.Tunes.paganCombat.Components[1].preLength = 2086;
	self.Tunes.paganCombat.Components[1].totalPost = 8979;
	self.Tunes.paganCombat.Components[1].Type = "Intro";
	
	self.Tunes.paganCombat.Components[2] = {};
	self.Tunes.paganCombat.Components[2].Container = CreateSoundContainer("Pagan Combat 02 15", "Mordhau.rte");
	self.Tunes.paganCombat.Components[2].preLength = 2086;
	self.Tunes.paganCombat.Components[2].totalPost = 11424;
	self.Tunes.paganCombat.Components[2].Type = "Intro";
	
	self.Tunes.paganCombat.Components[3] = {};
	self.Tunes.paganCombat.Components[3].Container = CreateSoundContainer("Pagan Combat 03 60", "Mordhau.rte");
	self.Tunes.paganCombat.Components[3].preLength = 2122;
	self.Tunes.paganCombat.Components[3].totalPost = 9559;
	self.Tunes.paganCombat.Components[3].Type = "Intro";
	
	self.Tunes.paganCombat.Components[4] = {};
	self.Tunes.paganCombat.Components[4].Container = CreateSoundContainer("Pagan Combat 04 50", "Mordhau.rte");
	self.Tunes.paganCombat.Components[4].preLength = 2068;
	self.Tunes.paganCombat.Components[4].totalPost = 9582;
	self.Tunes.paganCombat.Components[4].canLinkTo = {5, 7, 8};
	
	self.Tunes.paganCombat.Components[5] = {};
	self.Tunes.paganCombat.Components[5].Container = CreateSoundContainer("Pagan Combat 05 60", "Mordhau.rte");
	self.Tunes.paganCombat.Components[5].preLength = 2079;
	self.Tunes.paganCombat.Components[5].totalPost = 9516;
	self.Tunes.paganCombat.Components[5].canLinkTo = {6};
	
	self.Tunes.paganCombat.Components[6] = {};
	self.Tunes.paganCombat.Components[6].Container = CreateSoundContainer("Pagan Combat 06 60", "Mordhau.rte");
	self.Tunes.paganCombat.Components[6].preLength = 2064;
	self.Tunes.paganCombat.Components[6].totalPost = 9586;
	self.Tunes.paganCombat.Components[6].canLinkTo = {4, 7, 8};
	
	self.Tunes.paganCombat.Components[7] = {};
	self.Tunes.paganCombat.Components[7].Container = CreateSoundContainer("Pagan Combat 07 50", "Mordhau.rte");
	self.Tunes.paganCombat.Components[7].preLength = 2067;
	self.Tunes.paganCombat.Components[7].totalPost = 9612;
	self.Tunes.paganCombat.Components[7].canLinkTo = {4, 5, 8};
	
	self.Tunes.paganCombat.Components[8] = {};
	self.Tunes.paganCombat.Components[8].Container = CreateSoundContainer("Pagan Combat 08 50", "Mordhau.rte");
	self.Tunes.paganCombat.Components[8].preLength = 2075;
	self.Tunes.paganCombat.Components[8].totalPost = 9624;
	self.Tunes.paganCombat.Components[8].canLinkTo = {9};
	
	self.Tunes.paganCombat.Components[9] = {};
	self.Tunes.paganCombat.Components[9].Container = CreateSoundContainer("Pagan Combat 09 60", "Mordhau.rte");
	self.Tunes.paganCombat.Components[9].preLength = 2088;
	self.Tunes.paganCombat.Components[9].totalPost = 9582;
	self.Tunes.paganCombat.Components[9].canLinkTo = {4, 5, 7};
	
	self.Tunes.paganCombat.Components[10] = {};
	self.Tunes.paganCombat.Components[10].Container = CreateSoundContainer("Pagan Combat 10 65", "Mordhau.rte");
	self.Tunes.paganCombat.Components[10].preLength = 2079;
	self.Tunes.paganCombat.Components[10].totalPost = 9622;
	self.Tunes.paganCombat.Components[10].Type = "Transitional";
	
	self.Tunes.paganCombat.Components[11] = {};
	self.Tunes.paganCombat.Components[11].Container = CreateSoundContainer("Pagan Combat 11 70", "Mordhau.rte");
	self.Tunes.paganCombat.Components[11].preLength = 2065;
	self.Tunes.paganCombat.Components[11].totalPost = 17072;
	self.Tunes.paganCombat.Components[11].canLinkTo = {12};
	
	self.Tunes.paganCombat.Components[12] = {};
	self.Tunes.paganCombat.Components[12].Container = CreateSoundContainer("Pagan Combat 12 90", "Mordhau.rte");
	self.Tunes.paganCombat.Components[12].preLength = 2092;
	self.Tunes.paganCombat.Components[12].totalPost = 18426;
	self.Tunes.paganCombat.Components[12].canLinkTo = {11};
	
	self.Tunes.paganCombat.Components[13] = {};
	self.Tunes.paganCombat.Components[13].Container = CreateSoundContainer("Pagan Combat 13 60", "Mordhau.rte");
	self.Tunes.paganCombat.Components[13].preLength = 2062;
	self.Tunes.paganCombat.Components[13].totalPost = 17362;
	self.Tunes.paganCombat.Components[13].Type = "Transitional";
	
	self.Tunes.paganCombat.Components[14] = {};
	self.Tunes.paganCombat.Components[14].Container = CreateSoundContainer("Pagan Combat 14 20", "Mordhau.rte");
	self.Tunes.paganCombat.Components[14].preLength = 2169;
	self.Tunes.paganCombat.Components[14].totalPost = 18745;
	self.Tunes.paganCombat.Components[14].canLinkTo = {15};

	self.Tunes.paganCombat.Components[15] = {};
	self.Tunes.paganCombat.Components[15].Container = CreateSoundContainer("Pagan Combat 15 30", "Mordhau.rte");
	self.Tunes.paganCombat.Components[15].preLength = 2035;
	self.Tunes.paganCombat.Components[15].totalPost = 17049;
	self.Tunes.paganCombat.Components[15].canLinkTo = {16};	
	
	self.Tunes.paganCombat.Components[16] = {};
	self.Tunes.paganCombat.Components[16].Container = CreateSoundContainer("Pagan Combat 16 50", "Mordhau.rte");
	self.Tunes.paganCombat.Components[16].preLength = 2042;
	self.Tunes.paganCombat.Components[16].totalPost = 17089;
	self.Tunes.paganCombat.Components[16].canLinkTo = {14, 17};
	
	self.Tunes.paganCombat.Components[17] = {};
	self.Tunes.paganCombat.Components[17].Container = CreateSoundContainer("Pagan Combat 17 60", "Mordhau.rte");
	self.Tunes.paganCombat.Components[17].preLength = 2055;
	self.Tunes.paganCombat.Components[17].totalPost = 17122;
	self.Tunes.paganCombat.Components[17].canLinkTo = {14, 16};
	
	self.Tunes.paganCombat.Components[18] = {};
	self.Tunes.paganCombat.Components[18].Container = CreateSoundContainer("Pagan Combat 18 50", "Mordhau.rte");
	self.Tunes.paganCombat.Components[18].preLength = 2062;
	self.Tunes.paganCombat.Components[18].totalPost = 5864;
	self.Tunes.paganCombat.Components[18].Type = "Transitional";
	
	self.Tunes.paganCombat.Components[19] = {};
	self.Tunes.paganCombat.Components[19].Container = CreateSoundContainer("Pagan Combat 19 70", "Mordhau.rte");
	self.Tunes.paganCombat.Components[19].preLength = 2139;
	self.Tunes.paganCombat.Components[19].totalPost = 17239;	
	self.Tunes.paganCombat.Components[19].canLinkTo = {20, 21};
	
	self.Tunes.paganCombat.Components[20] = {};
	self.Tunes.paganCombat.Components[20].Container = CreateSoundContainer("Pagan Combat 20 80", "Mordhau.rte");
	self.Tunes.paganCombat.Components[20].preLength = 2152;
	self.Tunes.paganCombat.Components[20].totalPost = 17104;
	self.Tunes.paganCombat.Components[20].canLinkTo = {19};
	
	self.Tunes.paganCombat.Components[21] = {};
	self.Tunes.paganCombat.Components[21].Container = CreateSoundContainer("Pagan Combat 21 70", "Mordhau.rte");
	self.Tunes.paganCombat.Components[21].preLength = 2097;
	self.Tunes.paganCombat.Components[21].totalPost = 17528;	
	self.Tunes.paganCombat.Components[21].canLinkTo = {19, 22};
	
	self.Tunes.paganCombat.Components[22] = {};
	self.Tunes.paganCombat.Components[22].Container = CreateSoundContainer("Pagan Combat 22 90", "Mordhau.rte");
	self.Tunes.paganCombat.Components[22].preLength = 2095;
	self.Tunes.paganCombat.Components[22].totalPost = 17091;
	self.Tunes.paganCombat.Components[22].canLinkTo = {19, 21};	
	
	self.Tunes.paganCombat.Components[23] = {};
	self.Tunes.paganCombat.Components[23].Container = CreateSoundContainer("Pagan Combat 23 100", "Mordhau.rte");
	self.Tunes.paganCombat.Components[23].preLength = 2110;
	self.Tunes.paganCombat.Components[23].totalPost = 17129;	
	self.Tunes.paganCombat.Components[23].Type = "Transitional";
	
	self.Tunes.paganCombat.intensityTables = {};
	self.Tunes.paganCombat.intensityTables[1] = {};
	self.Tunes.paganCombat.intensityTables[1].Loops = {1, 2, 3};
	self.Tunes.paganCombat.intensityTables[1].Transitional = 3;
	
	self.Tunes.paganCombat.intensityTables[2] = {};
	self.Tunes.paganCombat.intensityTables[2].Loops = {4, 5, 6, 7, 8, 9};
	self.Tunes.paganCombat.intensityTables[2].Transitional = 10;
	
	self.Tunes.paganCombat.intensityTables[4] = {};
	self.Tunes.paganCombat.intensityTables[4].Loops = {11, 12};
	self.Tunes.paganCombat.intensityTables[4].Transitional = 13;
	
	self.Tunes.paganCombat.intensityTables[3] = {};
	self.Tunes.paganCombat.intensityTables[3].Loops = {14, 15, 16, 17};
	self.Tunes.paganCombat.intensityTables[3].Transitional = 18;
	
	self.Tunes.paganCombat.intensityTables[5] = {};
	self.Tunes.paganCombat.intensityTables[5].Loops = {19, 20, 21, 22};
	self.Tunes.paganCombat.intensityTables[5].Transitional = 23;
	
	self.currentIndex = 1;
	local tuneTable = {};
	for k, v in pairs(self.Tunes) do
		table.insert(tuneTable, v);
	end
	self.currentTuneIndex = math.random(1, #tuneTable);
	self.currentTune = tuneTable[self.currentTuneIndex];
	self.currentTune.Components[self.currentIndex].Container:Play();
	
	
end

function YeOldeSongsScript:UpdateScript()

	if UInputMan:KeyPressed(39) then
		self.desiredIntensity = 2;
	elseif UInputMan:KeyPressed(40) then
		self.desiredIntensity = 3;
	elseif UInputMan:KeyPressed(41) then
		self.desiredIntensity = 4;
	elseif UInputMan:KeyPressed(42) then
		self.desiredIntensity = 5;
	end

	AudioMan:ClearMusicQueue();
	AudioMan:StopMusic();
	
	if self.MUSIC_STATE == "Intro" then
		if self.componentTimer:IsPastSimMS(self.currentTune.Components[self.currentIndex].totalPost - self.currentTune.Components[self.currentIndex + 1].preLength) then
			
			self.currentIndex = self.currentIndex + 1;
			
			if self.currentTune.Components[self.currentIndex].Type == nil then
				self.MUSIC_STATE = "Normal";
				self.desiredIntensity = 2;
				self.Intensity = 2;
				self.indexToPlay = self.currentIndex;
			end
			
			self.currentTune.Components[self.currentIndex].Container:Play();
			
			self.componentTimer:Reset();
		end
	elseif self.MUSIC_STATE == "Rest" then
		if self.restTimer:IsPastSimMS(self.restTime) then
			self.endTune = false;
			self.MUSIC_STATE = "Intro";
			self.currentIndex = 1;
			local tuneTable = {};
			for k, v in pairs(self.Tunes) do
				if v ~= self.currentTune then
					table.insert(tuneTable, v);
				end
			end
			self.currentTuneIndex = math.random(1, #tuneTable);
			self.currentTune = tuneTable[self.currentTuneIndex];
			self.currentTune.Components[self.currentIndex].Container:Play();
			self.componentTimer:Reset();
		end
	else

		if self.componentTimer:IsPastSimMS(self.currentTune.Components[self.currentIndex].totalPost/3) then
			-- a third thru current loop, decide what to play next
			if self.nextDecided ~= true then
				self.nextDecided = true;
				
				local index
				
				if self.MUSIC_STATE == "Transitioning" then
				
					self.loopNumber = 0;
					self.totalLoopNumber = 0;
					
					if self.endTune == true then
					
						self.MUSIC_STATE = "Rest";
						self.restTimer:Reset();
						self.restTime = math.random(20000, 40000);
						
						self.indexToPlay = 1;
						
						return;
					
					else
					
						self.MUSIC_STATE = "Normal";
				
						local loopTable = self.currentTune.intensityTables[self.Intensity].Loops;
						index = loopTable[1];

					end
				
				else
				
					if type(self.currentTune.intensityTables[self.Intensity].Transitional) == "table" then
						
						local linkableTable = self.currentTune.Components[self.currentIndex].canLinkTo;
						local loopTable =  self.currentTune.intensityTables[self.Intensity].Loops;
						index = linkableTable[math.random(1, #linkableTable)];
						
						-- if it's a table then we have a loop and intensity to change to after the intensity
						-- runs its course. sort of an automatic loopback
						
						if self.currentIndex == loopTable[#loopTable] then
						
							-- take the first value as the loop to change to
							-- and use the second value as the intensity
							local transitionalTable = self.currentTune.intensityTables[self.Intensity].Transitional;
							index = transitionalTable[1];
							self.Intensity = transitionalTable[2];
							self.desiredIntensity = transitionalTable[2];
						end
					else

					
						local loopTable = self.currentTune.Components[self.currentIndex].canLinkTo or self.currentTune.intensityTables[self.Intensity].Loops;
						index = loopTable[math.random(1, #loopTable)];
					
						if (self.desiredIntensity ~= self.Intensity and self.loopNumber > 2) or (self.totalLoopNumber >= self.tuneMaxLoops) then
							
							local loopTable = self.currentTune.intensityTables[self.Intensity].Loops;
							
							if self.totalLoopNumber >= self.tuneMaxLoops then
								self.endTune = true;
							end
							
							-- cue up the transitional
							index = self.currentTune.intensityTables[self.Intensity].Transitional
							self.MUSIC_STATE = "Transitioning";
												
							self.Intensity = self.desiredIntensity

						end
					end
				end
					
				self.indexToPlay = index;
				
			end
		
			if self.componentTimer:IsPastSimMS(self.currentTune.Components[self.currentIndex].totalPost - self.currentTune.Components[self.indexToPlay].preLength) then
			
				self.nextDecided = false;
			
				self.loopNumber = self.loopNumber + 1;
				
				self.totalLoopNumber = self.totalLoopNumber + 1;
				
				self.currentIndex = self.indexToPlay;
				
				self.currentTune.Components[self.currentIndex].Container:Play();
				
				self.componentTimer:Reset();
				
			end
		end
	end
		
	
	-- PROTOTYPE PLACEHOLDER ONLY ONE SONG TODO MAKE MODULAR

end

function YeOldeSongsScript:EndScript()
end

function YeOldeSongsScript:PauseScript()
end

function YeOldeSongsScript:CraftEnteredOrbit()
end
