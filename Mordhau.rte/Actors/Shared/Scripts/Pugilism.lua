
function Create(self)
	--self.pugilism = {}
	self.pugilismArmFG = {
		targetOffset = Vector(0, 0),
		position = Vector(self.Pos.X ,self.Pos.Y),
		strengths = {1.5, 2.0, 3.0, 2.5},
		strengthBase = 60.0,
		velocity = Vector(0, 0),
		originalParentOffset = Vector(self.FGArm.ParentOffset.X, self.FGArm.ParentOffset.Y)
	}
	self.pugilismArmBG = {
		targetOffset = Vector(0, 0),
		position = Vector(self.Pos.X ,self.Pos.Y),
		strengths = {1.5, 2.0, 3.0, 2.5},
		strengthBase = 60.0,
		velocity = Vector(0, 0),
		originalParentOffset = Vector(self.BGArm.ParentOffset.X, self.BGArm.ParentOffset.Y)
	}
	
	self.pugilismArms = {self.pugilismArmFG, self.pugilismArmBG}
	self.pugilismArmActivePrevious = self.pugilismArmBG
	self.pugilismArmActive = self.pugilismArmFG
	self.pugilismArmIndex = 1
	self.pugilismStates = {Idle = 1, Blocking = 2, Punch = 3, Showe = 4}
	self.pugilismState = self.pugilismStates.Idle
	
	self.pugilismAttackDuration = 500
	self.pugilismAttackTimer = Timer()
	self.pugilismAttackCooldown = 400
	self.pugilismAttackCooldownTimer = Timer()
	self.pugilismAttackGrunt = true
	self.pugilismAttackDamage = true
	
	self.pugilismSwingSound = CreateSoundContainer("Pugilism Swing Mordhau", "Mordhau.rte");
	self.pugilismBlockedSound = CreateSoundContainer("Pugilism Blocked Mordhau", "Mordhau.rte");
	self.pugilismHitMetalSound = CreateSoundContainer("Pugilism HitMetal Mordhau", "Mordhau.rte");
	self.pugilismHitFleshSound = CreateSoundContainer("Pugilism HitFlesh Mordhau", "Mordhau.rte");
	
end

