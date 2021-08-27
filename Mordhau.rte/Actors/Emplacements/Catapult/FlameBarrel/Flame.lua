function Create(self)
end
function Update(self)
	self.ToSettle = false;
	local age = (self.Age * 0.0006) + 1;	--Have age slightly affect particle settings relative to 10 seconds
	local chance = math.random();
	local particle;
	--[[if chance < (0.08/age) then
		particle = CreateMOPixel("Ground Fire Burn Particle");
		particle.Vel = self.Vel + Vector(RangeRand(-15, 15), -math.random(-10, 20));
		particle.Sharpness = particle.Sharpness * RangeRand(0.5, 1.0);
	elseif chance < (0.4/age) then
		--Spawn another, shorter flame particle occasionally
		particle = CreateMOSParticle("Flame Smoke 2");
		particle.Lifetime = math.random(250, 1000)/age;
		particle.Vel = self.Vel + Vector(0, -1);
		particle.Vel = particle.Vel + Vector(math.random(), 0):RadRotate(math.random() * 6.28);
	end]]
	if chance < (0.4/age) then
		--Spawn another, shorter flame particle occasionally
		particle = CreateMOSParticle("Flame Smoke 2");
		particle.Lifetime = math.random(250, 1000)/age;
		particle.Vel = self.Vel + Vector(0, -1);
		particle.Vel = particle.Vel + Vector(math.random(), 0):RadRotate(math.random() * 6.28);
	end
	if particle then
		particle.Pos = Vector(self.Pos.X + math.random(-2, 2), self.Pos.Y - math.random(0, 4));
		MovableMan:AddParticle(particle);
	end
end