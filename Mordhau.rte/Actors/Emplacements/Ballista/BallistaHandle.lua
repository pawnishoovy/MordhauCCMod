
function OnDetach(self, exParent)
	exParent:SetNumberValue("LostHandle", 1)
	self.ToDelete = true
end
