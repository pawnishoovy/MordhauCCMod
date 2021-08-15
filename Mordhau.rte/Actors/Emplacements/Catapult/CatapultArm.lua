function mathSign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end

function Create(self)
	self.lastRotation = 0
	
	self.wiggle = 0
	self.wiggleModulator = 0
	self.wiggleModulatorSpeed = 15
end

function Update(self)

	self.parent = self:GetRootParent();
	
	if self.parent and IsACrab(self.parent) then
		--self.RotAngle = self.RotAngle + ToACrab(self.parent):GetNumberValue("Arm Rotation");
		local rotation = ToACrab(self.parent):GetNumberValue("Arm Rotation") * self.FlipFactor
		
		local value = self.lastRotation - rotation;
		local ret = (value + math.pi) % (math.pi * 2);
		if ret < 0 then ret = ret + (math.pi * 2) end
		local result = ret - math.pi;
		
		local limit = math.rad(30)
		local limitWiggle = math.rad(15)
		self.wiggle = self.wiggle - math.min(math.max(result, -limit), limit) * TimerMan.DeltaTimeSecs * 100
		self.wiggle = math.min(math.max(self.wiggle, -limitWiggle), limitWiggle)
		
		self.wiggleModulator = (self.wiggleModulator + self.wiggle * TimerMan.DeltaTimeSecs * self.wiggleModulatorSpeed) / (1 + TimerMan.DeltaTimeSecs * self.wiggleModulatorSpeed)
		
		self.wiggle = self.wiggle - self.wiggleModulator * TimerMan.DeltaTimeSecs * 25.0
		self.wiggle = self.wiggle / (1 + TimerMan.DeltaTimeSecs * 0.5)
		
		
		self.InheritedRotAngleOffset = rotation + self.wiggle;
		self.lastRotation = rotation
		
		--self:ClearForces();
		--self:ClearImpulseForces();
		
		--self:RemoveWounds(self.WoundCount);
		
		self.GetsHitByMOs = false;
	else
		self:GibThis();
	end
end
	