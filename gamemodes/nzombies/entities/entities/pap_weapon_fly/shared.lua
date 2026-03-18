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

ENT.PrintName		= "pap_weapon_fly"
ENT.Author			= "Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.NZEntity = true

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "WeaponClass")
end

function ENT:Initialize()

	self:SetMoveType( MOVETYPE_FLY )
	self:SetSolid( SOLID_OBB )
	--self:SetCollisionBounds(Vector(-5, -10, -3), Vector(5, 10, 3))
	--self:UseTriggerBounds(true, 1)
	self:SetMoveType(MOVETYPE_FLY)
	self:PhysicsInitBox(Vector(-5, -10, -3), Vector(5, 10, 3))
	self:GetPhysicsObject():EnableCollisions(false)
	self:SetNotSolid(true)
	self:DrawShadow( false )
	self.TriggerPos = self:GetPos()
	
	if SERVER then
		self:SetUseType( SIMPLE_USE )
		self:SetWeaponClass(self.WepClass)
	else
		local wep = weapons.Get(self:GetWeaponClass())
		if wep and wep.DrawWorldModel then self.WorldModelFunc = wep.DrawWorldModel end
	end
end

function ENT:SetWepClass(class)
	if IsValid(self.button) then
		self.button:SetWepClass(class)
	end
	self:SetWeaponClass(class)
end

function ENT:CreateTriggerZone(reroll)
	if SERVER then
		self.button = ents.Create("pap_weapon_trigger")
		self.button:SetPos(self.TriggerPos)
		self.button:SetAngles(self:GetAngles() - Angle(90,90,0))
		self.button:Spawn()
		self.button:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		self.button.RerollingAtts = reroll
		self.button:SetPaPOwner(self.Owner)
		self.button.wep = self
		self.button:SetWepClass(self.WepClass)
	end
end

function ENT:OnRemove()
	if IsValid(self.button) then self.button:Remove() end
end

if CLIENT then
	function ENT:Draw()
		-- We can use the stored world model draw function from the original weapon, but if it doesn't exist or errors, then just draw model
		if !self.WorldModelFunc or !pcall(self.WorldModelFunc, self) then self:DrawModel() end
	end
end
