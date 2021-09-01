--require("AI/NativeHumanAI")   -- or NativeCrabAI or NativeTurretAI

function CheckTerrain(self, direction)
	local rayOrigin = self.Pos + Vector(2 * direction, 2)
	local rayVector = Vector(13 * direction, 24) * 1.5
	
	if self.AI.debug then
		PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVector, 162);
	end
	
	return SceneMan:CastStrengthRay(rayOrigin, rayVector, 30, Vector(), 4, 0, SceneMan.SceneWrapsX);
end

function Sign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end

function Create(self)
	
	self.AI = {}
	self.AI.debug = true
	
	--"Mordhau.rte/Actors/Shared/Scripts/MeleeAI.lua"
	
	MovableMan:ChangeActorTeam(self, 2)
	
	-- States:
	self.AI.state = 0
	
	--self.AI.wanderTimer = Timer()
	--self.AI.wanderDelayMin = 1000
	--self.AI.wanderDelayMax = 3000
	--self.AI.wanderDelay = math.random(self.AI.wanderDelayMin, self.AI.wanderDelayMax)
	
	self.AI.radar = AIRadar.Create({position = self.Pos, rotation = 0, arc = math.rad(120), distance = 600, steps = 1, stepDeg = 5, team = self.Team})
	
	self.AI.target = nil
	self.AI.targetForgetTimer = Timer()
	self.AI.targetForgetDelay = 2000
	
	self.AI.alarmPos = nil
	self.AI.alarmTimer = nil
	self.AI.alarmDuration = 1000
	
	self.AI.calculateShapeTimer = Timer()
	self.AI.calculateShapeDelay = 300
	self.AI.targetShape = nil
	
	self.AI.lookDirection = 0
	
	self.AI.skill = 1
	
end

