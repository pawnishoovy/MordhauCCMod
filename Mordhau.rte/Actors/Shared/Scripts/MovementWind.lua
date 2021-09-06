
function Create(self)

	self.movementWindSound = CreateSoundContainer("Movement Wind Mordhau", "Mordhau.rte");
	self.movementWindSound.Volume = 0;
	self.movementWindSound:Play(self.Pos);
	
end

function Update(self)
	
	self.movementWindSound.Pos = self.Pos;
	if self.Vel.Magnitude > 3 and self:IsPlayerControlled() then
		if self.movementWindSound.Volume < 0.09 then
			self.movementWindSound.Volume = self.movementWindSound.Volume + 0.045 * TimerMan.DeltaTimeSecs;
		else
			self.movementWindSound.Volume = math.min(1, self.Vel.Magnitude/25 - 0.09)
		end
		self.movementWindSound.Pitch = math.min(0.9, math.max(1, self.Vel.Magnitude/25 - 0.09))
	else
		if self.movementWindSound.Volume > 0 then
			self.movementWindSound.Volume = self.movementWindSound.Volume - 0.25 * TimerMan.DeltaTimeSecs;
			if self.movementWindSound.Volume < 0 then
				self.movementWindSound.Volume = 0
			end
		end
		if self.movementWindSound.Pitch > 0.9 then
			self.movementWindSound.Pitch = self.movementWindSound.Pitch - 0.25 * TimerMan.DeltaTimeSecs;
			if self.movementWindSound.Pitch < 0.9 then
				self.movementWindSound.Pitch = 0.9
			end
		end
	end
	
end

function Destroy(self)
	self.movementWindSound:Stop(-1);
end