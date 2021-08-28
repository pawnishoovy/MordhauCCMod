function OnDetach(self)

	self:DisableScript("Mordhau.rte/Devices/Weapons/Melee/Axe/Axe.lua");
	
end

function OnAttach(self)

	self:EnableScript("Mordhau.rte/Devices/Weapons/Melee/Axe/Axe.lua");
	
end
