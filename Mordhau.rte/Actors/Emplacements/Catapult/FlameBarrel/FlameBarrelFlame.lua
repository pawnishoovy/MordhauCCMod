function Create(self)
	self.idleBurnSound = CreateSoundContainer("Firepot IdleBurn", "Mordhau.rte");
	self.idleBurnSound:Play(self.Pos);
end
function Update(self)
	local parent = self:GetParent();
	if parent then
		self.idleBurnSound.Pos = self.Pos
		self.Scale = 1;
		if math.random() < 0.3 then
			local part = CreateMOSParticle("Flame Smoke 2");
			if math.random() < 0.3 then
				part = CreateMOSParticle("Fire Puff Small");
			end
			part.Pos = self.Pos;
			part.Vel = self.Vel + Vector(math.random(), 0):RadRotate(math.random() * 6.28);
			part.Lifetime = part.Lifetime * RangeRand(0.5, 1.0);
			MovableMan:AddParticle(part);
		end
	else
		self.ToDelete = true;
	end
end
function Destroy(self)
	if self.idleBurnSound and self.idleBurnSound:IsBeingPlayed() then
		self.idleBurnSound:Stop(-1);
	end
end