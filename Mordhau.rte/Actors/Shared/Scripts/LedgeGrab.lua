
function LedgeCheck(self)
	local origin = self.Pos
	local offset = Vector(self.FlipFactor * self.Radius * 0.45, -1)--:RadRotate(self.RotAngle)
	
	local checks = 0
	local maxi = 14
	for i = 1, maxi do
		local point = origin + offset
		local checkPix = SceneMan:GetTerrMatter(point.X, point.Y)
		
		if checkPix == 0 then
			--PrimitiveMan:DrawCirclePrimitive(point, 1, 13);
			PrimitiveMan:DrawLinePrimitive(point, point, 13);
			break
		else
			--PrimitiveMan:DrawCirclePrimitive(point, 1, 5);
			PrimitiveMan:DrawLinePrimitive(point, point, 5);
			checks = checks + 1
			self.ledgeGrabPos = Vector(point.X, point.Y)
		end
		
		offset = offset + Vector(0, -2)
	end
	
	if self.ledgeGrabPos and checks > 0 and checks < maxi then
		-- TODO: do something ????
	else
		self.ledgeGrabPos = nil
	end
	
	--self.FGArm.IdleOffset
	
	--PrimitiveMan:DrawLinePrimitive(posA, posB, 5);
	--PrimitiveMan:DrawLinePrimitive(origin + offset, posB, 5);
	--PrimitiveMan:DrawCirclePrimitive(origin + offset, 1, 5);
end

function Create(self)
	self.ledgeGrabPos = nil
	self.ledgeGrabbed = false
	self.ledgeGrabPullTimer = Timer()
	self.ledgeGrabPullDuration = 700
	
	self.ledgeGrabLastPos = Vector()
	self.ledgeGrabAim = Vector(1,0)
	self.ledgeGrabOriginalPos = Vector()
	self.ledgeGrabOriginalRotAngle = 0
end

function Update(self)
	if self.controller and self.FGArm and self.BGArm then
		if self.controller:IsState(Controller.MOVE_UP) then
			if not self.ledgeGrabbed then
				LedgeCheck(self)
				if self.ledgeGrabPos then
					self.ledgeGrabbed = true
					self.ledgeGrabPullTimer:Reset()
					self.ledgeGrabOriginalPos = Vector(self.Pos.X, self.Pos.Y)
					self.ledgeGrabLastPos = Vector(self.Pos.X, self.Pos.Y)
					
					self.ledgeGrabOriginalRotAngle = self.RotAngle
					
					self.ledgeGrabAim = self.controller.AnalogAim
					
					if self.Status < 1 then
						self.Status = 1
					end
				end
			end
			if self.ledgeGrabPos then
				PrimitiveMan:DrawCirclePrimitive(self.ledgeGrabPos, 3, 5);
			else
				LedgeCheck(self)
			end
		--else
		--	self.ledgeGrabPos = nil
		end
		
		if self.ledgeGrabbed then
			self.controller:SetState(Controller.MOVE_UP, false)
			self.controller:SetState(Controller.MOVE_RIGHT, false)
			self.controller:SetState(Controller.MOVE_LEFT, false)
			
			self.controller.AnalogAim = self.ledgeGrabAim
			
			local factor = self.ledgeGrabPullTimer.ElapsedSimTimeMS / self.ledgeGrabPullDuration
			--factor = math.pow(factor, 2.0)
			
			self.ledgeGrabLastPos = Vector(self.Pos.X, self.Pos.Y)
			self.Pos = self.ledgeGrabPos + SceneMan:ShortestDistance(self.ledgeGrabPos, self.ledgeGrabOriginalPos, SceneMan.SceneWrapsX):RadRotate(-math.rad(135) * self.FlipFactor * factor) * (0.5 + (1 - math.sin(factor * math.pi))) / 1.5
			self.Vel = Vector(0, 0)
			self.RotAngle = -math.rad(75) * self.FlipFactor * (factor * 0.5 + math.sin(factor * math.pi)) * 0.66
			
			--self.FGArm.IdleOffset = SceneMan:ShortestDistance(self.Pos, self.ledgeGrabPos, SceneMan.SceneWrapsX):RadRotate(-self.RotAngle)
			--self.BGArm.IdleOffset = SceneMan:ShortestDistance(self.Pos, self.ledgeGrabPos, SceneMan.SceneWrapsX):RadRotate(-self.RotAngle)
			
			if self.ledgeGrabPullTimer:IsPastSimMS(self.ledgeGrabPullDuration) then
				self.ledgeGrabbed = false
				self.ledgeGrabPos = nil
				
				if self.Status < 2 then
					self.Status = 0
				end
				
				self.Vel = SceneMan:ShortestDistance(self.ledgeGrabLastPos, self.Pos, SceneMan.SceneWrapsX) / TimerMan.DeltaTimeSecs * 0.02
			end
		end
	end
end