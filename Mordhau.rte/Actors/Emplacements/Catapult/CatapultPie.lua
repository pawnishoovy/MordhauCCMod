function CatapultLargeRock(actor)
	local gun = ToACrab(actor).EquippedItem;
	if gun ~= nil then
		local gun = ToHDFirearm(gun);
		gun:SetStringValue("Switch Ammo", "Catapult Large Rock");
	end
end

function CatapultNothing(actor)
	local gun = ToACrab(actor).EquippedItem;
	if gun ~= nil then
		local gun = ToHDFirearm(gun);
		gun:SetStringValue("Switch Ammo", "Nothing");
	end
end