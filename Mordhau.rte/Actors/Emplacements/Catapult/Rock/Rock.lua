
function Explode(self)
	if not self.explode then return end
	self.explode = false
	
	self:GibThis();
	
	local smokeAmount = 20
	local smokeLingering = 5
	
	if self.Vel.Magnitude > 13 or self.enoughForce then
		smokeAmount = 100;
		smokeLingering = 30
		self.explodeSound:Play(self.Pos);
		local airBlast = CreateMOPixel("Air Blast Scripted Catapult Large Rock", "Mordhau.rte");
		airBlast.Pos = self.Pos;
		airBlast.Mass = math.min(self.Vel.Magnitude * 250, 1200);
		MovableMan:AddParticle(airBlast);
	end

	local particleSpread = 25

	local smokeVelocity = (1 + math.sqrt(smokeAmount / 8) ) * 0.5
	
	for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
		local spread = (math.pi * 2) * RangeRand(-1, 1) * 0.05
		local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
		
		local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
		particle.Pos = self.Pos
		particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
		particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
		particle.AirThreshold = particle.AirThreshold * 0.5
		particle.GlobalAccScalar = 0
		MovableMan:AddParticle(particle);
	end
	
	for i = 1, 50 do
		local spread = (math.pi * 2) * RangeRand(-1, 1)
		local velocity = 30 * RangeRand(0.1, 0.9) * 0.4;
		
		local particle = CreateMOSParticle("Tiny Smoke Ball 1");
		particle.Pos = self.Pos
		particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(spread) * (50 * 0.2)
		particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.9 * 25
		particle.AirThreshold = particle.AirThreshold * 0.5
		particle.GlobalAccScalar = -0.0001
		MovableMan:AddParticle(particle);
	end	
	
	for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
		local vel = Vector(110 ,0):RadRotate(self.RotAngle)
		
		local particle = CreateMOSParticle("Tiny Smoke Ball 1");
		particle.Pos = self.Pos
		-- oh LORD
		particle.Vel = self.Vel + ((Vector(vel.X, vel.Y):RadRotate((math.pi * 2) * (math.random(0,1) * 2.0 - 1.0) * 0.5 + (math.pi * 2) * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.3 + Vector(vel.X, vel.Y):RadRotate((math.pi * 2) * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.2) * 0.5) * smokeVelocity;
		-- have mercy
		particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
		particle.AirThreshold = particle.AirThreshold * 0.5
		particle.GlobalAccScalar = 0
		MovableMan:AddParticle(particle);
	end
	
	for i = 1, math.ceil(smokeAmount / (math.random(5,10) * 0.5)) do
		local spread = (math.pi * 2) * RangeRand(-1, 1)
		local velocity = 110 * 0.6 * RangeRand(0.9,1.1)
		
		local particle = CreateMOSParticle("Flame Smoke 1 Micro")
		particle.Pos = self.Pos
		particle.Vel = self.Vel + Vector(velocity ,0):RadRotate(self.RotAngle + spread) * smokeVelocity
		particle.Team = self.Team
		particle.Lifetime = particle.Lifetime * RangeRand(0.9,1.2) * 0.75 * smokeLingering
		particle.AirResistance = particle.AirResistance * 2.5 * RangeRand(0.9,1.1)
		particle.IgnoresTeamHits = true
		particle.AirThreshold = particle.AirThreshold * 0.5
		particle.GlobalAccScalar = 0
		MovableMan:AddParticle(particle);
	end	

end

function Create(self)
	self.explode = true
	self.soundFlyLoop = CreateSoundContainer("Large Rock FlightLoop Catapult", "Mordhau.rte");
	--self.originalPitch = math.random(8, 12) / 100;
	--self.soundFlyLoop:Play(self.Pos);
	
	self.HitsMOs = false; -- avoid hitting ourselves
	--self.hitTimer = Timer();
	
	self.lastPos = Vector(self.Pos.X, self.Pos.Y)
	self.launchVector = Vector()

	self.explodeSound = CreateSoundContainer("Large Rock Gib Catapult", "Mordhau.rte");
	
	self.flying = false
	
	--local parent = self:GetRootParent()
	--if parent and IsACrab(parent) then
	--	ToACrab(parent):SetNumberValue("Arm Rotation", ToACrab(parent):GetNumberValue("Arm Rotation") + math.pi * 0.01 * self.FlipFactor)
	--end
end

function OnDetach(self)
	self.flying = true
	
	self.Vel = self.launchVector / rte.PxTravelledPerFrame * 0.5
	self.Vel = self.Vel + Vector(0, -self.Vel.Magnitude * 0.3)
	self.AngularVel = RangeRand(-1, 1) * 6
	
	self.originalPitch = math.random(8, 12) / 100;
	self.soundFlyLoop:Play(self.Pos);
	
	--self.HitsMOs = false; -- avoid hitting ourselves
	self.hitTimer = Timer();
	
	self.HitsMOs = true
end

function Update(self)
	self.launchVector = SceneMan:ShortestDistance(self.lastPos, self.Pos,SceneMan.SceneWrapsX)
	self.lastPos = Vector(self.Pos.X, self.Pos.Y)
	
	if not self.flying then return end
	
	self.ToSettle = false
	
	self.soundFlyLoop.Pos = self.Pos
	
	self.soundFlyLoop.Volume = math.min(self.Vel.Magnitude / 20, 50) + 0.10;
	self.soundFlyLoop.Pitch = (self.Vel.Magnitude / 35) + self.originalPitch;
	
	--if self.hitTimer:IsPastSimMS(400) then
	--	self.HitsMOs = true;
	--end
	
end

function OnCollideWithTerrain(self, terrainID)
	if self.Vel.Magnitude > 13 then
		Explode(self)
		self.enoughForce = true;
	end
end

function OnCollideWithMO(self, MO, rootMO)
	if MO then
		MO:GibThis();
	end
	if self.Vel.Magnitude > 13 then
		Explode(self)
		if rootMO and rootMO.UniqueID ~= MO.UniqueID then
			rootMO:GibThis();
		end
		self.enoughForce = true;
	end
end

function Destroy(self)
	self.soundFlyLoop:Stop(-1);
end