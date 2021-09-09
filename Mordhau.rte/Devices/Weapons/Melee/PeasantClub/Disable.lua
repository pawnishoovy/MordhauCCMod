function OnDetach(self)

	self:RemoveNumberValue("AI Parry")
	self:RemoveNumberValue("AI Parry Eligible")

	if self.wasThrown == true then
	
		self.throwWounds = 5;
		self.throwPitch = 0.8;
	
		self.HUDVisible = false;
		
		self:EnableScript("Mordhau.rte/Devices/Shared/Scripts/TwirlBluntThrow.lua");
		self.thrownTeam = self.Team;

	end

	self:DisableScript("Mordhau.rte/Devices/Weapons/Melee/PeasantClub/PeasantClub.lua");
	
	self:RemoveStringValue("Parrying Type");
	self.Parrying = false;
	
	self.Blocking = false;
	self:RemoveNumberValue("Blocking");
	
	self.currentAttackAnimation = 0;
	self.currentAttackSequence = 0;
	self.currentAttackStart = false
	self.attackAnimationIsPlaying = false
	
	self.rotationInterpolationSpeed = 25;
	
	self.Frame = 5;
	
end

function OnAttach(self)

	self.HUDVisible = true;

	self:DisableScript("Mordhau.rte/Devices/Shared/Scripts/TwirlBluntThrow.lua");
	self.PinStrength = 0;

	self:EnableScript("Mordhau.rte/Devices/Weapons/Melee/PeasantClub/PeasantClub.lua");
	
	if self.RootID == 255 then --equipped from inv
	
		self.equipAnim = true;
		
		-- local rotationTarget = -225 / 180 * math.pi
		-- local stanceTarget = Vector(-4, 0);
	
		-- self.stance = self.stance + stanceTarget
		
		-- rotationTarget = rotationTarget * self.FlipFactor
		-- self.rotation = self.rotation + rotationTarget
		
		-- self.StanceOffset = self.originalStanceOffset + self.stance
		-- self.RotAngle = self.RotAngle + self.rotation
		
	end
	
end