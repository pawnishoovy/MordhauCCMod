function Update(self)

	self.parent = self:GetRootParent();
	
	if self.parent and IsACrab(self.parent) then
		self.RotAngle = self.RotAngle + ToACrab(self.parent):GetNumberValue("Arm Rotation");
		self:ClearForces();
		self:ClearImpulseForces();
		
		self:RemoveWounds(self.WoundCount);
		
		self.GetsHitByMOs = false;
	else
		self:GibThis();
	end
end
	