function Update(self)

	self.parent = self:GetRootParent();
	
	if self.parent and IsACrab(self.parent) then
		self.RotAngle = self.RotAngle + ToACrab(self.parent):GetNumberValue("Arm Rotation");
	else
		self:GibThis();
	end
end
	