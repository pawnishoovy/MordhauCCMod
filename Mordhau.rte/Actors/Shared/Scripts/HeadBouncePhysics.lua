function Create(self)
	
	self.impactTimer = Timer();
	self.impactCooldown = 0;	

end

function OnCollideWithTerrain(self, terrainID)	

	if self.TravelImpulse.Magnitude > 60 and self.impactTimer:IsPastSimMS(self.impactCooldown) then
	
		self.impactCooldown = 400;
		self.impactTimer:Reset();
	
		self.bounceSound:Play(self.Pos);
		
	end
	
end