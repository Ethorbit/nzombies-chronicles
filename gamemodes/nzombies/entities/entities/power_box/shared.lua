--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2017 Zet0rz
Copyright (C) 2016-2017 lolleko
Copyright (C) 2020-2025 Ethorbit

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
--]]

AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "Zombies Power"
ENT.Author			= "Zet0r"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.NZEntity = true

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Switch" )
	self:NetworkVar( "Entity", 0, "PowerHandle")
	
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/nzprops/zombies_power_lever.mdl" )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( ONOFF_USE )
		self:SetSwitch(false)
		
		self.Handle = ents.Create("nz_prop_effect_attachment")
		self.Handle:SetModel("models/nzprops/zombies_power_lever_handle.mdl")
		self.Handle:SetAngles( self:GetAngles() )
		self.Handle:SetPos(self:GetPos() + self:GetAngles():Up()*46 + self:GetAngles():Forward()*7)
		self.Handle:Spawn()
		self.Handle:SetParent(self)
		self:SetPowerHandle(self.Handle)
		
		self:DeleteOnRemove( self.Handle )
	else
		self.Switched = false
	end
end

function ENT:Use( activator )

	if ( !activator:IsPlayer() ) then return end
	if !IsElec() and nzRound:InProgress() then
		self:SetSwitch(true)
		self.Switched = 0
		nzElec:Activate()

		if (util.NetworkStringToID("VManip_SimplePlay") != 0) then
			net.Start("VManip_SimplePlay")
			net.WriteString("use")
			net.Send(activator)
		end
	end

end
	
if CLIENT then

	local offang = Angle(0,0,0)
	local onang = Angle(-90,0,0)

	function ENT:Think()
		local handle = self:GetPowerHandle()
		if self:GetSwitch() != self.Switched then
			self.Switching = math.Approach( self.Switching or 0, 1, FrameTime() * 2 )
			local ang = self:GetAngles()
			if self:GetSwitch() then
				handle:SetRenderAngles(LerpAngle(self.Switching, self:LocalToWorldAngles(offang), self:LocalToWorldAngles(onang)))
			else
				handle:SetRenderAngles(LerpAngle(self.Switching, self:LocalToWorldAngles(onang), self:LocalToWorldAngles(offang)))
			end
			
			if self.Switching >= 1 then
				self.Switched = self:GetSwitch()
				self.Switching = nil
			end
		end
	end
	
	function ENT:Draw()
		self:DrawModel()
	end
end
