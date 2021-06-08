function Create(self)
	
	self.bloodSound = CreateSoundContainer("Blood Mordhau", "Mordhau.rte");
	self.bounceSound = CreateSoundContainer("HeadBounce Mordhau", "Mordhau.rte");

	self.playSound = true
	self.bleedTimer = Timer()
	self.bleedDelay = 100
	
	--self.Vel = self.Vel:RadRotate(RangeRand(-1,1) * 0.7) * RangeRand(0.9,1.1)
end

function Update(self)
	if self.bleedTimer:IsPastSimMS(self.bleedDelay) then
		if math.random(1,3) < 2 then
			local effect = CreateMOSParticle((math.random(1,3) < 2 and "Blood Small Spray Particle Mordhau" or "Blood Tiny Spray Particle Mordhau"))
			if effect then
				effect.Pos = self.Pos + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 2
				effect.Vel = self.Vel * RangeRand(0.6, 0.8) + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 1
				effect.Lifetime = effect.Lifetime * RangeRand(0.8,1.2);
				MovableMan:AddParticle(effect)
			end
		end
		
		if math.random(1,2) < 2 then
			for i = 1, math.random(3) do
				local blood = CreateMOPixel("Drop Blood")
				if blood then
					blood.Pos = self.Pos + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 2
					blood.Vel = self.Vel * RangeRand(0.6, 0.8) + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 5
					blood.Lifetime = blood.Lifetime * RangeRand(0.8,1.2);
					MovableMan:AddParticle(blood)
				end
			end
		end
		
		self.bleedTimer:Reset()
		self.bleedDelay = math.random(30,200)
	end
	if self.Age > 15000 then
		self.ToDelete = true
	end
end

function OnCollideWithTerrain(self, terrainID)
	if self.playSound then
		self.bloodSound:Play(self.Pos);
		self.playSound = false
		if self.Vel.Magnitude > (20+math.random(0,9)) and math.random(1,2) < 2 then
			self.ToDelete = true
		
			for i = 3, math.random(8) do
				local blood = CreateMOPixel("Drop Blood")
				if blood then
					blood.Pos = self.Pos + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 2
					blood.Vel = self.Vel * RangeRand(0.6, 0.8) + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 16
					blood.Lifetime = blood.Lifetime * RangeRand(0.8,1.2);
					MovableMan:AddParticle(blood)
				end
			end
			
			for i = 2, math.random(6) do
				local effect = CreateMOSParticle((math.random(1,3) < 2 and "Blood Small Spray Particle Mordhau" or "Blood Tiny Spray Particle Mordhau"))
				if effect then
					effect.Pos = self.Pos + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 2
					effect.Vel = self.Vel * RangeRand(0.6, 0.8) + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 5
					effect.Lifetime = effect.Lifetime * RangeRand(0.8,1.2);
					MovableMan:AddParticle(effect)
				end
			end
			
			self.bounceSound:Play(self.Pos);
		end
	end
end