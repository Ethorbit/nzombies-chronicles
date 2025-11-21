--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2022 Zet0rz
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


AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.Editable			= true

function ENT:Initialize()

	if ( CLIENT ) then return end
	
	self:SetModel( "models/MaxOfS2D/cube_tool.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180
	
	local ent = ents.Create( ClassName )
		ent:SetPos( SpawnPos )
		ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end


function ENT:EnableForwardArrow()

	self:SetBodygroup( 1, 1 )

end

-- Gamemode uses serverside fog now, don't override clientside fog anymore:
function ENT:SetupWorldFog()
end

function ENT:SetupSkyFog()
end
