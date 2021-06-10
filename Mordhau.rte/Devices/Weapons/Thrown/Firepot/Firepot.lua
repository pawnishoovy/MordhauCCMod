
function Create(self)

	self.idleBurnSound = CreateSoundContainer("Firepot IdleBurn", "Mordhau.rte");
	self.throwSound = CreateSoundContainer("Firepot Throw", "Mordhau.rte");
	self.litFlyLoopSound = CreateSoundContainer("Firepot LitFlyLoop", "Mordhau.rte");
	
	self.explodeSound = CreateSoundContainer("Firepot Explode", "Mordhau.rte");

	self.origMass = self.Mass;
	self.lastVel = 0;
	
	self.Frame = math.random(0, self.FrameCount - 1);
end
function Update(self)

	self.idleBurnSound.Pos = self.Pos;
	self.litFlyLoopSound.Pos = self.Pos;
	
	self.litFlyLoopSound.Volume = math.min(self.Vel.Magnitude / 25, 0.95) + 0.05;
	self.litFlyLoopSound.Pitch = (self.Vel.Magnitude / 25) + 0.5;

	if not self:IsAttached() and self.Live then
		if not self.Thrown then
			self.Thrown = true;
			self.throwSound:Play(self.Pos);
			self.litFlyLoopSound:Play(self.Pos);
		end
		self.Mass = self.origMass + math.sqrt(self.lastVel);
	else
		self.Mass = self.origMass;
	end
	if self.WoundCount > 1 then
		self:Activate();
	end
	if not self.explosion and self:IsActivated() then
		self.idleBurnSound:Play(self.Pos);
		self.Live = true;
		self.explosion = CreateMOSRotating("Firepot Explosion")
		self.flameArea = CreateMOSRotating("Firepot Area")
	end
	self.lastVel = self.Vel.Magnitude;
end
function Destroy(self)
	self.litFlyLoopSound:Stop(-1);
	self.idleBurnSound:Stop(-1);
	-- Explode into flames only if lit
	if self.explosion then
		self.explodeSound:Play(self.Pos);
		self.explosion.Pos = Vector(self.Pos.X, self.Pos.Y);
		self.explosion.Vel = Vector(self.Vel.X, self.Vel.Y);
		MovableMan:AddParticle(self.explosion);
		self.explosion:GibThis();
	end
	
	if self.flameArea then
		self.flameArea.Pos = Vector(self.Pos.X, self.Pos.Y);
		self.flameArea.Vel = Vector(self.Vel.X, self.Vel.Y);
		MovableMan:AddParticle(self.flameArea);
	end
end