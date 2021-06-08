function Create(self)
	
	self.impactTimer = Timer();
	self.impactCooldown = 0;	

end

function OnCollideWithTerrain(self, terrainID)

	if self.playBleed == true then
		self.playBleed = false;
		self.bloodSound:Play(self.Pos);
	end

	if self.TravelImpulse.Magnitude > 45 and self.impactTimer:IsPastSimMS(self.impactCooldown) then
	
		self.impactCooldown = 400;
		self.impactTimer:Reset();
	
		self.bounceSound:Play(self.Pos);
		
	end
	
end