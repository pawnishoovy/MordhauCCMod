function CatapultLargeRock(actor)
	local gun = ToACrab(actor).EquippedItem;
	if gun ~= nil then
		local gun = ToHDFirearm(gun);
		gun:SetStringValue("Switch Ammo", "Catapult Large Rock");
	end
end

function CatapultRockCluster(actor)
	local gun = ToACrab(actor).EquippedItem;
	if gun ~= nil then
		local gun = ToHDFirearm(gun);
		gun:SetStringValue("Switch Ammo", "Catapult RockCluster");
	end
end

function CatapultFlameBarrel(actor)
	local gun = ToACrab(actor).EquippedItem;
	local Funds = ActivityMan:GetActivity():GetTeamFunds(ToACrab(actor).Team);
	if gun ~= nil and Funds > 19 then
		local gun = ToHDFirearm(gun);
		if not gun:NumberValueExists("Bought Flame Barrel") then
			ActivityMan:GetActivity():SetTeamFunds(Funds - 20, ToACrab(actor).Team);
		end
		gun:SetStringValue("Switch Ammo", "Catapult FlameBarrel");
		gun:SetNumberValue("Bought Flame Barrel", 1);
	end
end

function CatapultNothing(actor)
	local gun = ToACrab(actor).EquippedItem;
	if gun ~= nil then
		local gun = ToHDFirearm(gun);
		gun:SetStringValue("Switch Ammo", "Nothing");
	end
end