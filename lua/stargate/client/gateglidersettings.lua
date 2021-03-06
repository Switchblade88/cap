/*
	Stargate Lib for GarrysMod10
	Copyright (C) 2007-2009  aVoN

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
--################# The keyboard layout, you see in the stargate/Keybinders #################

--################# Adds the glider's keysettings @aVoN
--[[function StarGate.Hook.AddGateGliderKeysettingsConfig()
	--if(not StarGate.Installed) then return end;
	spawnmenu.AddToolMenuOption("Cap","Keybinders","GateGlider"," Gate Glider Settings","","",StarGate.GateGliderSettings);
end
hook.Add("AddToolMenuTabs","StarGate.Hook.AddGateGliderKeysettingsConfig",StarGate.Hook.AddGateGliderKeysettingsConfig);]]

--################ The controls necessary for keybinding @aVoN
function StarGate.GateGliderSettings(Panel)
	if(StarGate.HasInternet) then
		-- The HELP Button
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/gateglider");
		VGUI:SetTopic("Help:  GateGlider Config");
		Panel:AddPanel(VGUI);
	end
	local LAYOUT = "GateGlider";
	-- Use soo much tables at the bottom to keep the sorting-order in exact this order.
	local KEYS = {
		{
			Name = "Movement",
			Keys = {
				{"Move forward","FWD"},
				{"Move Left(Strafe)","LEFT"},
				{"Move Right(Strafe)","RIGHT"},
				{"Move Back","BACK"},
				{"Move Up","UP"},
				{"Move Down","DOWN"},
				{"Roll left","RL"},
				{"Roll right","RR"},
				{"Reset Roll","RROLL"},
			},
		},
		--[[
		{
			Name = "Combat",
			Keys = {
				{"Fire Drones","FIRE"},
				{"Track Drones","TRACK"},
			},
		},
		]]--
		{
			Name = "Special Actions",
			Keys = {
				{"Selfdestruct","BOOM"},
				{"Toggle DHD","DHD"},
				{"Exit","EXIT"},
			},
		},
		{
			Name = "View",
			Keys = {
				{"Zoom in","Z+"},
				{"Zoom out","Z-"},
				{"Move view up","A+"},
				{"Move view down","A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end
