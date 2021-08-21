function OnDetach(self)

	self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/FlintlockPistol/Chamber.lua");
	self.ReloadTime = 9000;
	
	if self.meleeMode == true then
	
		self.ReloadTime = 15000;
	
		self.delayedFireDisabled = false;
	
		self.StanceOffset = Vector(3, 5);
		self.SharpStanceOffset = Vector(6, 0);
		self.SharpLength = 130;
		self.JointOffset = Vector(-5, 1);
		self.SupportOffset = Vector(-5, 1);
	
		self:RemoveNumberValue("Weapons - Mordhau Melee");
	
		self:RemoveNumberValue("Switch Mode");
		self.meleeMode = false;
		self.rotation = -115
		self.rotationTarget = 0;
			
		self.Flash = CreateAttachable("Muzzle Flash Shotgun", "Base.rte");
		self.FireSound = CreateSoundContainer("Fire FlintlockPistol", "Mordhau.rte");
		
		self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/FlintlockPistol/MeleeMode.lua");
		
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
	
		self.StanceOffset = Vector(8, 3);
		self.SharpStanceOffset = Vector(8, 3);
		self.meleeOriginalStanceOffset = Vector(8, 3);
		self.SharpLength = 0;
		self.JointOffset = Vector(5, -1);
		self.SupportOffset = Vector(500, 500);
	
		self:RemoveNumberValue("Switch Mode");
		self.meleeMode = true;
		
		self.originalBaseRotation = -115;
		self.baseRotation = -100;
		
		self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/FlintlockPistol/Chamber.lua");
		self:EnableScript("Mordhau.rte/Devices/Weapons/Handheld/FlintlockPistol/MeleeMode.lua");
	
		self.equipAnim = true;
		
		self.canBlock = true;
		
	else
	
		self.delayedFireDisabled = false;
	
		self.StanceOffset = Vector(3, 5);
		self.SharpStanceOffset = Vector(6, 0);
		self.SharpLength = 130;
		self.JointOffset = Vector(-5, 1);
		self.SupportOffset = Vector(-5, 1);
	
		self:RemoveNumberValue("Switch Mode");
		self.meleeMode = false;
		self.rotation = -115
		self.rotationTarget = 0;
			
		
		self:DisableScript("Mordhau.rte/Devices/Weapons/Handheld/FlintlockPistol/MeleeMode.lua");
		self:EnableScript("Mordhau.rte/Devices/Weapons/Handheld/FlintlockPistol/Chamber.lua");

	end
	
end