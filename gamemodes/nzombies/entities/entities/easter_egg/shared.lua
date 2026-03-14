--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2017 Zet0rz
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

ENT.Type = "anim"

ENT.PrintName		= "easter_egg"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.NZEntity = true

AddCSLuaFile()



function ENT:Initialize()

	self:SetModel( "models/props_lab/huladoll.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self.Used = false
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:Use( activator, caller )
	if !self.Used and nzRound:InProgress() then
		nzEE:ActivateEgg( self, activator )
		if (util.NetworkStringToID("VManip_SimplePlay") != 0) then
			net.Start("VManip_SimplePlay")
			net.WriteString("use")
			net.Send(activator)
		end
	end
end

function ENT:Draw()
	if LocalPlayer():IsInCreative() then
		self:DrawModel()
	return end

	if (!LocalPlayer():IsSpectating()) then
		self:DrawModel()
	end

	local targ = LocalPlayer():GetObserverTarget()
	if (IsValid(targ) and targ:IsPlayer() and targ:Alive() and LocalPlayer():GetObserverMode() != OBS_MODE_ROAMING) then -- Only show if they are spectating somebody (Not in free roam where they can easily tell teammates where parts are)
		self:DrawModel()
	return end
end
