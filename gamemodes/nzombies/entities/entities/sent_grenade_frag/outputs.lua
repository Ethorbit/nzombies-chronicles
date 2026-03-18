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


ENT.Sound				= {}
ENT.Sound.Blip			= "Grenade.Blip"
ENT.Sound.Explode		= "BaseGrenade.Explode"

ENT.Trail				= {}
ENT.Trail.Color			= Color( 255, 0, 0, 255 )
ENT.Trail.Material		= "sprites/bluelaser1.vmt"
ENT.Trail.StartWidth	= 8.0
ENT.Trail.EndWidth		= 1.0
ENT.Trail.LifeTime		= 0.5

// Nice helper function, this does all the work.

/*---------------------------------------------------------
   Name: DoExplodeEffect
---------------------------------------------------------*/
function ENT:DoExplodeEffect()

	local info = EffectData();
	info:SetEntity( self.Entity );
	info:SetOrigin( self.Entity:GetPos() );

	util.Effect( "Explosion", info );

end

/*---------------------------------------------------------
   Name: OnExplode
   Desc: The grenade has just exploded.
---------------------------------------------------------*/
function ENT:OnExplode( pTrace )

	local Pos1 = pTrace.HitPos + pTrace.HitNormal
	local Pos2 = pTrace.HitPos - pTrace.HitNormal

 	util.Decal( "Scorch", Pos1, Pos2 );

end

/*---------------------------------------------------------
   Name: OnInitialize
---------------------------------------------------------*/
function ENT:OnInitialize()
end

/*---------------------------------------------------------
   Name: StartTouch
---------------------------------------------------------*/
function ENT:StartTouch( entity )
end

/*---------------------------------------------------------
   Name: EndTouch
---------------------------------------------------------*/
function ENT:EndTouch( entity )
end

/*---------------------------------------------------------
   Name: Touch
---------------------------------------------------------*/
function ENT:Touch( entity )
end

/*---------------------------------------------------------
   Name: OnThink
---------------------------------------------------------*/
function ENT:OnThink()
end
