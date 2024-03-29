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
			self.originalStableVel = self.parent:GetStableVelocityThreshold();
			self.parent:SetStableVelocityThreshold(60, 60);
			if self.parent.BGLeg then
				self.parent.BGLeg.Scale = 0;
				if self.parent.BGFoot then
					self.parent.BGFoot.Scale = 0;
				end
			end
			
		end
		self.horseParent = ToACrab(MovableMan:FindObjectByUniqueID(self:GetNumberValue("Horse ID")));
	end
	
	if self.parent then

		if not self.ToDelete then
			if self.horseParent:IsDead() then
				self.parent:SetStableVelocityThreshold(self.originalStableVel);
				if self.parent.BGLeg then
					self.parent.BGLeg.Scale = 1;
					if self.parent.BGFoot then
						self.parent.BGFoot.Scale = 1;
					end
				end
				self.ToDelete = true;
				self.parent:RemoveNumberValue("Mordhau Disable Movement");
			elseif self.horseParent == nil then
				self.parent:SetStableVelocityThreshold(self.originalStableVel);
				if self.parent.BGLeg then
					self.parent.BGLeg.Scale = 1;
					if self.parent.BGFoot then
						self.parent.BGFoot.Scale = 1;
					end
				end
				self.ToDelete = true;
				self.parent:RemoveNumberValue("Mordhau Disable Movement");
			end
		end
	else
		self.ToDelete = true
	end
end

function Destroy(self)

	if self.parent then
		self.parent:SetStableVelocityThreshold(self.originalStableVel);
		if self.parent.BGLeg then
			self.parent.BGLeg.Scale = 1;
			if self.parent.BGFoot then
				self.parent.BGFoot.Scale = 1;
			end
		end
		self.parent:RemoveNumberValue("Mordhau Disable Movement");
	end
end