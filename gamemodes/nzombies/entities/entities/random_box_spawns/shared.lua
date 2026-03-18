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
 
ENT.PrintName		= "random_box_spawns"
ENT.Author			= "Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.NZEntity = true

function ENT:Initialize()
	self:SetModel( "models/nzprops/mysterybox_pile.mdl" )
	self:SetColor( Color(255, 255, 255) )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:EnableMotion(false)		
	end
	
	--self:SetNotSolid(true)
	--self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	--self:DrawShadow( false )
end

-- function ENT:Think()
	
-- end

-- Mysterybox moving by explosive bug fixed by Ethorbit:
function ENT:PhysicsCollide(colData, collider)
	self:SetMoveType( MOVETYPE_NONE )
end

if CLIENT then
	
end
