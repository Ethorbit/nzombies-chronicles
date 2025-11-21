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


include('shared.lua')


SWEP.PrintName			= "Knife"
SWEP.ClassName			= "nz_quickknife_crowbar"
SWEP.Slot				= 0
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true 
SWEP.DrawWeaponInfoBox	= false
SWEP.BounceWeaponIcon   = false

SWEP.WepSelectFont		= "HL2MPTypeDeath"
SWEP.WepSelectLetter	= "6"
SWEP.IconFont			= "HL2MPTypeDeath"
SWEP.IconLetter			= "6"

/*---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	// Set us up the texture
	surface.SetDrawColor( color_transparent )
	surface.SetTextColor( 255, 220, 0, alpha )
	surface.SetFont( self.WepSelectFont )
	local w, h = surface.GetTextSize( self.WepSelectLetter )

	// Draw that mother
	surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),
						y + ( tall / 2 ) - ( h / 2 ) )
	surface.DrawText( self.WepSelectLetter )

end

