function Create(self)

	self.equipSound = CreateSoundContainer("Shield Equip Mordhau", "Mordhau.rte");
	self.equipSound.Pitch = 1.0;
	
	self.pickUpSound = CreateSoundContainer("Metal Pickup Mordhau", "Mordhau.rte");
	self.pickUpSound.Pitch = 1.0;
	
	self.parrySound = CreateSoundContainer("Mordhau MediumShield Metal Impact", "Mordhau.rte");

	self.Parrying = false;

	self.parryTimer = Timer();
	self.parryWindow = 500;

	if math.random(0, 100) < 50 then
		self.pickUpSound = CreateSoundContainer("Wood Pickup Mordhau", "Mordhau.rte");
		self.pickUpSound.Pitch = 1.0;
		self.Frame = 2;
		self.parrySound = CreateSoundContainer("Mordhau MediumShield Wood Impact", "Mordhau.rte");
		self.GibSound = CreateSoundContainer("Mordhau MediumShield Wood Gib", "Mordhau.rte");
		self:SetEntryWound("Mordhau MediumShield Wood Wound", "Mordhau.rte");
		self:SetExitWound("Mordhau MediumShield Wood Wound", "Mordhau.rte");		
		for attachable in self.Attachables do
			attachable.Frame = 1;
			attachable.GibSound = CreateSoundContainer("Mordhau MediumShield Wood PartGib", "Mordhau.rte");
			attachable:SetEntryWound("Mordhau MediumShield Wood Wound", "Mordhau.rte");
			attachable:SetExitWound("Mordhau MediumShield Wood Wound", "Mordhau.rte");
		end
	end
end

function Update(self)

	if self:StringValueExists("Parrying Type") and self.Parrying == false then
		self.Parrying = true;
		self.parryTimer:Reset();
		
		self.StanceOffset = Vector(10, -2);
		self.SharpStanceOffset = Vector(10, -2);
		
	elseif self.Parrying == true then
	
		if self:StringValueExists("Blocked Type") then
			self.parrySound:Play(self.Pos);
			self:RemoveStringValue("Blocked Type");
		end
		
		if self.parryTimer:IsPastSimMS(self.parryWindow) then
			self.Parrying = false;
			self:RemoveStringValue("Parrying Type");
			
			self.StanceOffset = Vector(8, 2);
			self.SharpStanceOffset = Vector(8, 2);
			
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