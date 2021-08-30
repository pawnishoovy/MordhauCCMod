function OnDetach(self)

	self:DisableScript("Mordhau.rte/Devices/Weapons/Melee/Lance/Lance.lua");
	
end

function OnAttach(self)

	self:EnableScript("Mordhau.rte/Devices/Weapons/Melee/Lance/Lance.lua");
	
end
