function Create(self)

	self.parentSet = false;

end

function Update(self)
	
	if not self:IsAttached() then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = self:GetParent()
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
		self.horseParent = ToACrab(MovableMan:FindObjectByUniqueID(self:GetNumberValue("Horse ID")));
	end
	
	if self.parent then

		if not self.ToDelete then
			if self.horseParent:IsDead() then
				self.parent.Status = 1;
				self.parent:RemoveNumberValue("Mordhau Disable Movement");
			elseif self.horseParent == nil then
				self.parent:RemoveNumberValue("Mordhau Disable Movement");
			end
		end
	else
		self.ToDelete = true
	end
end

function Destroy(self)

	if self.parent then
		self.parent:RemoveNumberValue("Mordhau Disable Movement");
	end
end