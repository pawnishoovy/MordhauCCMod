function Create(self)
	self.HitsMOs = false; -- avoid hitting ourselves
	
	self.lastPos = Vector(self.Pos.X, self.Pos.Y)
	self.launchVector = Vector()

end

function OnDetach(self)

	self.Vel = self.launchVector / rte.PxTravelledPerFrame * 0.5
	self.Vel = self.Vel + Vector(0, -self.Vel.Magnitude * 0.3)
	self.AngularVel = RangeRand(-1, 1) * 2

	self:GibThis();
	
end

function Update(self)
	self.launchVector = SceneMan:ShortestDistance(self.lastPos, self.Pos,SceneMan.SceneWrapsX)
	self.lastPos = Vector(self.Pos.X, self.Pos.Y)
	
end