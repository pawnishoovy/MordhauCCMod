
function Kick(self, leg)
	local factor = self.kickTimer.ElapsedSimTimeMS / self.kickDuration
	factor = math.sin(factor * math.pi * 0.5)
	local angleOffset = math.pi * 0.35 * (math.sin(math.pow(factor, 1.5) * math.pi) + math.sin(math.pow(factor, 2) * math.pi))
	leg.RotAngle = leg.RotAngle + angleOffset * self.FlipFactor
	
	local lengthFactor = math.max(math.sin(math.sqrt(1 - factor) * math.pi), math.pow(factor, 2))
	leg.Frame = math.floor(lengthFactor * (leg.FrameCount - 1) + 0.5)
	
	local offsetX = 2 * math.cos(math.pow((1 - factor) * 2, 2) * math.pi)
	local offsetY = 2 * math.sin(math.pow((factor) * 2, 2) * math.pi)
	local jointOffset = Vector((leg.JointOffset.X + offsetX) * self.FlipFactor, leg.JointOffset.Y + offsetY):RadRotate(leg.RotAngle);
	leg.Pos = leg.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-angleOffset * leg.FlipFactor);
	
	local foot = leg.Foot
	if foot then
		foot.RotAngle = leg.RotAngle + math.pi * 0.5 * factor * self.FlipFactor
		foot.Pos = leg.Pos + Vector(foot.ParentOffset.X * leg.FlipFactor * lengthFactor, foot.ParentOffset.Y):RadRotate(leg.RotAngle) - Vector(foot.JointOffset.X * leg.FlipFactor * lengthFactor, foot.JointOffset.Y):RadRotate(foot.RotAngle)
		
		if self.kickTimer:IsPastSimMS(self.kickDuration * 0.2) and not self.kickTimer:IsPastSimMS(self.kickDuration * 0.7) then
			if self.kickDamage then
				--self.kickCooldown = self.kickCooldownDefault
				local footPos = foot.Pos + Vector(5 * self.FlipFactor * math.sin(factor * math.pi), 0)
				local checkPixTerrain = SceneMan:GetTerrMatter(footPos.X, footPos.Y)
				local checkPixMO = SceneMan:GetMOIDPixel(footPos.X, footPos.Y)
				
				--PrimitiveMan:DrawCirclePrimitive(footPos, 1, 5);
				
				if checkPixMO and checkPixMO ~= rte.NoMOID and MovableMan:GetMOFromID(checkPixMO).Team ~= self.Team then
					local mo = ToMOSRotating(MovableMan:GetMOFromID(checkPixMO))
					if mo then
						self.kickDamage = false
						self.Vel = self.Vel + Vector(-3 * self.FlipFactor, -3)
						
						local woundName = mo:GetEntryWoundPresetName()
						local woundNameExit = mo:GetExitWoundPresetName()
						local woundOffset = SceneMan:ShortestDistance(mo.Pos, footPos, SceneMan.SceneWrapsX):RadRotate(mo.RotAngle * -1.0)
						
						if woundName ~= "" and woundName ~= nil then -- generic wound adding for non-actors
							for i = 1, 3 do
								mo:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end
						end
						
						
						if IsHeldDevice(mo) then
						
							self.kickImpactDeviceSound:Play(self.Pos);
						
							if not mo:IsInGroup("Weapons - Mordhau Melee") then
								if IsAttached(mo) then
									ToAttachable(mo):RemoveFromParent(true, true);
									mo.Vel = Vector(4 * self.FlipFactor, -4)
									mo.AngularVel = RangeRand(2,7) * (math.random(0, 1) - 0.5) * 2.0
								end
							end
							
							mo:SetNumberValue("Mordhau Flinched", 1);
							local flincher = CreateAttachable("Mordhau Flincher", "Mordhau.rte")
							mo:AddAttachable(flincher)
						else
							local parent = mo:GetRootParent()
							if parent and IsActor(parent) then
							
								self.kickImpactSound:Play(self.Pos);
							
								parent = ToActor(parent)

								parent.Vel = parent.Vel + Vector(3 * self.FlipFactor, -3)
								
								mo:SetNumberValue("Mordhau Flinched", 1);
								mo:SetNumberValue("Mordhau Impact Sound", 1);
								local flincher = CreateAttachable("Mordhau Flincher", "Mordhau.rte")
								mo:AddAttachable(flincher)
								
								if parent.Status < 1 then
									parent.Status = 1
								end
							end
						end
						
					end
					
					
				end
				
				if checkPixTerrain and checkPixTerrain ~= 0 then
					self.kickDamage = false
					self.Vel = self.Vel + Vector(-3 * self.FlipFactor, -3) * self.kickRecoil
				end
			else
				self.kickDuration = math.max(self.kickDuration - TimerMan.DeltaTimeSecs * 2000, 0)
			end
		end
		
	end
