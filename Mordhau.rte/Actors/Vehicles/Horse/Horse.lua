package.path = package.path .. ";Mordhau.rte/?.lua";
require("Actors/Vehicles/Horse/HorseAIBehaviours")

-- Huge thanks to SunoMikey and his awesome IK code!
function calcIK(l1, l2, point)
	point = Vector(point.X, point.Y):SetMagnitude(math.min(point.Magnitude, l1 + l2 - 0.001))
	
	local q1, q2 = 0
	local x = point.X
	local y = point.Y
	
	q2 = math.acos((x*x + y*y - l1*l1 - l2*l2)/(2 * l1 * l2))
	q1 = math.atan2(y, x) - math.atan2((l2 * math.sin(q2)), (l1 + l2 * math.cos(q2)))
	
	return {q1, q2}
end

function getPathAnimationVector(animation, factor) -- factor goes form 0 to 1
	if factor < 0 then
		factor = 1 - abs(factor)
	end
	
	local length = #animation
	--local factor = self.runCycleTimer.ElapsedSimTimeMS / self.runCycleDuration
	local factorFract = math.fmod(factor * length, 1)
	factorFract = math.min(factorFract, 1)
	factorFract = math.max(factorFract, 0)
	
	local segmentIndex = math.max(math.min(math.ceil(length * factor), length), 1)
	local segmentNextIndex = (segmentIndex) % (length) + 1
	
	local segment = Vector(animation[segmentIndex][1], animation[segmentIndex][2])
	local segmentNext = Vector(animation[segmentNextIndex][1], animation[segmentNextIndex][2])
	
	return ((segmentNext) + (segment - segmentNext) * (1 - factorFract))
