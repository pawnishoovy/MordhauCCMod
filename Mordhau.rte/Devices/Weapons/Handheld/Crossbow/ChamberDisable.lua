function OnDetach(self)

	self:DisableScript("Medieval.rte/Devices/Weapons/Handheld/Flintlock/Chamber.lua");
	self.ReloadTime = 9000;
	
end

function OnAttach(self)

	self:EnableScript("Medieval.rte/Devices/Weapons/Handheld/Flintlock/Chamber.lua");
	
end