function OnDetach(self)

	self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/RecurveBow/RecurveBow.lua");

	self.charging = false
	
	self.shoot = false
	
end

function OnAttach(self)

	self:EnableScript("Mordhau.rte/Devices/Weapons/Handheld/RecurveBow/RecurveBow.lua");
	
	local parent = self:GetRootParent();
	
	if parent and IsAHuman(parent) and parent.PresetName == "Cunning Lady Rage" then
		self.chargeTime = 600;
		self.soundDraw = CreateSoundContainer("RecurveBow Draw", "Mordhau.rte");
	else
		self.chargeTime = 1200;
		self.soundDraw = CreateSoundContainer("RecurveBow DrawQuick", "Mordhau.rte");
	end
	
end