end

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
	
	self.legLength = 18
	
	self.legFrontShinLength = 7
	self.legFrontThighLength = 10
	self.legBackShinLength = 7.5
	self.legBackThighLength = 8.5
	
	self.legStepData = {false, false, false, false}
	
	self.runCyclePathAnimation = {
		{0, 7},
		{8, 7},
		{11, 10},
		{6, 12},
		{-4, 12},
		{-11, 11}
	}
	-- wtf, real shit
	local longest = -1 -- Find the longest
	for i, vec in ipairs(self.runCyclePathAnimation) do
		longest = math.max(longest, Vector(vec[1], vec[2]).Magnitude)
	end
	for i = 1, #self.runCyclePathAnimation do -- Normalize them!
		local vec = Vector(self.runCyclePathAnimation[i][1], self.runCyclePathAnimation[i][2])
		vec = vec:SetMagnitude(vec.Magnitude / longest * ((self.legFrontShinLength + self.legFrontThighLength + self.legBackShinLength + self.legBackThighLength) * 0.5))
		self.runCyclePathAnimation[i] = {vec.X, vec.Y}
	end
	
	self.torsoPointBoundaryMagnitudeMax = 13
	self.torsoPointBoundaryMagnitudeMin = 10
	self.torsoPointBoundaryHeightUpper = 5
	self.torsoPointBoundaryHeightLower = 5
	self.torsoPointBoundaryWidthLeft = 8
	self.torsoPointBoundaryWidthRight = 8
	
	self.walkAnimationAcc = 0
	
	self.death = false
	self.deathStagger = 0
	self.deathCrippleLeg = 0
	
	self.movementInput = 0
	self.movementTargetVel = 4
	self.movementAcceleration = 1.5
	
	self.healthUpdateTimer = Timer();
	self.oldHealth = self.Health;
	
	self.headWounds = 0;
	
	self.Suppression = 0;
	self.Suppressed = false;	
	
	self.suppressionUpdateTimer = Timer();
	self.suppressedVoicelineTimer = Timer();
	self.suppressedVoicelineDelay = 8000;
	
	self.emotionTimer = Timer();
	self.emotionDuration = 0;
	
	self.deathFallSound = CreateSoundContainer("Horse Gear DeathFall", "Mordhau.rte");
	
	self.jingleSound = CreateSoundContainer("Horse Gear Jingle", "Mordhau.rte");
	self.jingleSound.Volume = 0;
	self.jingleSound:Play(self.Pos);
	self.creakSound = CreateSoundContainer("Horse Gear SaddleCreak", "Mordhau.rte");
	self.creakSound.Volume = 0;
	self.creakSound:Play(self.Pos);
	
	self.jumpSound = CreateSoundContainer("Horse Gear Jump", "Mordhau.rte");
	self.landSound = CreateSoundContainer("Horse Gear Land", "Mordhau.rte");
	
	self.mountGrabSound = CreateSoundContainer("Horse Gear MountGrab", "Mordhau.rte");
	self.mountingSound = CreateSoundContainer("Horse Gear Mounting", "Mordhau.rte");
	
	self.terrainSounds = {
	HoofStep = {[12] = CreateSoundContainer("Horse HoofStep Stone", "Mordhau.rte"),
			[164] = CreateSoundContainer("Horse HoofStep Stone", "Mordhau.rte"),
			[177] = CreateSoundContainer("Horse HoofStep Stone", "Mordhau.rte"),
			[9] = CreateSoundContainer("Horse HoofStep Dirt", "Mordhau.rte"),
			[10] = CreateSoundContainer("Horse HoofStep Dirt", "Mordhau.rte"),
			[11] = CreateSoundContainer("Horse HoofStep Dirt", "Mordhau.rte"),
			[128] = CreateSoundContainer("Horse HoofStep Dirt", "Mordhau.rte"),
			[6] = CreateSoundContainer("Horse HoofStep Sand", "Mordhau.rte"),
			[8] = CreateSoundContainer("Horse HoofStep Sand", "Mordhau.rte"),
			[178] = CreateSoundContainer("Horse HoofStep Stone", "Mordhau.rte"),
			[179] = CreateSoundContainer("Horse HoofStep Stone", "Mordhau.rte"),
			[180] = CreateSoundContainer("Horse HoofStep Stone", "Mordhau.rte"),
			[181] = CreateSoundContainer("Horse HoofStep Stone", "Mordhau.rte"),
			[182] = CreateSoundContainer("Horse HoofStep Stone", "Mordhau.rte")},
	};
	
	self.voiceSounds = {
	breathIdle = CreateSoundContainer("Horse Breath Idle", "Mordhau.rte"),
	breathInFast = CreateSoundContainer("Horse Breath InFast", "Mordhau.rte"),
	breathInSlow = CreateSoundContainer("Horse Breath InSlow", "Mordhau.rte"),
	breathOutFast = CreateSoundContainer("Horse Breath OutFast", "Mordhau.rte"),
	breathOutSlow = CreateSoundContainer("Horse Breath OutSlow", "Mordhau.rte"),
	gruntAggressive = CreateSoundContainer("Horse Grunt Aggressive", "Mordhau.rte"),
	gruntGeneric = CreateSoundContainer("Horse Grunt Generic", "Mordhau.rte"),
	gruntScared = CreateSoundContainer("Horse Grunt Scared", "Mordhau.rte"),
	neighAggressive = CreateSoundContainer("Horse Grunt Aggressive", "Mordhau.rte"),
	neighGeneric = CreateSoundContainer("Horse Neigh Generic", "Mordhau.rte"),
	neighScared = CreateSoundContainer("Horse Neigh Scared", "Mordhau.rte"),
	snortFast = CreateSoundContainer("Horse Snort Fast", "Mordhau.rte"),
	snortSlow = CreateSoundContainer("Horse Snort Slow", "Mordhau.rte")
	};	
	
	self.voiceSound = CreateSoundContainer("Musketeer Gear Move", "Mordhau.rte");
	-- MEANINGLESS! this is just so we can do voiceSound.Pos without an if check first! it will be overwritten first actual VO play
	
end

