--[[
	Doors
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("extra")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sounds={
	DestOpen=Sound("door/dest_door_open.wav"),
	DestClose=Sound("door/dest_door_close.wav"),
	Lock=Sound("door/dest_door_lock.wav"),
	AtlOpen=Sound("door/atlantis_door_open.wav"),
	AtlClose=Sound("door/atlantis_door_close.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Doors");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Lockdown = false;
	self:CreateWireInputs( "Toggle", "Lockdown");
	self:CreateWireOutputs( "Opened");

	if (self.DoorModel) then
		local ent = ents.Create("cap_doors");
		ent:SetAngles(self:GetAngles());
		ent:SetPos(self:GetPos());
		ent:SetModel(self.DoorModel);
		ent:Spawn();
		ent:Activate();
		constraint.NoCollide(self, ent, 0, 0 ); -- be sure it wont flip out!
		ent:SetAngles(self:GetAngles());
		ent:SetPos(self:GetPos());
		constraint.Weld(self,ent,0,0,0,true)
		ent.Delay = 2.5;
		ent.Sound = false;
		self.Door = ent;
		ent.Frame = self;
	end
end

function ENT:SoundType(t)
	self.Door.Sound = true;
	if (t == 1) then
		self.Door.OpenSound = self.Sounds.DestOpen;
		self.Door.CloseSound = self.Sounds.DestClose;
	else
		self.Door.OpenSound = self.Sounds.AtlOpen;
		self.Door.CloseSound = self.Sounds.AtlClose;
	end
end

function ENT:OnRemove()
	if IsValid(self.Door) then self.Door:Remove() end
end

function ENT:TriggerInput(variable, value)
	if (variable == "Toggle" and value > 0) then
		self:Toggle();
	elseif (variable == "Lockdown") then
		if (value == 1) then
			if self.Door.Open then self:Toggle() end
			self.Lockdown = true;
		else
			self.Lockdown = false;
		end
	end
end

function ENT:Toggle()
	if (not self.Lockdown) then
		self.Door:Toggle();
		self:SetWire("Opened",self.Door.Open);
	elseif (self.Door:GetModel()=="models/madman07/doors/dest_door.mdl") then
		self.Entity:EmitSound(self.Sounds.Lock,100,math.random(90,110));
	end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if IsValid(self.Door) then
		dupeInfo.EntIDDoor = self.Door:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end

	if (self.Entity:GetMaterial() == "Madman07/doors/atlwall_red") then
		dupeInfo.Mat = true;
	end

	dupeInfo.DoorModel = self.DoorModel;

	duplicator.StoreEntityModifier(self, "DupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "DupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.DupeInfo

	self.DoorModel = dupeInfo.DoorModel;

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
		self.DoorModel = dupeInfo.DoorModel;
	end
	if dupeInfo.EntIDDoor then
		if (IsValid(self.Door)) then self.Door:Remove() end
		self.Door = CreatedEntities[ dupeInfo.EntIDDoor ]
		self.Door.Frame = self.Entity;
		if (self.DoorModel == "models/madman07/doors/dest_door.mdl" || self.DoorModel == "models/madman07/doors/dest_frame.mdl") then self.Entity:SoundType(1);
		else self.Entity:SoundType(2); end
	end

	if(Ent.EntityMods and Ent.EntityMods.DupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.DupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	if (dupeInfo.Mat) then
		self.Entity:SetMaterial("Madman07/doors/atlwall_red");
	end

	self.Owner = ply;
end