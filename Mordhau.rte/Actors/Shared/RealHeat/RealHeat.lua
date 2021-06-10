function Create(self)
	
	self.singeSound = CreateSoundContainer("RealHeat Singe", "Mordhau.rte");
	
	self.igniteSound = CreateSoundContainer("RealHeat Ignite", "Mordhau.rte");
	self.loopSound = CreateSoundContainer("RealHeat Loop", "Mordhau.rte");
	self.endSound = CreateSoundContainer("RealHeat End", "Mordhau.rte");

	self.parentSet = false;
	
	self.Heat = 0
	self.HeatMax = 100
	self.HeatLast = 0
	
	self.HeatOverheatThreshold = self.HeatMax * 0.9
	self.HeatDamageAccumulated = 0
	self.HeatDamageAccumulatedMax = 15
	self.HeatDamage = 6
	
	self.HeatBurning = false
	
	self.GFXDelayMin = 100
	self.GFXDelayMax = 300
	
	self.GFXTimer = Timer()
	self.GFXDelay = math.random(self.GFXDelayMin, self.GFXDelayMax)
	
	self.HeatDissipateTimer = Timer()
end
function Update(self)

	self.singeSound.Pos = self.Pos;
	self.igniteSound.Pos = self.Pos;
	self.loopSound.Pos = self.Pos;
	self.endSound.Pos = self.Pos;

	--PrimitiveMan:DrawCirclePrimitive(self.Pos, 13, 162)
	
	if not self:IsAttached() then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = self:GetParent()
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
	end
	
	if self.parent then
		self.Heat = self.parent:GetNumberValue("ActorHeat")
		
		self.Heat = math.min(self.Heat, self.HeatMax)
		--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "HEAT = ".. math.floor(self.Heat), true, 0)
		
		if self.Heat > self.HeatLast then
			self.HeatDamageAccumulated = self.HeatDamageAccumulated + math.abs(self.Heat - self.HeatLast)
			
			self.HeatLast = self.Heat
			
			self.HeatDissipateTimer:Reset()
		elseif self.Heat < self.HeatLast then
			self.HeatLast = self.Heat
		end
		
		if self.parent.Status ~= Actor.DEAD and self.parent.Status ~= Actor.DYING then
			--HeatIncrease
			if self.HeatBurning then
				self.parent.Health = self.parent.Health - 1.5 * TimerMan.DeltaTimeSecs
			elseif self.Heat > self.HeatOverheatThreshold then -- Overheat instakill
				self.parent:SetNumberValue("Death By Fire", self.Heat)
				self.igniteSound:Play(self.Pos);
				self.loopSound:Play(self.Pos);
				self.HeatBurning = true
			elseif self.HeatDamageAccumulated > self.HeatDamageAccumulatedMax then
				self.parent.Health = self.parent.Health - (self.HeatDamageAccumulated / self.HeatDamageAccumulatedMax) * self.HeatDamage
				self.singeSound:Play(self.Pos);
				self.HeatDamageAccumulated = 0
				
				if self.parent.Health < 1 or self.parent.Status == Actor.DEAD or self.parent.Status == Actor.DYING then
					self.parent:SetNumberValue("Death By Fire", self.Heat)
				end
				
				self.parent:FlashWhite(30)
			end
		end
		
		if self.GFXTimer:IsPastSimMS(self.GFXDelay) then
			if self.Heat > 5 and IsAHuman(self.parent) then
				local MOs = {self.parent.FGFoot, self.parent.BGFoot}
				local particles = {"Flame Smoke 2"}
				
				if self.Heat > 25 then
					table.insert(MOs, self.parent.FGLeg)
					table.insert(MOs, self.parent.BGLeg)
				end
				if self.Heat > 60 then
					table.insert(MOs, self.parent)
					
					table.insert(particles, "Explosion Smoke 1")
				end
				if self.Heat > 75 then
					table.insert(MOs, self.parent.FGArm)
					table.insert(MOs, self.parent.BGArm)
					
					table.insert(particles, "Explosion Smoke 1")
					table.insert(particles, "Firepot Flame")
				end
				
				if self.Heat > 90 then
					table.insert(MOs, self.parent.Head)
					table.insert(particles, "Explosion Smoke 1")
				end
				
				for i, leg in ipairs(MOs) do
					if leg then
							for i = 1, math.random(1,3) do
							local particle = CreateMOSParticle(particles[math.random(1,#particles)]);
							particle.Lifetime = math.random(250, 600);
							particle.Vel = leg.Vel + Vector(0, -1);
							particle.Vel = particle.Vel + Vector(math.random(), 0):RadRotate(math.random() * 6.28);
							particle.Pos = Vector(leg.Pos.X + math.random(-2, 2), leg.Pos.Y - math.random(0, 4));
							MovableMan:AddParticle(particle);
						end
					end
					
				end
			end
			
			self.GFXTimer:Reset()
			self.GFXDelay = math.random(self.GFXDelayMin, self.GFXDelayMax)
		end
		
		if self.HeatDissipateTimer:IsPastSimMS(300) and not self.HeatBurning then
			self.Heat = self.Heat / (1 + TimerMan.DeltaTimeSecs * 1.3) -- Slowly Reduce Heat
			
			if self.Heat < 1 then
				self.parent:RemoveNumberValue("ActorHeat")
				self.ToDelete = true
			end
		end
		
		if not self.ToDelete then
			self.parent:SetNumberValue("ActorHeat", self.Heat)
		end
	else
		self.ToDelete = true
	end
end
function Destroy(self)

	if self.loopSound:IsBeingPlayed() then
		self.loopSound:Stop(-1);
		self.endSound:Play(self.Pos);
	end
end