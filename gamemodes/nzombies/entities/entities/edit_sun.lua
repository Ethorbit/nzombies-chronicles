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
DEFINE_BASECLASS( "base_edit" )

ENT.Spawnable			= true
ENT.AdminOnly			= true

ENT.PrintName			= "Sun Editor"
ENT.Category			= "Editors"

ENT.NZOnlyVisibleInCreative = true

ENT.NZEntity = true

function ENT:Initialize()

	BaseClass.Initialize( self )
	self:EnableForwardArrow()

	self:SetMaterial( "gmod/edit_sun" )
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
	if ( SERVER ) then

		--
		-- Notify us when the entity angle changes, so we can update the sun entity
		--
		self:AddCallback( "OnAngleChange", self.OnAngleChange )


		--
		-- Find an env_sun entity
		--
		local list = ents.FindByClass( "env_sun" )
		if ( #list > 0 ) then
			self.EnvSun = list[1]
		end

	end

end

function ENT:SetupDataTables()

	self:NetworkVar( "Float",	0, "SunSize", { KeyName = "sunsize", Edit = { type = "Float", min = 0, max = 100, order = 1 } }  );
	self:NetworkVar( "Float",	1, "OverlaySize", { KeyName = "overlaysize", Edit = { type = "Float", min = 0, max = 200, order = 2 } }  );
	self:NetworkVar( "Vector",	0, "SunColor", { KeyName = "suncolor", Edit = { type = "VectorColor", order = 3 } }  );
	self:NetworkVar( "Vector",	1, "OverlayColor", { KeyName = "overlaycolor", Edit = { type = "VectorColor", order = 4 } }  );

	

	if ( SERVER ) then

		-- defaults
		self:SetSunSize( 20 )
		self:SetOverlaySize( 20 )
		self:SetOverlayColor( Vector( 1, 1, 1 ) )
		self:SetSunColor( Vector( 1, 1, 1 ) )

		-- call this function when something changes these variables
		self:NetworkVarNotify( "SunSize",		self.OnVariableChanged );
		self:NetworkVarNotify( "OverlaySize",	self.OnVariableChanged );
		self:NetworkVarNotify( "SunColor",		self.OnVariableChanged );
		self:NetworkVarNotify( "OverlayColor",	self.OnVariableChanged );

	end

end

--
-- Callback - serverside - added in :Initialize
--
function ENT:OnAngleChange( newang )

	if ( IsValid( self.EnvSun ) ) then
		self.EnvSun:SetKeyValue( "sun_dir", tostring( newang:Forward() ) );
	end

end


--
-- Update all the variables on the sun, from our variables in this entity
--
function ENT:OnVariableChanged()

	if ( !IsValid( self.EnvSun ) ) then return end

	self.EnvSun:SetKeyValue( "size", self:GetSunSize() );
	self.EnvSun:SetKeyValue( "overlaysize", self:GetOverlaySize() );

	local vec = self:GetOverlayColor()
	self.EnvSun:SetKeyValue( "overlaycolor", Format( "%i %i %i", vec.x * 255, vec.y * 255, vec.z * 255 ) );

	local vec = self:GetSunColor()
	self.EnvSun:SetKeyValue( "suncolor", Format( "%i %i %i", vec.x * 255, vec.y * 255, vec.z * 255 ) );
	

end

--
-- This edits something global - so always network - even when not in PVS
--
function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS
end

if CLIENT then
	function ENT:Draw()
		if ConVarExists("nz_creative_preview") and !GetConVar("nz_creative_preview"):GetBool() and nzRound:InState( ROUND_CREATE ) then
			self:DrawModel()
		end
	end
end
