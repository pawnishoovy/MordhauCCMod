function Create(self)

	self.equipSound = CreateSoundContainer("Generic Equip Mordhau", "Mordhau.rte");
	self.equipSound.Pitch = 1.0;

	self.fuseLightSound = CreateSoundContainer("FuseLight HolyHandGrenade", "Mordhau.rte");
	self.fuseSound = CreateSoundContainer("Fuse Blackpowder", "Mordhau.rte");
	
	self.playNose = true;
	self.explodeNoseSound = CreateSoundContainer("ExplodeNose Blackpowder", "Mordhau.rte");
	
	self.explodeOutdoorsSound = CreateSoundContainer("ExplodeOutdoors Blackpowder", "Mordhau.rte");
	self.explodeIndoorsSound = CreateSoundContainer("ExplodeIndoors Blackpowder", "Mordhau.rte");
	
	self.terrainSounds = {
	Bounce = {[12] = CreateSoundContainer("Bounce Concrete Blackpowder", "Mordhau.rte"),
			[164] = CreateSoundContainer("Bounce Concrete Blackpowder", "Mordhau.rte"),
			[177] = CreateSoundContainer("Bounce Concrete Blackpowder", "Mordhau.rte"),
			[9] = CreateSoundContainer("Bounce Dirt Blackpowder", "Mordhau.rte"),
			[10] = CreateSoundContainer("Bounce Dirt Blackpowder", "Mordhau.rte"),
			[11] = CreateSoundContainer("Bounce Dirt Blackpowder", "Mordhau.rte"),
			[128] = CreateSoundContainer("Bounce Dirt Blackpowder", "Mordhau.rte"),
			[6] = CreateSoundContainer("Bounce Sand Blackpowder", "Mordhau.rte"),
			[8] = CreateSoundContainer("Bounce Sand Blackpowder", "Mordhau.rte"),
			[178] = CreateSoundContainer("Bounce SolidMetal Blackpowder", "Mordhau.rte"),
			[179] = CreateSoundContainer("Bounce SolidMetal Blackpowder", "Mordhau.rte"),
			[180] = CreateSoundContainer("Bounce SolidMetal Blackpowder", "Mordhau.rte"),
			[181] = CreateSoundContainer("Bounce SolidMetal Blackpowder", "Mordhau.rte"),
			[182] = CreateSoundContainer("Bounce SolidMetal Blackpowder", "Mordhau.rte")}}
			
	self.fuseLightTimer = Timer();
	self.fuseLightDelay = 200;

	self.fuseDelay = 7500; -- i counted
	
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)
	self.impulse = Vector()
	self.bounceSoundTimer = Timer()	
	
end
function Update(self)

	self.impulse = (self.Vel - self.lastVel) / TimerMan.DeltaTimeSecs * self.Vel.Magnitude * 0.1
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)
	
	if self.fuse then
	
		self.fuseSound.Pos = self.Pos;
			
		if self.fuse:IsPastSimMS(self.fuseDelay) then
			self:GibThis();
			self.fuseSound:Stop(-1);
		elseif self.playNose == true and self.fuse:IsPastSimMS(self.fuseDelay - 150) then
			self.playNose = false;
			self.explodeNoseSound:Play(self.Pos)
		end
		
	elseif self:IsActivated() and not self.fuseLighting then
		self.fuseLighting = true;
		self.fuseLightSound:Play(self.Pos);
		self.fuseLightTimer:Reset();
		
		local pin = CreateMOSRotating("HolyHandGrenade Pin");
		pin.Pos = self.Pos;
		pin.Vel = self.Vel+Vector(0,-1)+Vector(3*math.random(),0):RadRotate(math.random()*(math.pi*2));
		MovableMan:AddParticle(pin);
		
		self.Frame = 1;
		
	elseif self.fuseLighting and self.fuseLightTimer:IsPastSimMS(self.fuseLightDelay) then
		self.fuse = Timer();
		self.fuseSound:Play(self.Pos);
	
	end
		
end

function OnCollideWithTerrain(self, terrainID)

	if self.bounceSoundTimer:IsPastSimMS(200) then
		if self.impulse.Magnitude > 25 then 
		
			if self.terrainSounds.Bounce[terrainID] ~= nil then
				self.terrainSounds.Bounce[terrainID]:Play(self.Pos);
			else -- default to concrete
				self.terrainSounds.Bounce[177]:Play(self.Pos);
			end			
			
			self.bounceSoundTimer:Reset()			
		end
	end
	
end

function Destroy(self)

	self.fuseSound:Stop(-1);
	
	local smokeAmount = 100
	local particleSpread = 25
	
	local smokeLingering = 30
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
		--

	if not self.ToSettle then

		local outdoorRays = 0;

		self.rayThreshold = 2; -- this is the first ray check to decide whether we play outdoors
		local Vector2 = Vector(0,-700); -- straight up
		local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
		local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
		local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
		local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
		local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
		local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

		self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
		self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
		self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
		self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
		self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
		
		self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft};
		
		for _, rayLength in ipairs(self.rayTable) do
			if rayLength < 0 then
				outdoorRays = outdoorRays + 1;
			end
		end
		
		if outdoorRays >= self.rayThreshold then
			self.explodeOutdoorsSound:Play(self.Pos);
		else
			self.explodeIndoorsSound:Play(self.Pos);
		end
		
	end
	
end