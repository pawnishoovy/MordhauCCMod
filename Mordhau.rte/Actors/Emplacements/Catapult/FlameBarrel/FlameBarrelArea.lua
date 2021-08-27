function Create(self)

	self.burnLoopSound = CreateSoundContainer("FlameBarrel Flame Loop Catapult", "Mordhau.rte");
	self.burnEndSound = CreateSoundContainer("FlameBarrel Flame End Catapult", "Mordhau.rte");
	self.playBurnEnd = true;
	
	self.burnLoopSound:Play(self.Pos);

	self.burnTime = self.Lifetime - 1000
	
	self.GFXDelayMin = 100
	self.GFXDelayMax = 600
	
	self.fuelData = {}
	local maxi = 35
	for i = 1, maxi do
		local data = {}
		data.Pos = Vector(self.Pos.X, self.Pos.Y)
		data.Vel = Vector(45 * ((i-1) / (maxi-1) - 0.5) + math.random(-2,2), math.random(0,-12)) * 0.5
		data.ID = math.random(0,999)
		data.Active = true
		data.Settled = false
		
		data.Bounces = 0
		data.BouncesMax = math.random(6,8)
		
		data.Lifetime = self.burnTime - math.random(0,1000)
		data.LifetimeTimer = Timer()
		
		data.GFXTimer = Timer()
		data.GFXDelay = math.random(self.GFXDelayMin, self.GFXDelayMax)
		
		data.DistanceToOrigin = 0
		
		table.insert(self.fuelData, data)
	end
	
	self.actorsInRange = {}
	self.checkActorsTimer = Timer()
	
	self.burnRangeMin = 39
	self.burnRangeMax = 78
	self.burnRate = 3 -- How much heat is added on contact
	
	self.fuelRange = 260
	self.loopTimer = Timer()
