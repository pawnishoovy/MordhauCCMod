function Create(self)
	if math.random(0, 100) < 50 then
		self.Frame = 1;
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
	if self.Frame == 1 then
		-- wood gib
	else
		-- metal gib
	end
end