function Update(self)

	if self.MOToNotHit then
		if MovableMan:ValidMO(self.MOToNotHit) then
			self:SetWhichMOToNotHit(self.MOToNotHit, -1)
		end
	end

	if UInputMan:KeyPressed(12) then
		self.Health = 0;
	end
	if UInputMan:KeyPressed(13) then
		self:GibThis();
	end
	if UInputMan:KeyPressed(14) then
		self:AddWound(CreateAEmitter("Wound Flesh Body Entry Knight"), Vector(0, 0), true)
		self.Health = self.Health - 20;
	end
	if UInputMan:KeyPressed(15) then
		self:AddWound(CreateAEmitter("Wound Flesh Body Entry Knight"), Vector(0, 0), true)
		self.Health = self.Health - 55;
	end
		
	-- Death
	if self.Status >= Actor.DYING then
		if not self.death then
			self.death = true
			self.deathCrippleLeg = math.random(0,2)
		end
		self.ToSettle = (self.deathStagger > 1.1)
		self.deathStagger = math.min(self.deathStagger + TimerMan.DeltaTimeSecs * 1.25, 1.25)
	end
	
	-- Input
	local ctrl = self:GetController()
	local player = false
	if self:IsPlayerControlled() then
		player = true
	end
	
	if self.Status < Actor.DYING and ctrl then
		self.movementInput = 0 - ((ctrl:IsState(Controller.MOVE_LEFT) or self.movingLeft) and 1 or 0) + ((ctrl:IsState(Controller.MOVE_RIGHT) or self.movingRight) and 1 or 0)
		if self.movementInput == 0 then 
			self.Moving = false;
		elseif self.Moving == false then
			self.Moving = true;
			--self.hoofStep1Played = false;
			--self.hoofStep2Played = false;
			--self.hoofStep3Played = false;
			--self.hoofStep4Played = false;
			self.legStepData = {false, false, false, false}
		end
		self.movingRight = false;
		self.movingLeft = false;
		self.Jumping = false;
	end
	
	local pointPositions = {self.Pos + Vector(-11, 0), self.Pos + Vector(11, 0)}
	local pointVectors = {Vector(0,0), Vector(0,0)}
	local pointMOs = {nil, nil}
	
	local legMOs = {{{nil,nil,nil}, {nil,nil,nil}}  ,  {{nil,nil,nil}, {nil,nil,nil}}}
	
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
				
				-- Setup
				local springStrength = 1
				if self.Status >= Actor.DYING then
					if self.deathCrippleLeg == i then
						springStrength = 0
					else
						springStrength = (math.random() * 0.5 + 0.5) * (1 - self.deathStagger)
					end
				end
				
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
						mo.Pos = mo.Pos - vec * TimerMan.DeltaTimeSecs / radius * 60 * springStrength
						mo.Vel = mo.Vel - vec * TimerMan.DeltaTimeSecs / radius * 20 * springStrength
						
					--	PrimitiveMan:DrawCirclePrimitive(point, 1, 5);
					--else
					--	PrimitiveMan:DrawCirclePrimitive(point, 1, 13);
					end
				end
				
				-- Save positions for later
				pointPositions[i] = Vector(mo.Pos.X, mo.Pos.Y)
				
				-- Leg movement / physics (Fucking levitate)
				local legPartSets = {{"Horse Leg Back Thigh", "Horse Leg Back Shin", "Horse Leg Back Hoof"}, {"Horse Leg Front Thigh", "Horse Leg Front Shin", "Horse Leg Front Hoof"}}
				local legG = {"FG", "BG"}
				for leg = 1, 2 do
					
					local legPartSet = legPartSets[self.HFlipped and (3 - i) or (i)]
					local legPartG = legG[self.HFlipped and (3 - leg) or (leg)]
					
					local legThigh = legPartSet[1].." "..legPartG
					local legShin = legPartSet[2].." "..legPartG
					local legHoof = legPartSet[3].." "..legPartG
					
					local valid = true
					
					legThigh = MovableMan:FindObjectByUniqueID(self:GetNumberValue(legThigh))
					if legThigh then
						legThigh = ToAttachable(legThigh)
					else
						valid = false
					end
					
					legShin = MovableMan:FindObjectByUniqueID(self:GetNumberValue(legShin))
					if legShin then
						legShin = ToAttachable(legShin)
					else
						valid = false
					end
					
					legHoof = MovableMan:FindObjectByUniqueID(self:GetNumberValue(legHoof))
					if legHoof then
						legHoof = ToAttachable(legHoof)
					end
					
					if valid then
						legMOs[i][leg][1] = legThigh
						legMOs[i][leg][2] = legShin
						legMOs[i][leg][3] = legHoof
						
						local shinLength = self.legBackShinLength
						local thighLength = self.legBackThighLength
						local footLength = 2
						
						if i == 2 then
							local shinLength = self.legFrontShinLength
							local thighLength = self.legFrontThighLength
						end
						
						-- Animation system
						local animationOffset = (leg - 1) * 0.5 + 0.25 * (i - 1)
						local animationFactor = (self.walkAnimationAcc + animationOffset) % 1
						local animationVector = getPathAnimationVector(self.runCyclePathAnimation, animationFactor)
						
						--local sound = CreateSoundContainer("Pre Catapult");
						--sound.Volume = 0.7		
						--[[
						local toPlay = false;
						if self.hoofStep1Played ~= true and ((leg - 1) * 0.5 + 0.25 * (i - 1)) == 0.50 then
							self.hoofStep1Played = true;
							toPlay = true;

						elseif math.abs(self.walkAnimationAcc) > 0.22 and math.abs(self.walkAnimationAcc) < 0.28 and self.hoofStep2Played ~= true and ((leg - 1) * 0.5 + 0.25 * (i - 1)) == 0.25 then
							self.hoofStep2Played = true;
							toPlay = true;
						elseif math.abs(self.walkAnimationAcc) > 0.46 and math.abs(self.walkAnimationAcc) < 0.54 and self.hoofStep3Played ~= true and ((leg - 1) * 0.5 + 0.25 * (i - 1)) == 0 then
							self.hoofStep3Played = true;
							toPlay = true;
						elseif math.abs(self.walkAnimationAcc) > 0.72 and math.abs(self.walkAnimationAcc) < 0.78 and self.hoofStep4Played ~= true and ((leg - 1) * 0.5 + 0.25 * (i - 1)) == 0.75 then
							self.hoofStep4Played = true;
							toPlay = true;
						end]]
						
						local index = leg + (i - 1) * 2
						
						local dif
						local value = animationFactor - 0.5
						local ret = (value) % 1;
						if ret < 0 then ret = ret + 1 end
						dif = math.abs(ret);
						
						local toPlay = false
						if self.legStepData[index] == false and dif < 0.06 then
							self.legStepData[index] = true
							toPlay = true
						elseif self.legStepData[index] == true and dif > 0.12 then
							self.legStepData[index] = false
						end
						
						local offset = (((self.HFlipped and i == 2) or (not self.HFlipped and i == 1)) and Vector(-4 * self.FlipFactor, 0) or Vector(0, 1))
						
						local rayOrigin = mo.Pos + Vector(2 * (leg - 1.5) * 2.0, 5)--:RadRotate(mo.RotAngle)
						local rayVector = offset + Vector(0, self.legLength) + Vector(animationVector.X * 0.75, (animationVector.Y * 3 - 35) * 0.65) * math.min(math.abs(mo.Vel.X / 2), 1)
						
						local terrCheck = SceneMan:CastStrengthRay(rayOrigin, rayVector, 15, Vector(), 0, 0, SceneMan.SceneWrapsX);
						
						-- Debug
						--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVector, 13);
						
						local length = rayVector.Magnitude
						local contact = false
						if terrCheck then
							local rayHitPos = SceneMan:GetLastRayHitPos()
							local dif = SceneMan:ShortestDistance(rayOrigin, rayHitPos, SceneMan.SceneWrapsX)
							
							-- Debug
							--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + dif, 5);
							
							contact = true
							length = dif.Magnitude
							
							local factor = (1 - dif.Magnitude / rayVector.Magnitude)
							
							local strength = 0.5
							
							if self.movementInput == 0 then
								mo.Vel = Vector(mo.Vel.X / (1 + TimerMan.DeltaTimeSecs * 2), mo.Vel.Y)
							else
								local target = self.movementInput * self.movementTargetVel
								local speed = self.movementAcceleration
								mo.Vel = Vector((mo.Vel.X + target * TimerMan.DeltaTimeSecs * speed) / (1 + TimerMan.DeltaTimeSecs * speed), mo.Vel.Y)
							end
							
							mo.Vel = mo.Vel + Vector(0, math.sqrt(math.max(factor, 0.01)) * -80 * TimerMan.DeltaTimeSecs) * springStrength * strength
							--mo.Vel = mo.Vel:RadRotate(rayVector.AbsRadAngle * -1)
							if self.Status < Actor.DYING then
								if mo.Vel.Y > 0 then
									mo.Vel = Vector(mo.Vel.X, mo.Vel.Y / (1 + TimerMan.DeltaTimeSecs * 25 * strength))
								else
									mo.Vel = Vector(mo.Vel.X, mo.Vel.Y / (1 + TimerMan.DeltaTimeSecs * 5 * strength))
								end
							end
							
							--mo.Vel = Vector(mo.Vel.X, math.min(mo.Vel.Y, 0))
							--mo.Vel = mo.Vel:RadRotate(rayVector.AbsRadAngle)
							--mo.Pos = mo.Pos + Vector(0, (1 - dif.Magnitude / rayVector.Magnitude) * -5 * TimerMan.DeltaTimeSecs)
						end
						
						if legHoof and toPlay == true then
							local pos = Vector(0, 0);
							SceneMan:CastObstacleRay(legHoof.Pos, Vector(0, 8), pos, Vector(0, 0), self.ID, self.Team, 0, 3);
							PrimitiveMan:DrawLinePrimitive(legHoof.Pos, legHoof.Pos + Vector(0, 8), 5);
							local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
							
							if terrPixel ~= 0 then -- 0 = air
								if self.terrainSounds.HoofStep[terrPixel] ~= nil then
									self.terrainSounds.HoofStep[terrPixel].Volume = 0.5;
									self.terrainSounds.HoofStep[terrPixel]:Play(self.Pos);
								else -- default to concrete
									self.terrainSounds.HoofStep[177].Volume = 0.5;
									self.terrainSounds.HoofStep[177]:Play(self.Pos);
								end
							end
						end
						
						self.walkAnimationAcc = self.walkAnimationAcc + mo.Vel.X * TimerMan.DeltaTimeSecs * 0.07
						if self.walkAnimationAcc > 1 then
							self.walkAnimationAcc = self.walkAnimationAcc - 1
						elseif self.walkAnimationAcc < -1 then
							self.walkAnimationAcc = self.walkAnimationAcc + 1
						end
						
						-- Leg rotation
						local parent = legThigh:GetParent()
						if parent then
							parent = ToAttachable(parent)
							
							local angles = calcIK(thighLength, shinLength, Vector(0.1 + math.max(length - footLength, 1), 0.0))
							if (self.HFlipped and i == 2) or (not self.HFlipped and i == 1) then
								legThigh.InheritedRotAngleOffset = -mo.RotAngle * self.FlipFactor + angles[1] + rayVector.AbsRadAngle * self.FlipFactor + (math.pi * (-self.FlipFactor + 1) * 0.5)
								legShin.InheritedRotAngleOffset = angles[2]
								if legHoof then
									if contact then
										legHoof.InheritedRotAngleOffset = -angles[2] - angles[1]
									else
										legHoof.InheritedRotAngleOffset = -angles[2]
									end
								end
							else
								legThigh.InheritedRotAngleOffset = -self.RotAngle * self.FlipFactor - angles[1] + rayVector.AbsRadAngle * self.FlipFactor + (math.pi * (-self.FlipFactor + 1) * 0.5)
								legShin.InheritedRotAngleOffset = - angles[2]
								if legHoof then
									if contact then
										legHoof.InheritedRotAngleOffset = angles[2] + angles[1]
									else
										legHoof.InheritedRotAngleOffset = 0
									end
								end
							end
							
							--legThigh.Pos = parent.Pos + Vector(legThigh.ParentOffset.X * parent.FlipFactor, legThigh.ParentOffset.Y):RadRotate(parent.RotAngle) - Vector(legThigh.JointOffset.X * parent.FlipFactor, legThigh.JointOffset.Y):RadRotate(legThigh.RotAngle)
							--legShin.Pos = legThigh.Pos + Vector(legShin.ParentOffset.X * legThigh.FlipFactor, legShin.ParentOffset.Y):RadRotate(legThigh.RotAngle) - Vector(legShin.JointOffset.X * legThigh.FlipFactor, legShin.JointOffset.Y):RadRotate(legShin.RotAngle)
							--if legHoof then
							--	legHoof.Pos = legShin.Pos + Vector(legHoof.ParentOffset.X * legShin.FlipFactor, legHoof.ParentOffset.Y):RadRotate(legShin.RotAngle) - Vector(legHoof.JointOffset.X * legShin.FlipFactor, legHoof.JointOffset.Y):RadRotate(legHoof.RotAngle)
							--end
						end
					end
				end
				
				local dif = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX)
				pointVectors[i] = dif
				
				self.effectiveVel = mo.Vel;
				
				-- Debug
				--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + dif, 5);
				--PrimitiveMan:DrawCirclePrimitive(mo.Pos, mo.Radius, 5);
			end
		end
	end
	
	-- Adjust torso according to the simulation point's positions
	local previousPos = Vector(self.Pos.X, self.Pos.Y)
	local posDifference
	
	local center = pointPositions[1] + SceneMan:ShortestDistance(pointPositions[1], pointPositions[2], SceneMan.SceneWrapsX) * 0.5
	self.Pos = center
	
	self.jingleSound.Pos = self.Pos;
	self.creakSound.Pos = self.Pos;
	if self.Moving then
		if true then -- TODO!! different ranges and behaviour for the 4 gaits
			if self.effectiveVel.Magnitude > 0 then
				self.jingleSound.Volume = math.max(0, math.min(0.2, self.effectiveVel.Magnitude / 4 - 0.8))
			end
		end
	else
		if self.jingleSound.Volume > 0 then
			self.jingleSound.Volume = self.jingleSound.Volume - 0.5 * TimerMan.DeltaTimeSecs;
			if self.jingleSound.Volume < 0 then
				self.jingleSound.Volume = 0
			end
		end
		if self.creakSound.Volume > 0 then
			self.creakSound.Volume = self.creakSound.Volume - 0.5 * TimerMan.DeltaTimeSecs;
			if self.creakSound.Volume < 0 then
				self.creakSound.Volume = 0
			end
		end
	end	
	
	self.Vel = Vector(0,0)
	
	if SceneMan.SceneWrapsX then
		if self.Pos.X > SceneMan.SceneWidth then
			self.Pos.X = self.Pos.X - SceneMan.SceneWidth
		elseif self.Pos.X < 0 then
			self.Pos.X = self.Pos.X + SceneMan.SceneWidth
		end
	end
	
	posDifference = SceneMan:ShortestDistance(previousPos, self.Pos, SceneMan.SceneWrapsX)
	
	for i, mo in ipairs(pointMOs) do
		
		local dif = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX)
		pointVectors[i] = dif
		
		mo.RotAngle = dif.AbsRadAngle + math.pi * (1 - (i - 1))
		
		local value = mo.RotAngle
		local ret = (value + math.pi) % (math.pi * 2);
		if ret < 0 then ret = ret + (math.pi * 2) end
		local result = ret - math.pi;
		
		mo.RotAngle = result * 0.5
		
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
	
	local angleA = (pointVectors[1] + Vector(0, 1)).AbsRadAngle
	local angleB = (pointVectors[2] + Vector(0, 1)).AbsRadAngle 
	
	local value = angleB - angleA
	local ret = (value + math.pi) % (math.pi * 2);
	if ret < 0 then ret = ret + (math.pi * 2) end
	local result = ret - math.pi;
	
	local angleFinal = angleB - result * 0.5
	
	self.RotAngle = angleFinal + math.pi * 0.5
	
	-- Body parts
	local attachable
	local butt
	local front
	
	-- Butt
	attachable = MovableMan:FindObjectByUniqueID(self:GetNumberValue("Horse Torso Butt"))
	if attachable then
		attachable = ToAttachable(attachable)
		butt = attachable
		local i = self.HFlipped and 2 or 1
		
		--local offset = posDifference:RadRotate(-self.RotAngle)
		attachable.InheritedRotAngleOffset = (pointMOs[i] and ((pointMOs[i].RotAngle - self.RotAngle) * self.FlipFactor) or 0)
		--attachable.ParentOffset = Vector(offset.X * self.FlipFactor, offset.Y) + Vector(attachable:GetNumberValue("ParentOffsetX"), attachable:GetNumberValue("ParentOffsetY"))
		--attachable.ParentOffset = Vector(attachable:GetNumberValue("ParentOffsetX"), attachable:GetNumberValue("ParentOffsetY"))
		
		attachable.Pos = self.Pos + Vector(attachable.ParentOffset.X * self.FlipFactor, attachable.ParentOffset.Y):RadRotate(self.RotAngle) - Vector(attachable.JointOffset.X * self.FlipFactor, attachable.JointOffset.Y):RadRotate(attachable.RotAngle)
	else
		self.Health = self.Health - 100
	end
	
	-- Front
	attachable = MovableMan:FindObjectByUniqueID(self:GetNumberValue("Horse Torso Front"))
	if attachable then
		attachable = ToAttachable(attachable)
		front = attachable
		local i = self.HFlipped and 1 or 2
		
		--local offset = posDifference:RadRotate(-self.RotAngle)
		attachable.InheritedRotAngleOffset = (pointMOs[i] and ((self.RotAngle - pointMOs[i].RotAngle) * self.FlipFactor) or 0)
		--attachable.ParentOffset = Vector(offset.X * self.FlipFactor, offset.Y) + Vector(attachable:GetNumberValue("ParentOffsetX"), attachable:GetNumberValue("ParentOffsetY"))
		--attachable.ParentOffset = Vector(attachable:GetNumberValue("ParentOffsetX"), attachable:GetNumberValue("ParentOffsetY"))
		
		attachable.Pos = self.Pos + Vector(attachable.ParentOffset.X * self.FlipFactor, attachable.ParentOffset.Y):RadRotate(self.RotAngle) - Vector(attachable.JointOffset.X * self.FlipFactor, attachable.JointOffset.Y):RadRotate(attachable.RotAngle)
		
		-- Neck
		local subAttachable = MovableMan:FindObjectByUniqueID(self:GetNumberValue("Horse Neck"))
		if subAttachable then
			subAttachable = ToAttachable(subAttachable)
			
			local velFactor = (0.3 + 3.0 * math.min(math.abs(self.Vel.X / 7), 1.0))
			
			local time = (self.Age / 2000) * math.pi
			local sinA = math.sin(time + self.UniqueID * 1.15) * 0.07
			local sinB = math.sin(time * 0.5 + self.UniqueID * 1.55) * 0.045
			local sinC = math.sin(time * 0.25 + self.UniqueID * 0.25) * 0.04
			local sinD = math.sin(time * 1.75 + self.UniqueID * 0.15) * 0.01
			local angle = 2 * (sinA + sinB + sinC + sinD) * velFactor
			
			subAttachable.InheritedRotAngleOffset = -attachable.InheritedRotAngleOffset - math.abs(angle)
			
			subAttachable.Pos = attachable.Pos + Vector(subAttachable.ParentOffset.X * self.FlipFactor, subAttachable.ParentOffset.Y):RadRotate(attachable.RotAngle) - Vector(subAttachable.JointOffset.X * self.FlipFactor, subAttachable.JointOffset.Y):RadRotate(subAttachable.RotAngle)
			
			if self.MOToNotHit then
				if MovableMan:ValidMO(self.MOToNotHit) then
					self:SetWhichMOToNotHit(self.MOToNotHit, -1)
				end
			end	
			
			-- Head
			self.head = MovableMan:FindObjectByUniqueID(self:GetNumberValue("Horse Head"))
			if self.head then
				self.head = ToAttachable(self.head)
						
				local time = (self.Age / 3000) * math.pi
				local sinA = math.sin(time + self.UniqueID * 0.2) * 0.06
				local sinB = math.sin(time * 0.5 + self.UniqueID * 0.5) * 0.05
				local sinC = math.sin(time * 0.25 + self.UniqueID * 1) * 0.035
				local sinD = math.sin(time * 1.75 + self.UniqueID * 2.5) * 0.015
				local angle = 2 * (sinA + sinB + sinC + sinD) * velFactor
				
				self.head.InheritedRotAngleOffset = subAttachable.InheritedRotAngleOffset + angle
				
				self.head.Pos = subAttachable.Pos + Vector(self.head.ParentOffset.X * self.FlipFactor, self.head.ParentOffset.Y):RadRotate(subAttachable.RotAngle) - Vector(self.head.JointOffset.X * self.FlipFactor, self.head.JointOffset.Y):RadRotate(self.head.RotAngle)
				
				if self.head.HitWhatMOID ~= 255 then
					local id = self.head.HitWhatMOID
					self.MOToNotHit = MovableMan:GetMOFromID(id);
				end
				
				if self.MOToNotHit then
					if MovableMan:ValidMO(self.MOToNotHit) then
						self:SetWhichMOToNotHit(self.MOToNotHit, -1)
					end
				end
				
			end
		end
	else
		self.Health = self.Health - 100
	end
	
	self.MOToNotHit = nil;
	
	-- Legs
	for i = 1, 2 do
		local parent = (i == (self.HFlipped and 2 or 1) and butt or front)
		if parent then
			for j = 1, 2 do
				previousPart = parent
				for h = 1, 3 do
					local part = legMOs[i][j][h]
					if part and previousPart then
						part.Pos = previousPart.Pos + Vector(part.ParentOffset.X * self.FlipFactor, part.ParentOffset.Y):RadRotate(previousPart.RotAngle) - Vector(part.JointOffset.X * self.FlipFactor, part.JointOffset.Y):RadRotate(part.RotAngle)
						--part.ParentOffset = Vector(part:GetNumberValue("ParentOffsetX"), part:GetNumberValue("ParentOffsetY")) + posDifference:RadRotate(-previousPart.RotAngle)
					end
					previousPart = part
				end
			end
		end
	end
	
	if self.toGibMO then
		local mo = MovableMan:FindObjectByUniqueID(self.toGibMO)
		if mo and IsMOSRotating(mo) then
			ToMOSRotating(mo):GibThis()
		end
	end
	
	self.voiceSound.Pos = self.Pos;
	
	if self.Status < Actor.DYING then
		
		HorseAIBehaviours.handleMovement(self);
		
		HorseAIBehaviours.handleHealth(self);
		
		HorseAIBehaviours.handleSuppression(self);
		
		HorseAIBehaviours.handleVoicelines(self);
		
		--HorseAIBehaviours.handleHeadFrames(self);

	else
	
		HorseAIBehaviours.handleDying(self);
	
		HorseAIBehaviours.handleHeadLoss(self);
	
		HorseAIBehaviours.handleMovement(self);
		
	end
	
end

function OnCollideWithTerrain(self, terrainID)

	if self.death and self.deathFallSoundPlayed ~= true then
		self.deathFallSoundPlayed = true;
		self.deathFallSound:Play(self.Pos);
	end

end

function OnCollideWithMO(self, collidedMO, collidedRootMO)
	--self.toGibMO = collidedMO.UniqueID
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
	
	if not self.ToSettle then -- we have been gibbed
		self.voiceSound:Stop(-1);		
	end	
	
	self.jingleSound:Stop(-1);	
	self.creakSound:Stop(-1);
	
end
