function OnAttach(self)

	if self.RootID == 255 then -- equipped from inv
		if self.equipSound then
			self.equipSound:Play(self.Pos);
		end
	else
		if self.pickUpSound then
			self.pickUpSound:Play(self.Pos);
		end
	end

end