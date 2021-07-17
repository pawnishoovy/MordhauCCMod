function OnDetach(self)

	self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/Longbow/Longbow.lua");

	self.charging = false
	
	self.shoot = false
	
end

function OnAttach(self)

	self:EnableScript("Mordhau.rte/Devices/Weapons/Handheld/Longbow/Longbow.lua");
	
	local parent = self:GetRootParent();
	
	if parent and IsAHuman(parent) and parent.PresetName == "Cunning Lady Rage" then
		self.chargeTime = 1300;
		self.soundDraw = CreateSoundContainer("Longbow DrawQuick", "Mordhau.rte");
	else
		self.chargeTime = 2600;
		self.soundDraw = CreateSoundContainer("Longbow Draw", "Mordhau.rte");
	end
	
end