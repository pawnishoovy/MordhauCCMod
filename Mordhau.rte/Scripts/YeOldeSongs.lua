function YeOldeSongsScript:StartScript()
	self.activity = ActivityMan:GetActivity();
	
	AudioMan:ClearMusicQueue();
	AudioMan:StopMusic();
	
	-- our dynamic music is just normal sound, so get the current ratio between sound and music volume
	-- to set the container volumes
	
	self.dynamicVolume = AudioMan.MusicVolume / AudioMan.SoundsVolume;
	
	self.MUSIC_STATE = "Intro";
	
	self.componentTimer = Timer();
	self.restTimer = Timer();
	
	self.loopNumber = 0;
	self.totalLoopNumber = 0;
	self.tuneMaxLoops = 48;
	
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
	
	self.victoryPath = "Mordhau.rte/Music/Victory.ogg";
	self.defeatPath = "Mordhau.rte/Music/Defeat.ogg";
	
	self.happyAmbients = {"Mordhau.rte/Music/Ambient1.ogg", "Mordhau.rte/Music/Ambient2.ogg",
	"Mordhau.rte/Music/Ambient3.ogg", "Mordhau.rte/Music/Ambient4.ogg", "Mordhau.rte/Music/Ambient5.ogg"
	, "Mordhau.rte/Music/Ambient6.ogg", "Mordhau.rte/Music/Ambient7.ogg"};
	
	self.evilAmbients = {"Mordhau.rte/Music/EvilAmbient1.ogg", "Mordhau.rte/Music/EvilAmbient2.ogg",
	"Mordhau.rte/Music/EvilAmbient3.ogg"};
	
	
	self.Tunes.smallBattleA = {};
	self.Tunes.smallBattleA.Path = "Mordhau.rte/Music/SmallBattleA.ogg";
	self.Tunes.smallBattleA.Type = "Basic";
	
	self.Tunes.smallBattleB = {};
	self.Tunes.smallBattleB.Path = "Mordhau.rte/Music/SmallBattleB.ogg";
	self.Tunes.smallBattleB.Type = "Basic";
	
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
	self.Tunes.combatA.Components[16].totalPost = 8473;
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
	
	self.Tunes.combatB = {};
	self.Tunes.combatB.Components = {};
	self.Tunes.combatB.Components[1] = {};
	self.Tunes.combatB.Components[1].Container = CreateSoundContainer("Combat B 01 10", "Mordhau.rte");
	self.Tunes.combatB.Components[1].preLength = 1000;
	self.Tunes.combatB.Components[1].totalPost = 9422;
	self.Tunes.combatB.Components[1].Type = "Intro";
	
	self.Tunes.combatB.Components[2] = {};
	self.Tunes.combatB.Components[2].Container = CreateSoundContainer("Combat B 02 10", "Mordhau.rte");
	self.Tunes.combatB.Components[2].preLength = 1000;
	self.Tunes.combatB.Components[2].totalPost = 13673;
	self.Tunes.combatB.Components[2].Type = "Intro";
	
	self.Tunes.combatB.Components[3] = {};
	self.Tunes.combatB.Components[3].Container = CreateSoundContainer("Combat B 03 10", "Mordhau.rte");
	self.Tunes.combatB.Components[3].preLength = 1000;
	self.Tunes.combatB.Components[3].totalPost = 5300;
	self.Tunes.combatB.Components[3].Type = "Intro";
	
	self.Tunes.combatB.Components[4] = {};
	self.Tunes.combatB.Components[4].Container = CreateSoundContainer("Combat B 04 20", "Mordhau.rte");
	self.Tunes.combatB.Components[4].preLength = 1000;
	self.Tunes.combatB.Components[4].totalPost = 9462;
	self.Tunes.combatB.Components[4].canLinkTo = {5};
	
	self.Tunes.combatB.Components[5] = {};
	self.Tunes.combatB.Components[5].Container = CreateSoundContainer("Combat B 05 20", "Mordhau.rte");
	self.Tunes.combatB.Components[5].preLength = 1000;
	self.Tunes.combatB.Components[5].totalPost = 9462;
	self.Tunes.combatB.Components[5].canLinkTo = {6};
	
	self.Tunes.combatB.Components[6] = {};
	self.Tunes.combatB.Components[6].Container = CreateSoundContainer("Combat B 06 20", "Mordhau.rte");
	self.Tunes.combatB.Components[6].preLength = 1000;
	self.Tunes.combatB.Components[6].totalPost = 9462;
	self.Tunes.combatB.Components[6].canLinkTo = {7};
	
	self.Tunes.combatB.Components[7] = {};
	self.Tunes.combatB.Components[7].Container = CreateSoundContainer("Combat B 07 20", "Mordhau.rte");
	self.Tunes.combatB.Components[7].preLength = 1000;
	self.Tunes.combatB.Components[7].totalPost = 9462;
	self.Tunes.combatB.Components[7].canLinkTo = {4, 8};
	
	self.Tunes.combatB.Components[8] = {};
	self.Tunes.combatB.Components[8].Container = CreateSoundContainer("Combat B 08 30", "Mordhau.rte");
	self.Tunes.combatB.Components[8].preLength = 1000;
	self.Tunes.combatB.Components[8].totalPost = 9462;
	self.Tunes.combatB.Components[8].canLinkTo = {9};
	
	self.Tunes.combatB.Components[9] = {};
	self.Tunes.combatB.Components[9].Container = CreateSoundContainer("Combat B 09 30", "Mordhau.rte");
	self.Tunes.combatB.Components[9].preLength = 1000;
	self.Tunes.combatB.Components[9].totalPost = 9462;
	self.Tunes.combatB.Components[9].canLinkTo = {10};
	
	self.Tunes.combatB.Components[10] = {};
	self.Tunes.combatB.Components[10].Container = CreateSoundContainer("Combat B 10 20", "Mordhau.rte");
	self.Tunes.combatB.Components[10].preLength = 1000;
	self.Tunes.combatB.Components[10].totalPost = 9462;
	self.Tunes.combatB.Components[10].canLinkTo = {11};
	
	self.Tunes.combatB.Components[11] = {};
	self.Tunes.combatB.Components[11].Container = CreateSoundContainer("Combat B 11 20", "Mordhau.rte");
	self.Tunes.combatB.Components[11].preLength = 1000;
	self.Tunes.combatB.Components[11].totalPost = 9462;
	self.Tunes.combatB.Components[11].canLinkTo = {4, 6, 10, 12};
	
	self.Tunes.combatB.Components[12] = {};
	self.Tunes.combatB.Components[12].Container = CreateSoundContainer("Combat B 12 40", "Mordhau.rte");
	self.Tunes.combatB.Components[12].preLength = 1000;
	self.Tunes.combatB.Components[12].totalPost = 9462;
	self.Tunes.combatB.Components[12].canLinkTo = {13};
	
	self.Tunes.combatB.Components[13] = {};
	self.Tunes.combatB.Components[13].Container = CreateSoundContainer("Combat B 13 40", "Mordhau.rte");
	self.Tunes.combatB.Components[13].preLength = 1000;
	self.Tunes.combatB.Components[13].totalPost = 9462;
	self.Tunes.combatB.Components[13].canLinkTo = {14};
	
	self.Tunes.combatB.Components[14] = {};
	self.Tunes.combatB.Components[14].Container = CreateSoundContainer("Combat B 14 10", "Mordhau.rte");
	self.Tunes.combatB.Components[14].preLength = 1000;
	self.Tunes.combatB.Components[14].totalPost = 9462;
	self.Tunes.combatB.Components[14].canLinkTo = {4};

	self.Tunes.combatB.Components[15] = {};
	self.Tunes.combatB.Components[15].Container = CreateSoundContainer("Combat B 15 10", "Mordhau.rte");
	self.Tunes.combatB.Components[15].preLength = 1000;
	self.Tunes.combatB.Components[15].totalPost = 9462;
	self.Tunes.combatB.Components[15].canLinkTo = {16};	
	self.Tunes.combatB.Components[15].Type = "Transitional";
	
	self.Tunes.combatB.Components[16] = {};
	self.Tunes.combatB.Components[16].Container = CreateSoundContainer("Combat B 16 50", "Mordhau.rte");
	self.Tunes.combatB.Components[16].preLength = 1000;
	self.Tunes.combatB.Components[16].totalPost = 9462;
	self.Tunes.combatB.Components[16].canLinkTo = {17};
	
	self.Tunes.combatB.Components[17] = {};
	self.Tunes.combatB.Components[17].Container = CreateSoundContainer("Combat B 17 50", "Mordhau.rte");
	self.Tunes.combatB.Components[17].preLength = 1000;
	self.Tunes.combatB.Components[17].totalPost = 9462;
	self.Tunes.combatB.Components[17].canLinkTo = {16, 18};
	
	self.Tunes.combatB.Components[18] = {};
	self.Tunes.combatB.Components[18].Container = CreateSoundContainer("Combat B 18 50", "Mordhau.rte");
	self.Tunes.combatB.Components[18].preLength = 1000;
	self.Tunes.combatB.Components[18].totalPost = 9462;
	self.Tunes.combatB.Components[18].canLinkTo = {19};
	
	self.Tunes.combatB.Components[19] = {};
	self.Tunes.combatB.Components[19].Container = CreateSoundContainer("Combat B 19 50", "Mordhau.rte");
	self.Tunes.combatB.Components[19].preLength = 1000;
	self.Tunes.combatB.Components[19].totalPost = 9462;	
	self.Tunes.combatB.Components[19].canLinkTo = {16, 20};
	
	self.Tunes.combatB.Components[20] = {};
	self.Tunes.combatB.Components[20].Container = CreateSoundContainer("Combat B 20 40", "Mordhau.rte");
	self.Tunes.combatB.Components[20].preLength = 1000;
	self.Tunes.combatB.Components[20].totalPost = 9462;
	self.Tunes.combatB.Components[20].canLinkTo = {21};
	
	self.Tunes.combatB.Components[21] = {};
	self.Tunes.combatB.Components[21].Container = CreateSoundContainer("Combat B 21 50", "Mordhau.rte");
	self.Tunes.combatB.Components[21].preLength = 1000;
	self.Tunes.combatB.Components[21].totalPost = 9462;	
	self.Tunes.combatB.Components[21].canLinkTo = {16, 18};
	
	self.Tunes.combatB.Components[22] = {};
	self.Tunes.combatB.Components[22].Container = CreateSoundContainer("Combat B 22 50", "Mordhau.rte");
	self.Tunes.combatB.Components[22].preLength = 1000;
	self.Tunes.combatB.Components[22].totalPost = 9462;
	self.Tunes.combatB.Components[22].canLinkTo = {23};	
	self.Tunes.combatB.Components[22].Type = "Transitional";
	
	self.Tunes.combatB.Components[23] = {};
	self.Tunes.combatB.Components[23].Container = CreateSoundContainer("Combat B 23 50", "Mordhau.rte");
	self.Tunes.combatB.Components[23].preLength = 1000;
	self.Tunes.combatB.Components[23].totalPost = 9462	
	self.Tunes.combatB.Components[23].canLinkTo = {22, 24};	
	
	self.Tunes.combatB.Components[24] = {};
	self.Tunes.combatB.Components[24].Container = CreateSoundContainer("Combat B 24 40", "Mordhau.rte");
	self.Tunes.combatB.Components[24].preLength = 1000;
	self.Tunes.combatB.Components[24].totalPost = 9462;
	self.Tunes.combatB.Components[24].canLinkTo = {25};	
	
	self.Tunes.combatB.Components[25] = {};
	self.Tunes.combatB.Components[25].Container = CreateSoundContainer("Combat B 25 40", "Mordhau.rte");
	self.Tunes.combatB.Components[25].preLength = 1000;
	self.Tunes.combatB.Components[25].totalPost = 9462;
	self.Tunes.combatB.Components[25].canLinkTo = {22};	
	
	self.Tunes.combatB.Components[26] = {};
	self.Tunes.combatB.Components[26].Container = CreateSoundContainer("Combat B 26 80", "Mordhau.rte");
	self.Tunes.combatB.Components[26].preLength = 1000;
	self.Tunes.combatB.Components[26].totalPost = 22079;
	self.Tunes.combatB.Components[26].Type = "Transitional";
	
	self.Tunes.combatB.Components[27] = {};
	self.Tunes.combatB.Components[27].Container = CreateSoundContainer("Combat B 27 80", "Mordhau.rte");
	self.Tunes.combatB.Components[27].preLength = 1000;
	self.Tunes.combatB.Components[27].totalPost = 9366;
	self.Tunes.combatB.Components[27].canLinkTo = {28};
	
	self.Tunes.combatB.Components[28] = {};
	self.Tunes.combatB.Components[28].Container = CreateSoundContainer("Combat B 28 80", "Mordhau.rte");
	self.Tunes.combatB.Components[28].preLength = 1000;
	self.Tunes.combatB.Components[28].totalPost = 9366;
	self.Tunes.combatB.Components[28].canLinkTo = {27, 29};
	
	self.Tunes.combatB.Components[29] = {};
	self.Tunes.combatB.Components[29].Container = CreateSoundContainer("Combat B 29 100", "Mordhau.rte");
	self.Tunes.combatB.Components[29].preLength = 1000;
	self.Tunes.combatB.Components[29].totalPost = 9366;
	self.Tunes.combatB.Components[29].canLinkTo = {30};
	
	self.Tunes.combatB.Components[30] = {};
	self.Tunes.combatB.Components[30].Container = CreateSoundContainer("Combat B 30 90", "Mordhau.rte");
	self.Tunes.combatB.Components[30].preLength = 1000;
	self.Tunes.combatB.Components[30].totalPost = 9366;
	self.Tunes.combatB.Components[30].canLinkTo = {31};
	
	self.Tunes.combatB.Components[31] = {};
	self.Tunes.combatB.Components[31].Container = CreateSoundContainer("Combat B 31 100", "Mordhau.rte");
	self.Tunes.combatB.Components[31].preLength = 1000;
	self.Tunes.combatB.Components[31].totalPost = 9366;
	self.Tunes.combatB.Components[31].canLinkTo = {32};
	
	self.Tunes.combatB.Components[32] = {};
	self.Tunes.combatB.Components[32].Container = CreateSoundContainer("Combat B 32 100", "Mordhau.rte");
	self.Tunes.combatB.Components[32].preLength = 1000;
	self.Tunes.combatB.Components[32].totalPost = 9366;
	self.Tunes.combatB.Components[32].canLinkTo = {27, 33};
	
	self.Tunes.combatB.Components[33] = {};
	self.Tunes.combatB.Components[33].Container = CreateSoundContainer("Combat B 33 100", "Mordhau.rte");
	self.Tunes.combatB.Components[33].preLength = 1000;
	self.Tunes.combatB.Components[33].totalPost = 9366;
	self.Tunes.combatB.Components[33].canLinkTo = {34};
	
	self.Tunes.combatB.Components[34] = {};
	self.Tunes.combatB.Components[34].Container = CreateSoundContainer("Combat B 34 100", "Mordhau.rte");
	self.Tunes.combatB.Components[34].preLength = 1000;
	self.Tunes.combatB.Components[34].totalPost = 9366;
	self.Tunes.combatB.Components[34].canLinkTo = {35};
	
	self.Tunes.combatB.Components[35] = {};
	self.Tunes.combatB.Components[35].Container = CreateSoundContainer("Combat B 35 100", "Mordhau.rte");
	self.Tunes.combatB.Components[35].preLength = 1000;
	self.Tunes.combatB.Components[35].totalPost = 9366;
	self.Tunes.combatB.Components[35].canLinkTo = {36};
	
	self.Tunes.combatB.Components[36] = {};
	self.Tunes.combatB.Components[36].Container = CreateSoundContainer("Combat B 36 100", "Mordhau.rte");
	self.Tunes.combatB.Components[36].preLength = 1000;
	self.Tunes.combatB.Components[36].totalPost = 9366;
	self.Tunes.combatB.Components[36].canLinkTo = {22, 27, 33};
	
	self.Tunes.combatB.Components[37] = {};
	self.Tunes.combatB.Components[37].Container = CreateSoundContainer("Combat B 37 100", "Mordhau.rte");
	self.Tunes.combatB.Components[37].preLength = 1000;
	self.Tunes.combatB.Components[37].totalPost = 9366;
	self.Tunes.combatB.Components[37].Type = "Transitional";
	
	self.Tunes.combatB.intensityTables = {};
	self.Tunes.combatB.intensityTables[1] = {};
	self.Tunes.combatB.intensityTables[1].Loops = {1, 2, 3};
	self.Tunes.combatB.intensityTables[1].Transitional = 3;
	
	self.Tunes.combatB.intensityTables[2] = {};
	self.Tunes.combatB.intensityTables[2].Loops = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14};
	self.Tunes.combatB.intensityTables[2].Transitional = 15;
	
	self.Tunes.combatB.intensityTables[3] = {};
	self.Tunes.combatB.intensityTables[3].Loops = {16, 17, 18, 18, 19, 20, 21};
	self.Tunes.combatB.intensityTables[3].Transitional = 22;
	
	self.Tunes.combatB.intensityTables[4] = {};
	self.Tunes.combatB.intensityTables[4].Loops = {22, 23, 24, 25};
	self.Tunes.combatB.intensityTables[4].Transitional = 26;
	
	self.Tunes.combatB.intensityTables[5] = {};
	self.Tunes.combatB.intensityTables[5].Loops = {27, 28, 29, 30, 31, 32, 33, 34, 35, 36};
	self.Tunes.combatB.intensityTables[5].Transitional = 37;
	
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
	
	self.Tunes.paganCombatA = {};
	self.Tunes.paganCombatA.Components = {};
	self.Tunes.paganCombatA.Components[1] = {};
	self.Tunes.paganCombatA.Components[1].Container = CreateSoundContainer("Pagan Combat A 01 10", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[1].preLength = 850;
	self.Tunes.paganCombatA.Components[1].totalPost = 8154;
	self.Tunes.paganCombatA.Components[1].Type = "Intro";
	
	self.Tunes.paganCombatA.Components[2] = {};
	self.Tunes.paganCombatA.Components[2].Container = CreateSoundContainer("Pagan Combat A 02 10", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[2].preLength = 850;
	self.Tunes.paganCombatA.Components[2].totalPost = 8154;
	self.Tunes.paganCombatA.Components[2].Type = "Intro";
	
	self.Tunes.paganCombatA.Components[3] = {};
	self.Tunes.paganCombatA.Components[3].Container = CreateSoundContainer("Pagan Combat A 03 05", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[3].preLength = 850;
	self.Tunes.paganCombatA.Components[3].totalPost = 8154;
	self.Tunes.paganCombatA.Components[3].Type = "Intro";
	
	self.Tunes.paganCombatA.Components[4] = {};
	self.Tunes.paganCombatA.Components[4].Container = CreateSoundContainer("Pagan Combat A 04 15", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[4].preLength = 850;
	self.Tunes.paganCombatA.Components[4].totalPost = 8154;
	self.Tunes.paganCombatA.Components[4].Type = "Intro";
	
	self.Tunes.paganCombatA.Components[5] = {};
	self.Tunes.paganCombatA.Components[5].Container = CreateSoundContainer("Pagan Combat A 05 30", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[5].preLength = 850;
	self.Tunes.paganCombatA.Components[5].totalPost = 15597;
	self.Tunes.paganCombatA.Components[5].Type = "Intro";
	
	self.Tunes.paganCombatA.Components[6] = {};
	self.Tunes.paganCombatA.Components[6].Container = CreateSoundContainer("Pagan Combat A 06 30", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[6].preLength = 850;
	self.Tunes.paganCombatA.Components[6].totalPost = 8154;
	self.Tunes.paganCombatA.Components[6].canLinkTo = {7};
	
	self.Tunes.paganCombatA.Components[7] = {};
	self.Tunes.paganCombatA.Components[7].Container = CreateSoundContainer("Pagan Combat A 07 40", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[7].preLength = 850;
	self.Tunes.paganCombatA.Components[7].totalPost = 6005;
	self.Tunes.paganCombatA.Components[7].canLinkTo = {8};
	
	self.Tunes.paganCombatA.Components[8] = {};
	self.Tunes.paganCombatA.Components[8].Container = CreateSoundContainer("Pagan Combat A 08 40", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[8].preLength = 850;
	self.Tunes.paganCombatA.Components[8].totalPost = 6005;
	self.Tunes.paganCombatA.Components[8].canLinkTo = {9};
	
	self.Tunes.paganCombatA.Components[9] = {};
	self.Tunes.paganCombatA.Components[9].Container = CreateSoundContainer("Pagan Combat A 09 40", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[9].preLength = 850;
	self.Tunes.paganCombatA.Components[9].totalPost = 6005;
	self.Tunes.paganCombatA.Components[9].canLinkTo = {10};
	
	self.Tunes.paganCombatA.Components[10] = {};
	self.Tunes.paganCombatA.Components[10].Container = CreateSoundContainer("Pagan Combat A 10 40", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[10].preLength = 850;
	self.Tunes.paganCombatA.Components[10].totalPost = 6005;
	self.Tunes.paganCombatA.Components[10].canLinkTo = {11};
	
	self.Tunes.paganCombatA.Components[11] = {};
	self.Tunes.paganCombatA.Components[11].Container = CreateSoundContainer("Pagan Combat A 11 40", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[11].preLength = 850;
	self.Tunes.paganCombatA.Components[11].totalPost = 6005;
	self.Tunes.paganCombatA.Components[11].canLinkTo = {12};
	
	self.Tunes.paganCombatA.Components[12] = {};
	self.Tunes.paganCombatA.Components[12].Container = CreateSoundContainer("Pagan Combat A 12 40", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[12].preLength = 850;
	self.Tunes.paganCombatA.Components[12].totalPost = 6005;
	self.Tunes.paganCombatA.Components[12].canLinkTo = {6};
	
	self.Tunes.paganCombatA.Components[13] = {};
	self.Tunes.paganCombatA.Components[13].Container = CreateSoundContainer("Pagan Combat A 13 50", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[13].preLength = 850;
	self.Tunes.paganCombatA.Components[13].totalPost = 7915;
	self.Tunes.paganCombatA.Components[13].canLinkTo = {14};
	self.Tunes.paganCombatA.Components[13].Type = "Transitional";
	
	self.Tunes.paganCombatA.Components[14] = {};
	self.Tunes.paganCombatA.Components[14].Container = CreateSoundContainer("Pagan Combat A 14 50", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[14].preLength = 850;
	self.Tunes.paganCombatA.Components[14].totalPost = 7915;
	self.Tunes.paganCombatA.Components[14].canLinkTo = {15};

	self.Tunes.paganCombatA.Components[15] = {};
	self.Tunes.paganCombatA.Components[15].Container = CreateSoundContainer("Pagan Combat A 15 60", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[15].preLength = 850;
	self.Tunes.paganCombatA.Components[15].totalPost = 7758;
	self.Tunes.paganCombatA.Components[15].canLinkTo = {16};	
	
	self.Tunes.paganCombatA.Components[16] = {};
	self.Tunes.paganCombatA.Components[16].Container = CreateSoundContainer("Pagan Combat A 16 60", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[16].preLength = 850;
	self.Tunes.paganCombatA.Components[16].totalPost = 7758;
	self.Tunes.paganCombatA.Components[16].canLinkTo = {13, 17};
	
	self.Tunes.paganCombatA.Components[17] = {};
	self.Tunes.paganCombatA.Components[17].Container = CreateSoundContainer("Pagan Combat A 17 35", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[17].preLength = 850;
	self.Tunes.paganCombatA.Components[17].totalPost = 6075;
	self.Tunes.paganCombatA.Components[17].canLinkTo = {18};
	
	self.Tunes.paganCombatA.Components[18] = {};
	self.Tunes.paganCombatA.Components[18].Container = CreateSoundContainer("Pagan Combat A 18 35", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[18].preLength = 850;
	self.Tunes.paganCombatA.Components[18].totalPost = 6075;
	self.Tunes.paganCombatA.Components[18].canLinkTo = {17, 19};
	
	self.Tunes.paganCombatA.Components[19] = {};
	self.Tunes.paganCombatA.Components[19].Container = CreateSoundContainer("Pagan Combat A 19 60", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[19].preLength = 850;
	self.Tunes.paganCombatA.Components[19].totalPost = 11252;	
	self.Tunes.paganCombatA.Components[19].canLinkTo = {20};
	
	self.Tunes.paganCombatA.Components[20] = {};
	self.Tunes.paganCombatA.Components[20].Container = CreateSoundContainer("Pagan Combat A 20 60", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[20].preLength = 850;
	self.Tunes.paganCombatA.Components[20].totalPost = 11252;
	self.Tunes.paganCombatA.Components[20].canLinkTo = {19, 21};
	
	self.Tunes.paganCombatA.Components[21] = {};
	self.Tunes.paganCombatA.Components[21].Container = CreateSoundContainer("Pagan Combat A 21 40", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[21].preLength = 850;
	self.Tunes.paganCombatA.Components[21].totalPost = 7724;	
	self.Tunes.paganCombatA.Components[21].canLinkTo = {16, 22};
	
	self.Tunes.paganCombatA.Components[22] = {};
	self.Tunes.paganCombatA.Components[22].Container = CreateSoundContainer("Pagan Combat A 22 40", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[22].preLength = 850;
	self.Tunes.paganCombatA.Components[22].totalPost = 7724;
	self.Tunes.paganCombatA.Components[22].canLinkTo = {13, 21};
	
	self.Tunes.paganCombatA.Components[23] = {};
	self.Tunes.paganCombatA.Components[23].Container = CreateSoundContainer("Pagan Combat A 23 65", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[23].preLength = 850;
	self.Tunes.paganCombatA.Components[23].totalPost = 9289;	
	self.Tunes.paganCombatA.Components[23].canLinkTo = {24};	
	self.Tunes.paganCombatA.Components[23].Type = "Transitional";
	
	self.Tunes.paganCombatA.Components[24] = {};
	self.Tunes.paganCombatA.Components[24].Container = CreateSoundContainer("Pagan Combat A 24 65", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[24].preLength = 850;
	self.Tunes.paganCombatA.Components[24].totalPost = 9289;
	self.Tunes.paganCombatA.Components[24].canLinkTo = {25};	
	
	self.Tunes.paganCombatA.Components[25] = {};
	self.Tunes.paganCombatA.Components[25].Container = CreateSoundContainer("Pagan Combat A 25 70", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[25].preLength = 850;
	self.Tunes.paganCombatA.Components[25].totalPost = 9289;
	self.Tunes.paganCombatA.Components[25].canLinkTo = {23, 26};	
	
	self.Tunes.paganCombatA.Components[26] = {};
	self.Tunes.paganCombatA.Components[26].Container = CreateSoundContainer("Pagan Combat A 26 75", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[26].preLength = 850;
	self.Tunes.paganCombatA.Components[26].totalPost = 9289;
	self.Tunes.paganCombatA.Components[26].canLinkTo = {23, 27};	
	
	self.Tunes.paganCombatA.Components[27] = {};
	self.Tunes.paganCombatA.Components[27].Container = CreateSoundContainer("Pagan Combat A 27 70", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[27].preLength = 850;
	self.Tunes.paganCombatA.Components[27].totalPost = 7200;
	self.Tunes.paganCombatA.Components[27].canLinkTo = {26};
	
	self.Tunes.paganCombatA.Components[28] = {};
	self.Tunes.paganCombatA.Components[28].Container = CreateSoundContainer("Pagan Combat A 28 70", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[28].preLength = 850;
	self.Tunes.paganCombatA.Components[28].totalPost = 11404;
	self.Tunes.paganCombatA.Components[28].Type = "Transitional";
	
	self.Tunes.paganCombatA.Components[29] = {};
	self.Tunes.paganCombatA.Components[29].Container = CreateSoundContainer("Pagan Combat A 29 80", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[29].preLength = 850;
	self.Tunes.paganCombatA.Components[29].totalPost = 9289;
	self.Tunes.paganCombatA.Components[29].canLinkTo = {30};
	
	self.Tunes.paganCombatA.Components[30] = {};
	self.Tunes.paganCombatA.Components[30].Container = CreateSoundContainer("Pagan Combat A 30 80", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[30].preLength = 850;
	self.Tunes.paganCombatA.Components[30].totalPost = 9289;
	self.Tunes.paganCombatA.Components[30].canLinkTo = {29, 31};
	
	self.Tunes.paganCombatA.Components[31] = {};
	self.Tunes.paganCombatA.Components[31].Container = CreateSoundContainer("Pagan Combat A 31 90", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[31].preLength = 850;
	self.Tunes.paganCombatA.Components[31].totalPost = 9289;
	self.Tunes.paganCombatA.Components[31].canLinkTo = {32};
	
	self.Tunes.paganCombatA.Components[32] = {};
	self.Tunes.paganCombatA.Components[32].Container = CreateSoundContainer("Pagan Combat A 32 90", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[32].preLength = 850;
	self.Tunes.paganCombatA.Components[32].totalPost = 9289;
	self.Tunes.paganCombatA.Components[32].canLinkTo = {29};
	
	self.Tunes.paganCombatA.Components[33] = {};
	self.Tunes.paganCombatA.Components[33].Container = CreateSoundContainer("Pagan Combat A 33 99", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[33].preLength = 850;
	self.Tunes.paganCombatA.Components[33].totalPost = 17722;
	self.Tunes.paganCombatA.Components[33].canLinkTo = {34};
	self.Tunes.paganCombatA.Components[33].Type = "Transitional";
	
	self.Tunes.paganCombatA.Components[34] = {};
	self.Tunes.paganCombatA.Components[34].Container = CreateSoundContainer("Pagan Combat A 34 90", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[34].preLength = 850;
	self.Tunes.paganCombatA.Components[34].totalPost = 9289;
	self.Tunes.paganCombatA.Components[34].canLinkTo = {35};
	
	self.Tunes.paganCombatA.Components[35] = {};
	self.Tunes.paganCombatA.Components[35].Container = CreateSoundContainer("Pagan Combat A 35 90", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[35].preLength = 850;
	self.Tunes.paganCombatA.Components[35].totalPost = 9289;
	self.Tunes.paganCombatA.Components[35].canLinkTo = {36};
	
	self.Tunes.paganCombatA.Components[36] = {};
	self.Tunes.paganCombatA.Components[36].Container = CreateSoundContainer("Pagan Combat A 36 50", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[36].preLength = 850;
	self.Tunes.paganCombatA.Components[36].totalPost = 9289;
	self.Tunes.paganCombatA.Components[36].canLinkTo = {33, 37};
	
	self.Tunes.paganCombatA.Components[37] = {};
	self.Tunes.paganCombatA.Components[37].Container = CreateSoundContainer("Pagan Combat A 37 40", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[37].preLength = 850;
	self.Tunes.paganCombatA.Components[37].totalPost = 9289;
	self.Tunes.paganCombatA.Components[37].canLinkTo = {38};
	
	self.Tunes.paganCombatA.Components[38] = {};
	self.Tunes.paganCombatA.Components[38].Container = CreateSoundContainer("Pagan Combat A 38 100", "Mordhau.rte");
	self.Tunes.paganCombatA.Components[38].preLength = 850;
	self.Tunes.paganCombatA.Components[38].totalPost = 22388;
	self.Tunes.paganCombatA.Components[38].canLinkTo = {29};
	
	self.Tunes.paganCombatA.intensityTables = {};
	self.Tunes.paganCombatA.intensityTables[1] = {};
	self.Tunes.paganCombatA.intensityTables[1].Loops = {1, 2, 3, 4, 5};
	self.Tunes.paganCombatA.intensityTables[1].Transitional = 5;
	
	self.Tunes.paganCombatA.intensityTables[2] = {};
	self.Tunes.paganCombatA.intensityTables[2].Loops = {6, 7, 8, 9, 10, 11, 12};
	self.Tunes.paganCombatA.intensityTables[2].Transitional = 13;
	
	self.Tunes.paganCombatA.intensityTables[3] = {};
	self.Tunes.paganCombatA.intensityTables[3].Loops = {13, 14, 15, 16, 17, 18, 19, 20, 21, 22};
	self.Tunes.paganCombatA.intensityTables[3].Transitional = 23;
	
	self.Tunes.paganCombatA.intensityTables[4] = {};
	self.Tunes.paganCombatA.intensityTables[4].Loops = {23, 24, 25, 26, 27};
	self.Tunes.paganCombatA.intensityTables[4].Transitional = 28;
	
	self.Tunes.paganCombatA.intensityTables[5] = {};
	self.Tunes.paganCombatA.intensityTables[5].Loops = {29, 30, 31, 32};
	self.Tunes.paganCombatA.intensityTables[5].Transitional = 33;
	
	self.Tunes.paganCombatA.intensityTables[6] = {};
	self.Tunes.paganCombatA.intensityTables[6].Loops = {33, 34, 35, 36, 37, 38};
	self.Tunes.paganCombatA.intensityTables[6].Transitional = {29, 5, 33};
	
	if self.activity.ActivityState == Activity.EDITING then
	
		self.editingMusic = true;
	
		AudioMan:ClearMusicQueue();
		AudioMan:StopMusic();
		local ambientTable = {};
		for k, v in pairs(self.happyAmbients) do
			table.insert(ambientTable, v);
		end
		for i = 1, #ambientTable do
			local randomizedIndex = math.random(1, #ambientTable);
			local randomizedAmbient = ambientTable[randomizedIndex];
			AudioMan:QueueMusicStream(randomizedAmbient);
			AudioMan:QueueSilence(10);
			table.remove(ambientTable, randomizedIndex);
		end
		
	else
	
		self.currentIndex = 1;
		local tuneTable = {};
		for k, v in pairs(self.Tunes) do
			table.insert(tuneTable, v);
		end
		self.currentTuneIndex = math.random(1, #tuneTable);
		self.currentTune = tuneTable[self.currentTuneIndex];
		if self.currentTune.Components then
			self.dynamicMusic = true;
			self.currentTune.Components[self.currentIndex].Container.Volume = self.dynamicVolume;
			self.currentTune.Components[self.currentIndex].Container:Play();
		else -- normal music!
			self.dynamicMusic = false;
			AudioMan:PlayMusic(self.currentTune.Path, 0, -1);
		end
		
	end
	
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
	elseif UInputMan:KeyPressed(43) then
		self.desiredIntensity = 6;
	end
	
	if self.activity.ActivityState == Activity.EDITING then
		-- if we're editing, either stop basic music or tell dynamic
		-- music to transition off
		-- then we start our music
		if self.editingMusic ~= true then
			if self.dynamicMusic then
				self.endTune = true;
				self.loopNumber = 10;
				self.totalLoopNumber = 100;
				self.desiredIntensity = 6; -- fake an intensity switch so we get around tricky situations
										   -- like being in INTRO
				
				
				if self.MUSIC_STATE == "Rest" then
					if self.restTimer:IsPastRealMS(self.restTime - 100) then
						self.endTune = false;
						self.dynamicMusic = false;
						self.editingMusic = true;
					
						AudioMan:ClearMusicQueue();
						AudioMan:StopMusic();
						local ambientTable = {};
						for k, v in pairs(self.evilAmbients) do
							table.insert(ambientTable, v);
						end
						for i = 1, #ambientTable do
							local randomizedIndex = math.random(1, #ambientTable);
							local randomizedAmbient = ambientTable[randomizedIndex];
							AudioMan:QueueMusicStream(randomizedAmbient);
							AudioMan:QueueSilence(10);
							table.remove(ambientTable, randomizedIndex);
						end
					end
				end
				
			elseif AudioMan:IsMusicPlaying() then
			
				self.editingMusic = true;
			
				AudioMan:ClearMusicQueue();
				AudioMan:StopMusic();
				local ambientTable = {};
				for k, v in pairs(self.evilAmbients) do
					table.insert(ambientTable, v);
				end
				for i = 1, #ambientTable do
					local randomizedIndex = math.random(1, #ambientTable);
					local randomizedAmbient = ambientTable[randomizedIndex];
					AudioMan:QueueMusicStream(randomizedAmbient);
					AudioMan:QueueSilence(10);
					table.remove(ambientTable, randomizedIndex);
				end
			end
		end
	end
				
	
	
	if self.dynamicMusic == true then

		AudioMan:ClearMusicQueue();
		AudioMan:StopMusic();
		
		if self.MUSIC_STATE == "Intro" then
			if self.componentTimer:IsPastRealMS(self.currentTune.Components[self.currentIndex].totalPost - self.currentTune.Components[self.currentIndex + 1].preLength) then
				
				self.currentIndex = self.currentIndex + 1;
				
				if self.currentTune.Components[self.currentIndex].Type == nil then
					self.MUSIC_STATE = "Normal";
					self.desiredIntensity = 2;
					self.Intensity = 2;
					self.indexToPlay = self.currentIndex;
				end
				
				self.dynamicVolume = AudioMan.MusicVolume / AudioMan.SoundsVolume;
				
				self.currentTune.Components[self.currentIndex].Container.Volume = self.dynamicVolume;
				self.currentTune.Components[self.currentIndex].Container:Play();
				
				self.componentTimer:Reset();
			end
		elseif self.MUSIC_STATE == "Rest" then
			if self.restTimer:IsPastRealMS(self.restTime) then
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
				
				self.dynamicVolume = AudioMan.MusicVolume / AudioMan.SoundsVolume;
				
				if self.currentTune.Components then
					self.dynamicMusic = true;
					self.currentTune.Components[self.currentIndex].Container.Volume = self.dynamicVolume;
					self.currentTune.Components[self.currentIndex].Container:Play();
				else -- normal music!
					self.dynamicMusic = false;
					AudioMan:PlayMusic(self.currentTune.Path, 0, -1);
				end
				
				self.componentTimer:Reset();
			end
		else

			if self.componentTimer:IsPastRealMS(self.currentTune.Components[self.currentIndex].totalPost/3) then
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
							
							if loopTable[1] == self.currentIndex then
								-- "integrated transitional" where the transition of the former
								-- intensity is also the first of the next's loop
								index = index + 1;
							end
							
							if self.intensityLowering == true then
								-- dramatic pause for effect when lowering intensity
								self.intensityLowering = false;
								self.intensityLowerPreLength = self.currentTune.Components[index].preLength / 2
							end

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
							elseif self.currentTune.intensityTables[self.Intensity].Transitional[3] then
								-- a third value set denotes that this intensity, despite its automatic loopback
								-- also has a potential to loop forever due to how it links up
								-- in that case we don't want to be forced to wait, so we use the third value
								-- as a transitional index, which may or may not differ from the usual auto exit index
								if (self.desiredIntensity ~= self.Intensity and self.loopNumber > 2) or (self.totalLoopNumber >= self.tuneMaxLoops) then
									
									local loopTable = self.currentTune.intensityTables[self.Intensity].Loops;
									
									if self.totalLoopNumber >= self.tuneMaxLoops then
										self.endTune = true;
									end
									
									-- cue up the transitional
									index = self.currentTune.intensityTables[self.Intensity].Transitional[3]
									self.MUSIC_STATE = "Transitioning";
									
									if self.Intensity > self.desiredIntensity then
										self.intensityLowering = true;
									else
										self.intensityLowering  = false;
									end
														
									self.Intensity = self.desiredIntensity

								end
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
								
								if self.Intensity > self.desiredIntensity then
									self.intensityLowering = true;
								else
									self.intensityLowering  = false;
								end
													
								self.Intensity = self.desiredIntensity

							end
						end
					end
						
					self.indexToPlay = index;
					
				end
				
				local actingPreLength = self.intensityLowerPreLength or self.currentTune.Components[self.indexToPlay].preLength
			
				if self.componentTimer:IsPastRealMS(self.currentTune.Components[self.currentIndex].totalPost - actingPreLength) then
				
					self.nextDecided = false;
				
					self.loopNumber = self.loopNumber + 1;
					
					self.totalLoopNumber = self.totalLoopNumber + 1;
					
					self.intensityLowerPreLength = nil;
					
					print(self.currentIndex)
					
					self.currentIndex = self.indexToPlay;
					
					print(self.currentIndex)
					
					self.dynamicVolume = AudioMan.MusicVolume / AudioMan.SoundsVolume;
					
					self.currentTune.Components[self.currentIndex].Container.Volume = self.dynamicVolume;
					self.currentTune.Components[self.currentIndex].Container:Play();
					
					self.componentTimer:Reset();
					
				end
			end
		end
	else
		if (self.editingMusic == false and AudioMan:IsMusicPlaying() == false)
		or (self.editingMusic == true and self.activity.ActivityState ~= Activity.EDITING) then
			self.editingMusic = false;
			AudioMan:StopMusic();
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
			
			self.dynamicVolume = AudioMan.MusicVolume / AudioMan.SoundsVolume;
			
			if self.currentTune.Components then
				self.dynamicMusic = true;
				self.currentTune.Components[self.currentIndex].Container.Volume = self.dynamicVolume;
				self.currentTune.Components[self.currentIndex].Container:Play();
			else -- normal music!
				self.dynamicMusic = false;
				AudioMan:PlayMusic(self.currentTune.Path, 0, -1);
			end	
		end
	end
		
		
	
	-- PROTOTYPE PLACEHOLDER ONLY ONE SONG TODO MAKE MODULAR

end

function YeOldeSongsScript:EndScript()
	AudioMan:StopMusic();
	AudioMan:ClearMusicQueue();
	if self.activityOverPlayed ~= true then
		if self.currentTune.Components and self.currentTune.Components[self.currentIndex].Container:IsBeingPlayed() then
			self.currentTune.Components[self.currentIndex].Container:Stop(-1);
		end
		self.activityOverPlayed = true;
		if self.activity:HumanBrainCount() == 0 then
			AudioMan:PlayMusic(self.defeatPath, 0, -1);
			for i = 1, #self.evilAmbients do
				AudioMan:QueueSilence(10);
				local randomizedIndex = math.random(1, #self.evilAmbients);
				local randomizedAmbient = self.evilAmbients[randomizedIndex];
				AudioMan:QueueMusicStream(randomizedAmbient);
				table.remove(self.evilAmbients, randomizedIndex);
			end

		else
			--But if humans are left, play happy music!
			AudioMan:ClearMusicQueue();
			AudioMan:PlayMusic(self.victoryPath, 0, -1);
			for i = 1, #self.happyAmbients do
				AudioMan:QueueSilence(10);
				local randomizedIndex = math.random(1, #self.happyAmbients);
				local randomizedAmbient = self.happyAmbients[randomizedIndex];
				AudioMan:QueueMusicStream(randomizedAmbient);
				table.remove(self.happyAmbients, randomizedIndex);
			end
		end
	end
end

function YeOldeSongsScript:PauseScript()
end

function YeOldeSongsScript:CraftEnteredOrbit()
end
