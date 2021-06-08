function Create(self)

	self:DisableScript("Scrappers.rte/Devices/Weapons/Handheld/HeadBouncePhysics.lua");
	
end

function OnDetach(self)

	self.Vel = self.Vel + Vector(0, -5);
	
	self.AngularVel = self.AngularVel + math.random(-6, 6);

	self:EnableScript("Mordhau.rte/Actors/Shared/Scripts/HeadBounce.lua");
	
	self.playBleed = true;
	
	self.bounceSound = CreateSoundContainer("HeadBounce Mordhau", "Mordhau.rte");
	self.bloodSound = CreateSoundContainer("Blood Mordhau", "Mordhau.rte");
	
end