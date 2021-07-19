function Create(self)

	self.equipSound = CreateSoundContainer("Shield Equip Mordhau", "Mordhau.rte");
	self.equipSound.Pitch = 1.4;
	
	self.pickUpSound = CreateSoundContainer("Metal Pickup Mordhau", "Mordhau.rte");
	self.pickUpSound.Pitch = 1.1;

	self.parrySound = CreateSoundContainer("Mordhau ParryingShield Metal Impact", "Mordhau.rte");

	self.Parrying = false;

	self.parryTimer = Timer();
	self.parryWindow = 500;

	if math.random(0, 100) < 50 then
		self.pickUpSound = CreateSoundContainer("Wood Pickup Mordhau", "Mordhau.rte");
		self.pickUpSound.Pitch = 1.1;
		self.Frame = 1;
		self.parrySound = CreateSoundContainer("Mordhau ParryingShield Wood Impact", "Mordhau.rte");
		self.GibSound = CreateSoundContainer("Mordhau ParryingShield Wood Gib", "Mordhau.rte");
		self:SetEntryWound("Mordhau ParryingShield Wood Wound", "Mordhau.rte");
		self:SetExitWound("Mordhau ParryingShield Wood Wound", "Mordhau.rte");		
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
	if self.Frame == 1 then
		-- wood gib
	else
		-- metal gib
	end
end