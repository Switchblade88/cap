--[[############################################################################################################
	Anti Priori Device
	Copyright (C) 2010 assassin21
############################################################################################################]]

if (not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


--##############################Init @ assassin21

function ENT:Initialize()

	self.Entity:SetModel("models/Madman07/anti_priest/anti_priest.mdl");

	self.Entity:SetName("Anti Priori Weapon");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE);

	self.IsOn = false;
	self.Radius = math.random(600, 800);
	self.Inputs = WireLib.CreateInputs( self.Entity, {"Activate"});

end

--###############################Spawn @ assassin21

function ENT:SpawnFunction( ply, tr )
	if (!tr.Hit) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("anti_prior");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then phys:EnableMotion(false); end

	return ent;
end

--##############################Use @ assassin21

function ENT:Use()
	if self.IsOn==false then
		self.IsOn=true;
	else
		self.IsOn=false;
	end
end


--################################Wire @ assassin21

function ENT:TriggerInput(variable, value)
	if (variable == "Activate") then self.IsOn = util.tobool(value) end
end

--################################Think @ assassin21

function ENT:Think()
	if self.IsOn==true then
		local e = ents.FindInSphere(self:GetPos(), self.Radius);
			for _,v in pairs(e) do
				if v:IsPlayer() and v:GetMoveType() == MOVETYPE_NOCLIP then
					if v != self.Owner then
						v:SetMoveType(MOVETYPE_WALK)
					end
				end
			end
	end

	if self.IsOn==true then
		self.Entity:Fire("skin",1);
	else
		self.Entity:Fire("skin",0);
	end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end

	dupeInfo.IsOn = self.IsOn;
	dupeInfo.Radius = self.Radius;

	duplicator.StoreEntityModifier(self, "AntiProriDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "AntiProriDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.AntiProriDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.AntiProriDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.AntiProriDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	self.IsOn = dupeInfo.IsOn;
	self.Radius = dupeInfo.Radius;

	self.Owner = ply;
end