function UpdateAI(self)
	if self.Status >= Actor.DYING or not self.Head then
		return
	end
	
	local ctrl = (self.controller and self.controller or self:GetController())
	
	ctrl:SetState(Controller.MOVE_LEFT, true)
	ctrl:SetState(Controller.AIM_SHARP, true)
	self:SetAimAngle(0)
	self.HFlipped = false
	
	-- Misc
	local movementInput = 0
	
	ctrl:SetState(Controller.BODY_CROUCH, false)
	
	-- -- Radar logic
	-- AIRadar.SetTransform(self.AI.radar, self.Head.Pos, self.Head.RotAngle, self.HFlipped)
	-- if self:NumberValueExists("Set Target") and self:GetNumberValue("Set Target") ~= -1 then
		-- self.AI.target = self:GetNumberValue("Set Target")
		-- self:RemoveNumberValue("Set Target")
	-- end
	
	-- local forceSetHFlipped
	-- if self.AI.target then
		-- self:SetNumberValue("Group Alert Target Found", -1)
		-- self.AI.state = -1
		
		-- local target = MovableMan:FindObjectByUniqueID(self.AI.target)
		-- if target then
			-- local dif = SceneMan:ShortestDistance(self.Pos, target.Pos, SceneMan.SceneWrapsX)
			
			-- -- Check if visible
			-- if not self.AI.targetShape or self.AI.calculateShapeTimer:IsPastSimMS(self.AI.calculateShapeDelay) then
				-- self.AI.targetShape = AIRadar.CalculateActorVisibilityShape(self.Head.Pos, target)
				-- self.AI.calculateShapeTimer:Reset()
			-- end
	
			-- local shape = self.AI.targetShape
			-- if shape and math.random() < 0.5 then
				-- local angle = shape[1]
				-- local radius = shape[2]
				-- local center = target.Pos + shape[3]
				-- --PrimitiveMan:DrawCirclePrimitive(center, radius, 13)
				
				-- local rayOrigin = self.Head.Pos
				-- local rayPos = center + Vector(0, radius * RangeRand(-1,1)):RadRotate(angle)
				-- local rayVec = SceneMan:ShortestDistance(rayOrigin, rayPos, SceneMan.SceneWrapsX)
				
				-- local terrCheck = SceneMan:CastStrengthRay(rayOrigin, rayVec, 30, Vector(), math.random(6,8), 0, SceneMan.SceneWrapsX);
				-- if terrCheck == false then
					-- self.AI.targetForgetTimer:Reset()
				-- end
				-- if self.AI.debug then
					-- PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec, 122);
				-- end
			-- end
			-- --PrimitiveMan:DrawBoxPrimitive(target.Pos + cornerA, target.Pos + cornerB, 13)
			
			-- if self.AI.debug then
				-- PrimitiveMan:DrawCirclePrimitive(self.Pos, 5, 13)
				-- PrimitiveMan:DrawCircleFillPrimitive(target.Pos, 2, 13)
				
				-- PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + dif, 13);
			-- end
			
			-- -- ATTACK!
			-- --self.HFlipped = dif.X < 0
			-- forceSetHFlipped = dif.X < 0
			
			-- self.AI.lookDirection = dif.AbsRadAngle
			-- if self.HFlipped then
				-- self.AI.lookDirection = -self.AI.lookDirection + math.pi
			-- end
			
			-- -- Move
			-- if math.abs(dif.X) > 60 then
				-- movementInput = Sign(dif.X)
			-- else
				-- movementInput = -Sign(dif.X)
			-- end
			-- --[[
			-- if dif.X > 0 then
				-- movementInput = 1
			-- elseif dif.X < 0 then
				-- movementInput = -1
			-- end]]
			
			-- if dif.Magnitude < 85 + math.random(-5,40) then
				-- ctrl:SetState(Controller.WEAPON_FIRE, true)
			-- end
			
			-- if self.AI.targetForgetTimer:IsPastSimMS(self.AI.targetForgetDelay) then
				-- self.AI.target = nil
			-- end
		-- else
			-- self.AI.target = nil
		-- end
	-- else
		
		-- AIRadar.Update(self.AI.radar)
		-- --[[
		-- if self.AI.wanderTimer:IsPastSimMS(self.AI.wanderDelay) then
			-- self.AI.wanderDelay = math.random(self.AI.wanderDelayMin, self.AI.wanderDelayMax)
			-- self.AI.wanderTimer:Reset()
			
			-- self.AI.state = math.random(0,1)
			
			-- self.HFlipped = math.random(0,1) < 1
		-- end]]
		
		-- --if self.AI.state == 0 then
			-- -- Stand still
		-- --elseif self.AI.state == 1 then
		-- if self.AI.state == 1 then
			-- -- Move Around
			-- movementInput = self.FlipFactor
		-- end
		
		-- self.AI.lookDirection = 0
		
		-- local targets = AIRadar.GetDetectedActorsThisFrame(self.AI.radar) -- Get actors
		-- if targets and #targets > 0 then
			-- local target = targets[math.random(1, #targets)] -- Pick random
			-- if target and target.ClassName ~= "ADoor" then
				-- self.AI.target = target.UniqueID
				-- self.AI.targetShape = nil
				
				-- -- Call others!
				-- -- local call = false
				-- for actor in MovableMan.Actors do
					-- if actor.Team == self.Team then
						-- local dif = SceneMan:ShortestDistance(self.Pos, actor.Pos, true);
						-- if dif.Magnitude < 800 then
							-- local terrainCheck = SceneMan:CastStrengthRay(self.Pos, dif, 50, Vector(), 4, 0, SceneMan.SceneWrapsX)
							-- if not terrainCheck then
								-- actor:SetNumberValue("Group Alert Target Found", self.AI.target)
								-- -- call = true
							-- else
								-- if IsAHuman(actor) and ToAHuman(actor).Head then -- if it is a human check for head
									-- dif = SceneMan:ShortestDistance(self.Pos, ToAHuman(actor).Head.Pos, true);
									
									-- terrainCheck = SceneMan:CastStrengthRay(self.Pos, dif, 50, Vector(), 4, 0, SceneMan.SceneWrapsX)
									-- if not terrainCheck then		
										-- actor:SetNumberValue("Group Alert Target Found", self.AI.target)
										-- -- call = true
									-- end
								-- end
								
							-- end
						-- end
					-- end
				-- end
				
				-- -- if call then -- YAHH
					-- -- self.soundDeath.Pitch = 1.2
					-- -- self.soundDeath:Play(self.Pos)
				-- -- end
			-- end
			
			-- self.AI.targetForgetTimer:Reset()
		-- end
		
		-- if not self.AI.target then
			-- if self:NumberValueExists("Group Alert Target Found") and self:GetNumberValue("Group Alert Target Found") ~= -1 then
				-- self.AI.target = self:GetNumberValue("Group Alert Target Found")
				-- self.AI.targetShape = nil
				-- self:SetNumberValue("Group Alert Target Found", -1)
				
				-- -- self.soundHurt.Pitch = 1.2
				-- -- self.soundHurt:Play(self.Pos)
			-- end
		-- end
		
		-- -- Debug
		-- if self.AI.debug then
			-- AIRadar.DrawDebugVisualization(self.AI.radar)
		-- end
	-- end
	-- --
	
	-- -- Alarm logic
	-- local alarmPos = self:GetAlarmPoint()
	-- if not alarmPos:IsZero() then
		-- self.AI.alarmPos = Vector(alarmPos.X, alarmPos.Y)
		-- self.AI.alarmTimer = Timer()
		
		-- local dif = SceneMan:ShortestDistance(self.Pos, self.AI.alarmPos, SceneMan.SceneWrapsX)
		-- if dif.X > 0 then
			-- movementInput = 1
		-- elseif dif.X < 0 then
			-- movementInput = -1
		-- end
	-- end
	
	-- if self.AI.alarmPos and self.AI.alarmTimer then
		-- local dif = SceneMan:ShortestDistance(self.Pos, self.AI.alarmPos, SceneMan.SceneWrapsX)
		
		-- self.HFlipped = dif.X < 0
		
		-- self.AI.lookDirection = dif.AbsRadAngle
		-- if self.HFlipped then
			-- self.AI.lookDirection = -self.AI.lookDirection + math.pi
		-- end
		
		-- if self.AI.debug then
			-- PrimitiveMan:DrawCirclePrimitive(self.Pos, 5, 86)
			-- PrimitiveMan:DrawCircleFillPrimitive(self.AI.alarmPos, 2, 86)
			
			-- PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + SceneMan:ShortestDistance(self.Pos, self.AI.alarmPos, SceneMan.SceneWrapsX), 86);
		-- end
		
		-- if self.AI.alarmTimer:IsPastSimMS(self.AI.alarmDuration) then
			-- self.AI.alarmPos = nil
			-- self.AI.alarmTimer = nil
		-- end
	-- end
	-- --
	
	-- -- Movement
	-- if movementInput ~= 0 then
		
		-- if self.FlipFactor ~= movementInput then
			-- self.HFlipped = true
		-- end
		
		-- if CheckTerrain(self, movementInput) then
			-- if movementInput == 1 then
				-- ctrl:SetState(Controller.MOVE_RIGHT, true)
			-- elseif movementInput == -1 then
				-- ctrl:SetState(Controller.MOVE_LEFT, true)
			-- end
		-- end
		
	-- end
	
	-- if forceSetHFlipped then
		-- self.HFlipped = forceSetHFlipped
	-- end
	
	-- Look around
	local sway = math.sin(self.Age * 0.01 + self.UniqueID) * 0.05 + math.sin(self.Age * 0.002 + 2) * 0.1 + math.sin(self.Age * 0.015 - 3 - self.UniqueID) * 0.05 + math.sin(self.Age * 0.005 + 6) * 0.075 * 0.05 + math.sin(self.Age * 0.001 + 15 + self.UniqueID) * 0.3
	local factor = self.AI.lookDirection + sway * (1 - self.AI.skill)
	self:SetAimAngle(math.pi * 0.5 * factor)
	
end