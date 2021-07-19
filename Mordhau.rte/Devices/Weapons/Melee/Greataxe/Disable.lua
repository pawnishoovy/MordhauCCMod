function OnDetach(self)

	self:DisableScript("Mordhau.rte/Devices/Weapons/Melee/Greataxe/Greataxe.lua");
	
	self:RemoveStringValue("Parrying Type");
	self.Parrying = false;
	
	self.Blocking = false;
	self:RemoveNumberValue("Blocking");
	
	self.currentAttackAnimation = 0;
	self.currentAttackSequence = 0;
	self.currentAttackStart = false
	self.attackAnimationIsPlaying = false
	
	self.rotationInterpolationSpeed = 25;
	
	self.canBlock = false;
	
end

function OnAttach(self)

	self.HUDVisible = true;

	self:DisableScript("Mordhau.rte/Devices/Shared/Scripts/TwirlPierceThrow.lua");
	self.PinStrength = 0;

	self:EnableScript("Mordhau.rte/Devices/Weapons/Melee/Greataxe/Greataxe.lua");
	
	if self.RootID == 255 then --equipped from inv
	
		self.equipAnim = true;
		
		-- local rotationTarget = 170 / 180 * math.pi
		-- local stanceTarget = Vector(-15, -25);
	
		-- self.stance = self.stance + stanceTarget
		
		-- rotationTarget = rotationTarget * self.FlipFactor
		-- self.rotation = self.rotation + rotationTarget
		
		-- self.StanceOffset = self.originalStanceOffset + self.stance
		-- self.RotAngle = self.RotAngle + self.rotation
		
	end
	
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