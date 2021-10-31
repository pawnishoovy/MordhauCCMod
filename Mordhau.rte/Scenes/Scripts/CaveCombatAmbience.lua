function Create(self)

	self.activity = ActivityMan:GetActivity();
	
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

function Update(self)

	if self.activity:PlayerActive(Activity.PLAYER_1) and self.activity:PlayerHuman(Activity.PLAYER_1) then
		local cursorPos = SceneMan:GetScrollTarget(Activity.PLAYER_1)
		
		if SceneMan.Scene:WithinArea("Interior", cursorPos) then
			self.interiorAmbience = true;
		else
			self.interiorAmbience = false;
		end	
	end
	
	if self.interiorAmbience == false and self.windInteriorAmbienceSound.Volume > 0.001 then
		self.windInteriorAmbienceSound.Volume = self.windInteriorAmbienceSound.Volume - 0.5 * TimerMan.DeltaTimeSecs;
		if self.windInteriorAmbienceSound.Volume < 0.001 then
			self.windInteriorAmbienceSound.Volume = 0.001;
		end
	elseif self.interiorAmbience == true and self.windInteriorAmbienceSound.Volume < 0.5 then
		self.windInteriorAmbienceSound.Volume = self.windInteriorAmbienceSound.Volume + 0.5 * TimerMan.DeltaTimeSecs;
		if self.windInteriorAmbienceSound.Volume > 0.5 then
			self.windInteriorAmbienceSound.Volume = 0.5;
		end
	end
	
	if self.interiorAmbience == true and self.windAmbienceSound.Volume > 0.001 then
		self.windAmbienceSound.Volume = self.windAmbienceSound.Volume - 0.5 * TimerMan.DeltaTimeSecs;
		if self.windAmbienceSound.Volume < 0.001 then
			self.windAmbienceSound.Volume = 0.001;
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
	
end