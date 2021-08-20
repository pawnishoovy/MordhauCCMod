function OnDetach(self)

	self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/Flintlock/Chamber.lua");
	self.ReloadTime = 9000;
	
end

function OnAttach(self)

	self:EnableScript("Mordhau.rte/Devices/Weapons/Handheld/Flintlock/Chamber.lua");
	
end