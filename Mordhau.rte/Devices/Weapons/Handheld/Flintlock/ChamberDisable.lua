function OnDetach(self)

	self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/Flintlock/Chamber.lua");
	self.ReloadTime = 9000;
	
	if self.meleeMode == true then
	
		self.ReloadTime = 15000;
	
		self.delayedFireDisabled = false;
	
		self.StanceOffset = Vector(3, 5);
		self.SharpStanceOffset = Vector(6, 2);
		self.SharpLength = 400;
		self.JointOffset = Vector(-7, 1);
		self.SupportOffset = Vector(3, 0);
	
		self:RemoveNumberValue("Weapons - Mordhau Melee");
	
		self:RemoveNumberValue("Switch Mode");
		self.meleeMode = false;
		self.rotation = -115
		self.rotationTarget = 0;
			
		self.Flash = CreateAttachable("Muzzle Flash Shotgun", "Base.rte");
		self.FireSound = CreateSoundContainer("Fire Flintlock", "Mordhau.rte");
		
		self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/Flintlock/MeleeMode.lua");
		
		self:RemoveStringValue("Parrying Type");
		self.Parrying = false;
		
		self.Blocking = false;
		self:RemoveNumberValue("Blocking");
		
		self.currentAttackAnimation = 0;
		self.currentAttackSequence = 0;
		self.currentAttackStart = false
		self.attackAnimationIsPlaying = false
		
		self.rotationInterpolationSpeed = 25;
		
	end
	
end

function OnAttach(self)

	self.HUDVisible = true;

	self:DisableScript("Mordhau.rte/Devices/Shared/Scripts/TwirlBluntThrow.lua");
	self.PinStrength = 0;
	
	if self.meleeMode == true and self.RootID == 255 then --equipped from inv
	
		self.delayedFireDisabled = true;
	
		self.StanceOffset = Vector(5, 7);
		self.SharpStanceOffset = Vector(5, 7);
		self.SharpLength = 0;
		self.JointOffset = Vector(8, 0);
		self.SupportOffset = Vector(9, 0);
	
		self:RemoveNumberValue("Switch Mode");
		self.meleeMode = true;
		
		self.originalBaseRotation = -115;
		
		self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/Flintlock/Chamber.lua");
		self:EnableScript("Mordhau.rte/Devices/Weapons/Handheld/Flintlock/MeleeMode.lua");
	
		self.equipAnim = true;
		
		self.canBlock = true;
		
	else
	
		self.delayedFireDisabled = false;
	
		self.StanceOffset = Vector(3, 5);
		self.SharpStanceOffset = Vector(6, 2);
		self.SharpLength = 400;
		self.JointOffset = Vector(-7, 1);
		self.SupportOffset = Vector(3, 0);
	
		self:RemoveNumberValue("Switch Mode");
		self.meleeMode = false;
		self.rotation = -115
		self.rotationTarget = 0;
			
		
		self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/Flintlock/MeleeMode.lua");
		self:EnableScript("Mordhau.rte/Devices/Weapons/Handheld/Flintlock/Chamber.lua");

	end
	
end