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

ENT.Type = "anim"
ENT.Base = "base_entity"

AddCSLuaFile( )
ENT.PrintName = "nz_spawn_player_special"
ENT.NZOnlyVisibleInCreative = true

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "Link" )
end

function ENT:Initialize()
	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self:SetColor(Color(0, 255, 0))
	self:DrawShadow( false )
end

function ENT:IsSuitable()
	local tr = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos(),
		filter = self,
		mins = Vector( -20, -20, 0 ),
		maxs = Vector( 20, 20, 70 ),
		ignoreworld = true,
		mask = MASK_NPCSOLID
	} )

	return not tr.Hit
end

if CLIENT then
	function ENT:Draw()
		if ConVarExists("nz_creative_preview") and !GetConVar("nz_creative_preview"):GetBool() and nzRound:InState( ROUND_CREATE ) then
			self:DrawModel()
		end
	end
end

function ENT:Initialize()
	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self:SetColor(Color(255, 255, 255))
	self:DrawShadow( false )
end