end

function Create(self)

	self.kickImpactSound = CreateSoundContainer("Kick Impact Mordhau", "Mordhau.rte");
	self.kickImpactDeviceSound = CreateSoundContainer("Kick Impact Device Mordhau", "Mordhau.rte");

	self.kicking = false
	self.kickDurationDefault = 1000
	self.kickDuration = self.kickDurationDefault
	self.kickTimer = Timer()
	self.kickCooldown = 1000
	self.kickCooldownTimer = Timer()
	
	self.kickRecoil = 0.5
	
	self.kickYell = true
	self.kickDamage = true
	
	self.kickAim = Vector(1,0)
end

function Update(self)

	if self:NumberValueExists("Mordhau Impact Sound") then
		self:RemoveNumberValue("Mordhau Impact Sound");
		self.BodyHitSound:Play(self.Pos);
	end

	local leg = (self.FGLeg and self.FGLeg or self.BGLeg)
	
	if self.Status < 1 and self.controller and leg then
		if self.controller:IsState(Controller.MOVE_UP) then
		end
		if not self.kicking and self.kickCooldownTimer:IsPastSimMS(self.kickCooldown) and (self:NumberValueExists("AI Kick") or (UInputMan:KeyPressed(20) and self:IsPlayerControlled())) then
			local valid = true
			if self.EquippedItem then	
				if (IsHDFirearm(self.EquippedItem)) then
					local weapon = ToHDFirearm(self.EquippedItem);
					if (weapon:NumberValueExists("Current Attack Type") and weapon:GetNumberValue("Current Attack Type") > 0) then
						valid = false
					end
				end
			end
			
			if valid then
				self.kickTimer:Reset()
				self.kicking = true
				self.kickYell = true
				self.kickDamage = true
				
				self.Vel = self.Vel + Vector(-3 * self.FlipFactor, -1) * self.kickRecoil
				
				self.kickDuration = self.kickDurationDefault
				
				self.kickAim = self.controller.AnalogAim
				
				if self.movementSounds.Jump then
					self.movementSounds.Jump:Play(self.Pos);
				end
				
			end
			
			self:RemoveNumberValue("AI Kick")
		end
		
		if self.kicking then
			self.controller:SetState(Controller.MOVE_UP, false)
			self.controller:SetState(Controller.MOVE_RIGHT, false)
			self.controller:SetState(Controller.MOVE_LEFT, false)
			self.controller:SetState(Controller.WEAPON_FIRE, false)
			
			Kick(self, leg)
			self:SetNumberValue("Kicking", 1)
			
			if self.kickYell and self.kickTimer:IsPastSimMS(self.kickDuration * 0.1) then
				self.kickYell = false
				self:SetNumberValue("Kick Attack", 1)
				
				self.Vel = self.Vel + Vector(6 * self.FlipFactor, -2.5) * self.kickRecoil
			end
			
			--self.controller.AnalogAim = self.kickAim
			
			if self.kickTimer:IsPastSimMS(self.kickDuration) then
				self.kickCooldownTimer:Reset()
				self.kicking = false
				self:RemoveNumberValue("Kicking")
			end
		end
	end
end