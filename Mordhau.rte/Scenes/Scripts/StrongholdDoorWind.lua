function Create(self)
	
	self.windAmbienceSound = CreateSoundContainer("Stronghold Door Wind", "Mordhau.rte");
	self.windAmbienceSound:Play(self.Pos);
	
	self.ambienceSoundFinal = self.windAmbienceSound
	self.ambienceTimer = Timer();
	self.ambienceDelay = 1881;

end

function Update(self)
	
	if self.ambienceTimer:IsPastSimMS(self.ambienceDelay) then
		self.windAmbienceSound:Play(self.Pos);
		self.ambienceTimer:Reset();
	end
	
end