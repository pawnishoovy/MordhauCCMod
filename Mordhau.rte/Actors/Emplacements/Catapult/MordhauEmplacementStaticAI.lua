dofile("Base.rte/Constants.lua")
package.path = package.path .. ";Mordhau.rte/?.lua";
require("Actors/Emplacements/Catapult/NativeMordhauEmplacementStaticAI")

function Create(self)
	self.AI = NativeMordhauEmplacementStaticAI:Create(self)	--Emplacement AI for static weapons

	self.crewSpawnTimer = Timer()
	self.crewReloaderDelay = 150
	self.crewSpotterDelay = 300

	self.gotGunner = false
	
	self.crewSize = 1

	self.IsPlayer = ActivityMan:GetActivity():IsHumanTeam(self.Team)

end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)
	self.AI:Destroy(self)
end
