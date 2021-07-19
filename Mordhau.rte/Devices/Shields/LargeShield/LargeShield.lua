function Create(self)

	self.equipSound = CreateSoundContainer("Shield Equip Mordhau", "Mordhau.rte");
	self.equipSound.Pitch = 0.9;
	
	self.pickUpSound = CreateSoundContainer("Metal Pickup Mordhau", "Mordhau.rte");
	self.pickUpSound.Pitch = 1.0;

	if math.random(0, 100) < 50 then
		self.pickUpSound = CreateSoundContainer("Wood Pickup Mordhau", "Mordhau.rte");
		self.pickUpSound.Pitch = 0.9;
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
end

function Destroy(self)
	if self.Frame == 2 then
		-- wood gib
	else
		-- metal gib
	end
end