end
function Update(self)

	self.burnLoopSound.Pos = self.Pos;
	
	PrimitiveMan:DrawCirclePrimitive(self.Pos, self.fuelRange, 5)
	
	if self.Age > self.burnTime then
		self.ToDelete = true
	elseif self.Age > (self.burnTime - 2000) then
		if self.playBurnEnd == true then
			self.playBurnEnd = false;
			self.burnLoopSound:FadeOut(500);
			self.burnEndSound:Play(self.Pos);
		end
	end
	
	local averagePos = Vector()
	for fuelI, fuel in ipairs(self.fuelData) do
		
		if fuel.Active then
			averagePos = averagePos + SceneMan:ShortestDistance(fuel.Pos, self.Pos, true)
			
			--.ElapsedSimTimeMS
			
			if not fuel.Settled then -- Scatter/Spread
				
				fuel.DistanceToOrigin = SceneMan:ShortestDistance(fuel.Pos, self.Pos, true).Magnitude
			
				local velMagnitude = fuel.Vel.Magnitude
				
				local step = Vector(fuel.Vel.X, fuel.Vel.Y) * GetPPM() * TimerMan.DeltaTimeSecs
				local checkPos = Vector(fuel.Pos.X, fuel.Pos.Y) + step
				if velMagnitude > 1 then -- Collision
					--if SceneMan:GetTerrMatter(checkPos.X, checkPos.Y) == 0 then
					--	fuel.Pos = fuel.Pos + step
					--end
					fuel.Pos = fuel.Pos + step
					
					if (self.Age + fuel.ID) % 4 >= 2 then -- Optimization: update only some fuel points
						local detections = 0
						local lastPos = Vector(fuel.Pos.X, fuel.Pos.Y)
						
						local maxi = 6
						for i = 1, maxi do
							local angle = math.pi * 2 / maxi * i
							local vec = Vector(3,0):RadRotate(angle):RadRotate(((self.Age + fuel.ID) % 12) / 6 * math.pi)
							local pos = fuel.Pos + vec
							if SceneMan:GetTerrMatter(pos.X, pos.Y) ~= 0 then
								fuel.Pos = fuel.Pos - vec:SetMagnitude(1)
								fuel.Vel = fuel.Vel - vec:SetMagnitude(math.min(velMagnitude, 2))
								
								fuel.Vel = fuel.Vel / (1 + TimerMan.DeltaTimeSecs * maxi * 0.3)
								
								detections = detections + 1
							end
						end
						
						if detections > maxi-1 then
							fuel.Active = false
						else
							fuel.Bounces = fuel.Bounces + detections
							if fuel.Bounces > fuel.BouncesMax then -- Settle
								local strength = SceneMan:CastStrengthSumRay(fuel.Pos, lastPos, 0, 98);
								if strength < 80 then
									fuel.Settled = true
								else
									fuel.Active = false
								end
							end
						end
					end
				end
				
				fuel.Vel = fuel.Vel + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs * 0.65
				fuel.Vel = fuel.Vel / (1 + TimerMan.DeltaTimeSecs * 1.5)
			
				if fuel.DistanceToOrigin > self.fuelRange then -- Delete when out of range
					fuel.Active = false
				end
				
			end
			
			-- Lifetime
			local lifespan = fuel.Lifetime * (2 - (fuel.DistanceToOrigin / self.fuelRange)) / 2
			local strength = 1 - (fuel.LifetimeTimer.ElapsedSimTimeMS / lifespan)
			
			--.ElapsedSimTimeMS
			if fuel.LifetimeTimer:IsPastSimMS(lifespan) then
				fuel.Active = false
			end
			
			-- GFX
			
			if fuel.GFXTimer:IsPastSimMS(fuel.GFXDelay * (1 + math.pow(1 - strength, 2))) then
				
				for i = 1, math.random(1,2) do
					local fx = CreateMOSParticle("FlameBarrel Flame");
					if fx then
						fx.Pos = fuel.Pos +  Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 2;
						fx.Vel = Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 5
						fx.Lifetime = fx.Lifetime * RangeRand(0.7, 1.7) * 0.5 * (0.5 + strength) * math.random(1,3) * RangeRand(0.15, 0.3);
						if math.random(1,3) < 2 then
							fx.GlobalAccScalar = RangeRand(0.5, 0.2)
							fx.Lifetime = fx.Lifetime * 4
						end
						MovableMan:AddParticle(fx);
					end
				end
				
				if math.random(1,2) < 2 then
					for i = 1, math.random(1,2) do
						local fx = CreateMOSParticle("Explosion Smoke 1");
						if fx then
							fx.Pos = fuel.Pos +  Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 2;
							fx.Vel = Vector(RangeRand(-0.35, 0.35), RangeRand(-1, 1)) * 5
							fx.Lifetime = fx.Lifetime * RangeRand(0.7, 1.3) * 2.0 * (0.5 + strength);
							MovableMan:AddParticle(fx);
						end
					end
				end
				
				
				fuel.GFXTimer:Reset()
				fuel.GFXDelay = math.random(self.GFXDelayMin, self.GFXDelayMax)
			end
			
			PrimitiveMan:DrawCirclePrimitive(fuel.Pos, 13 - 10 * (1 - strength), 13) -- Debug draw
		end
	end
	
	-- Set Position to average position between all fuel points
	self.Pos = self.Pos - averagePos / #self.fuelData
	
	-- Get all potential actors
	if self.checkActorsTimer:IsPastSimMS(100) then
		self.actorsInRange = {}
		
		for actor in MovableMan.Actors do
			if actor.ClassName ~= "ADoor" or actor.ClassName ~= "ACraft" then
				local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
				if dist.Magnitude <= self.fuelRange then
					
					--local terrCheck = SceneMan:CastStrengthRay(self.Pos, dist, 30, Vector(), 5, 0, SceneMan.SceneWrapsX)
					--if terrCheck == false then
					--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + dist,  147)
					table.insert(self.actorsInRange, actor.UniqueID)
					--else
						--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + dist,  47)
					--end
				end
			end
		end
		self.checkActorsTimer:Reset()
	end
	
	-- BURN THINGS
	local actors = {}
	if #self.actorsInRange > 0 then
		for i, ID in ipairs(self.actorsInRange) do
			local mo = MovableMan:FindObjectByUniqueID(ID)
			if mo and IsActor(mo) then
				table.insert(actors, ToActor(mo))
			else
				table.remove(self.actorsInRange, i)
			end
		end
	end
	
	for i, actor in ipairs(actors) do
		for fuelI, fuel in ipairs(self.fuelData) do
			if fuel.Active then
				local lifespan = fuel.Lifetime * (2 - (fuel.DistanceToOrigin / self.fuelRange)) / 2
				local strength = 1 - (fuel.LifetimeTimer.ElapsedSimTimeMS / lifespan)
				
				local range = self.burnRangeMax * strength + self.burnRangeMin * (1 - strength)
				
				local dist = SceneMan:ShortestDistance(fuel.Pos, actor.Pos, SceneMan.SceneWrapsX)
				if dist.Magnitude <= range then
					--PrimitiveMan:DrawLinePrimitive(fuel.Pos, fuel.Pos + dist, 122)
					if actor:NumberValueExists("ActorHeat") then
						actor:SetNumberValue("ActorHeat", actor:GetNumberValue("ActorHeat") + self.burnRate * TimerMan.DeltaTimeSecs * (1 + math.pow(strength, 2)))
					else
						local heatHandler = CreateAttachable("RealHeat Handler", "Mordhau.rte")
						actor:AddAttachable(heatHandler)
						actor:SetNumberValue("ActorHeat", 0)
					end
				end
			end
		end
		
	end
	
end