function Update(self)
	local handsEmpty = not self.EquippedItem and not self.EquippedBGItem
	
	if handsEmpty then
		self:SetNumberValue("Pugilism", 1)
		
		local armFG = self.FGArm
		local armBG = self.BGArm
		local arms = {armFG, armBG}
		
		local ctrl = (self.controller and self.controller or self:GetController())
		
		local blocking = (self:IsPlayerControlled() and UInputMan:KeyHeld(18)) or self:NumberValueExists("AI Block")
		local attacking = (ctrl and ctrl:IsState(Controller.WEAPON_FIRE) or false)
		
		self:RemoveNumberValue("AI Block");
		
		if self.pugilismState == self.pugilismStates.Idle then
			local idleAnimFG = Vector(3, 0):RadRotate(self.Age * 0.003)
			local idleAnimBG = Vector(0, 2):RadRotate(self.Age * 0.003)
			
			self:RemoveNumberValue("Puglism Blocking")
			self:RemoveNumberValue("Puglism Attacking")
			
			if attacking then
				if self.pugilismAttackCooldownTimer:IsPastSimMS(self.pugilismAttackCooldown) then
					self.pugilismState = self.pugilismStates.Punch
					self.pugilismAttackTimer:Reset()
					
					local new = self.pugilismArmActivePrevious
					self.pugilismArmActivePrevious = self.pugilismArmActive
					self.pugilismArmActive = new
					self.pugilismArmIndex = (self.pugilismArmIndex) % 2 + 1
					
					self.Vel = self.Vel + Vector(-3 * self.FlipFactor, -1) * 0.3
					
					self.pugilismAttackGrunt = true
					self.pugilismAttackDamage = true
				end
			end
			
			self.pugilismArmFG.targetOffset = Vector(7, -4) + Vector(idleAnimFG.X, idleAnimFG.Y * 1.0)
			self.pugilismArmBG.targetOffset = Vector(7, -4) + Vector(idleAnimBG.X, idleAnimBG.Y * 1.0)
			
			if armFG then
				armFG.ParentOffset = armFG.ParentOffset + ((self.pugilismArmFG.originalParentOffset) - armFG.ParentOffset) * TimerMan.DeltaTimeSecs * 8
			end
			if armBG then
				armBG.ParentOffset = armFG.ParentOffset + ((self.pugilismArmBG.originalParentOffset) - armBG.ParentOffset) * TimerMan.DeltaTimeSecs * 8
			end
			
			if blocking then
				self.pugilismState = self.pugilismStates.Blocking
				self:SetNumberValue("Puglism Block", 1)
			end
		elseif self.pugilismState == self.pugilismStates.Blocking then
			local blockAnim = Vector(10, -10)--:RadRotate(self:GetAimAngle(false))
			self.pugilismArmFG.targetOffset = blockAnim
			self.pugilismArmBG.targetOffset = blockAnim
			
			self:SetNumberValue("Puglism Blocking", 1)
			self:RemoveNumberValue("Puglism Attacking")
			
			if armFG then
				armFG.ParentOffset = armFG.ParentOffset + ((self.pugilismArmFG.originalParentOffset + Vector(4, 1)) - armFG.ParentOffset) * TimerMan.DeltaTimeSecs * 5.5
			end
			if armBG then
				armBG.ParentOffset = armBG.ParentOffset + ((self.pugilismArmBG.originalParentOffset + Vector(4, 1)) - armBG.ParentOffset) * TimerMan.DeltaTimeSecs * 5.5
			end
			
			if not blocking then
				self.pugilismState = self.pugilismStates.Idle
			end
		elseif self.pugilismState == self.pugilismStates.Punch then
			local factor = self.pugilismAttackTimer.ElapsedSimTimeMS / self.pugilismAttackDuration
			factor = math.max(math.min(factor, 1), 0.01)
			factor = math.pow(factor, 4)
			
			self:RemoveNumberValue("Puglism Blocking")
			self:SetNumberValue("Puglism Attacking", 1)
			
			local arm = arms[self.pugilismArmIndex]
			if arm then
				if self.pugilismAttackGrunt and factor > 0.2 then
					self:SetNumberValue("Puglism Attack", 1)
					self.pugilismSwingSound:Play(self.Pos);
					self.pugilismAttackGrunt = false
					
					self.Vel = self.Vel + Vector(3 * self.FlipFactor, -1) * 0.3
				end
				
				local attackAnim = Vector(-12, 0) * (1 - factor) + Vector(25, 0):RadRotate(self:GetAimAngle(false)) * math.max(math.sqrt(math.sin(factor * math.pi)), math.sqrt(math.sin(math.pow(factor, 2) * math.pi)) * 0.5)
				self.pugilismArmActive.targetOffset = Vector(5, -4) + attackAnim
				arm.ParentOffset = arm.ParentOffset + ((self.pugilismArmActive.originalParentOffset + Vector(4 * math.sin((1 - factor) * math.pi), 1)) - arm.ParentOffset) * TimerMan.DeltaTimeSecs * 14.0
				
				if self.pugilismAttackDamage and (factor < 0.7 or (self.pugilismArmActive.velocity).Magnitude > 3) then
					local handPos = arm.HandPos + Vector(5, 0):RadRotate(self:GetAimAngle(true)) * math.sqrt(math.sin(factor * math.pi))
					local checkPixTerrain = SceneMan:GetTerrMatter(handPos.X, handPos.Y)
					local checkPixMO = SceneMan:GetMOIDPixel(handPos.X, handPos.Y)
					
					--PrimitiveMan:DrawCirclePrimitive(handPos, 1, 5);
					
					if checkPixMO and checkPixMO ~= rte.NoMOID and MovableMan:GetMOFromID(checkPixMO).Team ~= self.Team then
						local mo = ToMOSRotating(MovableMan:GetMOFromID(checkPixMO))
						if mo then
							self.pugilismAttackDamage = false
							
							local woundName = mo:GetEntryWoundPresetName()
							local woundNameExit = mo:GetExitWoundPresetName()
							local woundOffset = SceneMan:ShortestDistance(mo.Pos, handPos, SceneMan.SceneWrapsX):RadRotate(mo.RotAngle * -1.0)
							
							local material = mo.Material.PresetName
							
							if woundName ~= "" and woundName ~= nil then -- generic wound adding for non-actors
								for i = 1, 2 do
									mo:AddWound(CreateAEmitter(woundName), woundOffset, true)
								end
							end
							
							
							if not IsHeldDevice(mo) then
								local parent = mo:GetRootParent()
								if parent and IsActor(parent) then
								
									--self.kickImpactSound:Play(self.Pos);
								
									parent = ToActor(parent)
									
									if parent.BodyHitSound then
										parent.BodyHitSound:Play(parent.Pos)
									end

									parent.Vel = parent.Vel + Vector(1.5, 0):RadRotate(self:GetAimAngle(true))
									
									mo:SetNumberValue("Mordhau Flinched", 1);
									local flincher = CreateAttachable("Mordhau Flincher", "Mordhau.rte")
									mo:AddAttachable(flincher)
								end
							end
							
							if string.find(material,"Metal") or string.find(woundName,"Metal") or string.find(woundNameExit,"Metal") or string.find(material,"Stuff") or string.find(woundName,"Dent") or string.find(woundNameExit,"Dent") then
								-- if self.attackAnimationsGFX[self.currentAttackAnimation].hitMetalGFX then
									-- local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitMetalGFX);
									-- if effect then
										-- effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
										-- MovableMan:AddParticle(effect);
										-- effect:GibThis();
									-- end
								-- end
								self.pugilismHitMetalSound:Play(self.Pos);
							else
								self.pugilismHitFleshSound:Play(self.Pos);
							end
							
						end
						
						
					end
					
					if checkPixTerrain and checkPixTerrain ~= 0 then
						
						self.pugilismAttackDamage = false
					end
				end
				
			end
			
			if self.pugilismAttackTimer:IsPastSimMS(self.pugilismAttackDuration) then
				self.pugilismState = self.pugilismStates.Idle
				self.pugilismAttackCooldownTimer:Reset()
			end
			
		elseif self.pugilismState == self.pugilismStates.Showe then
			self:RemoveNumberValue("Puglism Blocking")
			self:SetNumberValue("Puglism Attacking", 1)
		end
		
		for i, arm in ipairs(arms) do
			if arm then
				local data = self.pugilismArms[i]
				
				local pos = Vector(data.position.X, data.position.Y)
				local vel = Vector(data.velocity.X, data.velocity.Y)
				
				local posTarget = self.Pos + Vector(data.targetOffset.X * self.FlipFactor, data.targetOffset.Y):RadRotate(self.RotAngle)
				local dif = SceneMan:ShortestDistance(pos, posTarget, SceneMan.SceneWrapsX)
				
				
				
				vel = vel + Vector(dif.X, dif.Y).Normalized * math.min(math.max((dif.Magnitude * 0.66), 0), 4) * TimerMan.DeltaTimeSecs * data.strengthBase * data.strengths[self.pugilismState]
				
				vel = vel + self.Vel * TimerMan.DeltaTimeSecs * 2
				vel = vel + Vector(-self.AngularVel, 0):RadRotate(self.RotAngle) * TimerMan.DeltaTimeSecs * 3
				
				local friction = (3 - math.min(math.max((dif.Magnitude), 1), 2)) * 7.0
				vel = Vector(vel.X , vel.Y) / (1 + TimerMan.DeltaTimeSecs * friction)
			
				
				pos = pos + vel * rte.PxTravelledPerFrame
				pos = pos + SceneMan:ShortestDistance(pos, posTarget, SceneMan.SceneWrapsX) * TimerMan.DeltaTimeSecs * 0.3
				
				data.position = Vector(pos.X, pos.Y)
				data.velocity = Vector(vel.X, vel.Y)
				
				--PrimitiveMan:DrawCirclePrimitive(data.position, 1, 5);
				--PrimitiveMan:DrawLinePrimitive(data.position, posTarget, 5);
				local offset = SceneMan:ShortestDistance(self.Pos + Vector(arm.ParentOffset.X * self.FlipFactor, arm.ParentOffset.Y):RadRotate(self.RotAngle), pos + vel * rte.PxTravelledPerFrame * 0.25, SceneMan.SceneWrapsX):RadRotate(-self.RotAngle)
				if self.Charging then		
					arm.IdleOffset = Vector(13 + (offset.X * self.FlipFactor), offset.Y)
				else				
					arm.IdleOffset = Vector(offset.X * self.FlipFactor, offset.Y)
				end
			end
		end
		
	else
		self:RemoveNumberValue("Pugilism")
	end
end