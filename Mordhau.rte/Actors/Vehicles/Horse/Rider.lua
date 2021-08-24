------ Thanks to Zeta for that amazing hovercraft Bike. thanks to Just Alex for the modified former  -------
------ Modified script of the turret --------

function Create(self)
	
	self.optimizationTimer = Timer();
	self.optimizationDelay = 10
	
	self.rider = nil;

end

function Update(self)
		
	if (self.rider == nil or not MovableMan:IsActor(self.rider)) then

		if self:IsPlayerControlled() then
			local ctrl = self:GetController();
			local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);	
			
			PrimitiveMan:DrawTextPrimitive(screen, self.AboveHUDPos + Vector(0, -25), "CANNOT CONTROL LONE HORSE!", true, 0);	
		end

		if self.optimizationTimer:IsPastSimMS(self.optimizationDelay) then
			self.optimizationTimer:Reset();
			for actor in MovableMan.Actors do 
				if actor.Team == self.Team and SceneMan:ShortestDistance(actor.Pos, self.Pos, SceneMan.SceneWrapsX).Magnitude < 30 and actor.Vel.Magnitude < 10 and actor.Status == 0 then
					if IsAHuman(actor) then
						if not (math.abs(self.AngularVel) > 7 or math.abs(self.RotAngle) > 0.8 or not MovableMan:IsActor(self) or self.Health <= 0) then
							if (actor:IsPlayerControlled() and UInputMan:KeyPressed(6)) or (not actor:IsPlayerControlled() and actor.AIMode == Actor.AIMODE_SENTRY) then	--F to mount
								self.rider = ToAHuman(actor);		
								self.rider.AIMode = 1
								self.HUDVisible = false
								self.AIMode = 1
								self:SetControllerMode(2 , self:GetController().Player)
								self.rider.PinStrength = 54;
								
								self.mountInProcess = true;								
								-- get rider's pos relative to us so we ease between it and final pos for a mounting ""animation""
								self.relativeMountPos = SceneMan:ShortestDistance(self.Pos, self.rider.Pos, SceneMan.SceneWrapsX);
								self.relativeMountMagnitude = 1;
								
								
							end
						end
					end
				end
			end
		end
		
			
	elseif self:IsDead() then
		if self.rider then				
			self.rider.AIMode = 1
			self.rider.Status = 1;
			self.rider:SetControllerMode(2 , self.rider:GetController().Player)	
			self.rider.HUDVisible = true
			self.rider.PinStrength = 0;
			
			-- if self.IsPlayer and self and self:IsPlayerControlled() then
				-- local switcher = ActivityMan:GetActivity()
				-- switcher:SwitchToActor(self.rider, self:GetController().Player, self.Team)
			-- end
			
			self.rider = nil;
		end	
	
	elseif self.mountInProcess == true then
		
		self.rider.Vel = self.Vel;
		local value = 1 * TimerMan.DeltaTimeSecs;
		self.relativeMountMagnitude = self.relativeMountMagnitude - value;
		local mountPos = Vector(self.relativeMountPos.X, self.relativeMountPos.Y):SetMagnitude(self.relativeMountPos.Magnitude * self.relativeMountMagnitude)
		self.rider.Pos = (self.Pos + Vector(0*self.FlipFactor,-10):RadRotate(self.RotAngle)) + mountPos
		self.rider.HFlipped = self.HFlipped;
		
		if self.relativeMountMagnitude <= 0 then
			self.mountInProcess = false;
		end
		
	elseif self.rider then			--We have rider
	
		self.rider:GetController():SetState(Controller.MOVE_RIGHT, false);
		self.rider:GetController():SetState(Controller.MOVE_LEFT, false);
		self.rider:GetController():SetState(Controller.MOVE_UP, false);
		self.rider:GetController():SetState(Controller.MOVE_DOWN, false);
		self.rider:GetController():SetState(Controller.BODY_JUMPSTART, false);
		self.rider:GetController():SetState(Controller.BODY_JUMP, false);
		self.rider:GetController():SetState(Controller.BODY_CROUCH, false);

		-- if self.IsPlayer and self.rider:IsPlayerControlled() then
			-- local switcher = ActivityMan:GetActivity()
			-- switcher:SwitchToActor(self, self.rider:GetController().Player, self.Team)
		-- end		

		-- if self.rider:GetController().InputMode ~= Controller.CIM_DISABLED then
			-- self.rider:SetControllerMode(Controller.CIM_DISABLED , self.rider:GetController().Player);
			-- self.rider.AIMode = Actor.AIMODE_NONE;
		-- end

		
		--Set rider pos and vel so it moves with the turret
		
		self.rider.Vel = self.Vel;
		self.rider.Pos = self.Pos + Vector(0*self.FlipFactor,-10):RadRotate(self.RotAngle)					
		self.rider.HFlipped = self.HFlipped;				

		if self.rider.Status ~= 0 then						
			self.rider.AIMode = 1
			self.rider:SetControllerMode(2 , self.rider:GetController().Player)	
			self.rider.HUDVisible = true
			self.rider.PinStrength = 0;
			self.rider = nil
		elseif (self.rider:IsPlayerControlled() and UInputMan:KeyPressed(8)) then
			
			self.rider.AIMode = 1
			self.rider:SetControllerMode(2 , self.rider:GetController().Player)	
			self.rider.HUDVisible = true
			self.rider.PinStrength = 0;

			self.rider = nil
		end

		--------------- HUD Part, should make this more user friednly in create but oh well --------------------------

		local ctrl = self:GetController();
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);	
		
		-- local riderFrame = (math.abs(self.AngularVel) > 7 or math.abs(self.RotAngle) > 0.8) and 5 or self.rider and (self.Team + 1) or 0
		-- local riderIcon = CreateMOSRotating("rider HUD Icon", "Mordhau.rte");
		-- local riderIconPos = self.crewSize > 1 and self.Pos + Vector(-6, -32) or self.Pos + Vector(0, -32)
			
		-- PrimitiveMan:DrawBitmapPrimitive(screen, riderIconPos, riderIcon, 3.14, riderFrame, true, true);
		
	end	
		
end

function Destroy(self)

	if self.rider then
		self.rider.AIMode = 1
		self.rider:SetControllerMode(2 , self.rider:GetController().Player)
		self.rider.HUDVisible = true
		self.rider.PinStrength = 0;
	
		if self.IsPlayer and self and self:IsPlayerControlled() then
			local switcher = ActivityMan:GetActivity()
			switcher:SwitchToActor(self.rider, self:GetController().Player, self.Team)
		end
		
		self.rider = nil
	end
end