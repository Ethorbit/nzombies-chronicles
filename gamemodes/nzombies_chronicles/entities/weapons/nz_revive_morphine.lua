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

if SERVER then
	AddCSLuaFile("nz_revive_morphine.lua")
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= true
end

if CLIENT then

	SWEP.PrintName     	    = "Morphine"			
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	
	SWEP.Category			= "nZombies"

end


SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0r"
SWEP.Purpose		= "Fancy Viewmodel Animations"
SWEP.Instructions	= "Let the gamemode give you it"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.HoldType = "slam"

SWEP.ViewModel	= "models/weapons/c_revive_morphine.mdl"
SWEP.WorldModel	= ""
SWEP.UseHands = true
SWEP.vModel = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NZPreventBox = true
SWEP.NZTotalBlacklist = true

function SWEP:Initialize()

	self:SetHoldType( "slam" )

end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.WepOwner = self.Owner
end

function SWEP:Equip( owner )
	--owner:SetActiveWeapon("nz_revive_morphine")
end

function SWEP:PrimaryAttack()
	
end

function SWEP:PostDrawViewModel()

end

function SWEP:DrawWorldModel()

end

function SWEP:OnRemove()
	if SERVER then
		if !self.WepOwner then return end
		if !IsValid(self.WepOwner:GetActiveWeapon()) or !self.WepOwner:GetActiveWeapon():IsSpecial() then
			self.WepOwner:SetUsingSpecialWeapon(false)
		end
		self.WepOwner:SetActiveWeapon(nil)
		self.WepOwner:EquipPreviousWeapon()
	end
end

function SWEP:GetViewModelPosition( pos, ang )
 
 	local newpos = LocalPlayer():EyePos()
	local newang = LocalPlayer():EyeAngles()
	local up = newang:Up()
	
	newpos = newpos + LocalPlayer():GetAimVector()*6 - up*63
	
	return newpos, newang
 
end
