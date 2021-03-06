/*
	Tampered ZPM for GarrysMod10
	Copyright (C) 2010  Llapp
*/

include("shared.lua");
language.Add("tampered_zpm",Language.GetMessage("stool_tzpm"));

ENT.ZpmSprite = StarGate.MaterialFromVMT(
	"ZpmSprite",
	[["Sprite"
	{
		"$spriteorientation" "vp_parallel"
		"$spriteorigin" "[ 0.50 0.50 ]"
		"$basetexture" "sprites/glow04"
		"$spriterendermode" 5
	}]]
);

ENT.SpritePositions = {
    Vector(0,0,5),
	Vector(0,0,3),
	Vector(0,0,0),
	Vector(0,0,-3),
	Vector(0,0,-5),
}

ENT.Zpm_hud = surface.GetTextureID("VGUI/resources_hud/zpm_temp");

function ENT:Initialize()
	self.Entity:SetNetworkedString("add","Disconnected");
	self.Entity:SetNWString("perc",0);
	self.Entity:SetNWString("eng",0);
end

function ENT:Draw()
	self.Entity:DrawModel();
	hook.Remove("HUDPaint",tostring(self.Entity).."TP");
    if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 1024)then
		hook.Add("HUDPaint",tostring(self.Entity).."TP",function()
		    local w = 0;
            local h = 260;
		    surface.SetTexture(self.Zpm_hud);
	        surface.SetDrawColor(Color( 255, 255, 255, 255 ));
	        surface.DrawTexturedRect(ScrW() / 2 + 6 + w, ScrH() / 2 - 50 - h, 180, 360);

	        surface.SetFont("center2")
	        surface.SetFont("header")

            draw.DrawText("TP ZPM", "header", ScrW() / 2 + 62 + w, ScrH() / 2 +41 - h, Color(0,255,255,255), 0)
            draw.DrawText("Status", "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +65 - h, Color(209,238,238,255),0);
		    draw.DrawText("Energy", "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +115 - h, Color(209,238,238,255),0);
		    draw.DrawText("Capacity", "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +165 - h, Color(209,238,238,255),0);

			if(IsValid(self.Entity))then
	            add = self.Entity:GetNetworkedString("add");
	            perc = self.Entity:GetNWString("perc");
	            eng = self.Entity:GetNWString("eng");
	        end

            surface.SetFont("center")

            local color = Color(0,255,0,255);
            if(add == "Disconnected" or add == "Depleted")then
                color = Color(255,0,0,255);
            end
            if(tonumber(perc)>0)then
                perc = string.format("%f",perc);
	        end

	        draw.SimpleText(add, "center", ScrW() / 2 + 40 + w, ScrH() / 2 +85 - h, color,0)
	        draw.SimpleText(tostring(eng), "center", ScrW() / 2 + 40 + w, ScrH() / 2 +135 - h, Color(255,255,255,255),0)
	        draw.SimpleText(tostring(perc).."%", "center", ScrW() / 2 + 40 + w, ScrH() / 2 +185 - h, Color(255,255,255,255),0)
		end);
	end

	render.SetMaterial(self.ZpmSprite);
	local alpha = self.Entity:GetNWInt("zpmbluerlightalpha");
	local col = Color(110,200,222,alpha);
	for i=1,5 do
	    local size = 9;
		if(i==3)then
		    size = 8;
		elseif(i==4)then
		    size = 7;
		elseif(i==5)then
		    size = 6;
		end
	    render.DrawSprite(self.Entity:LocalToWorld(self.SpritePositions[i]),size,size,col);
	end
end

function ENT:OnRemove()
    hook.Remove("HUDPaint",tostring(self.Entity).."TP");
end