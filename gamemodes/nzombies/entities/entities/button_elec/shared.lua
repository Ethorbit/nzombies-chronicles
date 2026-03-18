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
 
ENT.PrintName		= "button_elec"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.NZEntity = true

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Switch" )
	
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/MaxOfS2D/button_01.mdl" )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( ONOFF_USE )
		self:SetSwitch(false)
	else
		self.PosePosition = 0
	end
end

function ENT:Use( activator )

	if ( !activator:IsPlayer() ) then return end
	if !IsElec() and nzRound:InProgress() then
		self:SetSwitch(true)
		nz.nzElec.Functions.Activate()
	end

end
	
if CLIENT then

	function ENT:Think()

		local TargetPos = 0.0;
		
		if ( self:GetSwitch() ) then TargetPos = 1.0; end
		
		self.PosePosition = math.Approach( self.PosePosition, TargetPos, FrameTime() * 5.0 )	
		
		self:SetPoseParameter( "switch", self.PosePosition )
		self:InvalidateBoneCache()

	end
	
	function ENT:Draw()
		self:DrawModel()
	end
end
