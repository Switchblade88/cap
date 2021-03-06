/*
	DHD SENT for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

--################# HEADER #################
if (not StarGate.CheckModule("base")) then return end
--################# Include
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

--################# SENT CODE #################

--################# Init @aVoN
function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);
	self.Range = StarGate.CFG:Get("mobile_dhd","range",3000);
	--################# Wire!
	self:CreateWireInputs("Dial Address","Dial String [STRING]","Dial Mode","Transmit [STRING]","Start String Dial","Close","Disable Autoclose");
	self:CreateWireOutputs("Active","Open","Inbound","Chevron","Chevron Locked","Chevrons [STRING]","Dialing Address [STRING]","Dialing Mode","Dialing Symbol [STRING]","Dialed Symbol [STRING]","Received [STRING]");
	--################# Set physic and entity properties
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake();
		phys:SetMass(10);
	end
end

--################# Find nearest stargate @aVoN
-- FIXME: Add this to the stargate lib!
function ENT:FindGate()
	local gate;
	local dist = self.Range;
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate) then
			local sg_dist = (pos - v:GetPos()):Length();
			if(dist >= sg_dist) then
				dist = sg_dist;
				gate = v;
			end
		end
	end
	return gate;
end

--################# Update the speech bubbles @aVoN
function ENT:Think()
	self:SetOverlayText("Mobile DHD");
	self.Entity:NextThink(CurTime() + 5);
	return true;
end

--################# Use @aVoN
function ENT:Use(p)
	self:OpenMenu(p);
end

--################# Open the menue @aVoN
function ENT:OpenMenu(p)
	if(not IsValid(p)) then return end;
	local e = self:FindGate();
	if(not IsValid(e)) then return end;
	if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,e) == false) then return end;
	if (e.IsGroupStargate and GetConVar("stargate_group_system"):GetBool()) then
		umsg.Start("StarGate.OpenDialMenuDHD_Group",p);
	elseif (e.IsGroupStargate) then
		umsg.Start("StarGate.OpenDialMenuDHD_Galaxy",p);
	else
		umsg.Start("StarGate.OpenDialMenuDHD",p);
	end
	umsg.Entity(e);
	umsg.End();
end

--################# Wire input - Relay to the gate @aVoN
function ENT:TriggerInput(k,v)
	local gate = self:FindGate();
	if(IsValid(gate)) then
		gate:TriggerInput(k,v,true,self.Entity);
	end
end