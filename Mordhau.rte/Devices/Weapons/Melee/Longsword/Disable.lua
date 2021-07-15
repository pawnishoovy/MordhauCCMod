function OnDetach(self)

	self:DisableScript("Mordhau.rte/Devices/Weapons/Melee/Longsword/Longsword.lua");
	
	self.currentAttackAnimation = 0;
	self.currentAttackSequence = 0;
	self.currentAttackStart = false
	self.attackAnimationIsPlaying = false
	
	self.canBlock = false;
	
end

function OnAttach(self)

	self:EnableScript("Mordhau.rte/Devices/Weapons/Melee/Longsword/Longsword.lua");
	
	self.canBlock = true;
	
end

function Update(self)
	
	if self.canBlock == false then
		if self.WoundCount > self.woundCounter then
			self.woundCounter = self.WoundCount;
			self.breakSound:Play(self.Pos);
		end
	end
	
end