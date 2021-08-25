------ Thanks to Zeta for that amazing hovercraft Bike. thanks to Just Alex for the modified former  -------
------ Modified script of the turret --------

function Create(self)
	
	self.optimizationTimer = Timer();
	self.optimizationDelay = 10
	
	self.IsPlayer = ActivityMan:GetActivity():IsHumanTeam(self.Team)
	
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
							if (actor:IsPlayerControlled() and UInputMan:KeyPressed(6)
							or (not actor:IsPlayerControlled() and actor.AIMode == Actor.AIMODE_SENTRY))
							and not (actor:NumberValueExists("Mordhau Disable Movement")) then	--F to mount
								self.rider = ToAHuman(actor);		
								self.rider.AIMode = 1
								self.HUDVisible = false
								self.AIMode = 1
								self:SetControllerMode(2 , self:GetController().Player)
								
								local riderHandler = CreateAttachable("Rider Handler", "Mordhau.rte");
								actor:AddAttachable(riderHandler);
								riderHandler:SetNumberValue("Horse ID", self.UniqueID);
								actor:SetNumberValue("Mordhau Disable Movement", 0);
								
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
			self.rider:RemoveNumberValue("Mordhau Riding Horse");
			
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
	
		local ctrl = self:GetController();
		local riderCtrl = self.rider:GetController();
	
		if self.IsPlayer and self and self:IsPlayerControlled() then
			local switcher = ActivityMan:GetActivity()
			switcher:SwitchToActor(self.rider, self:GetController().Player, self.Team)
		end
	
		ctrl:SetState(Controller.MOVE_RIGHT, false);
		ctrl:SetState(Controller.MOVE_LEFT, false);
		ctrl:SetState(Controller.MOVE_UP, false);
		ctrl:SetState(Controller.MOVE_DOWN, false);
		ctrl:SetState(Controller.BODY_JUMPSTART, false);
		ctrl:SetState(Controller.BODY_JUMP, false);
		ctrl:SetState(Controller.BODY_CROUCH, false);
		
		if riderCtrl:IsState(Controller.MOVE_RIGHT) then
			ctrl:SetState(Controller.MOVE_RIGHT, true);
			self.movingRight = true;
		else
			ctrl:SetState(Controller.MOVE_RIGHT, false);
			self.movingRight = false;
		end
		
		if riderCtrl:IsState(Controller.MOVE_LEFT) then
			ctrl:SetState(Controller.MOVE_LEFT, true);
			self.movingLeft = true;
		else
			ctrl:SetState(Controller.MOVE_LEFT, false);
			self.movingLeft = false;
		end
		
		if riderCtrl:IsState(Controller.BODY_JUMPSTART) then
			ctrl:SetState(Controller.BODY_JUMPSTART, true);
			self.Jumping = true;
		else
			ctrl:SetState(Controller.BODY_JUMPSTART, false);
			self.Jumping = false;
		end
	
		riderCtrl:SetState(Controller.MOVE_RIGHT, false);
		riderCtrl:SetState(Controller.MOVE_LEFT, false);
		riderCtrl:SetState(Controller.MOVE_UP, false);
		riderCtrl:SetState(Controller.MOVE_DOWN, false);
		riderCtrl:SetState(Controller.BODY_JUMPSTART, false);
		riderCtrl:SetState(Controller.BODY_JUMP, false);
		riderCtrl:SetState(Controller.BODY_CROUCH, false);
		
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
			self.rider:RemoveNumberValue("Mordhau Disable Movement");
			
			if self.IsPlayer and self and self:IsPlayerControlled() then
				local switcher = ActivityMan:GetActivity()
				switcher:SwitchToActor(self.rider, self:GetController().Player, self.Team)
			end			
			
			self.rider = nil
		elseif (self.rider:IsPlayerControlled() and UInputMan:KeyPressed(8)) then
			
			self.rider.AIMode = 1
			self.rider:SetControllerMode(2 , self.rider:GetController().Player)	
			self.rider.HUDVisible = true
			self.rider:RemoveNumberValue("Mordhau Disable Movement");
			
			if self.IsPlayer and self and self:IsPlayerControlled() then
				local switcher = ActivityMan:GetActivity()
				switcher:SwitchToActor(self.rider, self:GetController().Player, self.Team)
			end			

			self.rider = nil
		end

		--------------- HUD Part, should make this more user friednly in create but oh well --------------------------

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
		self.rider:RemoveNumberValue("Mordhau Disable Movement");
	
		if self.IsPlayer and self and self:IsPlayerControlled() then
			local switcher = ActivityMan:GetActivity()
			switcher:SwitchToActor(self.rider, self:GetController().Player, self.Team)
		end
		
		self.rider = nil
	end
end