
function Create(self)
	
end

function Update(self)
	self.InheritedRotAngleOffset = self:GetParent().RotAngle * -self.FlipFactor
end

--function OnStride(self)
--end