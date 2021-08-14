
-- Please have mercy upon me
-- For I am about to do something that has not been done before (except 4zK did it but it is not as "detailed")
-- I'm not commenting any of this in hopes that nobody will (re)use it.

function Create(self)
	self.breastPhysicsPivotOffset = Vector(3, -4)
	self.breastPhysicsPointPos = self.Pos + Vector(self.breastPhysicsPivotOffset.X * self.FlipFactor, self.breastPhysicsPivotOffset.Y):RadRotate(self.RotAngle)
	self.breastPhysicsPointVel = Vector(0, 0)
	
	self.breastPhysicsWiggleState = -1
end

function Update(self)
	local pivot = self.Pos + Vector(self.breastPhysicsPivotOffset.X * self.FlipFactor, self.breastPhysicsPivotOffset.Y):RadRotate(self.RotAngle)
	local vel = Vector(self.breastPhysicsPointVel.X, self.breastPhysicsPointVel.Y)-- + SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs
	local pos = Vector(self.breastPhysicsPointPos.X, self.breastPhysicsPointPos.Y)
	
	local dif = SceneMan:ShortestDistance(pos, pivot, SceneMan.SceneWrapsX)
	
	vel = vel + dif * math.min(math.max((dif.Magnitude / 5), 0), 6) * TimerMan.DeltaTimeSecs * 15
	vel = vel / (1 + TimerMan.DeltaTimeSecs * 8.0) -- Boob air friction
	
	pos = pos + vel * rte.PxTravelledPerFrame
	
	self.breastPhysicsPointPos = Vector(pos.X, pos.Y)
	self.breastPhysicsPointVel = Vector(vel.X, vel.Y)
	
	-- DEBUG
	--PrimitiveMan:DrawCirclePrimitive(self.breastPhysicsPointPos, 1, 5);
	
	local vec = SceneMan:ShortestDistance(pivot,self.breastPhysicsPointPos,SceneMan.SceneWrapsX)
	--PrimitiveMan:DrawLinePrimitive(pivot, pivot + vec, 5);
	--print(vec.Magnitude)
	if vec.Magnitude < 1.3 then
		self.Frame = 0
		self.breastPhysicsWiggleState = -1
	else
		local factors = {}
		for i = 0, 3 do
			local angle = self.RotAngle + -math.pi * 0.5 * i
			
			local min_value = -math.pi;
			local max_value = math.pi;
			local value = vec.AbsRadAngle - angle;
			local result;
			
			local range = max_value - min_value;
			if range <= 0 then
				result = min_value;
			else
				local ret = (value - min_value) % range;
				if ret < 0 then ret = ret + range end
				result = ret + min_value;
			end
			
			factors[i+1] = 1 - math.min(math.max(math.abs(result) / (math.pi * 0.5), 0), 1)
		end
		
		local closestI = -1
		local closestFactor = -1
		for i = 1, 4 do
			local factor = factors[i]
			
			if factor > closestFactor then
				closestFactor = factor
				closestI = i
			end
		end
		
		if self.HFlipped then
			if closestI == 1 then
				closestI = 3
			elseif closestI == 3 then
				closestI = 1
			end
		end
		
		if vec.Magnitude > 3 then
			self.breastPhysicsWiggleState = 0
		elseif self.breastPhysicsWiggleState < 1 then
			self.breastPhysicsWiggleState = math.random(1, 2)
		end
		
		self.Frame = 3 * closestI
		self.Frame = self.Frame - math.min(0, self.breastPhysicsWiggleState)
		
		-- DEBUG
		--[[
		local l = (self.breastPhysicsWiggleState < 1 and 5 or 15)
		if closestI == 1 then
			PrimitiveMan:DrawLinePrimitive(pivot, pivot + Vector(l * self.FlipFactor, 0), 13);
		elseif closestI == 2 then
			PrimitiveMan:DrawLinePrimitive(pivot, pivot + Vector(0, l), 13);
		elseif closestI == 3 then
			PrimitiveMan:DrawLinePrimitive(pivot, pivot + Vector(-l * self.FlipFactor, 0), 13);
		elseif closestI == 4 then
			PrimitiveMan:DrawLinePrimitive(pivot, pivot + Vector(0, -l), 13);
		end
		
		PrimitiveMan:DrawLinePrimitive(pivot, pivot + Vector(l, 0):RadRotate(vec.AbsRadAngle), 5);]]
	end
end

function OnStride(self)
	self.breastPhysicsPointVel = self.breastPhysicsPointVel + Vector(self.Vel.X, self.Vel.Y):SetMagnitude(math.min(self.Vel.Magnitude, 7)) * 0.75 + Vector(0, 3)
end