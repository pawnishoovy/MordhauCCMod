
function Create(self)
	self:SetNumberValue("ParentOffsetX", self.ParentOffset.X)
	self:SetNumberValue("ParentOffsetY", self.ParentOffset.Y)
	ToACrab(self:GetRootParent()):SetNumberValue(self.PresetName, self.UniqueID)
end
