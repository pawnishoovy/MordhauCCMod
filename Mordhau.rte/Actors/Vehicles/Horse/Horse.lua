
function AddTorsoPoint(self, pos)
	local mo = CreateMOSRotating("Horse Torso Point", "Mordhau.rte")
	mo.Pos = pos
	mo.RotAngle = self.RotAngle
	mo.Team = self.Team
	mo.Vel = self.Vel
	mo.IgnoresTeamHits = true
	mo:SetNumberValue("Parent", self.UniqueID)
	MovableMan:AddParticle(mo)
	
	return mo
end

function Create(self)
	self.torsoPoints = {}
	for i = 1, 2 do
		local pos = self.Pos + Vector(11 * (i - 1.5) * 2, 0)
		local mo = AddTorsoPoint(self, pos)
		
		self.torsoPoints[i] = mo.UniqueID
	end
	
	self.legLength = 22
	
	self.torsoPointBoundaryMagnitudeMax = 13
	self.torsoPointBoundaryMagnitudeMin = 10
	self.torsoPointBoundaryHeightUpper = 5
	self.torsoPointBoundaryHeightLower = 5
	self.torsoPointBoundaryWidthLeft = 8
	self.torsoPointBoundaryWidthRight = 8
end

function Update(self)
	
	-- Input
	local ctrl = self:GetController()
	local player = false
	if self:IsPlayerControlled() then
		player = true
	end
	
	if ctrl then
		local input = 0 - (ctrl:IsState(Controller.MOVE_LEFT) and 1 or 0) + (ctrl:IsState(Controller.MOVE_RIGHT) and 1 or 0)
		
		self.Vel = self.Vel + Vector(input * TimerMan.DeltaTimeSecs * 30, 0)
	end
	
	local pointPositions = {self.Pos + Vector(-11, 0), self.Pos + Vector(11, 0)}
	local pointVectors = {Vector(0,0), Vector(0,0)}
	local pointMOs = {nil, nil}
	
	for i, point in ipairs(self.torsoPoints) do
		if point then
			local mo = MovableMan:FindObjectByUniqueID(point)
			if mo then
				mo = ToMOSRotating(mo)
			else
				mo = ToMOSRotating(AddTorsoPoint(self, self.Pos + Vector(11 * (i - 1.5) * 2, 0)))
				self.torsoPoints[i] = mo.UniqueID
			end
			
			if mo then
				pointMOs[i] = mo
				
				mo.ToSettle = false
				mo.Vel = mo.Vel + self.Vel * 0.5-- * TimerMan.DeltaTimeSecs * 5
				
				-- Move out of terrain
				local angleOffset = mo.UniqueID * math.pi * 0.1 + mo.Age * 0.1
				
				local maxi = 6
				for i = 1, maxi do
					local factor = i / maxi
					local angle = math.pi * 2 * factor
					local origin = mo.Pos
					
					local radius = mo.Radius * 1.1
					local vec = Vector(radius, 0):RadRotate(angle + angleOffset)
					local point = origin + vec
					
					local checkPix = SceneMan:GetTerrMatter(point.X, point.Y)
					if checkPix > 0 then
						self.Pos = self.Pos - vec * TimerMan.DeltaTimeSecs / radius * 50
						
						PrimitiveMan:DrawCirclePrimitive(point, 1, 5);
					else
						PrimitiveMan:DrawCirclePrimitive(point, 1, 13);
					end
				end
				
				-- Save positions for later
				pointPositions[i] = Vector(mo.Pos.X, mo.Pos.Y)
				
				-- Fucking levitate
				local rayOrigin = mo.Pos + Vector(0, 5)--:RadRotate(mo.RotAngle)
				local rayVector = Vector(0 + self.Vel.X * GetPPM() * TimerMan.DeltaTimeSecs * 1.0, self.legLength)
				
				local terrCheck = SceneMan:CastStrengthRay(rayOrigin, rayVector, 15, Vector(), 0, 0, SceneMan.SceneWrapsX);
				PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVector, 5);
				
				if terrCheck then
					local rayHitPos = SceneMan:GetLastRayHitPos()
					local dif = SceneMan:ShortestDistance(rayOrigin, rayHitPos, SceneMan.SceneWrapsX)
					
					local factor = (1 - dif.Magnitude / rayVector.Magnitude)
					
					mo.Vel = mo.Vel + Vector(0, factor * -95 * TimerMan.DeltaTimeSecs)
					--mo.Vel = mo.Vel:RadRotate(rayVector.AbsRadAngle * -1)
					mo.Vel = Vector(mo.Vel.X, math.min(mo.Vel.Y, 0))
					--mo.Vel = mo.Vel:RadRotate(rayVector.AbsRadAngle)
					--mo.Pos = mo.Pos + Vector(0, (1 - dif.Magnitude / rayVector.Magnitude) * -5 * TimerMan.DeltaTimeSecs)
				end
				
				local dif = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX)
				pointVectors[i] = dif
				
				mo.RotAngle = dif.AbsRadAngle + math.pi * (1 - (i - 1))
				
				-- Debug
				PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + dif, 5);
				--PrimitiveMan:DrawCirclePrimitive(mo.Pos, mo.Radius, 5);
			end
		end
	end
	
	for i, mo in ipairs(pointMOs) do
		-- Length
		local targetPos = Vector(mo.Pos.X, mo.Pos.Y)
		targetPos = self.Pos + Vector(pointVectors[i].X, pointVectors[i].Y):SetMagnitude(math.max(math.min(pointVectors[i].Magnitude, self.torsoPointBoundaryMagnitudeMax), self.torsoPointBoundaryMagnitudeMin))
		targetPos = Vector(targetPos.X, math.max(targetPos.Y, self.Pos.Y - self.torsoPointBoundaryHeightUpper))
		targetPos = Vector(targetPos.X, math.min(targetPos.Y, self.Pos.Y + self.torsoPointBoundaryHeightLower))
		
		if i == 1 then
			targetPos = Vector(math.min(targetPos.X, self.Pos.X - self.torsoPointBoundaryWidthLeft), targetPos.Y)
		else
			targetPos = Vector(math.max(targetPos.X, self.Pos.X + self.torsoPointBoundaryWidthRight), targetPos.Y)
		end
		
		local targetPosDif = SceneMan:ShortestDistance(mo.Pos, targetPos, SceneMan.SceneWrapsX)
		
		mo.Pos = mo.Pos + targetPosDif * TimerMan.DeltaTimeSecs * 15
		mo.Vel = mo.Vel + targetPosDif * TimerMan.DeltaTimeSecs * 15
	end
	
	-- Adjust torso according to the simulation point's positions
	local center = pointPositions[1] + SceneMan:ShortestDistance(pointPositions[1], pointPositions[2], SceneMan.SceneWrapsX) * 0.5
	self.Pos = center
	self.Vel = Vector(0,0)
	
	local angleA = (pointVectors[1] + Vector(0, 1)).AbsRadAngle
	local angleB = (pointVectors[2] + Vector(0, 1)).AbsRadAngle 
	
	local value = angleB - angleA
	local ret = (value + math.pi) % (math.pi * 2);
	if ret < 0 then ret = ret + (math.pi * 2) end
	local result = ret - math.pi;
	
	local angleFinal = angleB - result * 0.5
	
	self.RotAngle = angleFinal + math.pi * 0.5
end

function OnCollideWithTerrain(self, terrainID)
end

function UpdateAI(self)
end

function Destroy(self)
	for i, point in ipairs(self.torsoPoints) do
		if point then
			local mo = MovableMan:FindObjectByUniqueID(point)
			if mo then
				mo.ToDelete = true
			end
		end
	end
end
